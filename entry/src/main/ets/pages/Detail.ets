import router from '@ohos.router';
import { convertTempStr, tempUnitLabel } from '../model/TemperatureConverter';
import { bgGradient, cardAccent, cardSecondary, cardBorder, cardBorderSub, tcPrimary, tcSecondary, tcTertiary, tcMuted } from '../model/ThemeManager';
import prefManager from '../service/PreferenceManager';
import loadingManager from '../service/LoadingManager';
import { LoadingComponent } from '../components/LoadingComponent';

/**
 * Detail — 未来天气详情页
 * 展示单日最高/最低温度、降水概率、天气小贴士
 */
@Entry
@Component
struct Detail {
  @State date: string = '';
  @State dayOfWeek: string = '';
  @State weatherIcon: string = '\u2600\uFE0F';
  @State weatherDesc: string = '';
  @State maxTemp: string = '--';
  @State minTemp: string = '--';
  @State chanceOfRain: string = '';
  @State tempUnit: string = 'C';
  @State isDark: boolean = false;

  aboutToAppear(): void {
    // 读取路由参数
    let p = router.getParams() as Record<string, Object>;
    if (p !== null && p !== undefined) {
      this.date = String((p as Record<string, Object>).date ?? "");
      this.dayOfWeek = String((p as Record<string, Object>).dayOfWeek ?? "");
      this.weatherIcon = String((p as Record<string, Object>).weatherIcon ?? "\u2600\uFE0F");
      this.weatherDesc = String((p as Record<string, Object>).weatherDesc ?? "");
      this.maxTemp = String((p as Record<string, Object>).maxTemp ?? "--");
      this.minTemp = String((p as Record<string, Object>).minTemp ?? "--");
      this.chanceOfRain = String((p as Record<string, Object>).chanceOfRain ?? "");
    }
    this.loadThemeSettings();
  }

  onPageShow(): void {
    this.loadThemeSettings();
  }

  /** 加载设置（深色模式、温度单位） */
  loadThemeSettings(): void {
    loadingManager.show();
    try {
      let ctx: Context = this.getUIContext().getHostContext()!;
      prefManager.init(ctx).then((): void => {
        prefManager.getSettings().then((s): void => {
          this.tempUnit = s.tempUnit;
          this.isDark = s.darkMode === 'true';
          loadingManager.hide();
        }).catch((): void => { loadingManager.hide(); });
      }).catch((): void => { loadingManager.hide(); });
    } catch (_e) { loadingManager.hide(); }
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
        // 返回按钮
        Row() {
          Text('\u2190 ').fontSize(16).fontColor(tcSecondary(this.isDark))
            .onClick((): void => { this.getUIContext().getRouter().back(); })
          Text($r('app.string.back')).fontSize(16).fontColor(tcSecondary(this.isDark))
          Blank()
        }.width('100%').padding({ top: 28, left: 8 })

        Scroll() {
          Column() {
            // 主卡片
            Column() {
              Text(this.dayOfWeek).fontSize(18).fontColor(tcSecondary(this.isDark)).letterSpacing(2)
              Text(this.date).fontSize(14).fontColor(tcTertiary(this.isDark)).margin({ top: 4 })
              Text(this.weatherIcon).fontSize(72).margin({ top: 20 })
              Text(this.weatherDesc).fontSize(22).fontColor(tcPrimary(this.isDark))
                .letterSpacing(3).margin({ top: 10 })

              // 温度范围
              Row() {
                Text(convertTempStr(this.minTemp, this.tempUnit) + tempUnitLabel(this.tempUnit))
                  .fontSize(28).fontColor(tcTertiary(this.isDark))
                Text(' / ').fontSize(28).fontColor(tcMuted(this.isDark))
                Text(convertTempStr(this.maxTemp, this.tempUnit) + tempUnitLabel(this.tempUnit))
                  .fontSize(36).fontWeight(FontWeight.Bold).fontColor(tcPrimary(this.isDark))
              }.alignItems(VerticalAlign.Center).margin({ top: 16 })

              // 降水概率
              if (this.chanceOfRain.length > 0) {
                Row() {
                  Text('\uD83C\uDF27\uFE0F').fontSize(16)
                  Text(' ' + $r('app.string.precip_prob') + ' ' + this.chanceOfRain)
                    .fontSize(14).fontColor(tcTertiary(this.isDark))
                }.margin({ top: 16 })
              }

              // 昼夜温度双卡片
              if (this.minTemp !== '--') {
                Row() {
                  Column() {
                    Text('\uD83C\uDF21\uFE0F').fontSize(18)
                    Text($r('app.string.day_high')).fontSize(11)
                      .fontColor(tcTertiary(this.isDark)).margin({ top: 4 })
                    Text(convertTempStr(this.maxTemp, this.tempUnit) + tempUnitLabel(this.tempUnit))
                      .fontSize(16).fontWeight(FontWeight.Bold)
                      .fontColor(tcPrimary(this.isDark)).margin({ top: 2 })
                  }.alignItems(HorizontalAlign.Center).layoutWeight(1)

                  Column() {
                    Text('\uD83C\uDF19').fontSize(18)
                    Text($r('app.string.night_low')).fontSize(11)
                      .fontColor(tcTertiary(this.isDark)).margin({ top: 4 })
                    Text(convertTempStr(this.minTemp, this.tempUnit) + tempUnitLabel(this.tempUnit))
                      .fontSize(16).fontWeight(FontWeight.Bold)
                      .fontColor(tcPrimary(this.isDark)).margin({ top: 2 })
                  }.alignItems(HorizontalAlign.Center).layoutWeight(1)
                }
                .width('100%').padding(14).borderRadius(20).margin({ top: 16 })
                .backgroundColor(cardSecondary(this.isDark)).backdropBlur(18)
                .border({ width: 0.5, color: cardBorderSub(this.isDark) })
              }
            }
            .width('100%').padding(30).borderRadius(32).alignItems(HorizontalAlign.Center)
            .backgroundColor(cardAccent(this.isDark)).backdropBlur(24)
            .border({ width: 0.5, color: cardBorder(this.isDark) })

            // 天气小贴士
            Column() {
              Row() {
                Text('\uD83D\uDCA1').fontSize(16).margin({ right: 8 })
                Text($r('app.string.weather_tips_title')).fontSize(15).fontWeight(FontWeight.Bold)
                  .fontColor(tcSecondary(this.isDark))
              }.width('100%').margin({ bottom: 10 })
              Text(this.weatherTip()).fontSize(14).fontColor(tcTertiary(this.isDark)).width('100%')
            }
            .width('100%').padding(16).borderRadius(24).margin({ top: 16 })
            .backgroundColor(cardSecondary(this.isDark)).backdropBlur(18)
            .border({ width: 0.5, color: cardBorderSub(this.isDark) })

            Blank().height(40)
          }.width('100%').padding({ left: 20, right: 20 })
        }.scrollBar(BarState.Off).width('100%')
      }.width('100%').height('100%').padding(20)

      LoadingComponent()
    }.width('100%').height('100%')
  }

  /** 根据温度/天气生成小贴士 */
  weatherTip(): string {
    let max: number = Number(this.maxTemp);
    let min: number = Number(this.minTemp);
    if (!isNaN(max) && max >= 35) { return '当心中暑！请避开高温时段出门，多喝水。'; }
    if (!isNaN(min) && min <= 0) { return '水箱可能结冰，出行请注意路面滑。'; }
    if (this.weatherDesc.indexOf('雨') >= 0) { return '带上雨伞，注意防滑。'; }
    if (this.weatherDesc.indexOf('雾') >= 0) { return '能见度较低，驾车请开启雾灯。'; }
    if (this.weatherDesc.indexOf('雪') >= 0) { return '雪天路滑，出行请穿防滑鞋。'; }
    if (this.weatherDesc.indexOf('风') >= 0) { return '风力较大，请注意广告牌落下。'; }
    let diff: number = max - min;
    if (!isNaN(diff) && diff > 15) { return '日差较大，请适当增减衣物。'; }
    return '今天天气不错，适合户外活动！';
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
