import { ToastUtil } from "@pura/harmony-utils";
import { BackButton } from "../buttons/BackButton";
import { CommonCircleButton } from "../buttons/CircleButton";
import { PlayController } from "../play/PlayController";

@Component
export struct ListHead {
  title:string = ''

  @BuilderParam slot: () => void = this.Slot

  build() {
    Row({ space: 20 }) {
      BackButton()
      Text(`${this.title}`).fontSize(18).fontColor($r('app.color.reverse')).maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      this.slot()
    }
    .padding({ left: 10, right: 10 })
    .width('100%')
    .backgroundColor(Color.Transparent)
    .onClick(() => {
      ToastUtil.showToast(`${this.title}`)
    })
  }

  @Builder
  Slot() {
    CommonCircleButton()
  }
}