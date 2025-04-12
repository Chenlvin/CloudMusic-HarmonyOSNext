import Constants from "../../common/constants/Constants"
import { LyricTranslate, SetLyricStyle } from "../../components/settings/LyricSettings"
import { MixWithOthers } from "../../components/settings/MixWithOthers"
import { SetPlayQuality } from "../../components/settings/SetPlayQuality"

@Component
export struct PlaySettingsPage {
  build() {
    NavDestination() {
      List({ space: 10 }) {
        ListItem() {
          SetPlayQuality()
            .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
        }
        .itemStyle()

        ListItem() {
          MixWithOthers()
            .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
        }
        .itemStyle()

        ListItem() {
          LyricTranslate()
            .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
        }
        .itemStyle()

        ListItem() {
          SetLyricStyle()
        }
        .itemStyle()
      }
      .scrollBar(BarState.Off)
      .padding(Constants.PADDING_EDGE_DEFAULT)
      .height('100%')
      .width('100%')
    }
    .title($r('app.string.SET_PLAYANDLYRIC'))
    .backgroundColor($r('app.color.background'))
  }

  @Styles itemStyle() {
    .backgroundColor($r('app.color.main'))
    .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT, top: 5, bottom: 5 })
    .margin({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
    .borderRadius(Constants.RADIUS_CARD)
  }
}