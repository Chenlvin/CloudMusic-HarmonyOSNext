import { getPlayLists } from "../../api/playListApi"
import { PlayList, playListClass } from "../../common/entities/PlayList"
import { PlayListCard } from "./PlayListCard"
import { SpinKit, SpinType } from '@pura/spinkit'
import { DialogUtil, LogUtil } from "@pura/harmony-utils";
import { RecommendCards } from "./RecommendCards";
import { Announcement } from "../../common/entities/Announcement";

@Component
export struct PlayLists {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('Announcement') announcement: Announcement = {
    code: -1,
    data: { title:'', content: '' },
    visible: false
  }

  @State isLoading:boolean = false
  @State isLoadingMore:boolean = false
  @State hasMore:boolean = false

  @State playLists:Array<PlayList> = new Array()
  @State LikeList:PlayList = playListClass
  async aboutToAppear(): Promise<void> {
    LogUtil.info('Announcement: ' + JSON.stringify(this.announcement))
    this.isLoading = true
    try {
      const result = await getPlayLists(0)
      this.playLists = result.playlist
      this.LikeList = this.playLists[0]
      this.playLists = this.playLists.slice(1)

      LogUtil.info('Get play lists: ' + JSON.stringify(this.playLists))
      this.hasMore = result.more
      setTimeout(() => {
        this.isLoading = false
      }, 100)
    } catch (e) {
      LogUtil.error('Error fetching playlists: ', e)
    }
  }

  @Builder
  itemLayout(playList: PlayList, index: number): void {
    PlayListCard({playList: playList})
  }

  @Builder
  Announcement() {
    Row() {
      Text(this.announcement.data.content)
        .width('100%')
        .textAlign(TextAlign.Center)
        .fontColor($r('app.color.main'))
        .fontSize(16)
        .padding({ top: 5, bottom: 5 })
        .layoutWeight(1)
        .textOverflow({ overflow: TextOverflow.MARQUEE })
        .onClick(() => {
          DialogUtil.showConfirmDialog({
            title: this.announcement.data.title,
            message: this.announcement.data.content + '\n\n(首页横幅消息支持在【设置】中关闭)'
          })
        })
    }
    .backgroundColor('#fff8b8b8')
  }

  build() {
    Column() {
      if(this.isLoading == true) {
        Column() {
          SpinKit({ spinType: SpinType.spinG, spinSize:60, spinColor:Color.Gray })
            .width(60)
        }
        .height('100%')
        .padding({ bottom: px2vp(this.topRectHeight) })
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
      else {
        List({ space: 10 }) {
          if(this.announcement.visible) {
            ListItem() {
              this.Announcement()
            }
          }
          ListItem() {
            RecommendCards({ LikeList: this.LikeList })
          }
          ForEach(this.playLists, (item: PlayList, index) => {
            ListItem() {
              PlayListCard({playList: item})
            }
          })
          ListItem().height( px2vp(this.bottomRectHeight) + 140 )
        }
        .height('100%')
        .width('100%')
        .scrollBar(BarState.Auto)
      }
    }
    .width('100%')
    .height('100%')
  }

}