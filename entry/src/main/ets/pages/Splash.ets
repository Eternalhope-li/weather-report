// ============================================================
// Splash — 启动画面
// 深空渐变 + 序列渐入动画 + 加载指示
// ============================================================

@Entry
@Component
struct Splash {
  @State opacityVal: number = 0;
  @State iconScale: number = 0.5;
  @State titleOpacity: number = 0;
  @State subOpacity: number = 0;
  @State loadOpacity: number = 0;
  private navTimer: number = -1;

  aboutToAppear(): void {
    // 序列动画：图标 → 标题 → 副标题 → 加载
    setTimeout((): void => { this.opacityVal = 1; this.iconScale = 1; }, 100);
    setTimeout((): void => { this.titleOpacity = 1; }, 500);
    setTimeout((): void => { this.subOpacity = 1; }, 900);
    setTimeout((): void => { this.loadOpacity = 1; }, 1300);

    this.navTimer = setTimeout((): void => {
      this.getUIContext().getRouter().pushUrl({ url: "pages/Index" });
    }, 3200);
  }

  aboutToDisappear(): void {
    if (this.navTimer > 0) {
      clearTimeout(this.navTimer);
      this.navTimer = -1;
    }
  }

  build() {
    Stack() {
      // 底层深空渐变
      Column().width("100%").height("100%")
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            ["#080B1A", 0],
            ["#0C1028", 0.3],
            ["#121838", 0.6],
            ["#182248", 1]
          ]
        })

      // 装饰光晕（左上暖色）
      Column().width(160).height(160).borderRadius(80)
        .backgroundColor("rgba(90,150,240,0.04)")
        .position({ x: -30, y: -30 }).blur(40)

      // 装饰光晕（右下冷色）
      Column().width(200).height(200).borderRadius(100)
        .backgroundColor("rgba(60,120,200,0.03)")
        .position({ x: "55%", y: "65%" }).blur(50)

      // 主内容区
      Column() {
        // 天气图标
        Text("\u2600\uFE0F")
          .fontSize(80)
          .scale({ x: this.iconScale, y: this.iconScale })
          .animation({ duration: 900, curve: Curve.Friction })

        // 应用名称
        Text($r("app.string.app_name"))
          .fontSize(28).fontWeight(FontWeight.Bold)
          .fontColor(Color.White).letterSpacing(8)
          .margin({ top: 24 })
          .opacity(this.titleOpacity)
          .animation({ duration: 600, curve: Curve.EaseOut })

        // 副标题
        Text($r("app.string.app_subtitle"))
          .fontSize(15)
          .fontColor("rgba(255,255,255,0.5)")
          .letterSpacing(6).margin({ top: 12 })
          .opacity(this.subOpacity)
          .animation({ duration: 600, curve: Curve.EaseOut })
      }
      .width("100%").alignItems(HorizontalAlign.Center)
      .opacity(this.opacityVal)
      .animation({ duration: 500, curve: Curve.EaseOut })

      // 底部加载提示
      Row() {
        LoadingProgress().width(14).height(14).color("rgba(255,255,255,0.3)")
        Text($r("app.string.loading_text"))
          .fontSize(13).fontColor("rgba(255,255,255,0.25)")
          .margin({ left: 8 }).letterSpacing(3)
      }
      .position({ x: "50%", y: "90%" }).alignSelf(ItemAlign.Center)
      .opacity(this.loadOpacity)
      .animation({ duration: 500, curve: Curve.EaseOut })
    }
    .width("100%").height("100%")
  }

  pageTransition() {
    PageTransitionEnter({ type: RouteType.Pop, duration: 400, curve: Curve.EaseOut }).opacity(1)
    PageTransitionExit({ type: RouteType.Push, duration: 350, curve: Curve.EaseIn }).opacity(0)
  }
}