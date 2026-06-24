export interface CurrentWeather {
  temp: string;
  feelsLike: string;
  humidity: string;
  windSpeed: string;
  windDir: string;
  windScale: string;
  uvIndex: string;
  visibility: string;
  pressure: string;
  weatherDesc: string;
  weatherIcon: string;
  cloudCover: string;
  aqi: string;
  sunrise: string;
  sunset: string;
}

export interface HourlyForecast {
  time: string;            // ISO时间 "2026-06-24T14:00:00+08:00"
  temp: string;            // 温度(℃)
  feelsLike: string;       // 体感温度(℃)
  humidity: string;        // 相对湿度(%)
  windDir: string;         // 风向文字 "南风"
  windScale: string;       // 风力等级 "3-4"
  windSpeed: string;       // 风速(km/h)
  precipProb: string;      // 降水概率(%)
  precip: string;          // 降水量(mm)
  pressure: string;        // 大气压(hPa)
  uvIndex: string;         // 紫外线指数
  weatherIcon: string;     // 天气图标emoji
  weatherDesc: string;     // 天气描述 "晴"
  isDay: string;           // 昼夜 "1"白天 "0"夜间
}

export interface DailyForecast {
  date: string;
  dayOfWeek: string;
  maxTemp: string;
  minTemp: string;
  weatherDesc: string;
  weatherIcon: string;
  chanceOfRain: string;
  uvIndex: string;
  hours?: HourlyForecast[];   // 该日逐小时预报(可选)
  sunrise: string;            // 日出时间
  sunset: string;             // 日落时间
  moonPhase: string;          // 月相
}

// 和风天气逐日预报内嵌小时项(短格式，用于daily.hours)
export interface QHourInner {
  time: string;
  temp: string;
  icon: string;
  desc: string;
}

export interface WeatherData {
  city: string;
  country: string;
  current: CurrentWeather;
  /** 独立逐小时预报数组(48h) */
  hourly: HourlyForecast[];
  /** 每日内嵌小时数据(7天x24h) */
  hourlyByDay?: HourlyForecast[][];
  daily: DailyForecast[];
  lastUpdated: string;
  warningTitle: string;
  warningDesc: string;
}
