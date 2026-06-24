import { WeatherData, CurrentWeather, HourlyForecast, DailyForecast } from "../model/WeatherData";
import { convertTempStr, tempUnitLabel, cleanCityName } from "../model/TemperatureConverter";
import { bgGradient, cardBg, cardBgStrong, cardFrost, accentBlue, textPrimary, textSecondary, textTertiary, textMuted, textPrimaryLight, textSecondaryLight, textTertiaryLight } from "../model/ThemeManager";
import weatherService from "../service/WeatherService";
import prefManager from "../service/PreferenceManager";
import router from "@ohos.router";
import locationService from "../service/LocationService";
import searchHistoryManager from "../service/SearchHistoryManager";
import loadingManager from "../service/LoadingManager";
import { LoadingComponent } from "../components/LoadingComponent";

@Entry
@Component
struct Index {
  @State city: string = "滨州";
  @State temp: string = "--";
  @State feelsLike: string = "--";
  @State humidity: string = "--";
  @State windSpeed: string = "--";
  @State windDir: string = "";
  @State windScale: string = "";
  @State aqi: string = "--";
  @State weatherDesc: string = "加载中";
  @State weatherIcon: string = "☀️";
  @State lastUpdated: string = "";
  @State daily: DailyForecast[] = [];
  @State hourly: HourlyForecast[] = [];
  @State searchText: string = "";
  @State showSearch: boolean = false;
  @State loading: boolean = true;
  @State error: string = "";
  @State bg: string = "day";
  @State history: string[] = [];
  @State favorites: string[] = [];
  @State searchHistory: string[] = [];
  @State isFav: boolean = false;
  @State globalMinTemp: number = 0;
  @State globalMaxTemp: number = 30;
  @State isRefreshing: boolean = false;
  @State isLocating: boolean = false;
  @State locErrorMsg: string = "";
  @State warningTitle: string = "";
  @State tempUnit: string = "C";
  @State isDark: boolean = false;
  @State refreshInterval: string = "30";
  @State warningDesc: string = "";
  @State sunrise: string = "--";
  @State sunset: string = "--";

  @State showHourlyPop: boolean = false;
  @State popTime: string = "";
  @State popTemp: string = "--";
  @State popFeelsLike: string = "--";
  @State popHumidity: string = "--";
  @State popWindDir: string = "";
  @State popWindScale: string = "";
  @State popWindSpeed: string = "--";
  @State popPrecipProb: string = "--";
  @State popPrecip: string = "--";
  @State popPressure: string = "--";
  @State popUvIndex: string = "--";
  @State popWeatherIcon: string = "☀️";
  @State popWeatherDesc: string = "";

  private refreshTimer: number = -1;
  private lastReqCity: string = "";

  aboutToAppear(): void {
    this.loadSettingsAndStart();
  }

  onPageShow(): void {
    try {
      let ctx: Context = this.getUIContext().getHostContext()!;
      prefManager.init(ctx).then((): void => {
        prefManager.getSettings().then((s): void => {
          this.tempUnit = s.tempUnit; this.isDark = s.darkMode === "true";
          this.refreshInterval = s.refreshInterval; this.setupAutoRefresh();
        }).catch((): void => {});
        this.loadSearchHistory();
        this.loadLastCity();
      }).catch((): void => {});
      try {
        let params = router.getParams() as Record<string, Object>;
        if (params !== null && params !== undefined && params.switchCity !== undefined) {
          let switchTo: string = String(params.switchCity);
          if (switchTo.length > 0) { this.loadW(cleanCityName(switchTo)); }
        }
      } catch (_e) {}
    } catch (_e) {}
  }

  aboutToDisappear(): void {
    if (this.refreshTimer > 0) { clearInterval(this.refreshTimer); this.refreshTimer = -1; }
  }

  loadSettingsAndStart(): void {
    try {
      let ctx: Context = this.getUIContext().getHostContext()!;
      prefManager.init(ctx).then((): void => {
        Promise.all([prefManager.getSettings(), prefManager.getFavorites(), prefManager.getHistory()]).then((r): void => {
          this.tempUnit = r[0].tempUnit; this.isDark = r[0].darkMode === "true";
          this.refreshInterval = r[0].refreshInterval; this.setupAutoRefresh();
          this.favorites = r[1];
          if (this.favorites.indexOf(this.city) >= 0) { this.isFav = true; }
          this.history = r[2];
        }).catch((): void => {});
        this.loadSearchHistory();
        this.loadLastCity();
      }).catch((): void => { this.loadLastCity(); });
    } catch (_e) { this.loadLastCity(); }
  }

  checkRouteParam(): void {
    try {
      let params = router.getParams() as Record<string, Object>;
      if (params !== null && params !== undefined && params.switchCity !== undefined) {
        let s: string = String(params.switchCity);
        if (s.length > 0) { this.loadW(cleanCityName(s)); return; }
      }
    } catch (_e) {}
    // 启动时读取上次查看的城市
    prefManager.getLastCity().then((c: string): void => {
      this.loadW(c);
    }).catch((): void => { this.loadW("滨州"); });
  }

  loadSearchHistory(): void {
    try {
      let ctx: Context = this.getUIContext().getHostContext()!;
      searchHistoryManager.init(ctx).then((): void => {
        searchHistoryManager.getHistory().then((items): void => {
          this.searchHistory = items.map((item): string => item.cityName);
        }).catch((): void => {});
      }).catch((): void => {});
    } catch (_e) {}
  }

  setupAutoRefresh(): void {
    if (this.refreshTimer > 0) { clearInterval(this.refreshTimer); }
    let interval: number = Number(this.refreshInterval) * 60000;
    if (interval <= 0) { return; }
    this.refreshTimer = setInterval((): void => {
      this.loadW(this.city);
    }, interval);
  }

  async loadW(city: string): Promise<void> {
    let q: string = city.trim();
    if (q.length === 0) { return; }
    this.lastReqCity = q; this.loading = true; this.error = "";
    this.showCachedFirst(q);
    try {
      let data: WeatherData = await weatherService.fetchWeather(q);
      this.city = data.city;
      if (this.isErrorMsg(data.current.weatherDesc)) {
        this.error = data.current.weatherDesc; this.loading = false;
        return;
      }
      this.applyWeatherData(data);
      try {
        let ctx: Context = this.getUIContext().getHostContext()!;
        searchHistoryManager.init(ctx).then((): void => {
          searchHistoryManager.addHistory(data.city).catch((): void => {});
          searchHistoryManager.getHistory().then((h): void => { this.searchHistory = h.map((i): string => i.cityName); }).catch((): void => {});
        }).catch((): void => {});
      } catch (_se) {}
      try { prefManager.saveWeatherCache(data.city, JSON.stringify(data)); } catch (_ce) {}
      try { prefManager.addToHistory(data.city).catch((): void => {}); } catch (_he) {}
      try { prefManager.saveLastCity(data.city).catch((): void => {}); } catch (_lc) {}
    } catch (e) { this.error = "获取天气失败"; this.tryLoadCache(city); }
    this.loading = false; this.isRefreshing = false;
  }

  isErrorMsg(desc: string): boolean {
    return desc === "和风天气权限同步中，稍后刷新重试" || desc === "城市解析失败，请更换城市" || desc === "网络异常，请检查网络后重试" || desc === "天气数据请求失败，请登录和风控制台确认";
  }

  applyWeatherData(data: WeatherData): void {
    this.temp = data.current.temp; this.feelsLike = data.current.feelsLike;
    this.humidity = data.current.humidity; this.windSpeed = data.current.windSpeed;
    this.windDir = data.current.windDir; this.windScale = data.current.windScale;
    this.aqi = data.current.aqi; this.weatherDesc = data.current.weatherDesc;
    this.weatherIcon = data.current.weatherIcon; this.lastUpdated = data.lastUpdated;
    this.daily = data.daily; this.hourly = data.hourly;
    this.sunrise = data.current.sunrise; this.sunset = data.current.sunset;
    this.warningTitle = data.warningTitle; this.warningDesc = data.warningDesc;
    this.bg = this.pickBg(data.current.weatherDesc);
    let gMin: number = 100; let gMax: number = -100;
    for (let i: number = 0; i < data.daily.length; i++) {
      let d: DailyForecast = data.daily[i];
      let mi: number = Number(d.minTemp); let ma: number = Number(d.maxTemp);
      if (!isNaN(mi) && mi < gMin) { gMin = mi; }
      if (!isNaN(ma) && ma > gMax) { gMax = ma; }
    }
    if (gMin < 100 && gMax > -100) { this.globalMinTemp = gMin; this.globalMaxTemp = gMax; }
  }

  showCachedFirst(q: string): void {
    try {
      let ctx: Context = this.getUIContext().getHostContext()!;
      prefManager.init(ctx).then((): void => {
        prefManager.getWeatherCache(q).then((c: string | null): void => {
          if (c !== null && c.length > 0) {
            try { let d: WeatherData = JSON.parse(c) as WeatherData; this.applyWeatherData(d); this.city = d.city; } catch (_pe) {}
          }
        }).catch((): void => {});
      }).catch((): void => {});
    } catch (_ce) {}
  }

  tryLoadCache(city: string): void {
    try {
      let ctx: Context = this.getUIContext().getHostContext()!;
      prefManager.init(ctx).then((): void => {
        prefManager.getWeatherCache(city).then((c: string | null): void => {
          if (c !== null && c.length > 0) {
            try { let d: WeatherData = JSON.parse(c) as WeatherData; this.applyWeatherData(d); this.city = d.city; } catch (_pe) {}
          }
        }).catch((): void => {});
      }).catch((): void => {});
    } catch (_ce) {}
  }

  async tryLocateAndLoad(): Promise<void> {
    try {
      let r = await locationService.getCurrentCity(this.getUIContext().getHostContext()!);
      if (r.success) { await this.loadW(cleanCityName(r.city)); }
      else { this.loadLastCity(); }
    } catch (_e) { this.loadLastCity(); }
  }

  async locate(): Promise<void> {
    this.isLocating = true; loadingManager.show();
    try {
      let r = await locationService.getCurrentCity(this.getUIContext().getHostContext()!);
      if (r.success) { await this.loadW(cleanCityName(r.city)); }
      else { this.locErrorMsg = r.errorMsg; setTimeout((): void => { this.locErrorMsg = ""; }, 3000); }
    } catch (e) { this.locErrorMsg = "定位失败"; setTimeout((): void => { this.locErrorMsg = ""; }, 3000); }
    finally { loadingManager.hide(); this.isLocating = false; }
  }

  loadLastCity(): void {
    prefManager.getLastCity().then((c: string): void => { this.loadW(c); }).catch((): void => { this.loadW("滨州"); });
  }

  pickBg(desc: string): string {
    let h: number = new Date().getHours();
    if (h >= 19 || h < 6) { if (desc.indexOf("雨") >= 0 || desc.indexOf("雪") >= 0 || desc.indexOf("雷") >= 0) { return "rain"; } return "night"; }
    if (desc.indexOf("雨") >= 0 || desc.indexOf("雪") >= 0 || desc.indexOf("雷") >= 0) { return "rain"; }
    if (desc.indexOf("雾") >= 0) { return "fog"; }
    if (desc.indexOf("多云") >= 0 || desc.indexOf("阴") >= 0) { return "cloudy"; }
    return "day";
  }

  aqiLevel(aqiStr: string): string {
    let v: number = Number(aqiStr);
    if (isNaN(v)) { return ""; }
    if (v <= 50) { return "优"; } if (v <= 100) { return "良"; }
    if (v <= 150) { return "轻度污染"; } if (v <= 200) { return "中度污染"; }
    if (v <= 300) { return "重度污染"; } return "严重污染";
  }

  barWidth(min: string, max: string): string {
    let mi: number = Number(min); let ma: number = Number(max);
    if (isNaN(mi) || isNaN(ma)) { return "50%"; }
    let range: number = this.globalMaxTemp - this.globalMinTemp;
    if (range <= 0) { return "50%"; }
    let pct: number = ((ma - mi) / range) * 100;
    if (pct < 10) { pct = 10; } if (pct > 90) { pct = 90; }
    return String(pct) + "%";
  }

  barOffset(min: string): string {
    let mi: number = Number(min); if (isNaN(mi)) { return "0%"; }
    let range: number = this.globalMaxTemp - this.globalMinTemp;
    if (range <= 0) { return "0%"; }
    let pct: number = ((mi - this.globalMinTemp) / range) * 70 + 15;
    if (pct < 0) { pct = 0; } if (pct > 80) { pct = 80; }
    return String(pct) + "%";
  }

  build() {
    Stack() {
      Column().width("100%").height("100%").linearGradient({ direction: GradientDirection.Bottom, colors: bgCol(this.isDark, this.bg) })

      // 夜间星空
      if (this.bg === "night") {
        ForEach(starPositions, (s: StarPos): void => {
          Column()
            .width(s.size).height(s.size)
            .backgroundColor(Color.White)
            .borderRadius(s.size / 2)
            .position({ x: s.x, y: s.y })
            .opacity(s.opacity)
            .shadow({ radius: s.size, color: "rgba(255,255,255,0.3)" })
        }, (s: StarPos): string => s.x + s.y)
      }

      if (this.loading && this.error.length === 0) {
        Column() {
          Row() {
            Column().width(80).height(22).borderRadius(11).backgroundColor("rgba(255,255,255,0.10)")
            Blank()
            Row() { ForEach([1, 2, 3, 4, 5], (): void => { Column().width(24).height(24).borderRadius(12).backgroundColor("rgba(255,255,255,0.06)").margin({ left: 10 }) }) }
          }.width("100%").padding({ top: 36, bottom: 16, left: 8, right: 8 })
          Column() {
            Column().width(72).height(72).borderRadius(36).backgroundColor("rgba(255,255,255,0.10)").margin({ top: 30 })
            Column().width(140).height(56).borderRadius(28).backgroundColor("rgba(255,255,255,0.06)").margin({ top: 12 })
            Column().width(100).height(18).borderRadius(9).backgroundColor("rgba(255,255,255,0.06)").margin({ top: 8 })
          }.width("100%").alignItems(HorizontalAlign.Center)
          Row() {
            ForEach([1, 2], (): void => {
              Column() {
                Column().width(24).height(24).borderRadius(12).backgroundColor("rgba(255,255,255,0.06)")
                Column().width(40).height(10).borderRadius(5).backgroundColor("rgba(255,255,255,0.06)").margin({ top: 8 })
                Column().width(56).height(20).borderRadius(10).backgroundColor("rgba(255,255,255,0.06)").margin({ top: 6 })
              }.alignItems(HorizontalAlign.Center).layoutWeight(1)
            })
          }.width("100%").padding(20).borderRadius(28).backgroundColor(cardFrost(this.isDark)).margin({ top: 16 }).padding(8)
        }.width("100%").padding({ left: 20, right: 20 })
      }

      if (this.error.length > 0 && !this.loading) {
        Column() {
          Text(String(this.weatherIcon)).fontSize(48).margin({ top: 40 })
          Text(String(this.error)).fontSize(16).fontColor(Color.White).textAlign(TextAlign.Center).margin({ top: 12 }).width("100%").maxLines(3)
          if (this.error.indexOf("请尝试") >= 0) {
            Text("一键切换：").fontSize(13).fontColor("rgba(255,255,255,0.5)").margin({ top: 20, bottom: 10 }).width("100%").textAlign(TextAlign.Center)
            Flex({ alignItems: ItemAlign.Center, wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center }) {
              ForEach(["北京", "上海", "广州", "深圳", "大连", "青岛", "杭州", "成都"], (c: string): void => {
                Text(c).fontSize(14).fontColor(Color.White).padding({ top: 8, bottom: 8, left: 20, right: 20 }).backgroundColor("rgba(255,255,255,0.12)").borderRadius(20).margin({ right: 8, bottom: 8 }).onClick((): void => { this.error = ""; this.loadW(c); })
              }, (c: string): string => c)
            }.width("100%").margin({ top: 4 })
          } else {
            Button("刷新重试").margin({ top: 24 }).height(44).width(160).borderRadius(22).backgroundColor("rgba(255,255,255,0.15)").fontColor(Color.White).fontWeight(FontWeight.Bold).onClick((): void => { this.error = ""; this.loadW(this.city); })
          }
        }.width("100%").alignItems(HorizontalAlign.Center)
      }

      if (this.locErrorMsg.length > 0) {
        Text(this.locErrorMsg).fontSize(13).fontColor("#FFCDD2").textAlign(TextAlign.Center).padding({ top: 8, bottom: 8, left: 20, right: 20 }).width("100%").backgroundColor("rgba(255,0,0,0.15)").borderRadius(12).margin({ top: 8, left: 20, right: 20 })
      }

      if (!this.loading || this.error.length > 0) {
        Refresh({ refreshing: this.isRefreshing }) {
          Scroll() {
            Column() {
              Row() {
                Row() { Text(this.city).fontSize(24).fontWeight(FontWeight.Bold).fontColor(Color.White); Text("  ›").fontSize(20).fontColor("rgba(255,255,255,0.4)") }.onClick((): void => { this.getUIContext().getRouter().pushUrl({ url: "pages/CityManage" }); })
                Blank()
                Text("📍").fontSize(18).margin({ left: 10 }).onClick((): void => { this.locate(); })
                Text("🔍").fontSize(18).margin({ left: 10 }).onClick((): void => { this.showSearch = !this.showSearch; })
                Text(!this.isFav ? "☆" : "★").fontSize(20).margin({ left: 10 }).fontColor(this.isFav ? "#FFD700" : "rgba(255,255,255,0.6)").onClick((): void => { prefManager.toggleFavorite(this.city).then((f: string[]): void => { this.favorites = f; this.isFav = f.indexOf(this.city) >= 0; }).catch((): void => {}); })
                Text("⚙️").fontSize(18).margin({ left: 10 }).onClick((): void => { this.getUIContext().getRouter().pushUrl({ url: "pages/Settings" }); })
              }.width("100%").padding({ top: 36, bottom: 16 })

              if (this.showSearch) {
                Row() {
                  TextInput({ placeholder: "搜索城市..." })
                    .height(48).layoutWeight(1).backgroundColor("rgba(255,255,255,0.12)")
                    .fontColor(Color.White).placeholderColor("rgba(255,255,255,0.4)")
                    .borderRadius(16).padding({ left: 16 })
                    .onChange((val: string): void => { this.searchText = val; })
                    .onSubmit((): void => {
                      let q: string = cleanCityName(this.searchText.trim());
                      if (q.length > 0) { this.showSearch = false; this.searchText = ""; this.loadW(q); }
                    })
                  Text("✕").fontSize(18).fontColor("rgba(255,255,255,0.5)").margin({ left: 8 }).width(36).height(48).textAlign(TextAlign.Center).lineHeight(48)
                    .onClick((): void => { this.showSearch = false; this.searchText = ""; })
                }.width("100%").margin({ bottom: 12 })
              }

              if (this.showSearch && this.searchHistory.length > 0) {
                Column() {
                  Row() {
                    Text("🕐 " + "搜索历史").fontSize(13).fontColor("rgba(255,255,255,0.4)")
                    Blank()
                    Text("清空").fontSize(12).fontColor("rgba(255,150,150,0.7)")
                      .onClick((): void => {
                        loadingManager.show();
                        searchHistoryManager.clearAll().then((): void => {
                          this.searchHistory = [];
                          loadingManager.hide();
                        }).catch((): void => { loadingManager.hide(); });
                      })
                  }.width("100%").margin({ bottom: 8 })
                  ForEach(this.searchHistory, (city: string): void => {
                    Text(city).fontSize(14).fontColor(Color.White).padding({ top: 6, bottom: 6, left: 14, right: 14 })
                      .backgroundColor("rgba(255,255,255,0.06)").borderRadius(12).margin({ right: 6, bottom: 6 })
                      .onClick((): void => { this.showSearch = false; this.searchText = ""; this.loadW(city); })
                  }, (city: string): string => city)
                }.width("100%").margin({ bottom: 12 }).alignItems(HorizontalAlign.Start)
              }

              // 主天气显示
              Column() {
                // Weather icon
                Text(String(this.weatherIcon)).fontSize(72).margin({ top: 8 }).opacity(0.9)
                Text(convertTempStr(this.temp, this.tempUnit)).fontSize(72).fontWeight(FontWeight.Bold).fontColor("rgba(255,255,255,0.95)").lineHeight(76).margin({ top: 4 })
                Text(tempUnitLabel(this.tempUnit)).fontSize(40).fontWeight(FontWeight.Bold).fontColor("rgba(255,255,255,0.5)").margin({ top: -20, right: "20%" }).alignSelf(ItemAlign.End)
                Text(this.weatherDesc).fontSize(24).fontWeight(FontWeight.Bold).fontColor("rgba(255,255,255,0.88)").letterSpacing(8).margin({ top: 8 })

                if (this.daily.length > 0) {
                  Row() {
                    Text("\u2191").fontSize(11).fontColor("rgba(255,255,255,0.35)")
                    Text(convertTempStr(this.daily[0].maxTemp, this.tempUnit) + "\u00B0").fontSize(16).fontColor("rgba(255,255,255,0.55)").margin({ left: 3 })
                    Text("  /  ").fontSize(13).fontColor("rgba(255,255,255,0.2)")
                    Text(convertTempStr(this.daily[0].minTemp, this.tempUnit) + "\u00B0").fontSize(16).fontColor("rgba(255,255,255,0.55)").margin({ right: 3 })
                    Text("\u2193").fontSize(11).fontColor("rgba(255,255,255,0.35)")
                  }.margin({ top: 6, bottom: 4 }).alignItems(VerticalAlign.Center)
                }

                Row() {
                  Column() {
                    Text("💧").fontSize(22)
                    Text($r("app.string.humidity")).fontSize(11).fontColor("rgba(255,255,255,0.35)").margin({ top: 6 })
                    Text(this.humidity + "%").fontSize(20).fontWeight(FontWeight.Bold).fontColor(Color.White).margin({ top: 4 })
                  }.alignItems(HorizontalAlign.Center).layoutWeight(1)
                  Column().width(1).height(36).backgroundColor("rgba(255,255,255,0.06)")
                  Column() {
                    Text("🌬️").fontSize(22)
                    Text($r("app.string.wind")).fontSize(11).fontColor("rgba(255,255,255,0.35)").margin({ top: 6 })
                    Text(this.windScale.length > 0 ? this.windScale + "级" : (this.windSpeed + "km/h")).fontSize(20).fontWeight(FontWeight.Bold).fontColor(Color.White).margin({ top: 4 })
                  }.alignItems(HorizontalAlign.Center).layoutWeight(1)
                }.width("100%").padding(18).borderRadius(20).backgroundColor("rgba(255,255,255,0.06)").margin({ top: 20 }).backgroundBlurStyle(BlurStyle.Thin)
              }.width("100%").padding(20).borderRadius(28).backgroundColor(cardFrost(this.isDark)).margin({ top: 8 }).alignItems(HorizontalAlign.Center).transition({ type: TransitionType.Insert, opacity: 0 })

              if (this.hourly.length > 0 && this.error.length === 0) {
                Column() {
                  Row() { Text("⏰ 逐小时预报").fontSize(14).fontColor("rgba(255,255,255,0.45)").letterSpacing(3); Blank(); if (this.lastUpdated.length > 0) { Text("更新 " + this.lastUpdated).fontSize(11).fontColor("rgba(255,255,255,0.2)") } }.width("100%").margin({ bottom: 12 })
                  Scroll() {
                    Row() {
                      ForEach(this.hourly, (h: HourlyForecast): void => {
                        Column() {
                          Text(timeLabel(h.time)).fontSize(12).fontColor("rgba(255,255,255,0.45)").margin({ bottom: 8 })
                          Text(String(h.weatherIcon)).fontSize(22).margin({ bottom: 6 })
                          Text(convertTempStr(h.temp, this.tempUnit) + "°").fontSize(17).fontWeight(FontWeight.Bold).fontColor(Color.White)
                          if (h.precipProb !== "--") { Text(h.precipProb + "%").fontSize(10).fontColor("rgba(123,164,253,0.7)").margin({ top: 4 }) }
                        }.width(68).padding({ top: 14, bottom: 12 }).borderRadius(22).backgroundColor("rgba(255,255,255,0.06)")
                        .margin({ right: 8 })
                        .onClick((): void => {
                          this.popTime = h.time; this.popTemp = h.temp; this.popFeelsLike = h.feelsLike;
                          this.popHumidity = h.humidity; this.popWindDir = h.windDir; this.popWindScale = h.windScale;
                          this.popWindSpeed = h.windSpeed; this.popPrecipProb = h.precipProb; this.popPrecip = h.precip;
                          this.popPressure = h.pressure; this.popUvIndex = h.uvIndex;
                          this.popWeatherIcon = h.weatherIcon; this.popWeatherDesc = h.weatherDesc;
                          this.showHourlyPop = true;
                        })
                      }, (h: HourlyForecast): string => h.time)
                    }
                  }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring).width("100%")
                }.width("100%").padding(16).borderRadius(28).backgroundColor(cardFrost(this.isDark)).margin({ top: 16 })
              }
// Daily forecast
              if (this.daily.length > 0 && this.error.length === 0) {
                Column() {
                  Text("📅 未来天气").fontSize(14).fontColor("rgba(255,255,255,0.45)").margin({ bottom: 10 }).width("100%")
                  ForEach(this.daily, (d: DailyForecast): void => {
                    Row() {
                      Text(d.dayOfWeek).fontSize(15).fontColor(Color.White).width(44)
                      Text(d.weatherIcon).fontSize(20).margin({ left: 6 }).width(28).textAlign(TextAlign.Center)
                      Text(d.weatherDesc).fontSize(14).fontColor("rgba(255,255,255,0.5)").width(50).textAlign(TextAlign.Center).margin({ left: 4 })
                      Blank()
                      Text(convertTempStr(d.minTemp, this.tempUnit) + "°").fontSize(14).fontColor("rgba(255,255,255,0.4)").margin({ right: 8 })
                      Column() { Column().width(this.barWidth(d.minTemp, d.maxTemp)).height(4).borderRadius(2).backgroundColor("#7BA4FD").margin({ left: this.barOffset(d.minTemp) }) }.width(80).height(4).backgroundColor("rgba(255,255,255,0.1)").borderRadius(2).margin({ right: 8 })
                      Text(convertTempStr(d.maxTemp, this.tempUnit) + "°").fontSize(14).fontWeight(FontWeight.Bold).fontColor(Color.White).width(36).textAlign(TextAlign.End)
                      Text("›").fontSize(18).fontColor("rgba(255,255,255,0.2)").margin({ left: 4 })
                    }.width("100%").padding({ top: 10, bottom: 10 }).borderRadius(16).onClick((): void => { this.getUIContext().getRouter().pushUrl({ url: "pages/Detail", params: { date: d.date, dayOfWeek: d.dayOfWeek, weatherIcon: d.weatherIcon, weatherDesc: d.weatherDesc, maxTemp: d.maxTemp, minTemp: d.minTemp, chanceOfRain: d.chanceOfRain } }); })
                  }, (d: DailyForecast): string => d.date)
                }.width("100%").padding(14).borderRadius(28).backgroundColor(cardFrost(this.isDark)).margin({ top: 16 }).padding(8)
              }

              if (this.lastUpdated.length > 0) {
                Text($r("app.string.last_update") + " " + this.lastUpdated).fontSize(11).fontColor("rgba(255,255,255,0.18)").letterSpacing(1).margin({ top: 20, bottom: 4 }).width("100%").textAlign(TextAlign.Center)
              }
              Blank().height(40)
            }.width("100%")
          }.height("100%").scrollBar(BarState.Off).width("100%").padding({ left: 20, right: 20 }).edgeEffect(EdgeEffect.Spring)
        }.width("100%").height("100%").onStateChange((state: number): void => {
          if (state === 3) {
            this.isRefreshing = true;
            this.loadW(this.city);
          }
        })
      }

      if (this.showHourlyPop) {
        Column() {
          Column() {
            Row() { Text(this.popWeatherIcon).fontSize(36).margin({ right: 10 }); Column() { Text(this.popWeatherDesc).fontSize(18).fontWeight(FontWeight.Bold).fontColor(Color.White); Text(this.popTime.length >= 16 ? this.popTime.substring(11, 16) + " " + this.popTime.substring(0, 10) : this.popTime).fontSize(13).fontColor("rgba(255,255,255,0.45)").margin({ top: 2 }) }.alignItems(HorizontalAlign.Start); Blank(); Text("✕").fontSize(22).fontColor("rgba(255,255,255,0.5)").width(32).height(32).textAlign(TextAlign.Center).onClick((): void => { this.showHourlyPop = false; }) }.width("100%").margin({ bottom: 16 })
            Text(convertTempStr(this.popTemp, this.tempUnit) + tempUnitLabel(this.tempUnit)).fontSize(40).fontWeight(FontWeight.Bold).fontColor(Color.White).width("100%").textAlign(TextAlign.Center).margin({ bottom: 16 })
            Row() { this.detailItem("💧", $r("app.string.humidity"), this.popHumidity + "%"); this.detailItem("🌬️", $r("app.string.wind"), this.popWindScale.length > 0 ? this.popWindScale : this.popWindSpeed); this.detailItem("☀️", "UV", this.popUvIndex !== "--" ? this.popUvIndex : "-") }.width("100%").padding(12).borderRadius(16).backgroundColor(cardBgStrong(this.isDark)).margin({ bottom: 8 })
            Row() { this.detailItem("🌧️", $r("app.string.precip_prob"), (this.popPrecipProb !== "--" ? this.popPrecipProb : "-") + "%"); this.detailItem("💧", $r("app.string.precip_amount"), (this.popPrecip !== "--" ? this.popPrecip : "-") + "mm"); this.detailItem("🌫️", $r("app.string.pressure"), (this.popPressure !== "--" ? this.popPressure : "-") + "hPa") }.width("100%").padding(12).borderRadius(16).backgroundColor(cardBgStrong(this.isDark)).margin({ bottom: 8 })
            Row() { this.detailItem("🌡️", $r("app.string.feels_like"), convertTempStr(this.popFeelsLike, this.tempUnit) + tempUnitLabel(this.tempUnit)) }.width("100%").padding(12).borderRadius(16).backgroundColor(cardBgStrong(this.isDark)).margin({ bottom: 12 })
            Button($r("app.string.close")).width("100%").height(44).borderRadius(22).backgroundColor("rgba(255,255,255,0.12)").fontColor(Color.White).fontWeight(FontWeight.Bold).onClick((): void => { this.showHourlyPop = false; })
          }.width("100%").padding(24).borderRadius(32).backgroundColor(cardFrost(this.isDark))
        }.width("100%").height("100%").padding(24).justifyContent(FlexAlign.Center).backgroundColor("rgba(0,0,0,0.5)").onClick((): void => { this.showHourlyPop = false; })
      }

      LoadingComponent()
    }.width("100%").height("100%")
  }

  @Builder detailItem(icon: string, label: ResourceStr, value: string) {
    Column() { Text(icon).fontSize(18); Text(label).fontSize(11).fontColor("rgba(255,255,255,0.4)").margin({ top: 4 }); Text(value).fontSize(15).fontWeight(FontWeight.Bold).fontColor(Color.White).margin({ top: 2 }) }.alignItems(HorizontalAlign.Center).layoutWeight(1)
  }

  pageTransition() {
    PageTransitionEnter({ type: RouteType.Push, duration: 350, curve: Curve.EaseOut }).slide(SlideEffect.Right)
    PageTransitionExit({ type: RouteType.Push, duration: 250, curve: Curve.EaseIn }).slide(SlideEffect.Left)
    PageTransitionEnter({ type: RouteType.Pop, duration: 300, curve: Curve.EaseOut }).slide(SlideEffect.Left)
    PageTransitionExit({ type: RouteType.Pop, duration: 250, curve: Curve.EaseIn }).slide(SlideEffect.Right)
  }
}

function timeLabel(t: string): string {
  if (t.length >= 16) { return t.substring(11, 16); }
  if (t.length >= 5) { return t.substring(0, 5); }
  return t;
}

function bgCol(isDark: boolean, bg: string): Array<[ResourceColor, number]> {
  return bgGradient(isDark, bg);
}

interface StarPos {
  x: string;
  y: string;
  size: number;
  opacity: number;
}

const starPositions: StarPos[] = [
  { x: '36%', y: '15%', size: 2, opacity: 0.38 },
  { x: '53%', y: '28%', size: 2.5, opacity: 0.20 },
  { x: '70%', y: '41%', size: 3.5, opacity: 0.26 },
  { x: '87%', y: '54%', size: 2, opacity: 0.20 },
  { x: '14%', y: '67%', size: 2.5, opacity: 0.14 },
  { x: '31%', y: '80%', size: 3.5, opacity: 0.08 },
  { x: '48%', y: '8%', size: 2, opacity: 0.38 },
  { x: '65%', y: '21%', size: 2.5, opacity: 0.20 },
  { x: '82%', y: '34%', size: 3.5, opacity: 0.26 },
  { x: '9%', y: '47%', size: 2, opacity: 0.20 },
  { x: '26%', y: '60%', size: 2.5, opacity: 0.14 },
  { x: '43%', y: '73%', size: 3.5, opacity: 0.08 },
  { x: '60%', y: '86%', size: 2, opacity: 0.38 },
  { x: '77%', y: '14%', size: 2.5, opacity: 0.20 },
  { x: '94%', y: '27%', size: 3.5, opacity: 0.26 },
  { x: '21%', y: '40%', size: 2, opacity: 0.20 },
  { x: '38%', y: '53%', size: 2.5, opacity: 0.14 },
  { x: '55%', y: '66%', size: 3.5, opacity: 0.08 },
  { x: '72%', y: '79%', size: 2, opacity: 0.38 },
  { x: '89%', y: '92%', size: 2.5, opacity: 0.20 },
  { x: '16%', y: '20%', size: 3.5, opacity: 0.26 },
  { x: '33%', y: '33%', size: 2, opacity: 0.20 },
  { x: '50%', y: '46%', size: 2.5, opacity: 0.14 },
  { x: '67%', y: '59%', size: 3.5, opacity: 0.08 },
  { x: '84%', y: '72%', size: 2, opacity: 0.38 },
  { x: '11%', y: '85%', size: 2.5, opacity: 0.20 },
  { x: '28%', y: '13%', size: 3.5, opacity: 0.26 },
  { x: '45%', y: '26%', size: 2, opacity: 0.20 },
  { x: '62%', y: '39%', size: 2.5, opacity: 0.14 },
  { x: '79%', y: '52%', size: 3.5, opacity: 0.08 },
  { x: '6%', y: '65%', size: 2, opacity: 0.38 },
  { x: '23%', y: '78%', size: 2.5, opacity: 0.20 },
  { x: '40%', y: '91%', size: 3.5, opacity: 0.26 },
  { x: '57%', y: '19%', size: 2, opacity: 0.20 },
  { x: '74%', y: '32%', size: 2.5, opacity: 0.14 },
  { x: '91%', y: '45%', size: 3.5, opacity: 0.08 },
  { x: '18%', y: '58%', size: 2, opacity: 0.38 },
  { x: '35%', y: '71%', size: 2.5, opacity: 0.20 },
  { x: '52%', y: '84%', size: 3.5, opacity: 0.26 },
  { x: '69%', y: '12%', size: 2, opacity: 0.20 },
  { x: '86%', y: '25%', size: 2.5, opacity: 0.14 },
  { x: '13%', y: '38%', size: 3.5, opacity: 0.08 },
  { x: '30%', y: '51%', size: 2, opacity: 0.38 },
  { x: '47%', y: '64%', size: 2.5, opacity: 0.20 },
  { x: '64%', y: '77%', size: 3.5, opacity: 0.26 },
  { x: '81%', y: '90%', size: 2, opacity: 0.20 },
  { x: '8%', y: '18%', size: 2.5, opacity: 0.14 },
  { x: '25%', y: '31%', size: 3.5, opacity: 0.08 },
  { x: '42%', y: '44%', size: 2, opacity: 0.38 },
  { x: '59%', y: '57%', size: 2.5, opacity: 0.20 }
];






