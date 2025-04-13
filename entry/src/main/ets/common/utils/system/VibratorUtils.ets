import { vibrator } from "@kit.SensorServiceKit"
import { BusinessError } from "@kit.BasicServicesKit"
import { LogUtil } from "@pura/harmony-utils"

/**
 * 震动工具
 */
const TAG = '[VibratorUtils] '

class VibratorUtils {
  startDuration(duration: number, id: number) {
    try {
      vibrator.startVibration({
        type: 'time',
        duration: duration
      }, {
        id: id,
        usage: 'alarm'
      }, (error: BusinessError) => {
        if (error) {
          LogUtil.error(TAG, 'Start Vibrator Error: ' + error.message)
          return
        }
      })
    } catch (e) {
      LogUtil.error(TAG, 'Error: ' + e.message)
    }
  }

  /**
   * Start Count Vibrator
   * @param type - soft | hard | sharp
   * @param count
   * @param intensity
   */
  startCount(type: string, count: number, intensity: number) {
    try {
      let effectId: string = ''
      switch (type) {
        case 'soft':
          effectId = 'haptic.effect.soft'
        case 'hard':
          effectId = 'haptic.effect.hard'
        case 'sharp':
          effectId = 'haptic.effect.sharp'
        default :
          effectId = 'haptic.effect.hard'
      }
      vibrator.isSupportEffect(effectId, (err: BusinessError, state: boolean) => {
        if (err) {
          LogUtil.error(TAG, 'Error: ' + err.message)
          return
        }
        try {
          vibrator.startVibration({
            type: 'preset',
            effectId: 'haptic.effect.soft',
            count: count,
            intensity: intensity
          }, {
            usage: 'unknown'
          }, (error: BusinessError) => {
            if (error) {
              LogUtil.error(TAG, 'Start Vibrator Error: ' + error.message)
              return
            }
          })
        } catch (e) {
          LogUtil.error(TAG, 'Error: ' + e.message)
        }
      })
    } catch (e) {
      LogUtil.error(TAG, 'Error: ' + e.message)
    }
  }
}

const vibratorUtils: VibratorUtils = new VibratorUtils()
export default vibratorUtils as VibratorUtils