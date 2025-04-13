import { StorageConstants } from "../../common/constants/StorageConstants"
import { display, window } from "@kit.ArkUI"
import Constants from "../../common/constants/Constants";

interface Position {
  x: number,
  y: number
}

const TAG = "FloatingLyrics";
const DisplayH = display.getDefaultDisplaySync().height;
const BOTTOM_MARGIN = vp2px(60);

@Entry
@Component
export struct FloatingLyrics {
  @StorageProp(StorageConstants.CURRENT_LYRIC) currentLyric: string = '';
  @StorageProp(StorageConstants.PLAY_ARTISTS) artists: string = '';
  @State @Watch("moveWindow") windowPosition: Position = { x: 0, y: 0 };
  private panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.Vertical });
  private win: window.Window | null = null;

  aboutToAppear(): void {
    this.win = window.findWindow(Constants.FLOAT_LYRICS_WIN_NAME);
    this.win.setWindowBackgroundColor("#00000000") // transparent
    this.win.setWindowFocusable(false);
  }

  moveWindow() {
    this.win?.moveWindowTo(this.windowPosition.x, this.windowPosition.y);
  }

  build() {
    Stack() {
      Stack({alignContent: Alignment.Center}) {
        Text(this.currentLyric)
          .textStyle(14)
          .textOverflow({ overflow: TextOverflow.MARQUEE })
          .fontColor(Color.Gray)
      }
      .padding({left: 10})
      .width('80%')
      .height('100%')
      .backgroundBlurStyle(BlurStyle.Thick)
      .borderRadius(16)
    }
    .parallelGesture(GestureGroup(GestureMode.Exclusive,
      TapGesture({ count: 2, fingers: 1 })
        .onAction(() => {
          this.win?.destroyWindow();
        }),
      PanGesture(this.panOption)
        .onActionStart((event: GestureEvent) => {
          if (!this.win) {
            return;
          }
          this.windowPosition.y = this.win!.getGlobalRect().top;
        })
        .onActionUpdate((event: GestureEvent) => {
          let resY = this.windowPosition.y + event.offsetY;
          if (resY < Constants.FLOAT_LYRICS_TOP_MARGIN || resY >  DisplayH - BOTTOM_MARGIN) {
            return;
          }
          this.windowPosition.y = resY;
        })
        .onActionEnd((event: GestureEvent) => {})
    ))
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Transparent)
  }
}

@Extend(Text) function textStyle(size:number) {
  .fontSize(size)
  .fontColor($r('app.color.reverse'))
  .textAlign(TextAlign.Start)
  .layoutWeight(1)
  .width('100%')
  .maxLines(1)
  .padding({ left: 10, right: 10 })
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}
