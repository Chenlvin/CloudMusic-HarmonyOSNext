import { display, window } from '@kit.ArkUI'
import { LogUtil } from '@pura/harmony-utils'
import Constants from '../../constants/Constants'

const TAG = '[WindowUtils] '

class WindowUtils {
  windowClass: window.Window | undefined = undefined
  lyricWindowClass: window.Window | undefined = undefined
  flag: number = 0

  init(data: window.Window) {
    this.windowClass = data
  }

  getInstance(): window.Window {
    return this.windowClass!
  }

  toggleStatusBar(toggle: boolean) {
    this.windowClass!.setWindowSystemBarEnable(toggle ? ['status'] : [])
  }

  setOrientation(target: window.Orientation) {
    if(canIUse("SystemCapability.WindowManager.WindowManager.Core")) {
      try {
        let orientation = target
        if(target === window.Orientation.AUTO_ROTATION_LANDSCAPE_RESTRICTED) this.flag = 1
        else this.flag = 0
        if(this.windowClass) {
          this.windowClass.setPreferredOrientation(orientation)
        }
      } catch (e) {
        LogUtil.error(TAG + 'set orientation error: ' + e.message + '\n' + e.stack)
      }
    }
  }

  getOrientation(): window.Orientation {
    if(this.windowClass) {
      return this.windowClass.getPreferredOrientation()
    } else return window.Orientation.UNSPECIFIED
  }

  createLyricsFloatWindow(): void {
    if(this.lyricWindowClass) return
    let config: window.Configuration =
      { name: Constants.FLOAT_LYRICS_WIN_NAME, windowType: window.WindowType.TYPE_FLOAT, ctx: getContext(this) };
    window.createWindow(config, (err, data) => {
      if (err.code) {
        console.error('Failed to create the floatWindow. Cause: ' + JSON.stringify(err));
        return;
      }
      this.lyricWindowClass = data;
      console.info('Succeeded in creating the floatWindow. Data: ' + JSON.stringify(data));
      this.lyricWindowClass.setUIContent('pages/lyrics/FloatingLyrics');
      let displayW = display.getDefaultDisplaySync().width;
      this.lyricWindowClass.resize(displayW, 140);
      this.lyricWindowClass.moveWindowToGlobal(0, Constants.FLOAT_LYRICS_TOP_MARGIN);
      this.lyricWindowClass.showWindow();
    });
  }

  destoryLyricFloatWindow() {
    if(!this.lyricWindowClass) return
    this.lyricWindowClass.destroyWindow(() => {
      this.lyricWindowClass = undefined
    })
  }
}

const windowUtils: WindowUtils = new WindowUtils()
export default windowUtils as WindowUtils