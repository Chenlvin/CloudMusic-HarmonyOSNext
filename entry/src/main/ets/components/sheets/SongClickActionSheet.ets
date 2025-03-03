import { ToastUtil } from "@pura/harmony-utils"
import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import PreferencesUtils from "../../common/utils/data/PreferencesUtils"
import { ExplainButton } from "../buttons/ExplainButton"

/**
 * 歌曲卡片点击操作
 * Sheet
 */
@Component
export struct SongClickActionSheet {
  @StorageLink(StorageConstants.SONG_CLICK_ACTION) @Watch('changeActionType') songClickAction: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @Link isShowSheet: boolean

  changeActionType() {
    PreferencesUtils.putPreferenceValue(StorageConstants.SET_PERF, StorageConstants.SONG_CLICK_ACTION, this.songClickAction)
  }

  build() {
    Column({ space: 20 }) {
      Text('歌曲卡片点击模式')
        .width('100%')
        .fontSize(Constants.FONT_SIZE_TITLE)
        .fontWeight(FontWeight.Bold)
        .padding({ top: Constants.PADDING_EDGE_TEXT, left: Constants.PADDING_EDGE_TEXT, right: Constants.PADDING_EDGE_TEXT })

      this.SettingItem(0, '点击或长按弹出歌曲信息菜单')
      this.SettingItem(1, '点击直接播放当前歌曲（单首播放）\n长按弹出歌曲信息菜单')
      this.SettingItem(2, '点击直接播放当前歌曲（随歌单一同播放）\n长按弹出歌曲信息菜单')

    }
    .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT, bottom: px2vp(this.bottomRectHeight) + Constants.PADDING_EDGE_TEXT })
    .width('100%')
  }

  @Builder SettingItem(index: number, text: string) {
    Row({ space: 10 }) {
      Radio({ value: `${index}` , group: 'clickAction' })
        .checked(this.songClickAction == index)
        .onChange((isChecked) => {
          if(isChecked) {
            this.songClickAction = index
          }
        })
      Text(text)
        .textStyle()
    }
    .width('100%')
    .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
  }
}

@Extend(Text) function textStyle() {
  .fontSize(Constants.FONT_SIZE_COMMON)
  .fontWeight(FontWeight.Bold)
  .width('100%')
  .textAlign(TextAlign.Start)
}