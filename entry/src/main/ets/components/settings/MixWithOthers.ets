import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import PreferencesUtils from "../../common/utils/data/PreferencesUtils"
import AudioPlayUtils from "../../common/utils/play/AudioPlayUtils"

/**
 * 和其他应用同时播放
 */
@Component
export struct MixWithOthers {
  @StorageLink(StorageConstants.MIX_WITH_OTHERS) @Watch('toggleMixWithOthers') isActived: boolean = false

  build() {
    Row() {
      Text('与其他应用同时播放')
        .fontSize(Constants.FONT_SIZE_COMMON)
        .fontWeight(FontWeight.Bold)
      Toggle({ type: ToggleType.Switch, isOn: this.isActived })
        .height(24)
        .width(48)
        .onChange((isOn) => {
          this.isActived = isOn
          AudioPlayUtils.setAudioSession()
        })
        .selectedColor($r('app.color.app_red'))
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  toggleMixWithOthers() {
    PreferencesUtils.putPreferenceValue(
      StorageConstants.SET_PERF,
      StorageConstants.MIX_WITH_OTHERS,
      this.isActived
    )
  }
}