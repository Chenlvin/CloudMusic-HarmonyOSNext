import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { changeSettings } from "../../common/functions/app/settings"

/**
 * 设置默认页面
 */
@Component
export struct SetDefaultHomePage {
  @StorageLink(StorageConstants.DEFAULT_PAGE_INDEX) selected: number = 0

  build() {
    Row() {
      Text($r('app.string.SET_DEFAULTHOMEPAGE'))
        .fontSize(Constants.FONT_SIZE_COMMON)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.reverse'))
      Row() {
        Radio({ value: '发现', group: 'Radio' })
          .checked(this.selected == 0)
          .radioStyle({ checkedBackgroundColor: $r('app.color.app_red') })
          .onClick(() => {
            changeSettings(StorageConstants.DEFAULT_PAGE_INDEX, 0)
          })
        Text($r('app.string.Explore'))
          .fontColor($r('app.color.reverse'))
          .fontSize(Constants.FONT_SIZE_COMMON)
          .padding({ right: 10 })
        Radio({ value: '播单', group: 'Radio' })
          .checked(this.selected == 1)
          .radioStyle({ checkedBackgroundColor: $r('app.color.app_red') })
          .onClick(() => {
            changeSettings(StorageConstants.DEFAULT_PAGE_INDEX, 1)
          })
        Text($r('app.string.Lists'))
          .fontColor($r('app.color.reverse'))
          .fontSize(Constants.FONT_SIZE_COMMON)
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .height(Constants.HEIGHT_SETTINGS_ITEM)
    .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
  }
}