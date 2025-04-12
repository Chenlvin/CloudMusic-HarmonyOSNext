import Constants from "../../common/constants/Constants"

const cardWidth: number = 160
const cardHeight: number = 80

@Component
export struct IndexCard {
  imgUrl: string | ResourceStr = ''
  title: string | ResourceStr = ''
  desc: string | ResourceStr = ''
  wid: number = Constants.SIZE_ICON_BUTTON_COMMON
  clickAction: () => void = () => {}

  build() {
    Row({ space: Constants.PADDING_EDGE_DEFAULT }) {
      Image(this.imgUrl)
        .fitOriginalSize(true)
        .width(this.wid)
        .backgroundColor(Color.Transparent)
        .fillColor($r('app.color.app_red'))
      Column({ space: 5 }) {
        Text(this.title)
          .fontColor($r('app.color.reverse'))
          .fontSize(Constants.FONT_SIZE_TITLE)
          .fontWeight(Constants.FONT_WEIGHT_BOLD)
          .textAlign(TextAlign.Center)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.desc)
          .fontColor(Color.Gray)
          .maxFontSize(12)
          .minFontSize(8)
          .textAlign(TextAlign.Center)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .visibility(this.desc ? Visibility.Visible : Visibility.None)
      }
      .constraintSize({
        minWidth: 0,
        maxWidth: cardWidth - this.wid - Constants.PADDING_EDGE_DEFAULT * 2
      })
    }
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.main'))
    .width(cardWidth)
    .height(cardHeight)
    .borderRadius(Constants.RADIUS_CARD)
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
    .onClick(this.clickAction)
    .padding({
      left: Constants.PADDING_EDGE_DEFAULT,
      right: Constants.PADDING_EDGE_DEFAULT,
      top: 5,
      bottom: 5
    })
  }
}