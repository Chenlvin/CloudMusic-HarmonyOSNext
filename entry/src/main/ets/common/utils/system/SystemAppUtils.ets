import { common, Want } from "@kit.AbilityKit"
import { BusinessError } from "@kit.BasicServicesKit"
import { LogUtil, ToastUtil } from "@pura/harmony-utils"

const TAG = '[SystemAppUtils] '

class SystemAppUtils {
  openInBrowser(url: string) {
    if(!url) return
    ToastUtil.showToast('正在拉起浏览器...')
    if(getContext()) {
      let context = getContext() as common.UIAbilityContext
      let want: Want = {
        action: 'ohos.want.action.viewData',
        entities: ['entity.system.browsable'],
        uri: url
      }
      context.startAbility(want)
        .catch((err: BusinessError) => {
          LogUtil.error(TAG, '尝试拉起浏览器失败: ' + err.message)
        })
    } else {
      LogUtil.error(TAG, '拉起浏览器 getContext() 失败')
    }
  }
}

const systemAppUtils = new SystemAppUtils()
export default systemAppUtils as SystemAppUtils