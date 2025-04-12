import Constants from "../../common/constants/Constants"

@Component
export struct PlayAllButton {
  @Prop count: number = -1
  clickAction: () => void = () => {}
  build() {
    Button() {
      Row({ space: 5 }) {
        Image($r('app.media.ic_play_fill')).width(Constants.FONT_SIZE_COMMON)
          .fillColor(Color.Gray)
        Row({ space: 5 }) {
          Text() {
            Span(`播放全部`)
            Span(` (${this.count})`).visibility(this.count === -1 ? Visibility.None : Visibility.Visible)
          }
            .fontSize(Constants.FONT_SIZE_COMMON)
        }
      }
      .padding({ left: 20, right: 20 })
    }
    .height(Constants.HEIGHT_TEXT_BUTTON)
    .backgroundColor(Color.Transparent)
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
    .onClick(this.clickAction)
  }
}