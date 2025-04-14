import { StorageConstants } from "../../common/constants/StorageConstants"
import { display, window } from "@kit.ArkUI"
import Constants from "../../common/constants/Constants";
import { LogUtil } from "@pura/harmony-utils";
import { FloatLyric, FloatLyricItem, LyricPosition } from "../../common/entities/local/Settings";

const TAG = "FloatingLyrics";
const BOTTOM_MARGIN = vp2px(60);
const THRESHOLD = vp2px(20);

class FloatingLyricsController {
  win: window.Window | null = null;
  public displayH = display.getDefaultDisplaySync().height;
  public displayW = display.getDefaultDisplaySync().width;
  private leftMargin = px2vp(0.1 * this.displayW);
  private windowPosition: LyricPosition = { x: 0, y: 0 };

  public init() {
    try {
      this.win = window.findWindow(Constants.FLOAT_LYRICS_WIN_NAME);
      this.win.setWindowBackgroundColor("#00000000") // transparent
      this.win.setWindowFocusable(false);
    } catch (err) {
      LogUtil.error(TAG, "init err");
    }
  }

  public destroyWindow = () => {
    try {
      this.win?.destroyWindow();
    } catch (err) {
      LogUtil.error(TAG, "destroyWindow err");
    }
  }
  public handlePanGestureStart = (event: GestureEvent): void => {
    if (!this.win) {
      return;
    }
    this.windowPosition = { x: this.windowPosition.x, y: this.win.getGlobalRect().top };
  }

  public handlePanGestureUpdate = (event: GestureEvent): void => {
    if (Math.abs(event.offsetY) < 1) {
      return;
    }
    let resY = this.windowPosition.y + event.offsetY
    if (resY < 0 || resY > this.displayH - BOTTOM_MARGIN + THRESHOLD) {
      return;
    }
    this.windowPosition.y = resY;
    this.moveWindowTo(this.windowPosition.x, resY);
  }

  public getLeftMarin(): number {
    return this.leftMargin;
  }

  public onTouchableChange(floatTouchable: boolean) {
    try {
      this.win?.setWindowTouchable(floatTouchable);
    } catch (err) {
      LogUtil.error(TAG, "onTouchableChange err");
    }
  }

  private moveWindowTo(x: number, y: number) {
    try {
      this.win!.moveWindowTo(x, y);
    } catch (err) {
      LogUtil.error(TAG, "moveWindow err");
    }
  }
}

@Entry
@Component
export struct FloatingLyrics {
  @StorageProp(StorageConstants.CURRENT_LYRIC) currentLyric: string = '';
  @StorageProp(StorageConstants.PLAY_ARTISTS) artists: string = '';
  @StorageProp(StorageConstants.FLOAT_LYRIC_STYLE) @Watch('onTouchableChange') floatLyricStyle: FloatLyric = FloatLyricItem
  private controller: FloatingLyricsController = new FloatingLyricsController();

  aboutToAppear(): void {
    this.controller.init();
    this.controller.onTouchableChange(this.floatLyricStyle.touchable);
  }

  onTouchableChange() {
    this.controller.onTouchableChange(this.floatLyricStyle.touchable);
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Text(this.currentLyric)
        .textStyle(this.floatLyricStyle.size)
        .textAlign(this.floatLyricStyle.align === 'center' ? TextAlign.Center : TextAlign.Start)
    }
    // .margin({ left: this.controller.getLeftMarin() })
    .width(`${this.floatLyricStyle.width}%`)
    .backgroundColor(Color.Transparent)
    .opacity(this.floatLyricStyle.opacity)
    .backdropBlur(this.floatLyricStyle.bgBlur ? 50 : 0)
    .borderRadius(Constants.RADIUS_IMG)
    .parallelGesture(GestureGroup(GestureMode.Exclusive,
      // TapGesture({ count: 2, fingers: 1 })
      //   .onAction(this.controller.destroyWindow),
      PanGesture({ direction: PanDirection.Vertical })
        .onActionStart(this.controller.handlePanGestureStart)
        .onActionUpdate(this.controller.handlePanGestureUpdate)
    ))
  }
}

@Extend(Text)
function textStyle(size: number) {
  .fontSize(size)
  .fontColor($r('app.color.app_red'))
  .fontWeight(Constants.FONT_WEIGHT_BOLD)
  .width('100%')
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.MARQUEE })
  .padding(5)
}