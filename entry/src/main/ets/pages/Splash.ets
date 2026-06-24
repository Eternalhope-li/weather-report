import router from '@ohos.router';

@Entry
@Component
struct Splash {
  @State opacityVal: number = 0;
  @State iconScale: number = 0.6;
  private navTimer: number = -1;

  aboutToAppear(): void {
    setTimeout((): void => { this.opacityVal = 1; this.iconScale = 1; }, 200);

    this.navTimer = setTimeout((): void => {
      this.getUIContext().getRouter().pushUrl({ url: 'pages/Index' });
    }, 2800);
  }

  aboutToDisappear(): void {
    if (this.navTimer > 0) {
      clearTimeout(this.navTimer);
      this.navTimer = -1;
    }
  }

  build() {
    Stack() {
      Column().width('100%').height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#0A0D1E', 0], ['#0E1330', 0.3], ['#121A40', 0.6], ['#182250', 1]]
        })

      Column() {
        Text('\u2600\uFE0F').fontSize(80)
          .scale({ x: this.iconScale, y: this.iconScale })
          .animation({ duration: 800, curve: Curve.Friction })
        Text($r('app.string.app_name')).fontSize(28).fontWeight(FontWeight.Bold)
          .fontColor(Color.White).letterSpacing(6).margin({ top: 20 })
        Text($r('app.string.app_subtitle'))
          .fontSize(14).fontColor('rgba(255,255,255,0.5)')
          .letterSpacing(4).margin({ top: 10 })
      }.width('100%').alignItems(HorizontalAlign.Center).opacity(this.opacityVal)
        .animation({ duration: 600, curve: Curve.EaseOut })

      Text($r('app.string.loading_text')).fontSize(13).fontColor('rgba(255,255,255,0.3)')
        .position({ x: '50%', y: '90%' }).alignSelf(ItemAlign.Center)
    }.width('100%').height('100%')
  }

  pageTransition() {
    PageTransitionEnter({ type: RouteType.Pop, duration: 300, curve: Curve.EaseOut })
      .opacity(1)
    PageTransitionExit({ type: RouteType.Push, duration: 250, curve: Curve.EaseIn })
      .opacity(0)
  }
}

