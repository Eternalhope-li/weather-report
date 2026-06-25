import prefManager from "../service/PreferenceManager";
import { setPendingCity } from "../model/CitySwitch";
import { cleanCityName } from "../model/TemperatureConverter";
import {
  bgGradient, cardMain, cardAccent, cardSecondary, cardFrost,
  cardBorder, cardBorderSub,
  tcPrimary, tcSecondary, tcTertiary, tcMuted
} from "../model/ThemeManager";
import loadingManager from "../service/LoadingManager";
import { LoadingComponent } from "../components/LoadingComponent";

/**
 * CityManage — 城市管理页面
 * 搜索+添加城市，已存城市列表自动去重
 * 点击城市通过 AppStorage 通知首页切换
 */
@Entry
@Component
struct CityManage {
  @State cities: string[] = [];

  @State newCity: string = "";
  @State isDark: boolean = false;
  @State selectedCity: string = "";


  aboutToAppear(): void {
    this.loadThemeSettings();
    this.loadCityData();
  }

  onPageShow(): void {
    this.loadThemeSettings();
    this.loadCityData();
  }

  /** 加载收藏城市列表 */
  loadCityData(): void {
    let ctx: Context = this.getUIContext().getHostContext()!;
    prefManager.init(ctx).then((): void => {
      prefManager.getFavorites().then((favs: string[]): void => {
        this.cities = favs;
      }).catch((): void => {});
      prefManager.getLastCity().then((c: string): void => {
        this.selectedCity = c;
      }).catch((): void => {});
    }).catch((): void => {});
  }

  /** 加载深色模式设置 */
  loadThemeSettings(): void {
    try {
      let ctx: Context = this.getUIContext().getHostContext()!;
      prefManager.init(ctx).then((): void => {
        prefManager.getSettings().then((s): void => {
          this.isDark = s.darkMode === "true";
        }).catch((): void => {});
      }).catch((): void => {});
    } catch (_e) {}
  }

  /** 选中城市 -> 通知首页切换 -> 返回 */
  selectCityAndGo(city: string): void {
    let q: string = cleanCityName(city);
    if (q.length === 0) { return; }
    this.selectedCity = q;
    setPendingCity(q);
    prefManager.saveLastCity(q);
    this.getUIContext().getRouter().back();
  }

  /** 搜索城市并切换（收藏仅通过首页☆按钮操作） */
  addNewCity(cityName: string): void {
    let q: string = cleanCityName(cityName.trim());
    if (q.length === 0) { return; }
    this.newCity = "";
    // 直接在首页加载该城市天气，用户可通过☆按钮收藏
    this.selectCityAndGo(q);
  }

  /** 从收藏夹删除城市 */
  removeCity(city: string): void {
    loadingManager.show();
    prefManager.removeFavorite(city).then((favs: string[]): void => {
      this.cities = favs;
      if (this.selectedCity === city) {
        this.selectedCity = this.cities.length > 0 ? this.cities[0] : "";
      }
      loadingManager.hide();
    }).catch((): void => { loadingManager.hide(); });
  }

  build() {
    Stack() {
      // 天气渐变背景
      Column().width("100%").height("100%")
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: bgGradient(this.isDark, "")
        })

      Column() {
        // 顶部标题栏
        Row() {
          Text("\u2190 ").fontSize(22).fontColor("rgba(255,255,255,0.8)")
            .onClick((): void => { this.getUIContext().getRouter().back(); })
          Text("城市管理").fontSize(20).fontWeight(FontWeight.Bold)
            .fontColor(tcPrimary(this.isDark)).margin({ left: 8 })
          Blank()
        }.width("100%").padding({ top: 28, bottom: 12, left: 8, right: 8 })

        // 搜索输入框（自动唤起输入法）
        Row() {
          TextInput({ placeholder: "输入城市名搜索添加" })
            .defaultFocus(true)
            .height(48).layoutWeight(1)
            .backgroundColor(cardMain(this.isDark)).backdropBlur(12)
            .border({ width: 0.5, color: cardBorderSub(this.isDark) })
            .fontColor(tcPrimary(this.isDark)).placeholderColor(tcTertiary(this.isDark))
            .borderRadius(16).padding({ left: 16 })
            .onChange((val: string): void => { this.newCity = val; })
            .onSubmit((): void => { this.addNewCity(this.newCity); })
          Button("添加").height(48).borderRadius(16).margin({ left: 8 })
            .backgroundColor(cardAccent(this.isDark))
            .fontColor(tcPrimary(this.isDark)).fontWeight(FontWeight.Bold)
            .onClick((): void => { this.addNewCity(this.newCity); })
        }.width("100%").margin({ top: 4 })

        // 主滚动区域
        Scroll() {
          Column() {
            // ---- 已存城市列表（去重后展示） ----
            if (this.cities.length > 0) {
              Column() {
                Row() {
                  Text("\u2B50 收藏城市").fontSize(14).fontColor(tcTertiary(this.isDark))
                  Blank()
                }.width("100%").margin({ bottom: 8, top: 12 })

                ForEach(this.cities, (city: string): void => {
                  if (typeof city === "string") {
                    this.cityCard(city, city === this.selectedCity)
                  }
                }, (city: string): string => city)
              }.width("100%")
            }

            // 空状态
            if (this.cities.length === 0) {
              Column() {
                Text("\uD83C\uDFD4\uFE0F").fontSize(48).margin({ top: 40 })
                Text("暂无城市数据").fontSize(16).fontColor(tcTertiary(this.isDark)).margin({ top: 12 })
              }.width("100%").alignItems(HorizontalAlign.Center).margin({ top: 40 })
            }

            Blank().height(40)
          }.width("100%")
        }.scrollBar(BarState.Off).width("100%").margin({ top: 8 }).edgeEffect(EdgeEffect.Spring)

      }.width("100%").height("100%").padding(20)

      LoadingComponent()
    }.width("100%").height("100%")
  }

  /** 城市卡片 - 磨砂玻璃样式 */
  @Builder cityCard(city: string, isSelected: boolean) {
    Row() {
      Text(isSelected ? "\u2B50" : "\uD83D\uDCCD").fontSize(16).margin({ right: 10 })
      Text(city).fontSize(16).fontWeight(isSelected ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(isSelected ? tcPrimary(this.isDark) : tcSecondary(this.isDark)).layoutWeight(1)
      if (isSelected) {
        Text("\u2714\uFE0F").fontSize(14).fontColor("#3B78C2").margin({ right: 8 })
      }
      // 删除按钮
      Text("\u2716").fontSize(15).fontColor("rgba(255,120,120,0.75)")
        .padding({ left: 10, right: 6, top: 6, bottom: 6 })
        .onClick((): void => { this.removeCity(city); })
    }.width("100%").padding(14).margin({ top: 6 })
      .backgroundColor(isSelected ? "rgba(59,120,194,0.18)" : cardSecondary(this.isDark))
      .backdropBlur(12)
      .border({
        width: isSelected ? 0.8 : 0.5,
        color: isSelected ? "rgba(59,120,194,0.5)" : cardBorderSub(this.isDark)
      })
      .borderRadius(18)
      .onClick((): void => { this.selectCityAndGo(city); })
  }

  pageTransition() {
    PageTransitionEnter({ type: RouteType.Push, duration: 400, curve: Curve.EaseInOut }).slide(SlideEffect.Right).opacity(1)
    PageTransitionExit({ type: RouteType.Push, duration: 300, curve: Curve.EaseInOut }).slide(SlideEffect.Left).opacity(0)
    PageTransitionEnter({ type: RouteType.Pop, duration: 350, curve: Curve.EaseInOut }).slide(SlideEffect.Left).opacity(1)
    PageTransitionExit({ type: RouteType.Pop, duration: 300, curve: Curve.EaseInOut }).slide(SlideEffect.Right).opacity(0)
  }
}







