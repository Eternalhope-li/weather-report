import router from '@ohos.router';
import { convertTempStr, tempUnitLabel } from '../model/TemperatureConverter';
import { bgGradient, cardBg, cardBgStrong, cardFrost } from '../model/ThemeManager';
import prefManager from '../service/PreferenceManager';

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

  loadThemeSettings(): void {
    try {
      let ctx: Context = this.getUIContext().getHostContext()!;
      prefManager.init(ctx).then((): void => {
        prefManager.getSettings().then((s): void => {
          this.tempUnit = s.tempUnit;
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
        // Back button
        Row() {
          Text('\u2190 ').fontSize(16).fontColor('rgba(255,255,255,0.7)')
            .onClick((): void => { this.getUIContext().getRouter().back(); })
          Text($r('app.string.back')).fontSize(16).fontColor('rgba(255,255,255,0.7)')
          Blank()
        }.width('100%').padding({ top: 28, left: 8 })

        Scroll() {
          Column() {
            // Main card
            Column() {
              Text(this.dayOfWeek).fontSize(18).fontColor('rgba(255,255,255,0.6)').letterSpacing(2)
              Text(this.date).fontSize(14).fontColor('rgba(255,255,255,0.35)').margin({ top: 4 })

              Text(this.weatherIcon).fontSize(72).margin({ top: 20 })

              Text(this.weatherDesc).fontSize(22).fontColor(Color.White)
                .letterSpacing(3).margin({ top: 10 })

              // Temp range
              Row() {
                Text(convertTempStr(this.minTemp, this.tempUnit) + tempUnitLabel(this.tempUnit)).fontSize(28).fontColor('rgba(255,255,255,0.5)')
                Text(' / ').fontSize(28).fontColor('rgba(255,255,255,0.2)')
                Text(convertTempStr(this.maxTemp, this.tempUnit) + tempUnitLabel(this.tempUnit)).fontSize(36).fontWeight(FontWeight.Bold).fontColor(Color.White)
              }.alignItems(VerticalAlign.Center).margin({ top: 16 })

              if (this.chanceOfRain.length > 0) {
                Row() {
                  Text('\uD83C\uDF27\uFE0F').fontSize(16)
                  Text(' ' + $r('app.string.precip_prob') + ' ' + this.chanceOfRain)
                    .fontSize(14).fontColor('rgba(255,255,255,0.5)')
                }.margin({ top: 16 })
              } else if (this.minTemp !== '--' && this.maxTemp !== '--') {
                Text('\u6E29\u5EA6\u8303\u56F4 ' + convertTempStr(this.minTemp, this.tempUnit) + tempUnitLabel(this.tempUnit) + ' ~ ' + convertTempStr(this.maxTemp, this.tempUnit) + tempUnitLabel(this.tempUnit))
                  .fontSize(14).fontColor('rgba(255,255,255,0.4)').margin({ top: 16 })
              }

              if (this.minTemp !== '--') {
                Row() {
                  Column() {
                    Text('\uD83C\uDF21\uFE0F').fontSize(18)
                    Text($r('app.string.day_high')).fontSize(11).fontColor('rgba(255,255,255,0.4)').margin({ top: 4 })
                    Text(convertTempStr(this.maxTemp, this.tempUnit) + tempUnitLabel(this.tempUnit)).fontSize(16).fontWeight(FontWeight.Bold).fontColor(Color.White).margin({ top: 2 })
                  }.alignItems(HorizontalAlign.Center).layoutWeight(1)

                  Column() {
                    Text('\uD83C\uDF19').fontSize(18)
                    Text($r('app.string.night_low')).fontSize(11).fontColor('rgba(255,255,255,0.4)').margin({ top: 4 })
                    Text(convertTempStr(this.minTemp, this.tempUnit) + tempUnitLabel(this.tempUnit)).fontSize(16).fontWeight(FontWeight.Bold).fontColor(Color.White).margin({ top: 2 })
                  }.alignItems(HorizontalAlign.Center).layoutWeight(1)
                }.width('100%').padding(14).borderRadius(20)
                  .backgroundColor(cardFrost(this.isDark)).margin({ top: 16 })
              }
            }.width('100%').padding(30).borderRadius(32)
              .backgroundColor(cardBgStrong(this.isDark)).alignItems(HorizontalAlign.Center)

            // Extra tips card
            Column() {
              Row() {
                Text('\uD83D\uDCA1').fontSize(16).margin({ right: 8 })
                Text($r('app.string.weather_tips_title')).fontSize(15).fontWeight(FontWeight.Bold)
                  .fontColor('rgba(255,255,255,0.7)')
              }.width('100%').margin({ bottom: 10 })
              Text(this.weatherTip()).fontSize(14).fontColor('rgba(255,255,255,0.5)').width('100%')
            }.width('100%').padding(16).borderRadius(24).margin({ top: 16 })
              .backgroundColor(cardFrost(this.isDark))

            Blank().height(40)
          }.width('100%').padding({ left: 20, right: 20 })
        }.scrollBar(BarState.Off).width('100%')
      }.width('100%').height('100%').padding(20)

    }.width('100%').height('100%')
  }

  weatherTip(): string {
    let max: number = Number(this.maxTemp);
    let min: number = Number(this.minTemp);
    if (!isNaN(max) && max >= 35) { return '\u5F53\u5FC3\u4E2D\u6691\uFF01\u8BF7\u907F\u5F00\u9AD8\u6E29\u65F6\u6BB5\u51FA\u95E8\uFF0C\u591A\u996E\u6C34\u3002'; }
    if (!isNaN(min) && min <= 0) { return '\u6C34\u7BB1\u53EF\u80FD\u7ED3\u51B0\uFF0C\u51FA\u884C\u8BF7\u6CE8\u610F\u8DEF\u9762\u6ED1\u3002'; }
    if (this.weatherDesc.indexOf('\u96E8') >= 0) { return '\u5E26\u4E0A\u96E8\u4F1E\uFF0C\u6CE8\u610F\u9632\u6ED1\u3002'; }
    if (this.weatherDesc.indexOf('\u96FE') >= 0) { return '\u80FD\u89C1\u5EA6\u8F83\u4F4E\uFF0C\u9A7E\u8F66\u8BF7\u5F00\u542F\u96FE\u706F\u3002'; }
    if (this.weatherDesc.indexOf('\u96EA') >= 0) { return '\u96EA\u5929\u8DEF\u6ED1\uFF0C\u51FA\u884C\u8BF7\u7A7F\u9632\u6ED1\u978B\u3002'; }
    if (this.weatherDesc.indexOf('\u98CE') >= 0) { return '\u98CE\u529B\u8F83\u5927\uFF0C\u8BF7\u6CE8\u610F\u5E7F\u544A\u724C\u843D\u4E0B\u3002'; }
    let diff: number = max - min;
    if (!isNaN(diff) && diff > 15) { return '\u65E5\u5DEE\u8F83\u5927\uFF0C\u8BF7\u9002\u5F53\u589E\u51CF\u8863\u7269\u3002'; }
    return '\u4ECA\u5929\u5929\u6C14\u4E0D\u9519\uFF0C\u9002\u5408\u6237\u5916\u6D3B\u52A8\uFF01';
  }

  pageTransition() {
    PageTransitionEnter({ type: RouteType.Push, duration: 350, curve: Curve.EaseOut })
      .slide(SlideEffect.Right)
    PageTransitionExit({ type: RouteType.Push, duration: 300, curve: Curve.EaseIn })
      .slide(SlideEffect.Left)
    PageTransitionEnter({ type: RouteType.Pop, duration: 350, curve: Curve.EaseOut })
      .slide(SlideEffect.Left)
    PageTransitionExit({ type: RouteType.Pop, duration: 300, curve: Curve.EaseIn })
      .slide(SlideEffect.Right)
  }
}


