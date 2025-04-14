import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { LyricTranslate, SetFloatLyric, SetLyricStyle } from "../../components/settings/LyricSettings"
import { MixWithOthers } from "../../components/settings/MixWithOthers"
import { SetPlayQuality } from "../../components/settings/SetPlayQuality"

@Component
export struct PlaySettingsPage {
  @StorageProp(StorageConstants.BOTTOM_RECT_HEIGHT) bottomRectHeight: number = 0
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

        ListItem() {
          SetFloatLyric()
        }
        .itemStyle()

        ListItem().padding({ bottom: px2vp(this.bottomRectHeight) + 30 })

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