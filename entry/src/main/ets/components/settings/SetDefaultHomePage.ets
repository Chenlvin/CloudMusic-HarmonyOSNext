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
      Text('默认首页')
        .fontSize(Constants.FONT_SIZE_COMMON)
        .fontWeight(FontWeight.Bold)
      Row() {
        Radio({ value: '发现', group: 'Radio' })
          .checked(this.selected == 0)
          .radioStyle({ checkedBackgroundColor: $r('app.color.app_red') })
          .onClick(() => {
            changeSettings(StorageConstants.DEFAULT_PAGE_INDEX, 0)
          })
        Text('发现')
          .fontSize(Constants.FONT_SIZE_COMMON)
          .padding({ right: 10 })
        Radio({ value: '歌单', group: 'Radio' })
          .checked(this.selected == 1)
          .radioStyle({ checkedBackgroundColor: $r('app.color.app_red') })
          .onClick(() => {
            changeSettings(StorageConstants.DEFAULT_PAGE_INDEX, 1)
          })
        Text('歌单')
          .fontSize(Constants.FONT_SIZE_COMMON)
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
}