import { DialogUtil } from "@pura/harmony-utils"
import { DialogAction } from "@pura/harmony-utils/src/main/ets/entity/constraint"
import { PlayQueue } from "../../common/entities/PlayQueue"
import { playQueue } from "../../common/functions/playerControl"
import PlayQueueUtils from "../../common/utils/PlayQueueUtils"

/**
 * 播放列表 Sheet
 */
@Component
export struct PlayQueueSheet {
  @StorageProp('PlayQueue') queue: Array<PlayQueue> = []
  @StorageProp('currentQueueIndex') currentQueueIndex: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @Link isShow: boolean

  build() {
    Column({ space: 10 }) {
      Row() {
        Text() {
          Span('播放列表').fontSize(20).fontColor(Color.Gray).fontWeight(FontWeight.Bold)
          Span(`  (${PlayQueueUtils.getQueueLength()})`).fontSize(16).fontColor(Color.Gray)
        }
        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.ic_public_delete_filled')).width(25).fillColor(Color.Gray)
        }
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          DialogUtil.showPrimaryDialog({
            title: '确认',
            message: '清空播放列表',
            primaryButton: "取消",
            secondaryButton: "确认",
            onAction: async (action) => {
              if(action == DialogAction.TWO) {
                PlayQueueUtils.cleanQueue()
              }
            }
          })
        })
      }
      .padding({ left: 5, right: 5 })
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      List({ space: 15 }) {
        ForEach(this.queue, (item: PlayQueue, index) => {
          ListItem() {
            Row({ space: 10 }) {
              // 本地文件
              if (item.playmode == 0) {
                Image($r('app.media.ic_public_todo')).width(20).fillColor(Color.Green)
                if (this.currentQueueIndex == index) {
                  Text(`${item.song.name} - ${item.artists}`).textStyle(16).fontWeight(FontWeight.Bold).fontColor('#ffd25959').layoutWeight(1)
                } else {
                  Text() {
                    Span(`${item.song.name}`)
                    Span(` - ${item.artists}`).fontColor(Color.Gray)
                  }
                  .layoutWeight(1)
                  .textStyle(16)
                  .onClick(() => {
                    playQueue(index)
                  })
                }
              }
              // 在线音乐
              else {
                if (this.currentQueueIndex == index) {
                  Text(`${item.song.name} - ${item.artists}`)
                    .layoutWeight(1)
                    .textStyle(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#ffd25959')
                } else {
                  Text() {
                    Span(`${item.song.name}`)
                    Span(` - ${item.artists}`).fontColor(Color.Gray)
                  }
                  .layoutWeight(1)
                  .textStyle(16)
                  .onClick(() => {
                    playQueue(index)
                  })
                }
              }
              Button({ type: ButtonType.Circle }) { Image($r('app.media.ic_public_cancel')).width(20).fillColor(Color.Gray) }
              .backgroundColor(Color.Transparent)
              .onClick(() => {
                PlayQueueUtils.queueDelete(index)
              })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceAround)
          }
        })
        ListItem().height(px2vp(this.bottomRectHeight))
      }
      .layoutWeight(1)
      .height('100%')
      .scrollBar(BarState.Off)
    }
    .padding({ left:20, right:20, top:15 })
    .width('100%')
  }
}

@Extend(Text) function textStyle(size:number) {
  .width('100%')
  .fontSize(size)
  .maxLines(1)
  .fontColor($r('app.color.reverse'))
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}