import { notificationManager } from "@kit.NotificationKit"
import { LogUtil } from "@pura/harmony-utils"
import { BusinessError } from "@kit.BasicServicesKit"

/**
 * 通知类
 */
const TAG = '[NotificationUtils] '
class NotificationUtils {
  /**
   * 发布普通通知
   * @param id
   * @param text
   */
  publish(id: number, title: string, text: string) {
    const contentType = notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT
    notificationManager.publish({
      id: id,
      deliveryTime: new Date().getTime(),
      showDeliveryTime: true,
      content: {
        notificationContentType: contentType,
        normal: {
          title: title,
          text: text,
        }
      },
    }).catch((err:Error) => {
      LogUtil.error(TAG, '发送通知失败' + err.message)
    })
  }

  download(id: number, title: string, fileName: string, progress: number) {
    let notificationRequest: notificationManager.NotificationRequest = {
      id: id,
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT  ,
        normal: {
          title: title,
          text: fileName
        }
      },
      template: {
        name: 'downloadTemplate',
        data: { title: title, fileName: fileName, progressValue: progress }
      }
    }

    notificationManager.publish(notificationRequest, (err: BusinessError) => {
      if(err) {
        LogUtil.error(TAG, 'Error: ' + err.message)
        return
      }
    })
  }

  /**
   * 取消通知
   * @param id
   */
  cancel(id: number) {
    notificationManager.cancel(id, () => {})
  }

  /**
   * 取消所有通知
   */
  cancelAll() {
    notificationManager.cancelAll()
  }
}

const notificationUtils = new NotificationUtils()
export default notificationUtils as NotificationUtils