import { ToastUtil } from "@pura/harmony-utils"
import { AppConstants } from "../../common/constants/AppConstants"
import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { CommonSettingsCard } from "../../components/cards/SettingsCard"
import { LyricTranslate, SetLyricStyle } from "../../components/settings/LyricSettings"
import { MixWithOthers } from "../../components/settings/MixWithOthers"
import { SetPlayQuality } from "../../components/settings/SetPlayQuality"

@Component
export struct PlaySettingsPage {
  @StorageProp(StorageConstants.BOTTOM_RECT_HEIGHT) bottomRectHeight: number = 0
  @Consume('settingsPageInfos') settingsPageInfos: NavPathStack

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
          this.FloatLyric()
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

        ListItem().padding({ bottom: px2vp(this.bottomRectHeight) + 30 })

      }
      .scrollBar(BarState.Off)
      .padding({ top: Constants.PADDING_EDGE_DEFAULT, left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
      .height('100%')
      .width('100%')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .title($r('app.string.SET_PLAYANDLYRIC'))
    .backgroundColor($r('app.color.background'))
  }

  @Builder FloatLyric() {
    CommonSettingsCard({
      title: '浮动歌词设置',
      action: () => {
        if(AppConstants.AG_VERSION) {
          ToastUtil.showToast('当前应用版本不支持该功能')
        } else {
          this.settingsPageInfos.pushPathByName('FloatLyricPage', null)
        }
      }
    })
  }

  @Styles itemStyle() {
    .backgroundColor($r('app.color.main'))
    .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT, top: 5, bottom: 5 })
    .margin({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
    .borderRadius(Constants.RADIUS_CARD)
  }
}