import { CommonCircleButton } from "../buttons/CircleButton";
import { MeSheet } from "../sheets/MeSheet";
import { router } from "@kit.ArkUI";

@Component
export struct IndexHead {
  @State isShowSheet: boolean = false;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;

  build() {
    Row() {
      CommonCircleButton({ ButtonImageName:'ic_public_view_list_filled', BgColor:'#00cbcbcb'})
        .bindSheet(this.isShowSheet, this.Sheet(), {
          height: '50%',
          dragBar: false,
          showClose: false,
          blurStyle: BlurStyle.Thick,
          onDisappear: () => { this.isShowSheet = false }
        })
        .onClick(() => { this.isShowSheet = !this.isShowSheet })

      Text("云音汇").fontSize(20).fontColor($r('app.color.reverse'))
      CommonCircleButton({ ButtonImageName:'ic_public_more_filled', BgColor:'#00cbcbcb'})
        .bindMenu(this.MoreMenu())
    }
    .padding({ left: 10, right: 10 })
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
  }

  // 更多菜单
  @Builder
  MoreMenu() {
    Menu() {
      MenuItem({ startIcon: $r('app.media.ic_public_settings_filled'),content: "设置" })
        .contentFontColor($r('app.color.reverse'))
        .onClick(()=>{
          router.pushUrl({ url:'pages/Settings' })
        })

      MenuItem({ startIcon: $r('app.media.ic_public_download_filled'), content: "下载管理" })
        .contentFontColor($r('app.color.reverse'))
        .onClick(()=>{
          router.pushUrl({ url:'pages/DownloadPage' })
        })
    }
  }

  // 半模态
  @Builder
  Sheet() {
    MeSheet({ isShowSheet: this.isShowSheet })
  }
}