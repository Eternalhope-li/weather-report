/**
 * 全局Loading加载组件
 * 全屏半透明遮罩 + 居中旋转加载图标
 */
@Component
export struct LoadingComponent {
  @StorageProp('globalLoading') isVisible: boolean = false;

  build() {
    if (this.isVisible) {
      Stack() {
        Column()
          .width('100%').height('100%')
          .backgroundColor('rgba(0,0,0,0.35)')

        Column() {
          LoadingProgress()
            .width(40).height(40)
            .color('rgba(123,164,253,0.9)')
          Text($r('app.string.loading_text'))
            .fontSize(13)
            .fontColor('rgba(255,255,255,0.5)')
            .margin({ top: 14 })
            .letterSpacing(3)
        }
        .padding(40)
        .borderRadius(28)
        .backgroundColor('rgba(255,255,255,0.06)')
      }
      .width('100%').height('100%')
      .hitTestBehavior(HitTestMode.Block)
      .transition({ type: TransitionType.Insert, opacity: 0 })
    }
  }
}
