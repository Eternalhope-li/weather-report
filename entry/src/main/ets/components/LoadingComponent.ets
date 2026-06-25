/**
 * 全局Loading加载组件
 * 全屏磨砂遮罩 + 居中加载动画
 * 日夜通用配色，仅加载时显示
 */
@Component
export struct LoadingComponent {
  @StorageProp('globalLoading') isVisible: boolean = false;

  build() {
    if (this.isVisible) {
      Stack() {
        // 磨砂遮罩
        Column()
          .width('100%').height('100%')
          .backgroundColor('rgba(0,0,0,0.22)')
          .backdropBlur(6)

        // 加载卡片
        Column() {
          LoadingProgress()
            .width(36).height(36)
            .color('rgba(255,255,255,0.9)')

          Text("加载中...")
            .fontSize(14)
            .fontColor('rgba(255,255,255,0.6)')
            .margin({ top: 18 })
            .letterSpacing(4)
        }
        .padding(36)
        .borderRadius(28)
        .backgroundColor('rgba(0,0,0,0.35)')
        .backdropBlur(4)
      }
      .width('100%').height('100%')
      .hitTestBehavior(HitTestMode.Block)
      
    }
  }
}

