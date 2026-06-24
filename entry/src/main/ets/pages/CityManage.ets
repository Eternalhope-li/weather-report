import router from '@ohos.router';
import prefManager from '../service/PreferenceManager';
import { cleanCityName } from '../model/TemperatureConverter';
import { bgGradient, cardBg, cardFrost } from '../model/ThemeManager';
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

  aboutToAppear(): void {
    this.loadThemeSettings();
    let ctx: Context = this.getUIContext().getHostContext()!;
    prefManager.init(ctx).then((): void => {
      prefManager.getHistory().then((h: string[]): void => {
        this.cities = h;
      }).catch((): void => {});
      searchHistoryManager.init(ctx).then((): void => {
        searchHistoryManager.getHistory().then((items): void => {
          this.searchHistory = items.map((item): string => item.cityName);
        }).catch((): void => {});
      }).catch((): void => {});
    }).catch((): void => {});
  }

  onPageShow(): void {
    this.loadThemeSettings();
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

  build() {
    Stack() {
      Column().width('100%').height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: bgGradient(this.isDark, '')
        })

      Column() {
        Row() {
          Text('\u2190 ').fontSize(22).fontColor('rgba(255,255,255,0.8)')
            .onClick((): void => { this.getUIContext().getRouter().back(); })
          Text($r('app.string.city_manage')).fontSize(20).fontWeight(FontWeight.Bold).fontColor(Color.White).margin({ left: 8 })
          Blank()
        }.width('100%').padding({ top: 28, bottom: 12, left: 8, right: 8 })

        // Add city input
        Row() {
          TextInput({ placeholder: $r('app.string.input_city_hint') })
            .height(48).layoutWeight(1).backgroundColor('rgba(255,255,255,0.12)')
            .fontColor(Color.White).placeholderColor('rgba(255,255,255,0.4)')
            .borderRadius(16).padding({ left: 16 })
            .onChange((val: string): void => { this.newCity = val; })
          Button($r('app.string.add')).height(48).borderRadius(16).margin({ left: 8 })
            .backgroundColor('rgba(255,255,255,0.18)').fontColor(Color.White).fontWeight(FontWeight.Bold)
            .onClick((): void => {
              let q: string = cleanCityName(this.newCity.trim());
              if (q.length > 0) {
                prefManager.addToHistory(q).then((h: string[]): void => {
                  this.cities = h;
                  this.newCity = '';
                }).catch((): void => {});
              }
            })
        }.width('100%').margin({ top: 4 })

        // City list
        if (this.cities.length === 0) {
          Column() {
            Text($r('app.string.no_city')).fontSize(16).fontColor('rgba(255,255,255,0.3)').margin({ top: 60 })
          }.width('100%').alignItems(HorizontalAlign.Center)
        } else {
          Scroll() {
            Column() {
              ForEach(this.cities, (city: string): void => {
                Row() {
                  Text('\uD83D\uDCCD').fontSize(18).margin({ right: 12 })
                  Text(city).fontSize(17).fontColor(Color.White).layoutWeight(1)
                  Text('\u2716').fontSize(16).fontColor('rgba(255,100,100,0.85)')
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .onClick((): void => {
                      loadingManager.show();
                      prefManager.removeFromHistory(city).then((h: string[]): void => {
                        this.cities = h;
                        loadingManager.hide();
                      }).catch((): void => { loadingManager.hide(); });
                    })
                }.width('100%').padding(16).backgroundColor(cardFrost(this.isDark)).borderRadius(18)
                  .margin({ top: 6 })
                  .onClick((): void => {
                    this.getUIContext().getRouter().pushUrl({ url: 'pages/Index', params: { 'switchCity': cleanCityName(city) } }, router.RouterMode.Single);
                  })
              }, (city: string): string => city)
            }.width('100%')
          }.scrollBar(BarState.Off).width('100%').margin({ top: 8 })
        }

        // 搜索历史
        if (this.searchHistory.length > 0) {
          Column() {
            Row() {
              Text('\uD83D\uDD50 ' + $r('app.string.search_history')).fontSize(14).fontColor('rgba(255,255,255,0.4)').margin({ bottom: 8 })
              Blank()
              Text($r('app.string.clear_all')).fontSize(13).fontColor('rgba(255,150,150,0.7)')
                .onClick((): void => {
                  loadingManager.show();
                  searchHistoryManager.clearAll().then((): void => {
                    this.searchHistory = [];
                    loadingManager.hide();
                  }).catch((): void => { loadingManager.hide(); });
                })
            }.width('100%')
            ForEach(this.searchHistory, (city: string): void => {
              Row() {
                Text('\uD83D\uDCCD').fontSize(14).margin({ right: 10 })
                Text(city).fontSize(15).fontColor(Color.White).layoutWeight(1)
                Text('\u2716').fontSize(14).fontColor('rgba(255,255,255,0.3)').padding({ left: 8, right: 8 })
                  .onClick((): void => {
                    loadingManager.show();
                    searchHistoryManager.deleteHistory(city).then((): void => {
                      searchHistoryManager.getHistory().then((items): void => {
                        this.searchHistory = items.map((item): string => item.cityName);
                        loadingManager.hide();
                      }).catch((): void => { loadingManager.hide(); });
                    }).catch((): void => { loadingManager.hide(); });
                  })
              }.width('100%').padding({ top: 8, bottom: 8 }).borderRadius(12).backgroundColor(cardBg(this.isDark)).margin({ bottom: 4 })
                .onClick((): void => {
                  this.getUIContext().getRouter().pushUrl({ url: 'pages/Index', params: { 'switchCity': cleanCityName(city) } }, router.RouterMode.Single);
                })
            }, (city: string): string => city)
          }.width('100%').padding({ top: 16 }).margin({ bottom: 8 })
        }
      }.width('100%').height('100%').padding(20)

      LoadingComponent()
    }.width('100%').height('100%')
  }

  pageTransition() {
    PageTransitionEnter({ type: RouteType.Push, duration: 350, curve: Curve.EaseOut }).slide(SlideEffect.Right);
    PageTransitionExit({ type: RouteType.Push, duration: 300, curve: Curve.EaseIn }).slide(SlideEffect.Left);
    PageTransitionEnter({ type: RouteType.Pop, duration: 350, curve: Curve.EaseOut }).slide(SlideEffect.Left);
    PageTransitionExit({ type: RouteType.Pop, duration: 300, curve: Curve.EaseIn }).slide(SlideEffect.Right);
  }
}

