import { ToastUtil } from "@pura/harmony-utils"
import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import PreferencesUtils from "../../common/utils/data/PreferencesUtils"
import { ExplainButton } from "../buttons/ExplainButton"

/**
 * 自定义API服务器地址
 * Sheet
 */
@Component
export struct CustomApiUrlSheet {
  @StorageLink(StorageConstants.IS_CUSTOM_API_URL) isCustomApiUrl: boolean = false
  @StorageLink(StorageConstants.IS_CUSTOM_COOKIE) isCustomCookie: boolean = false
  @StorageProp(StorageConstants.CUSTOM_API_URL) customApiUrl: string = ''
  @StorageProp(StorageConstants.CUSTOM_COOKIE) customCookie: string = ''
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @Link isShowSheet: boolean

  build() {
    Column({ space: 20 }) {
      Text('设置')
        .width('100%')
        .fontSize(Constants.FONT_SIZE_TITLE)
        .fontWeight(FontWeight.Bold)
        .padding({ top: Constants.PADDING_EDGE_TEXT, left: Constants.PADDING_EDGE_TEXT, right: Constants.PADDING_EDGE_TEXT })

      this.SetApiUrl()

      this.SetCookie()
    }
    .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT, bottom: px2vp(this.bottomRectHeight) + Constants.PADDING_EDGE_TEXT })
    .width('100%')
  }

  @Builder SetApiUrl() {
    Column({ space: 10 }) {
      Row() {
        Row({ space: 5 }) {
          Text('自定义API服务器地址').LeftText()
          ExplainButton({ title: '自定义API服务器地址',
            msg: '推荐使用, 使用自己的服务器体验更佳\n' +
              '需要自行搭建NeteaseCloudMusicApi服务\n\n' +
              '地址格式: http://example.com:3000\n' +
              '(注意末尾不带\"/\")'
          })
        }
        Toggle({ type: ToggleType.Switch, isOn: this.isCustomApiUrl })
          .height(24)
          .width(48)
          .selectedColor($r('app.color.app_red'))
          .onChange((isOn) => {
            animateTo({ duration: 100, curve: Curve.EaseInOut }, () => {
              this.toggleCustomApiUrl(isOn)
            })
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: Constants.PADDING_EDGE_TEXT, right: Constants.PADDING_EDGE_TEXT })

      if(this.isCustomApiUrl) {
        Row({ space: 10 }) {
          TextInput({ text: this.customApiUrl })
            .layoutWeight(4)
            .onChange((text) => this.customApiUrl = text)
            .borderRadius(Constants.RADIUS_IMG)
          Button('设置')
            .backgroundColor($r('app.color.app_red'))
            .layoutWeight(1)
            .onClick(() => {
              this.setCustomApiUrl()
            })
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .padding({ left: Constants.PADDING_EDGE_TEXT, right: Constants.PADDING_EDGE_TEXT })
      }
    }
  }

  @Builder SetCookie() {
    Column({ space: 10 }) {
      Row() {
        Row({ space: 5 }) {
          Text('使用自定义Cookie').LeftText()
          ExplainButton({ title: '使用自定义Cookie',
            msg: '设置后每次API请求都将使用用户自定义Cookie, 包括登录、用户信息等获取（更新登录信息需要重启应用）\n\n' +
              'Cookie只需要其中key为MUSIC_U的数据即可\n' +
              '例如: MUSIC_U=XXXXX'
          })
        }
        Toggle({ type: ToggleType.Switch, isOn: this.isCustomCookie })
          .height(24)
          .width(48)
          .selectedColor($r('app.color.app_red'))
          .onChange((isOn) => {
            animateTo({ duration: 100, curve: Curve.EaseInOut }, () => {
              this.toggleCustomCookie(isOn)
            })
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: Constants.PADDING_EDGE_TEXT, right: Constants.PADDING_EDGE_TEXT })

      if(this.isCustomCookie) {
        Row({ space: 10 }) {
          TextInput({ text: this.customCookie })
            .layoutWeight(4)
            .onChange((text) => this.customCookie = text)
            .borderRadius(Constants.RADIUS_IMG)
          Button('设置')
            .backgroundColor($r('app.color.app_red'))
            .layoutWeight(1)
            .onClick(() => {
              this.setCustomCookie()
            })
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .padding({ left: Constants.PADDING_EDGE_TEXT, right: Constants.PADDING_EDGE_TEXT })
      }
    }
  }

  toggleCustomApiUrl(isOn: boolean) {
    this.isCustomApiUrl = isOn
    AppStorage.setOrCreate(StorageConstants.IS_CUSTOM_API_URL, this.isCustomApiUrl)
    PreferencesUtils.putPreferenceValue(StorageConstants.SET_PERF, StorageConstants.IS_CUSTOM_API_URL, this.isCustomApiUrl)
  }

  toggleCustomCookie(isOn: boolean) {
    this.isCustomCookie = isOn
    AppStorage.setOrCreate(StorageConstants.IS_CUSTOM_COOKIE, this.isCustomCookie)
    PreferencesUtils.putPreferenceValue(StorageConstants.SET_PERF, StorageConstants.IS_CUSTOM_COOKIE, this.isCustomCookie)
  }

  setCustomApiUrl() {
    AppStorage.setOrCreate(StorageConstants.CUSTOM_API_URL,this.customApiUrl)
    PreferencesUtils.putPreferenceValue(StorageConstants.SET_PERF ,StorageConstants.CUSTOM_API_URL,this.customApiUrl)
    ToastUtil.showToast('设置成功，API地址：\n' + this.customApiUrl)
  }

  setCustomCookie() {
    AppStorage.setOrCreate(StorageConstants.CUSTOM_COOKIE,this.customCookie)
    PreferencesUtils.putPreferenceValue(StorageConstants.SET_PERF ,StorageConstants.CUSTOM_COOKIE,this.customCookie)
    ToastUtil.showToast('设置成功，Cookie：\n' + this.customCookie)
  }
}

@Extend(Text) function LeftText() {
  .fontSize(Constants.FONT_SIZE_COMMON)
  .fontWeight(FontWeight.Bold)
}