import router from '@ohos.router';
import prefManager from '../service/PreferenceManager';
import { cleanCityName } from '../model/TemperatureConverter';
import { bgGradient, cardBg, cardAccent, cardSecondary, cardBorder, cardBorderSub, tcPrimary, tcSecondary, tcTertiary, tcMuted, cardMain } from '../model/ThemeManager';
import searchHistoryManager from '../service/SearchHistoryManager';
import loadingManager from '../service/LoadingManager';
import { LoadingComponent } from '../components/LoadingComponent';

@Entry
@Component
struct CityManage {
  @State cities: string[] = [];
  @State searchHistory: string[] = [];
  @State newCity: string = '';
  @State isDark: boolean = false;
  @State selectedCity: string = '';
  

  aboutToAppear(): void {
    this.loadThemeSettings();
    this.loadCityData();
  }

  onPageShow(): void {
    this.loadThemeSettings();
    this.loadCityData();
    try { focusControl.requestFocus('searchInput'); } catch (_e) {}
  }

  loadCityData(): void {
    let ctx: Context = this.getUIContext().getHostContext()!;
    prefManager.init(ctx).then((): void => {
      prefManager.getHistory().then((h: string[]): void => {
        this.cities = h;
      }).catch((): void => {});
      prefManager.getLastCity().then((c: string): void => {
        this.selectedCity = c;
      }).catch((): void => {});
    }).catch((): void => {});

    searchHistoryManager.init(ctx).then((): void => {
      searchHistoryManager.getHistory().then((items): void => {
        this.searchHistory = items.map((item): string => item.cityName);
      }).catch((): void => {});
    }).catch((): void => {});
  }

  loadThemeSettings(): void {
    try {
      let ctx: Context = this.getUIContext().getHostContext()!;
      prefManager.init(ctx).then((): void => {
        prefManager.getSettings().then((s): void => {
          this.isDark = s.darkMode === 'true';
        }).catch((): void => {});
      }).catch((): void => {});
    } catch (_e) {}
  }

  selectCityAndGo(city: string): void {
    let q: string = cleanCityName(city);
    if (q.length === 0) { return; }
    this.selectedCity = q;
    AppStorage.set<string>('globalCurrentCity', q);
    // 异步保存城市，不等待完成就返回
    prefManager.saveLastCity(q);
    this.getUIContext().getRouter().back();
  }

  build() {
    Stack() {
      // 天气渐变背景
      Column().width('100%').height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: bgGradient(this.isDark, '')
        })

      Column() {
        // 顶部标题栏
        Row() {
          Text('← ').fontSize(22).fontColor('rgba(255,255,255,0.8)')
            .onClick((): void => { this.getUIContext().getRouter().back(); })
          Text($r('app.string.city_manage')).fontSize(20).fontWeight(FontWeight.Bold).fontColor(tcPrimary(this.isDark)).margin({ left: 8 })
          Blank()
        }.width('100%').padding({ top: 28, bottom: 12, left: 8, right: 8 })

        // 搜索输入框（自动聚焦）
        Row() {
          TextInput({ placeholder: $r('app.string.input_city_hint') }).id('searchInput').focusable(true).id('searchInput').focusable(true)
            .height(48).layoutWeight(1)
            .backgroundColor(cardMain(this.isDark)).backdropBlur(18)
            .border({ width: 0.5, color: cardBorderSub(this.isDark) })
            .fontColor(tcPrimary(this.isDark)).placeholderColor(tcTertiary(this.isDark))
            .borderRadius(16).padding({ left: 16 })
            
            .onChange((val: string): void => { this.newCity = val; })
            .onSubmit((): void => {
              let q: string = cleanCityName(this.newCity.trim());
              if (q.length > 0) {
                loadingManager.show();
                prefManager.addToHistory(q).then((h: string[]): void => {
                  this.cities = h;
                  this.newCity = '';
                  loadingManager.hide();
                }).catch((): void => { loadingManager.hide(); });
              }
            })
          Button($r('app.string.add')).height(48).borderRadius(16).margin({ left: 8 })
            .backgroundColor(cardAccent(this.isDark)).fontColor(tcPrimary(this.isDark)).fontWeight(FontWeight.Bold)
            .onClick((): void => {
              let q: string = cleanCityName(this.newCity.trim());
              if (q.length > 0) {
                loadingManager.show();
                prefManager.addToHistory(q).then((h: string[]): void => {
                  this.cities = h;
                  this.newCity = '';
                  loadingManager.hide();
                }).catch((): void => { loadingManager.hide(); });
              }
            })
        }.width('100%').margin({ top: 4 })

        // 主滚动区域
        Scroll() {
          Column() {
            // ---- 历史城市列表 ----
            if (this.cities.length > 0) {
              Column() {
                Row() {
                  Text('📍').fontSize(14).fontColor(tcTertiary(this.isDark))
                  Text(' ' + $r('app.string.search_history')).fontSize(14).fontColor(tcTertiary(this.isDark)).margin({ left: 2 })
                  Blank()
                }.width('100%').margin({ bottom: 8, top: 12 })

                ForEach(this.cities, (city: string): void => {
                  this.cityCard(city, city === this.selectedCity)
                }, (city: string): string => city)
              }.width('100%')
            }

            // ---- 搜索历史（去重后） ----
            if (this.searchHistory.length > 0) {
              Column() {
                Row() {
                  Text('🕐').fontSize(14).fontColor(tcTertiary(this.isDark))
                  Text(' ' + $r('app.string.search_history')).fontSize(14).fontColor(tcTertiary(this.isDark)).margin({ left: 2 })
                  Blank()
                }.width('100%').margin({ bottom: 8, top: 16 })

                ForEach(this.searchHistory, (city: string): void => {
                  if (this.cities.indexOf(city) < 0) {
                    this.cityCard(city, city === this.selectedCity)
                  }
                }, (city: string): string => city)
              }.width('100%')
            }

            // 空状态
            if (this.cities.length === 0 && this.searchHistory.length === 0) {
              Column() {
                Text('🏔️').fontSize(48).margin({ top: 40 })
                Text($r('app.string.no_city')).fontSize(16).fontColor(tcTertiary(this.isDark)).margin({ top: 12 })
              }.width('100%').alignItems(HorizontalAlign.Center).margin({ top: 40 })
            }

            Blank().height(40)
          }.width('100%')
        }.scrollBar(BarState.Off).width('100%').margin({ top: 8 }).edgeEffect(EdgeEffect.Spring)

      }.width('100%').height('100%').padding(20)

      LoadingComponent()
    }.width('100%').height('100%')
  }

  @Builder cityCard(city: string, isSelected: boolean) {
    Row() {
      Text(isSelected ? '⭐' : '📍').fontSize(16).margin({ right: 10 })
      Text(city).fontSize(16).fontWeight(isSelected ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(isSelected ? tcPrimary(this.isDark) : tcSecondary(this.isDark)).layoutWeight(1)
      if (isSelected) {
        Text('✔️').fontSize(14).fontColor('#7BA4FD').margin({ right: 8 })
      }
      Text('✖').fontSize(15).fontColor('rgba(255,120,120,0.75)')
        .padding({ left: 10, right: 6, top: 6, bottom: 6 })
        .onClick((): void => {
          loadingManager.show();
          prefManager.removeFromHistory(city).then((h: string[]): void => {
            this.cities = h;
            loadingManager.hide();
          }).catch((): void => { loadingManager.hide(); });
        })
    }.width('100%').padding(14).margin({ top: 6 })
      .backgroundColor(isSelected ? cardAccent(this.isDark) : cardSecondary(this.isDark))
      .backdropBlur(18)
      .border({ width: isSelected ? 0.8 : 0.5, color: isSelected ? 'rgba(123,164,253,0.5)' : cardBorderSub(this.isDark) })
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
