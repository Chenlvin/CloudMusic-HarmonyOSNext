import Constants from "../../common/constants/Constants"

@Component
export struct BarLoading {
  build() {
    Row({ space: 5 }) {
      LoadingProgress()
        .width(Constants.SIZE_LOADING_PROGRESS_CARD)
        .aspectRatio(1)
      Text($r('app.string.Loading'))
        .fontSize(Constants.FONT_SIZE_COMMON)
        .fontColor(Color.Gray)
    }
    .padding({ left: 20 })
    .height(Constants.HEIGHT_TEXT_BUTTON)
    .justifyContent(FlexAlign.Center)
  }
}