import { ToastUtil } from "@pura/harmony-utils"
import { AppConstants } from "../../common/constants/AppConstants"
import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { PlaySettingsPageMap } from "../../common/model/PageMap"
import { CommonSettingsCard } from "../../components/cards/SettingsCard"
import { LyricTranslate, SetLyricStyle } from "../../components/settings/LyricSettings"
import { MixWithOthers } from "../../components/settings/MixWithOthers"
import { SetPlayQuality } from "../../components/settings/SetPlayQuality"

@Component
export struct PlaySettingsPage {
  @Consume('settingsPageInfos') settingsPageInfos: NavPathStack

  build() {
    NavDestination() {
      PlaySettings(() => {
        this.settingsPageInfos.pushPathByName('FloatLyricPage', null)
      })
    }
    .title($r('app.string.SET_PLAYANDLYRIC'))
    .backgroundColor($r('app.color.background'))
  }
}

@Component
export struct PlaySettingSinglePage {
  @Provide('playSettingsPageInfos') playSettingsPageInfos: NavPathStack = new NavPathStack()
  @StorageLink(StorageConstants.IS_PLAYER_SHOW) isPlayerShow: boolean = false
  private flag: number = 0
  aboutToAppear(): void {
    if(this.isPlayerShow) {
      this.isPlayerShow = false
      this.flag = 1
    }
  }

  aboutToDisappear(): void {
    if(this.flag) this.isPlayerShow = true
  }

  build() {
    Navigation(this.playSettingsPageInfos) {
      Column() {
        Text($r('app.string.SET_PLAYANDLYRIC'))
          .width('100%')
          .textAlign(TextAlign.Start)
          .fontSize(Constants.FONT_SIZE_TITLE)
          .fontWeight(Constants.FONT_WEIGHT_BOLD)
          .padding({ left: Constants.PADDING_EDGE_TEXT })
          .height(56)
        PlaySettings(() => {
          this.playSettingsPageInfos.pushPathByName('FloatLyricPage', null)
        })
      }
    }
    .backgroundColor($r('app.color.background'))
    .hideTitleBar(true)
    .navDestination(PlaySettingsPageMap)
    .hideBackButton(true)
  }
}

@Builder
function PlaySettings(floatLyricAction: () => void) {
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
      CommonSettingsCard({
        title: '浮动歌词设置',
        action: () => {
          if(AppConstants.AG_VERSION) {
            ToastUtil.showToast('当前版本不支持该功能')
          } else {
            floatLyricAction()
          }
        }
      })
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
  .padding({ top: Constants.PADDING_EDGE_DEFAULT, left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
  .height('100%')
  .width('100%')
  .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
}

@Extend(ListItem) function itemStyle() {
  .backgroundColor($r('app.color.main'))
  .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT, top: 5, bottom: 5 })
  .margin({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
  .borderRadius(Constants.RADIUS_CARD)
}