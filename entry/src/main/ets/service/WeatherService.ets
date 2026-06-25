import { WeatherData, CurrentWeather, DailyForecast, HourlyForecast } from '../model/WeatherData';
import http from '@ohos.net.http';
import prefManager from './PreferenceManager';

// ============================================================
//  HTTP 返回结果（包含状态码和正文）
// ============================================================
interface HttpResult {
  code: number;
  body: string | null;
}

// ============================================================
//  API 配置层 — 更换 API 只需修改此区域
// ============================================================

const QWEATHER_KEY: string = 'e7bbd2e6bbed414ea1f122d555adce6c';
const QWEATHER_BASE: string = 'https://m42k5q5mp7.re.qweatherapi.com/v7/weather';
const QWEATHER_AIR: string = 'https://m42k5q5mp7.re.qweatherapi.com/v7/air/now';
const AMAP_KEY: string = '2470620c1e3fa0d49323999b4aa4cf38';
const AMAP_GEO: string = 'https://restapi.amap.com/v3/geocode/geo';
const USE_QWEATHER: boolean = true;
const JUHE_URL: string = 'https://apis.juhe.cn/simpleWeather/query';
const JUHE_KEY: string = '133a4b6437c950bc2c7214b30e5c0fcd';

// ============================================================
//  QWeather JSON 响应结构接口（ArkTS 点号访问）
// ============================================================
interface QWeatherNowBody {
  temp?: string; feelsLike?: string; humidity?: string;
  windSpeed?: string; windDir?: string; windScale?: string;
  uvIndex?: string; visibility?: string; pressure?: string;
  text?: string; icon?: string; cloud?: string;
}
interface QWeatherNowRoot { now?: QWeatherNowBody; }
interface QWeatherHourItem {
  fxTime?: string; temp?: string; feelsLike?: string; humidity?: string;
  windDir?: string; windScale?: string; windSpeed?: string;
  precip?: string; pressure?: string; uvIndex?: string;
  icon?: string; text?: string; isDay?: string;
}
interface QWeatherHourRoot { hourly?: QWeatherHourItem[]; }
interface QWeatherDayItem {
  fxDate?: string; tempMax?: string; tempMin?: string;
  textDay?: string; iconDay?: string; precip?: string;
  uvIndex?: string; sunrise?: string; sunset?: string; moonPhase?: string;
}
interface QWeatherDayRoot { daily?: QWeatherDayItem[]; }
interface AmapGeoItem {
  location?: string;
}
interface AmapGeoResponse {
  status?: string;
  info?: string;
  geocodes?: AmapGeoItem[];
}
interface JuheToday {
  temperature?: string;
  weather?: string;
  humidity?: string;
  wind?: string;
  weather_icon?: string;
}
interface JuheFutureDay {
  date?: string;
  high?: string;
  low?: string;
  weather?: string;
  weather_icon?: string;
}
interface JuheResult {
  today?: JuheToday;
  future?: JuheFutureDay[];
}
interface JuheRoot { result?: JuheResult; }
interface JuheDay { date?: string; high?: string; low?: string; weather?: string; weather_icon?: string; }

// ============================================================
//  工具函数
// ============================================================
function safeStr(val: string | undefined | null, def: string): string {
  if (val === null || val === undefined) { return def; }
  return val;
}

async function httpGetQWeather(url: string): Promise<string | null> {
  let req: http.HttpRequest = http.createHttp();
  try {
    let resp: http.HttpResponse = await req.request(url, {
      method: http.RequestMethod.GET,
      header: { 'X-QW-Api-Key': QWEATHER_KEY },
      connectTimeout: 8000,
      readTimeout: 8000
    });
    let httpCode: number = resp.responseCode;
    if (httpCode === 403) {
      console.error('httpGetQWeather HTTP 403 - QWeather permission not synced');
      return '__HTTP_403__';
    }
    return String(resp.result);
  } catch (e) {
    console.error('httpGetQWeather error: ' + url.substring(0, 60) + '... ' + JSON.stringify(e));
    return null;
  } finally {
    req.destroy();
  }
}

async function httpGet(url: string): Promise<string | null> {
  let req: http.HttpRequest = http.createHttp();
  try {
    let resp: http.HttpResponse = await req.request(url, {
      method: http.RequestMethod.GET,
      connectTimeout: 8000,
      readTimeout: 8000
    });
    return String(resp.result);
  } catch (e) {
    console.error('httpGet error: ' + url.substring(0, 60) + '... ' + JSON.stringify(e));
    return null;
  } finally {
    req.destroy();
  }
}

function formatNow(): string {
  let now: Date = new Date();
  let y: string = String(now.getFullYear());
  let M: string = String(now.getMonth() + 1).padStart(2, "0");
  let d: string = String(now.getDate()).padStart(2, "0");
  let h: string = String(now.getHours()).padStart(2, "0");
  let m: string = String(now.getMinutes()).padStart(2, "0");
  return y + "-" + M + "-" + d + " " + h + ":" + m;
}

function getDayOfWeek(dateStr: string, index: number): string {
  if (index === 0) { return "今天"; }
  if (index === 1) { return "明天"; }
  if (index === 2) { return "后天"; }
  let d: Date = new Date(dateStr);
  let weekdays: string[] = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"];
  return weekdays[d.getDay()];
}

function qIconEmoji(icon: string): string {
  let code: number = Number(icon);
  if (isNaN(code)) { return "☀️"; }
  if (code === 100 || code === 150) { return "☀️"; }
  if (code === 101 || code === 151) { return "⛅"; }
  if (code === 102 || code === 152) { return "🌤️"; }
  if (code === 103 || code === 153) { return "⛅"; }
  if (code === 104 || code === 154) { return "☁️"; }
  if (code >= 300 && code < 400) { return "🌧️"; }
  if (code >= 400 && code < 500) { return "❄️"; }
  if (code === 500 || code === 501) { return "🌫️"; }
  if (code >= 503 && code < 510) { return "🌫️"; }
  if (code >= 511 && code < 600) { return "🌨️"; }
  if (code >= 600 && code < 700) { return "🌪️"; }
  if (code >= 800 && code < 900) { return "⛈️"; }
  if (code >= 900 && code < 910) { return "🌤️"; }
  return "☀️";
}

// ============================================================
//  JSON 解析函数（纯点号访问，无方括号）
// ============================================================

function parseCurrent(head: QWeatherNowRoot): CurrentWeather {
  let now: QWeatherNowBody = head.now ?? {};
  return {
    temp: safeStr(now.temp, "--"),
    feelsLike: safeStr(now.feelsLike, "--"),
    humidity: safeStr(now.humidity, "--"),
    windSpeed: safeStr(now.windSpeed, "--"),
    windDir: safeStr(now.windDir, ""),
    windScale: safeStr(now.windScale, ""),
    uvIndex: safeStr(now.uvIndex, "--"),
    visibility: safeStr(now.visibility, "--"),
    pressure: safeStr(now.pressure, "--"),
    weatherDesc: safeStr(now.text, "--"),
    weatherIcon: qIconEmoji(safeStr(now.icon, "")),
    cloudCover: safeStr(now.cloud, "--"),
    aqi: "--",
    sunrise: "--",
    sunset: "--"
  };
}

function parseHourly(hourlyArr: QWeatherHourItem[]): HourlyForecast[] {
  let result: HourlyForecast[] = [];
  for (let i: number = 0; i < hourlyArr.length; i++) {
    let h: QWeatherHourItem = hourlyArr[i];
    result.push({
      time: safeStr(h.fxTime, ""),
      temp: safeStr(h.temp, "--"),
      feelsLike: safeStr(h.feelsLike, "--"),
      humidity: safeStr(h.humidity, "--"),
      windDir: safeStr(h.windDir, ""),
      windScale: safeStr(h.windScale, ""),
      windSpeed: safeStr(h.windSpeed, "--"),
      precipProb: safeStr(h.precip, "--"),
      precip: safeStr(h.precip, "--"),
      pressure: safeStr(h.pressure, "--"),
      uvIndex: safeStr(h.uvIndex, "--"),
      weatherIcon: qIconEmoji(safeStr(h.icon, "")),
      weatherDesc: safeStr(h.text, ""),
      isDay: safeStr(h.isDay, "1")
    });
  }
  return result;
}

function parseDaily(dailyArr: QWeatherDayItem[]): DailyForecast[] {
  let result: DailyForecast[] = [];
  for (let i: number = 0; i < dailyArr.length; i++) {
    let d: QWeatherDayItem = dailyArr[i];
    let dateStr: string = safeStr(d.fxDate, "");
    result.push({
      date: dateStr,
      dayOfWeek: getDayOfWeek(dateStr, i),
      maxTemp: safeStr(d.tempMax, "--"),
      minTemp: safeStr(d.tempMin, "--"),
      weatherDesc: safeStr(d.textDay, "--"),
      weatherIcon: qIconEmoji(safeStr(d.iconDay, "")),
      chanceOfRain: safeStr(d.precip, "--"),
      uvIndex: safeStr(d.uvIndex, "--"),
      sunrise: safeStr(d.sunrise, "--"),
      sunset: safeStr(d.sunset, "--"),
      moonPhase: safeStr(d.moonPhase, "--")
    });
  }
  return result;
}

async function parseQWeather(raw: string, cityName: string): Promise<WeatherData> {
  let empty: WeatherData = makeEmpty(cityName);
  try {
    let semi1: number = raw.indexOf(";");
    if (semi1 <= 0) { return empty; }
    let semi2: number = raw.indexOf(";", semi1 + 1);
    if (semi2 <= 0) { return empty; }
    let semi3: number = raw.indexOf(";", semi2 + 1);
    let p1: string = raw.substring(0, semi1);
    let p2: string = raw.substring(semi1 + 1, semi2);
    let p3: string;
    if (semi3 > 0) { p3 = raw.substring(semi2 + 1, semi3); }
    else { p3 = raw.substring(semi2 + 1); }

    let nowJson: QWeatherNowRoot = JSON.parse(p1) as QWeatherNowRoot;
    let dailyJson: QWeatherDayRoot = JSON.parse(p2) as QWeatherDayRoot;
    let hourlyJson: QWeatherHourRoot = JSON.parse(p3) as QWeatherHourRoot;

    let current: CurrentWeather = parseCurrent(nowJson);
    let dailyArr: QWeatherDayItem[] = dailyJson.daily ?? [];
    let hourlyArr: QWeatherHourItem[] = hourlyJson.hourly ?? [];
    let daily: DailyForecast[] = parseDaily(dailyArr);
    let hourly: HourlyForecast[] = parseHourly(hourlyArr);

    let city: string = cityName;
    if (city === "null" || city.length === 0) { city = cityName; }

    return {
      city: city,
      country: "",
      current: current,
      hourly: hourly,
      daily: daily,
      lastUpdated: formatNow(),
      warningTitle: "",
      warningDesc: ""
    };
  } catch (e) {
    console.error("parseQWeather error: " + JSON.stringify(e));
    return empty;
  }
}

function makeEmpty(cityName: string): WeatherData {
  return {
    city: cityName,
    country: "",
    current: {
      temp: "--", feelsLike: "--", humidity: "--",
      windSpeed: "--", windDir: "", windScale: "",
      uvIndex: "--", visibility: "--", pressure: "--",
      weatherDesc: "加载中", weatherIcon: "☀️",
      cloudCover: "--", aqi: "--", sunrise: "--", sunset: "--"
    },
    hourly: [],
    daily: [],
    lastUpdated: "",
    warningTitle: "",
    warningDesc: ""
  };
}

// ============================================================
//  主服务类
// ============================================================
class WeatherService {
  private requestId: number = 0;

  async fetchWeather(cityName: string): Promise<WeatherData> {
    if (USE_QWEATHER) {
      let locationId: string = await this.geoLookup(cityName);
      if (locationId.length === 0 || locationId.indexOf("ERR_AM:") === 0) {
        let result: WeatherData = makeEmpty(cityName);
        result.current.weatherDesc = "城市解析失败，请更换城市";
        return result;
      }
      return await this.fetchQWeather(cityName, locationId);
    } else {
      let id: number = ++this.requestId;
      return await this.fetchJuhe(cityName, id);
    }
  }

  private async fetchQWeather(cityName: string, locationId: string): Promise<WeatherData> {
    let result: WeatherData = makeEmpty(cityName);
    try {
      let nowUrl: string = QWEATHER_BASE + "/now?location=" + locationId;
      let dailyUrl: string = QWEATHER_BASE + "/3d?location=" + locationId;
      let hourlyUrl: string = QWEATHER_BASE + "/24h?location=" + locationId;
      let airUrl: string = QWEATHER_AIR + "?location=" + locationId;

      // 1. 实时天气
      let nowRaw: string | null = await httpGetQWeather(nowUrl);
      if (nowRaw === null || nowRaw === "__HTTP_403__") {
        result.current.weatherDesc = nowRaw === "__HTTP_403__"
          ? "和风天气权限同步中，稍后刷新重试"
          : "网络异常，请检查网络后重试";
        return result;
      }

      // 2. 逐日预报
      let dailyRaw: string | null = await httpGetQWeather(dailyUrl);
      if (dailyRaw === null || dailyRaw === "__HTTP_403__") {
        result.current.weatherDesc = dailyRaw === "__HTTP_403__"
          ? "和风天气权限同步中，稍后刷新重试"
          : "网络异常，请检查网络后重试";
        return result;
      }

      // 3. 逐小时预报
      let hourlyRaw: string | null = await httpGetQWeather(hourlyUrl);
      if (hourlyRaw === null || hourlyRaw === "__HTTP_403__") {
        result.current.weatherDesc = hourlyRaw === "__HTTP_403__"
          ? "和风天气权限同步中，稍后刷新重试"
          : "网络异常，请检查网络后重试";
        return result;
      }

      // 4. 空气质量（可选，失败不影响主流程）
      let airRaw: string | null = await httpGetQWeather(airUrl);

      let combined: string = nowRaw + ";" + dailyRaw + ";" + hourlyRaw + ";" + (airRaw ?? "");
      result = await parseQWeather(combined, cityName);

      if (result.city === "null" || result.city.length === 0) {
        result.city = cityName;
      }

      try {
        let jsonStr: string = JSON.stringify(result);
        prefManager.saveWeatherCache(cityName, jsonStr);
      } catch (_ce) {}

      try {
        await prefManager.addToHistory(cityName);
      } catch (_he) {}

    } catch (e) {
      console.error("fetchQWeather error", JSON.stringify(e));
      result.current.weatherDesc = "网络异常，请检查网络后重试";
    }
    return result;
  }

  private async amapGeoFallback(city: string): Promise<string> {
    try {
      let encoded: string = encodeURIComponent(city);
      let url: string = AMAP_GEO + "?key=" + AMAP_KEY + "&address=" + encoded + "&city=";
      let raw: string | null = await httpGet(url);
      if (raw === null) { return ""; }
      let json: AmapGeoResponse = JSON.parse(raw) as AmapGeoResponse;
      let amapStatus: string = safeStr(json.status, "");
      let amapInfo: string = safeStr(json.info, "");
      if (amapStatus !== "1") {
        console.error("AMap geocode failed: status=" + amapStatus + " info=" + amapInfo);
        return "ERR_AM:" + amapStatus + ":" + amapInfo;
      }
      let geoCodes: AmapGeoItem[] = json.geocodes ?? [];
      if (geoCodes.length === 0) { return ""; }
      let location: string = safeStr(geoCodes[0].location, "");
      if (location.length > 0) {
        console.info("AMap success: " + city + " -> " + location);
        return location;
      }
      return "";
    } catch (e) {
      console.error("amapGeoFallback error", JSON.stringify(e));
      return "";
    }
  }

  private async geoLookup(city: string): Promise<string> {
    try {
      let cached: string | null = await prefManager.getLocationId(city);
      if (cached !== null && cached.length > 0) {
        return cached;
      }
      let amapLoc: string = await this.amapGeoFallback(city);
      if (amapLoc.length > 0 && amapLoc.indexOf("ERR_AM:") !== 0) {
        console.info("geoLookup AMap success: " + city + " -> " + amapLoc);
        await prefManager.saveLocationId(city, amapLoc);
        return amapLoc;
      }
      console.error("geoLookup AMap failed for: " + city + " result: " + amapLoc);
      return amapLoc;
    } catch (e) {
      console.error("geoLookup error", JSON.stringify(e));
      return "";
    }
  }

  private async fetchJuhe(cityName: string, id: number): Promise<WeatherData> {
    let result: WeatherData = makeEmpty(cityName);
    let url: string = JUHE_URL + "?city=" + encodeURIComponent(cityName) + "&key=" + JUHE_KEY;
    let raw: string | null = await httpGet(url);
    if (id !== this.requestId) { return makeEmpty(cityName); }
    if (raw === null) {
      result.current.weatherDesc = "未能获取" + cityName + "天气";
      return result;
    }
    try {
      let json: JuheRoot = JSON.parse(raw) as JuheRoot;
      let resObj = json.result;
      if (resObj !== undefined) {
        let today: JuheToday | undefined = resObj.today;
        let futureArr: JuheFutureDay[] = resObj.future ?? [];
        result.current.temp = safeStr(today?.temperature, "--");
        result.current.weatherDesc = safeStr(today?.weather, "--");
        result.current.humidity = safeStr(today?.humidity, "--");
        result.current.windSpeed = safeStr(today?.wind, "--");
        result.current.weatherIcon = qIconEmoji(safeStr(today?.weather_icon, ""));
        result.daily = [];
        for (let i: number = 0; i < futureArr.length; i++) {
          let f: JuheFutureDay = futureArr[i];
          result.daily.push({
            date: safeStr(f.date, ""),
            dayOfWeek: getDayOfWeek(safeStr(f.date, ""), i),
            maxTemp: safeStr(f.high, "--"),
            minTemp: safeStr(f.low, "--"),
            weatherDesc: safeStr(f.weather, "--"),
            weatherIcon: qIconEmoji(safeStr(f.weather_icon, "")),
            chanceOfRain: "",
            uvIndex: "--",
            sunrise: "--", sunset: "--", moonPhase: "--"
          });
        }
      }
    } catch (e) {
      console.error("fetchJuhe parse error", JSON.stringify(e));
      result.current.weatherDesc = "解析天气数据失败";
    }
    return result;
  }
}

const weatherService: WeatherService = new WeatherService();
export default weatherService;



