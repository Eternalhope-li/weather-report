import { WeatherData, CurrentWeather, HourlyForecast, DailyForecast } from "../model/WeatherData";
import { convertTempStr, tempUnitLabel, cleanCityName } from "../model/TemperatureConverter";
import { cardBg, cardBgStrong, cardFrost, cardMain, cardSecondary, cardAccent, cardShadowColor, cardBorder, cardBorderSub, accentBlue, tcPrimary, tcSecondary, tcTertiary, tcMuted, tcTemp, tcTempUnit, tcHiLo, getWeatherType, WeatherType, particleType, dayGradient, nightGradient } from "../model/ThemeManager";
import { RainSnowEffect } from "../components/RainSnowEffect";
import weatherService from "../service/WeatherService";
import prefManager from "../service/PreferenceManager";
import searchHistoryManager from "../service/SearchHistoryManager";
import loadingManager from "../service/LoadingManager";
import { getPendingCity, clearPendingCity } from "../model/CitySwitch";
import { LoadingComponent } from "../components/LoadingComponent";

/**
 * Index — 天气首页
 * 数据流：高德地理编码 → 和风天气API
 * 支持：切换城市、自动刷新、深色模式、温度单位切换
 */
@Entry
@Component
struct Index {
  // ==================== 天气数据 ====================
  @State city: string = "深圳";
  @State temp: string = "--";
  @State feelsLike: string = "--";
  @State humidity: string = "--";
  @State windSpeed: string = "--";
  @State windDir: string = "";
  @State windScale: string = "";
  @State aqi: string = "--";
  @State uvIndex: string = "--";
  @State pressure: string = "--";
  @State visRange: string = "--";
  @State cloudCover: string = "--";
  @State weatherDesc: string = "加载中";
  @State weatherIcon: string = "☀️";
  @State lastUpdated: string = "";
  @State daily: DailyForecast[] = [];
  @State hourly: HourlyForecast[] = [];
  @State sunrise: string = "--";
  @State sunset: string = "--";

  // ==================== 搜索相关 ====================
  @State searchText: string = "";
  @State showSearch: boolean = false;
  @State searchHistory: string[] = [];

  // ==================== 页面状态 ====================
  @State loading: boolean = true;
  @State error: string = "";
  @State isNight: boolean = false;
  @State rainSnowType: string = "none";
  @State history: string[] = [];
  @State favorites: string[] = [];
  @State isFav: boolean = false;

  // ==================== 设置 ====================
  @State tempUnit: string = "C";
  @State isDark: boolean = false;
  @State refreshInterval: string = "30";

  // ==================== 逐小时弹窗 ====================
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

  // ==================== 私有变量 ====================
  private refreshTimer: number = -1;
  private requestSeq: number = 0;
  private citySwitchPending: boolean = false;
  // ==================== AppStorage 跨页面通信 ====================
  // AppStorage city switching handled via onPageShow + CitySwitch helper
  @State isRefreshing: boolean = false;

  // ==================== 生命周期 ====================
  aboutToAppear(): void {
    this.initDayNight();
    this.loadSettingsAndStart();
  }

  onPageShow(): void {
    // 检查 AppStorage 是否有待切换的城市（来自 CityManage）
    try {
      let pendingCity: string = getPendingCity();
      if (pendingCity.length > 0) {
        console.info("[CitySwitch] detect pending city: " + pendingCity);
        clearPendingCity();
        this.citySwitchPending = true;
        // 先刷新收藏列表（CityManage可能已增删），再加载天气
        this.refreshFavoritesBeforeLoad(pendingCity);
        return;
      }
    } catch (_e) {}
    // 次选：检查路由参数（备用方案）
    try {
      let params = this.getUIContext().getRouter().getParams() as Record<string, Object>;
      if (params !== null && params !== undefined && params.switchCity !== undefined) {
        let switchTo: string = String(params.switchCity);
        if (switchTo.length > 0) {
          this.citySwitchPending = true;
          this.refreshFavoritesBeforeLoad(cleanCityName(switchTo));
          return;
        }
      }
    } catch (_e) {}
    // 从设置页返回时重新加载设置+收藏
    this.reloadAllState();
  }

  /** 从CityManage返回时：先刷新收藏列表，再加载天气 */
  refreshFavoritesBeforeLoad(city: string): void {
    try {
      let ctx: Context = this.getUIContext().getHostContext()!;
      prefManager.init(ctx).then((): void => {
        prefManager.getFavorites().then((favs: string[]): void => {
          this.favorites = favs;
          this.loadW(city);
        }).catch((): void => { this.loadW(city); });
      }).catch((): void => { this.loadW(city); });
    } catch (_e) { this.loadW(city); }
  }

  /** 从DB重新加载设置（用于从Settings页返回后同步） */
  reloadAllState(): void {
    try {
      let ctx: Context = this.getUIContext().getHostContext()!;
      prefManager.init(ctx).then((): void => {
        Promise.all([
          prefManager.getSettings(),
          prefManager.getFavorites()
        ]).then((r): void => {
          this.tempUnit = r[0].tempUnit;
          this.isDark = r[0].darkMode === 'true';
          this.refreshInterval = r[0].refreshInterval;
          this.setupAutoRefresh();
          this.favorites = r[1];
          this.isFav = r[1].indexOf(this.city) >= 0;
        }).catch((): void => {});
      }).catch((): void => {});
    } catch (_e) {}
  }

  aboutToDisappear(): void {
    if (this.refreshTimer > 0) { clearInterval(this.refreshTimer); this.refreshTimer = -1; }
  }

  // ==================== 初始化 ====================

  /** 加载设置 -> 并行初始化DB和搜索历史 -> 加载上次城市天气 */
  loadSettingsAndStart(): void {
    loadingManager.show();
    try {
      let ctx: Context = this.getUIContext().getHostContext()!;
      prefManager.init(ctx).then((): void => {
        Promise.all([
          prefManager.getSettings(),
          prefManager.getFavorites(),
          prefManager.getHistory()
        ]).then((r): void => {
          this.tempUnit = r[0].tempUnit;
          this.isDark = r[0].darkMode === "true";
          this.refreshInterval = r[0].refreshInterval;
          this.setupAutoRefresh();
          this.favorites = r[1];
          this.isFav = this.favorites.indexOf(this.city) >= 0;
          this.history = r[2];
        }).catch((): void => {});

        // 并行：加载搜索历史 + 上次城市
        this.loadSearchHistory();
        this.loadLastCity();
      }).catch((): void => { this.loadLastCity(); });
    } catch (_e) { this.loadLastCity(); }
  }

  /** 读取上次城市并自动加载天气 */
  loadLastCity(): void {
    if (this.citySwitchPending) { this.citySwitchPending = false; return; }
    prefManager.getLastCity().then((c: string): void => {
      this.loadW(c);
    }).catch((): void => {
      this.loadW("深圳");
    });
  }

  /** 初始化日夜判断（6~19点为白天） */
  initDayNight(): void {
    let h: number = new Date().getHours();
    this.isNight = h >= 19 || h < 6;
  }

  /** 根据日出日落精确更新日夜状态 */
  updateDayNight(sunrise: string, sunset: string): void {
    try {
      if (sunrise.length > 3 && sunset.length > 3) {
        let now: Date = new Date();
        let nowMin: number = now.getHours() * 60 + now.getMinutes();
        let srParts: string[] = sunrise.split(":");
        let ssParts: string[] = sunset.split(":");
        if (srParts.length >= 2 && ssParts.length >= 2) {
          let srMin: number = Number(srParts[0]) * 60 + Number(srParts[1]);
          let ssMin: number = Number(ssParts[0]) * 60 + Number(ssParts[1]);
          this.isNight = nowMin < srMin || nowMin > ssMin;
        }
      }
    } catch (_e) {}
  }

  // ==================== 天气数据加载 ====================

  /**
   * 核心加载方法：按高德->和风顺序获取天气
   * 切换城市时先清空旧预报数据，防止缓存污染
   */
  async loadW(city: string): Promise<void> {
    this.hourly = [];
    this.daily = [];
    let q: string = city.trim();
    if (q.length === 0) { loadingManager.hide(); return; }
    this.requestSeq++;
    let seq: number = this.requestSeq;
    console.info("[Weather] loadW #" + seq + " city=\"" + q + "\"");
    this.loading = true;
    this.error = "";
    // 清空旧预报数据，防止UI显示上次城市的缓存数据
    this.hourly = [];
    this.daily = [];

    try {
      let ctx: Context = this.getUIContext().getHostContext()!;
      await prefManager.init(ctx);
    } catch (_e) {}

    try {
      // 强制刷新：追加随机参数防止和风CDN缓存
      let data: WeatherData = await weatherService.fetchWeather(q);
      // 校验请求序号，防止过时响应覆盖
      if (seq !== this.requestSeq) {
        console.info("[Weather] skip stale #" + seq);
        loadingManager.hide();
        this.loading = false;
        return;
      }
      this.city = data.city;
      // 分层错误提示
      if (this.isErrorMsg(data.current.weatherDesc)) {
        this.error = data.current.weatherDesc;
        loadingManager.hide();
        this.loading = false;
        return;
      }
      this.applyWeatherData(data);
      // 异步保存：缓存、历史、上次城市（不阻塞UI）
      try {
        let ctx: Context = this.getUIContext().getHostContext()!;
        searchHistoryManager.init(ctx).then((): void => {
          searchHistoryManager.addHistory(data.city).catch((): void => {});
          searchHistoryManager.getHistory().then((h): void => {
            this.searchHistory = h.map((i): string => i.cityName);
          }).catch((): void => {});
        }).catch((): void => {});
      } catch (_se) {}
      try { prefManager.saveWeatherCache(data.city, JSON.stringify(data)); } catch (_ce) {}
      try { prefManager.addToHistory(data.city).catch((): void => {}); } catch (_he) {}
      try { prefManager.saveLastCity(data.city).catch((): void => {}); } catch (_lc) {}
    } catch (e) {
      console.error("[Weather] loadW error", JSON.stringify(e));
      this.error = "获取天气失败";
      this.tryLoadCache(city);
    }
    loadingManager.hide();
    this.loading = false;
  }

  /** 错误消息匹配 */
  isErrorMsg(desc: string): boolean {
    return desc === "和风天气权限同步中，稍后刷新重试"
        || desc === "城市解析失败，请更换城市"
        || desc === "网络异常，请检查网络后重试"
        || desc === "天气数据请求失败，请登录和风控制台确认";
  }

  /** 应用天气数据到状态变量 */
  applyWeatherData(data: WeatherData): void {
    this.temp = data.current.temp;
    this.feelsLike = data.current.feelsLike;
    this.humidity = data.current.humidity;
    this.windSpeed = data.current.windSpeed;
    this.windDir = data.current.windDir;
    this.windScale = data.current.windScale;
    this.aqi = data.current.aqi;
    this.weatherDesc = data.current.weatherDesc;
    this.weatherIcon = data.current.weatherIcon;
    this.lastUpdated = data.lastUpdated;
    this.daily = data.daily;
    this.hourly = data.hourly;
    this.sunrise = data.current.sunrise;
    this.sunset = data.current.sunset;
    this.pressure = data.current.pressure;
    this.visRange = data.current.visibility;
    this.cloudCover = data.current.cloudCover;
    this.uvIndex = data.current.uvIndex;
    // QWeather /v7/weather/now API 不返回 uvIndex，从逐日预报取
    if ((this.uvIndex === "--" || this.uvIndex === "-") && data.daily.length > 0 && data.daily[0].uvIndex !== "--") {
      this.uvIndex = data.daily[0].uvIndex;
    }
    this.updateDayNight(data.current.sunrise, data.current.sunset);
    // 更新天气类型用于背景渐变和粒子特效
    let wt: WeatherType = getWeatherType(data.current.weatherDesc);
    this.rainSnowType = particleType(wt);
    // 切换城市时检查当前城市是否已收藏
    this.isFav = this.favorites.indexOf(data.city) >= 0;
  }

  /** 优先展示本地缓存的天气数据 */
  showCachedFirst(city: string): void {
    let seq: number = this.requestSeq;
    prefManager.getWeatherCache(city).then((cached: string | null): void => {
      if (cached !== null && seq === this.requestSeq) {
        try {
          let data: WeatherData = JSON.parse(cached) as WeatherData;
          if (data.current.temp !== "--") {
            this.applyWeatherData(data);
          }
        } catch (_e) {}
      }
    }).catch((): void => {});
  }

  /** 网络请求失败时尝试读取缓存 */
  tryLoadCache(city: string): void {
    prefManager.getWeatherCache(city).then((cached: string | null): void => {
      if (cached !== null) {
        try {
          let data: WeatherData = JSON.parse(cached) as WeatherData;
          if (data.current.temp !== "--") {
            this.applyWeatherData(data);
            return;
          }
        } catch (_e) {}
      }
      this.loading = false;
    }).catch((): void => { this.loading = false; });
  }

  /** 删除单条搜索历史 */
  deleteSearchHistoryItem(city: string): void {
    try {
      let ctx: Context = this.getUIContext().getHostContext()!;
      searchHistoryManager.init(ctx).then((): void => {
        searchHistoryManager.deleteHistory(city).then((): void => {
          this.loadSearchHistory();
        }).catch((): void => {});
      }).catch((): void => {});
    } catch (_e) {}
  }

  /** 加载搜索历史 */
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

  // ==================== 自动刷新 ====================
  setupAutoRefresh(): void {
    if (this.refreshTimer > 0) { clearInterval(this.refreshTimer); }
    let interval: number = Number(this.refreshInterval) * 60000;
    if (interval <= 0) { return; }
    this.refreshTimer = setInterval((): void => {
      this.loadW(this.city);
    }, interval);
  }

  // ==================== 构建UI ====================

  build() {
    Stack() {
      // 底层：天气渐变背景
      Column().width("100%").height("100%")
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: bgCol(this.isNight, this.weatherDesc)
        })

      // 夜间星空粒子（晴/多云时显示）
      if (this.isNight && this.rainSnowType === "none") {
        Column() {
          ForEach(starPositions, (s: StarPos): void => {
            Column()
              .width(s.size).height(s.size)
              .backgroundColor(Color.White)
              .borderRadius(s.size / 2)
              .position({ x: s.x, y: s.y })
              .opacity(s.opacity)
              .shadow({ radius: s.size, color: tcTertiary(this.isDark) })
          }, (s: StarPos): string => s.x + s.y)
        }.width('100%').height('100%')
      }

      // 雨雪粒子特效（弹窗打开时暂停以降低渲染开销）
      if (!this.showHourlyPop) {
        RainSnowEffect({ particleType: this.rainSnowType, density: 1 })
      }

      // 加载骨架屏（仅首次加载时显示）
      if (this.loading && this.error.length === 0) {
        this.skeletonView()
      }

      // 主内容区域（可纵向滚动 + 下拉刷新；弹窗打开时隐藏以隔离渲染）
      if (!this.showHourlyPop) {
      Refresh({ refreshing: $$this.isRefreshing }) {
        Scroll() {
          Column() {
          // 顶部导航栏：城市名 + 功能按钮
          this.topBar()

          // 错误提示 + 刷新按钮
          if (this.error.length > 0) {
            this.errorBanner()
          }

          // 主温度大卡片
          if (this.error.length === 0) {
            this.mainTempCard()

            // 湿度 + 风力双卡片
            this.detailCards()

            // 逐小时预报（横向滚动）
            if (this.cloudCover !== "--") {
              Text("☁️ 云量 " + this.cloudCover + "%  ·  气压 " + this.pressure + "hPa").fontSize(12).fontColor(tcSecondary(this.isDark)).width("100%").textAlign(TextAlign.Center).margin({ top: 2, bottom: 2 })
            }
            if (this.hourly.length > 0 && this.error.length === 0) {
              this.hourlyForecast()
            }

            // 7天预报
            if (this.daily.length > 0 && this.error.length === 0) {
              this.dailyForecast()
            }

            // 更新时间
            if (this.lastUpdated.length > 0) {
              this.updateFooter()
            }
          }

          Blank().height(30)
        }.width("100%").padding({ left: 20, right: 20 })
      }.scrollBar(BarState.Off).width("100%").edgeEffect(EdgeEffect.Spring)
      }
      .onRefreshing((): void => {
        this.isRefreshing = true;
        this.loadW(this.city).then((): void => {
          this.isRefreshing = false;
        }).catch((): void => {
          this.isRefreshing = false;
        });
      })
      } // end if !showHourlyPop

      // 搜索面板（点击🔍展开）
      if (this.showSearch) {
        this.searchPanel()
      }

      // 逐小时详情弹窗
      if (this.showHourlyPop) {
        this.hourlyPopup()
      }

      // 全局加载动画
      LoadingComponent()
    }.width("100%").height("100%")
  }

  // ==================== @Builder 子视图 ====================

  /** 顶部导航栏 */
  @Builder topBar() {
    Row() {
      // 城市名 + 展开箭头
      Row() {
        Text(this.city).fontSize(24).fontWeight(FontWeight.Bold).fontColor(tcPrimary(this.isDark))
        Text("  ›").fontSize(20).fontColor(tcTertiary(this.isDark))
      }.onClick((): void => {
        this.getUIContext().getRouter().pushUrl({ url: "pages/CityManage" });
      })

      Blank()

      // 功能图标
      Text("📍").fontSize(18).margin({ left: 10 }).onClick((): void => { this.locate(); })
      Text("🔍").fontSize(18).margin({ left: 10 })
        .onClick((): void => { this.showSearch = !this.showSearch; })
      Text(!this.isFav ? "☆" : "★").fontSize(20).margin({ left: 10 })
        .fontColor(this.isFav ? "#FFD700" : tcSecondary(this.isDark))
        .onClick((): void => { this.toggleFav(); })
      Text("⚙️").fontSize(18).margin({ left: 10 })
        .onClick((): void => {
          this.getUIContext().getRouter().pushUrl({ url: "pages/Settings" });
        })
      // 刷新按钮
      Text("🔄").fontSize(16).margin({ left: 10 })
        .onClick((): void => { this.loadW(this.city); })
    }.width("100%").padding({ top: 36, bottom: 16 })
  }

  /** 主温度 + 天气图标大卡片 */
  @Builder mainTempCard() {
    Column() {
      // 天气图标
      Text(this.weatherIcon).fontSize(72)
      // 天气描述
      Text(this.weatherDesc).fontSize(20).fontWeight(FontWeight.Medium)
        .fontColor(tcSecondary(this.isDark)).margin({ top: 8 })
      // 当前温度
      Text(convertTempStr(this.temp, this.tempUnit) + tempUnitLabel(this.tempUnit))
        .fontSize(72).fontWeight(FontWeight.Bold).fontColor(tcPrimary(this.isDark))
        .lineHeight(80).margin({ top: 4 })
      // 体感温度
      Text("体感温度 "
        + convertTempStr(this.feelsLike, this.tempUnit) + tempUnitLabel(this.tempUnit)).fontSize(14).fontColor(tcSecondary(this.isDark)).margin({ top: 4 })
    }
    .width("100%").padding(30).alignItems(HorizontalAlign.Center)
    .backgroundColor(cardMain(this.isDark)).backdropBlur(16)
    .border({ width: 0.5, color: cardBorder(this.isDark) }).borderRadius(32)
    .shadow({ radius: 10, color: cardShadowColor(this.isDark), offsetY: 3 })
  }

  /** 湿度 + 风力详细卡片 */
  @Builder detailCards() {
    Row() {
      // 湿度
      Column() {
        Text("💧").fontSize(22)
        Text("湿度").fontSize(12).fontColor(tcSecondary(this.isDark)).margin({ top: 6 })
        Text(this.humidity + "%").fontSize(20).fontWeight(FontWeight.Bold)
          .fontColor(tcPrimary(this.isDark)).margin({ top: 4 })
      }.alignItems(HorizontalAlign.Center).layoutWeight(1)

      // 分隔
      Column().width(0.5).height(40).backgroundColor(cardBorderSub(this.isDark))

      // 风力
      Column() {
        Text("🌬️").fontSize(22)
        Text("风力").fontSize(12).fontColor(tcSecondary(this.isDark)).margin({ top: 6 })
        Text((this.windScale.length > 0 ? this.windScale + "级" : this.windSpeed))
          .fontSize(20).fontWeight(FontWeight.Bold).fontColor(tcPrimary(this.isDark)).margin({ top: 4 })
        Text(this.windDir).fontSize(12).fontColor(tcSecondary(this.isDark))
      }.alignItems(HorizontalAlign.Center).layoutWeight(1)

      // 分隔
      Column().width(0.5).height(40).backgroundColor(cardBorderSub(this.isDark))

      // UV / 空气质量
      Column() {
        Text("☀️").fontSize(22)
        Text("UV").fontSize(12).fontColor(tcSecondary(this.isDark)).margin({ top: 6 })
        Text(this.uvIndex !== "--" ? this.uvIndex : "-").fontSize(20).fontWeight(FontWeight.Bold)
          .fontColor(tcPrimary(this.isDark)).margin({ top: 4 })
      }.alignItems(HorizontalAlign.Center).layoutWeight(1)
    }
    .width("100%").padding(20).margin({ top: 16 })
    .backgroundColor(cardSecondary(this.isDark)).backdropBlur(12)
    .border({ width: 0.5, color: cardBorderSub(this.isDark) }).borderRadius(24)
    .shadow({ radius: 4, color: cardShadowColor(this.isDark), offsetY: 1 })
  }

  /** 逐小时预报 - 横向滚动列表 */
  @Builder hourlyForecast() {
    Column() {
      Row() {
        Text("⏰ 逐小时预报").fontSize(14).fontColor(tcSecondary(this.isDark)).letterSpacing(2)
        Blank()
        if (this.lastUpdated.length > 0) {
          Text(this.lastUpdated).fontSize(11).fontColor(tcMuted(this.isDark))
        }
      }.width("100%").margin({ bottom: 12 })

      List({ space: 10 }) {
        ForEach(this.hourly, (h: HourlyForecast): void => {
          ListItem() {
            Column() {
              Text(timeLabel(h.time)).fontSize(12).fontColor(tcSecondary(this.isDark)).margin({ bottom: 6 })
              Text(String(h.weatherIcon)).fontSize(22).margin({ bottom: 4 })
              Text(convertTempStr(h.temp, this.tempUnit) + "°")
                .fontSize(17).fontWeight(FontWeight.Bold).fontColor(tcPrimary(this.isDark))
              if (h.precipProb !== "--" && h.precipProb !== "") {
                Text(h.precipProb + "%").fontSize(10).fontColor(accentBlue).margin({ top: 4 })
              }
            }
            .width(72).padding({ top: 14, bottom: 12 }).borderRadius(22)
            .backgroundColor(cardAccent(this.isDark)).backdropBlur(12)
            .border({ width: 0.5, color: cardBorderSub(this.isDark) })
            .onClick((): void => {
              this.popTime = h.time; this.popTemp = h.temp; this.popFeelsLike = h.feelsLike;
              this.popHumidity = h.humidity; this.popWindDir = h.windDir;
              this.popWindScale = h.windScale; this.popWindSpeed = h.windSpeed;
              this.popPrecipProb = h.precipProb; this.popPrecip = h.precip;
              this.popPressure = h.pressure; this.popUvIndex = h.uvIndex;
              this.popWeatherIcon = h.weatherIcon; this.popWeatherDesc = h.weatherDesc;
              this.showHourlyPop = true;
            })
          }
        }, (h: HourlyForecast): string => h.time)
      }
      .listDirection(Axis.Horizontal).width("100%")
      .edgeEffect(EdgeEffect.Spring).scrollBar(BarState.Off)
    }
    .width("100%").padding(16).margin({ top: 16 }).borderRadius(28)
    .backgroundColor(cardSecondary(this.isDark)).backdropBlur(12)
    .border({ width: 0.5, color: cardBorderSub(this.isDark) })
    .shadow({ radius: 6, color: cardShadowColor(this.isDark), offsetY: 2 })
  }

  /** 7天预报 */
  @Builder dailyForecast() {
    Column() {
      Text("📅 近三日预报").fontSize(14).fontColor(tcSecondary(this.isDark)).margin({ bottom: 12 }).width("100%").letterSpacing(2)

      ForEach(this.daily, (d: DailyForecast): void => {
        Row() {
          Text(d.dayOfWeek).fontSize(15).fontColor(tcPrimary(this.isDark)).width(44)
          Text(d.weatherIcon).fontSize(20).margin({ left: 6 }).width(28).textAlign(TextAlign.Center)
          Text(d.weatherDesc).fontSize(14).fontColor(tcSecondary(this.isDark))
            .width(50).textAlign(TextAlign.Center).margin({ left: 4 })
          Blank()
          Text(convertTempStr(d.minTemp, this.tempUnit) + "°").fontSize(14)
            .fontColor(tcSecondary(this.isDark)).margin({ right: 8 })
          // 温度条
          Row() {
            Column().width(this.barWidth(d.minTemp, d.maxTemp)).height(4)
              .borderRadius(2).backgroundColor("#7BA4FD")
              .margin({ left: this.barOffset(d.minTemp) })
          }.width(80).height(4).backgroundColor(cardFrost(this.isDark)).borderRadius(2).margin({ right: 8 })
          Text(convertTempStr(d.maxTemp, this.tempUnit) + "°").fontSize(14)
            .fontWeight(FontWeight.Bold).fontColor(tcPrimary(this.isDark)).width(36).textAlign(TextAlign.End)
          Text("›").fontSize(18).fontColor(tcMuted(this.isDark)).margin({ left: 4 })
        }
        .width("100%").padding({ top: 10, bottom: 10 }).borderRadius(16)
        .onClick((): void => {
          this.getUIContext().getRouter().pushUrl({
            url: "pages/Detail",
            params: {
              date: d.date, dayOfWeek: d.dayOfWeek, weatherIcon: d.weatherIcon,
              weatherDesc: d.weatherDesc, maxTemp: d.maxTemp, minTemp: d.minTemp,
              chanceOfRain: d.chanceOfRain
            }
          });
        })
      }, (d: DailyForecast): string => d.date)
    }
    .width("100%").padding(16).margin({ top: 16 }).borderRadius(28)
    .backgroundColor(cardSecondary(this.isDark)).backdropBlur(12)
    .border({ width: 0.5, color: cardBorderSub(this.isDark) })
    .shadow({ radius: 6, color: cardShadowColor(this.isDark), offsetY: 2 })
  }

  /** 更新时间底部 */
  @Builder updateFooter() {
    Text("最后更新 " + this.lastUpdated)
      .fontSize(12).fontColor(tcMuted(this.isDark)).width("100%").textAlign(TextAlign.Center)
      .margin({ top: 12 })
  }

  /** 加载骨架屏 */
  @Builder skeletonView() {
    Column() {
      // 顶部骨架
      Row() {
        Column().width(80).height(22).borderRadius(11)
          .backgroundColor("rgba(255,255,255,0.10)")
        Blank()
        Row() {
          ForEach([1, 2, 3, 4, 5], (): void => {
            Column().width(24).height(24).borderRadius(12)
              .backgroundColor(cardFrost(this.isDark)).margin({ left: 10 })
          })
        }
      }.width("100%").padding({ top: 36, bottom: 16, left: 8, right: 8 })

      // 主卡片骨架
      Column() {
        Column().width(72).height(72).borderRadius(36)
          .backgroundColor("rgba(255,255,255,0.10)").margin({ top: 30 })
        Column().width(140).height(56).borderRadius(28)
          .backgroundColor(cardFrost(this.isDark)).margin({ top: 12 })
        Column().width(100).height(18).borderRadius(9)
          .backgroundColor(cardFrost(this.isDark)).margin({ top: 8 })
      }.width("100%").alignItems(HorizontalAlign.Center)

      // 详情骨架
      Row() {
        ForEach([1, 2], (): void => {
          Column() {
            Column().width(24).height(24).borderRadius(12)
              .backgroundColor(cardFrost(this.isDark))
            Column().width(40).height(10).borderRadius(5)
              .backgroundColor(cardFrost(this.isDark)).margin({ top: 8 })
            Column().width(56).height(20).borderRadius(10)
              .backgroundColor(cardFrost(this.isDark)).margin({ top: 6 })
          }.alignItems(HorizontalAlign.Center).layoutWeight(1)
        })
      }
      .width("100%").padding(20).borderRadius(28)
      .backgroundColor(cardFrost(this.isDark)).margin({ top: 16 })
      .shadow({ radius: 6, color: "rgba(64,80,110,0.05)", offsetY: 1 })
    }
    .width("100%").padding({ left: 20, right: 20 })
  }

  /** 错误提示条 */
  @Builder errorBanner() {
    Column() {
      Text(this.error).fontSize(15).fontColor("#FF6B6B").textAlign(TextAlign.Center)
        .margin({ top: 20, bottom: 10 }).width("100%")
      Button("🔄 返回")
        .fontSize(14).height(40).borderRadius(20)
        .backgroundColor(cardMain(this.isDark)).fontColor(tcPrimary(this.isDark))
        .onClick((): void => { this.loadW(this.city); })
    }
    .width("100%").padding(20).margin({ top: 30 })
    .backgroundColor(cardSecondary(this.isDark)).backdropBlur(12)
    .border({ width: 0.5, color: cardBorderSub(this.isDark) }).borderRadius(24)
    .alignItems(HorizontalAlign.Center)
  }

  /** 搜索面板 */
  @Builder searchPanel() {
    Column() {
      Row() {
        TextInput({ placeholder: $r('app.string.search_city_hint') })
          .height(44).layoutWeight(1).borderRadius(22)
          .backgroundColor(cardMain(this.isDark)).backdropBlur(12)
          .padding({ left: 16 }).fontColor(tcPrimary(this.isDark))
          .placeholderColor(tcTertiary(this.isDark))
          .onChange((val: string): void => { this.searchText = val; })
          .onSubmit((): void => {
            let q: string = cleanCityName(this.searchText.trim());
            if (q.length > 0) {
              this.showSearch = false;
              this.loadW(q);
            }
          })
        Text(" ✕").fontSize(20).fontColor(tcTertiary(this.isDark)).margin({ left: 12 })
          .onClick((): void => { this.showSearch = false; })
      }.width("100%").margin({ top: 28 })

      if (this.searchHistory.length > 0) {
        Text($r('app.string.search_history')).fontSize(13).fontColor(tcTertiary(this.isDark))
          .width("100%").margin({ top: 16, bottom: 8 })
        ForEach(this.searchHistory, (city: string): void => {
          Row() {
            Text(city).fontSize(15).fontColor(tcSecondary(this.isDark))
              .layoutWeight(1)
              .onClick((): void => {
                this.searchText = city;
                this.showSearch = false;
                this.loadW(city);
              })
            Text(" \u2716").fontSize(14).fontColor("rgba(255,120,120,0.7)")
              .padding({ left: 12, right: 4, top: 4, bottom: 4 })
              .onClick((): void => {
                this.deleteSearchHistoryItem(city);
              })
          }.width("100%").padding({ top: 6, bottom: 6 })
        }, (city: string): string => city)
      }
    }
    .width("100%").height("100%").padding(20)
    .backgroundColor(cardAccent(this.isDark)).backdropBlur(16)
  }

  /** 逐小时详情弹窗 - 全屏置顶隔离渲染 */
  @Builder hourlyPopup() {
    Stack() {
      // 背景渐变层 - 蓝白通透风格
      Column()
        .width("100%").height("100%")
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [["rgba(25,60,120,0.92)", 0], ["rgba(45,90,160,0.85)", 0.4], ["rgba(75,130,200,0.78)", 0.7], ["rgba(110,170,230,0.70)", 1]]
        })
        .onClick((): void => { this.showHourlyPop = false; })

      // 内容层：可滚动
      Column() {
        Scroll() {
        Column() {
          // 天气图标 + 温度 + 时间
          Column() {
            Text(this.popWeatherIcon).fontSize(64)
            Text(this.popWeatherDesc).fontSize(20).fontWeight(FontWeight.Medium)
              .fontColor("#FFFFFF").margin({ top: 6 }).letterSpacing(2)
            Row() {
              Text(convertTempStr(this.popTemp, this.tempUnit))
                .fontSize(56).fontWeight(FontWeight.Bold).fontColor("#FFFFFF")
              Text(tempUnitLabel(this.tempUnit))
                .fontSize(28).fontWeight(FontWeight.Bold).fontColor("rgba(255,255,255,0.75)")
                .margin({ top: 8 })
            }.alignItems(VerticalAlign.Center).margin({ top: 4 })

            Text("\u4F53\u611F " + convertTempStr(this.popFeelsLike, this.tempUnit) + tempUnitLabel(this.tempUnit))
              .fontSize(15).fontColor("rgba(255,255,255,0.65)").margin({ top: 6 })

            if (this.popTime.length > 0) {
              Text(this.popTime.length >= 16
                ? this.popTime.substring(0, 10) + "  " + this.popTime.substring(11, 16)
                : this.popTime)
                .fontSize(13).fontColor("rgba(255,255,255,0.5)")
                .margin({ top: 6 })
            }
          }.width("100%").alignItems(HorizontalAlign.Center)
            .padding({ top: 24, bottom: 24 })
            .backgroundColor("rgba(255,255,255,0.08)")
            .backdropBlur(20)
            .borderRadius(28)
            .border({ width: 0.5, color: "rgba(255,255,255,0.15)" })

          Blank().height(16)

          // 第一行：降水概率 / 降水量 / 气压
          Row() {
            this.bpDetailItem("\uD83C\uDF27\uFE0F", "\u964D\u6C34\u6982\u7387",
              (this.popPrecipProb !== "--" ? this.popPrecipProb : "-") + "%")
            this.bpDetailItem("\uD83D\uDCA7", "\u964D\u6C34\u91CF",
              (this.popPrecip !== "--" ? this.popPrecip : "-") + "mm")
            this.bpDetailItem("\uD83C\uDF2B\uFE0F", "\u6C14\u538B",
              (this.popPressure !== "--" ? this.popPressure : "-") + "hPa")
          }.width("100%")

          Blank().height(12)

          // 第二行：湿度 / 风力
          Row() {
            this.bpDetailItem("\uD83D\uDCA7", "\u6E7F\u5EA6", this.popHumidity + "%")
            this.bpDetailItem("\uD83C\uDF21\uFE0F", "\u98CE\u529B",
              this.popWindScale.length > 0 ? this.popWindScale + "\u7EA7" : this.popWindSpeed)
          }.width("100%")

          Blank().height(20)

          // 返回按钮
          Button("\u8FD4\u56DE")
            .width("100%").height(48).borderRadius(24)
            .backgroundColor("rgba(59,120,194,0.7)")
            .backdropBlur(12)
            .fontColor("#FFFFFF").fontSize(16).fontWeight(FontWeight.Medium)
            .onClick((): void => { this.showHourlyPop = false; })
        }
        .width("100%").padding({ left: 20, right: 20, top: 48, bottom: 20 })
        }
        .scrollBar(BarState.Off).width("100%")
      }
      .width("100%").height("100%")
      .padding({ top: 40 })
    }
  }

@Builder bpDetailItem(icon: string, label: string, value: string) {
    Column() {
      Text(icon).fontSize(22)
      Text(label).fontSize(12).fontColor("rgba(255,255,255,0.75)")
        .margin({ top: 6 })
      Text(value).fontSize(18).fontWeight(FontWeight.Bold)
        .fontColor("#FFFFFF").margin({ top: 4 })
    }
    .alignItems(HorizontalAlign.Center).layoutWeight(1)
    .padding({ top: 18, bottom: 16 })
    .backgroundColor("rgba(255,255,255,0.12)")
    .backdropBlur(18)
    .borderRadius(20)
    .margin({ left: 4, right: 4 })
    .border({ width: 0.5, color: "rgba(255,255,255,0.15)" })
  }


  // ==================== 工具方法 ====================

  /** 收藏/取消收藏 - 基于DB结果更新状态 */
  toggleFav(): void {
    try {
      let ctx: Context = this.getUIContext().getHostContext()!;
      prefManager.init(ctx).then((): void => {
        prefManager.toggleFavorite(this.city).then((list: string[]): void => {
          this.favorites = list;
          this.isFav = list.indexOf(this.city) >= 0;
        }).catch((): void => {});
      }).catch((): void => {});
    } catch (_e) {}
  }

  /** 定位功能（占位） */
  locate(): void {
    console.info("[Location] locate requested");
  }

  /** 温度条偏移量 */
  barOffset(temp: string): number {
    let t: number = Number(temp);
    if (isNaN(t)) { return 0; }
    return Math.max(0, (t + 10) * 1.2);
  }

  /** 温度条宽度 */
  barWidth(minTemp: string, maxTemp: string): number {
    let min: number = Number(minTemp);
    let max: number = Number(maxTemp);
    if (isNaN(min) || isNaN(max)) { return 40; }
    let diff: number = max - min;
    return Math.max(20, Math.min(80, diff * 4));
  }

  pageTransition() {
    PageTransitionEnter({ type: RouteType.Push, duration: 400, curve: Curve.EaseInOut })
      .slide(SlideEffect.Right).opacity(1)
    PageTransitionExit({ type: RouteType.Push, duration: 300, curve: Curve.EaseInOut })
      .slide(SlideEffect.Left).opacity(0)
    PageTransitionEnter({ type: RouteType.Pop, duration: 350, curve: Curve.EaseInOut })
      .slide(SlideEffect.Left).opacity(1)
    PageTransitionExit({ type: RouteType.Pop, duration: 300, curve: Curve.EaseInOut })
      .slide(SlideEffect.Right).opacity(0)
  }
}

// ==================== 全局工具函数 ====================

/** 格式化时间标签 */
function timeLabel(t: string): string {
  if (t.length >= 16) { return t.substring(11, 16); }
  if (t.length >= 5) { return t.substring(0, 5); }
  return t;
}

/** 根据日夜和天气返回渐变颜色数组 */
function bgCol(isNight: boolean, weatherDesc: string): Array<[ResourceColor, number]> {
  let wt: WeatherType = getWeatherType(weatherDesc);
  if (isNight) { return nightGradient(wt); }
  return dayGradient(wt);
}

/** 星空位置定义 */
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














