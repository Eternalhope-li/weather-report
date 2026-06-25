import router from '@ohos.router';
import prefManager from '../service/PreferenceManager';
import { bgGradient, cardAccent, cardFrost, cardSecondary, cardBorderSub, tcPrimary, tcSecondary, tcTertiary } from '../model/ThemeManager';
import loadingManager from '../service/LoadingManager';
import { LoadingComponent } from '../components/LoadingComponent';

/**
 * Settings — 设置页面
 * 温度单位(C/F)、自动刷新间隔、深色模式、关于、清除缓存
 */
@Entry
@Component
struct Settings {
  @State tempUnit: string = 'C';
  @State refreshInterval: string = '30';
  @State darkMode: string = 'false';
  @State isDark: boolean = false;

  aboutToAppear(): void {
    this.loadThemeSettings();
  }

  onPageShow(): void {
    this.loadThemeSettings();
  }

  /** 从DB加载全部设置 */
  loadThemeSettings(): void {
    loadingManager.show();
    let ctx: Context = this.getUIContext().getHostContext()!;
    prefManager.init(ctx).then((): void => {
      prefManager.getSettings().then((s): void => {
        this.tempUnit = s.tempUnit;
        this.refreshInterval = s.refreshInterval;
        this.darkMode = s.darkMode;
        this.isDark = s.darkMode === 'true';
        loadingManager.hide();
      }).catch((): void => { loadingManager.hide(); });
    }).catch((): void => { loadingManager.hide(); });
  }

  build() {
    Stack() {
      // 渐变背景
      Column().width('100%').height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: bgGradient(this.isDark, '')
        })

      Column() {
        // 顶部标题
        Row() {
          Text('\u2190 ').fontSize(22).fontColor('rgba(255,255,255,0.8)')
            .onClick((): void => { this.getUIContext().getRouter().back(); })
          Text($r('app.string.settings')).fontSize(22).fontWeight(FontWeight.Bold)
            .fontColor(tcPrimary(this.isDark)).margin({ left: 8 })
          Blank()
        }.width('100%').height(56).padding({ left: 20, right: 20 })

        Scroll() {
          Column() {
            // ---- 温度单位 ----
            Row() {
              Text($r('app.string.temp_unit')).fontSize(16).fontColor(tcPrimary(this.isDark))
              Blank()
              Text('\u2103')
                .fontSize(26).fontWeight(this.tempUnit === 'C' ? FontWeight.Bold : FontWeight.Normal)
                .fontColor(this.tempUnit === 'C' ? tcPrimary(this.isDark) : tcTertiary(this.isDark))
                .width(56).height(44).textAlign(TextAlign.Center).lineHeight(44)
                .backgroundColor(this.tempUnit === 'C' ? 'rgba(123,164,253,0.4)' : cardFrost(this.isDark))
                .borderRadius(22).margin({ right: 6 })
                .animation({ duration: 250, curve: Curve.EaseOut })
                .onClick((): void => { this.tempUnit = 'C'; prefManager.saveTempUnit('C'); })
              Text('\u2109')
                .fontSize(26).fontWeight(this.tempUnit === 'F' ? FontWeight.Bold : FontWeight.Normal)
                .fontColor(this.tempUnit === 'F' ? tcPrimary(this.isDark) : tcTertiary(this.isDark))
                .width(56).height(44).textAlign(TextAlign.Center).lineHeight(44)
                .backgroundColor(this.tempUnit === 'F' ? 'rgba(123,164,253,0.4)' : cardFrost(this.isDark))
                .borderRadius(22).margin({ left: 6 })
                .animation({ duration: 250, curve: Curve.EaseOut })
                .onClick((): void => { this.tempUnit = 'F'; prefManager.saveTempUnit('F'); })
            }.width('100%').height(56).padding({ left: 20, right: 20 })
              .backgroundColor(cardSecondary(this.isDark)).borderRadius(20)
              .backdropBlur(18).border({ width: 0.5, color: cardBorderSub(this.isDark) })

            Blank().height(12)

            // ---- 自动刷新 ----
            Column() {
              Row() {
                Text($r('app.string.auto_refresh')).fontSize(16).fontColor(tcPrimary(this.isDark))
                Blank()
                Row() {
                  Text($r('app.string.every_minutes')).fontSize(14).fontColor('#7BA4FD')
                  Text(' ' + this.refreshInterval + ' ').fontSize(14).fontColor('#7BA4FD')
                  Text($r('app.string.minutes')).fontSize(14).fontColor('#7BA4FD')
                }
              }.width('100%').margin({ bottom: 16 })

              Row() {
                ForEach([15, 30, 60], (val: number): void => {
                  Row() {
                    Text(String(val)).fontSize(14)
                      .fontColor(Number(this.refreshInterval) === val ? tcPrimary(this.isDark) : tcTertiary(this.isDark))
                    Text($r('app.string.min_abbr')).fontSize(14)
                      .fontColor(Number(this.refreshInterval) === val ? tcPrimary(this.isDark) : tcTertiary(this.isDark))
                  }.padding({ top: 8, bottom: 8, left: 22, right: 22 })
                    .backgroundColor(Number(this.refreshInterval) === val
                      ? 'rgba(123,164,253,0.3)' : cardFrost(this.isDark))
                    .borderRadius(14).margin({ right: 10 })
                    .onClick((): void => {
                      this.refreshInterval = String(val);
                      prefManager.saveRefreshInterval(String(val));
                    })
                }, (val: number): string => String(val))
                Blank()
              }.width('100%')
            }.width('100%').padding(20)
              .backgroundColor(cardSecondary(this.isDark)).borderRadius(20)
              .backdropBlur(18).border({ width: 0.5, color: cardBorderSub(this.isDark) })

            Blank().height(12)

            // ---- 深色模式 ----
            Row() {
              Column() {
                Text($r('app.string.dark_mode')).fontSize(16).fontColor(tcPrimary(this.isDark))
              }.layoutWeight(1).alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.Center)
              Toggle({ type: ToggleType.Switch, isOn: this.darkMode === 'true' })
                .onChange((isOn: boolean): void => {
                  this.darkMode = isOn ? 'true' : 'false';
                  this.isDark = isOn;
                  prefManager.saveDarkMode(this.darkMode);
                })
            }.width('100%').height(56).padding({ left: 20, right: 20 })
              .backgroundColor(cardSecondary(this.isDark)).borderRadius(20)
              .backdropBlur(18).border({ width: 0.5, color: cardBorderSub(this.isDark) })

            Blank().height(12)

            // ---- 关于 ----
            Row() {
              Text($r('app.string.about')).fontSize(16).fontColor(tcPrimary(this.isDark))
              Blank()
              Text($r('app.string.app_name')).fontSize(14).fontColor(tcTertiary(this.isDark)).margin({ right: 4 })
              Text($r('app.string.version')).fontSize(14).fontColor(tcTertiary(this.isDark))
            }.width('100%').height(56).padding({ left: 20, right: 20 })
              .backgroundColor(cardSecondary(this.isDark)).borderRadius(20)
              .backdropBlur(18).border({ width: 0.5, color: cardBorderSub(this.isDark) })

            Blank().height(12)

            // ---- 清除缓存 ----
            Row() {
              Text($r('app.string.clear_cache')).fontSize(16).fontColor(tcPrimary(this.isDark))
              Blank()
              Text($r('app.string.click_to_clear'))
                .fontSize(14).fontColor('rgba(255,120,120,0.8)')
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .borderRadius(10).backgroundColor('rgba(255,100,100,0.1)')
                .onClick((): void => {
                  this.getUIContext().showAlertDialog({
                    title: $r('app.string.clear_cache_title'),
                    message: $r('app.string.clear_cache_msg'),
                    primaryButton: {
                      value: $r('app.string.cancel'),
                      action: (): void => {}
                    },
                    secondaryButton: {
                      value: $r('app.string.confirm_clear'),
                      fontColor: '#FF6464',
                      action: (): void => {
                        prefManager.init(this.getUIContext().getHostContext()!).then((): void => {
                          prefManager.clearAllCache();
                        });
                      }
                    }
                  });
                })
            }.width('100%').height(56).padding({ left: 20, right: 20 })
              .backgroundColor(cardSecondary(this.isDark)).borderRadius(20)
              .backdropBlur(18).border({ width: 0.5, color: cardBorderSub(this.isDark) })

          }.width('100%')
        }.scrollBar(BarState.Off).width('100%').layoutWeight(1)

      }.width('100%').height('100%')

      LoadingComponent()
    }.width('100%').height('100%')
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
