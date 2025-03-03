import { getPlayLists } from "../../api/playListApi"
import { PlayList } from "../../common/entities/PlayList"
import { PlayListCard, PlayListCard_Skeleton } from "../cards/PlayListCard"
import { DialogUtil, LogUtil, ToastUtil } from "@pura/harmony-utils";
import { Announcement } from "../../common/entities/Announcement";
import { User, UserClass } from "../../common/entities/User";
import Constants from "../../common/constants/Constants";
import { StorageConstants } from "../../common/constants/StorageConstants";

/**
 * 用户歌单
 */
const TAG = '[UserPlayLists Component] '
@Component
export struct UserPlayLists {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp(StorageConstants.USER) user: User = UserClass
  @StorageProp(StorageConstants.IS_LOGGED) @Watch('getPlayLists') isLogged: boolean = false
  @StorageProp('Announcement') announcement: Announcement = {
    code: -1,
    data: { title:'', content: '' },
    visible: false
  }
  @StorageLink(StorageConstants.USER_PLAYLISTS) playLists: Array<PlayList> = []
  @State isLoading: boolean = false
  @State isLoadingMore: boolean = false
  @State isRefreshing: boolean = false
  @State lastRefreshTime: number = 0
  private refreshCooldown: number = 5000
  @Consume('pageInfos') pageInfos: NavPathStack

  async aboutToAppear(): Promise<void> {
    try {
      setTimeout(async () => {
        await this.getPlayLists()
      }, 500)
    } catch (e) {
      ToastUtil.showToast('获取歌单列表失败')
      LogUtil.error('Error fetching playlists: ', e.message)
    } finally {
      this.isLoading = false
    }
  }

  async getPlayLists() {
    if(this.isLogged && this.user && this.playLists.length == 0) {
      LogUtil.info(TAG + 'Start getPlayLists')
      this.isLoading = true
      const playlist = await getPlayLists(0)
      this.playLists = playlist.playlist
      this.isLoading = false
    }
    else return
  }

  build() {
    Column() {
      if(this.isLogged) {
        Refresh({ refreshing: this.isRefreshing}) {
          List({ space: 10 }) {
            if(this.announcement.visible) {
              ListItem() {
                this.Announcement()
              }
            }

            ListItem() {
              Column({ space: 10 }) {
                if(this.isLoading) {
                  this.Loading()
                } else {
                  ForEach(this.playLists, (item: PlayList, index) => {
                    ListItem() {
                      PlayListCard({
                        playList: item,
                        isShowHeart: item.creator.userId == this.user.data.account.id ? false : true
                      })
                    }
                  })
                }
              }
              .width('100%')
            }
            ListItem().height( px2vp(this.bottomRectHeight) + 115 )
          }
          .height('100%')
          .width('100%')
          .scrollBar(BarState.Off)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        }
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .onRefreshing(async () => {
          await this.refreshContent()
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  Loading() {
    ForEach([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], () => {
      PlayListCard_Skeleton()
    })
  }

  @Builder
  Announcement() {
    Row() {
      Text(this.announcement.data.content)
        .width('100%')
        .textAlign(TextAlign.Center)
        .fontColor($r('app.color.main'))
        .fontSize(Constants.FONT_SIZE_COMMON)
        .padding({ top: 5, bottom: 5 })
        .layoutWeight(1)
        .textOverflow({ overflow: TextOverflow.MARQUEE })
        .onClick(() => {
          DialogUtil.showConfirmDialog({
            title: this.announcement.data.title,
            message: this.announcement.data.content
          })
        })
    }
    .backgroundColor('#fff8b8b8')
  }

  private async refreshContent() {
    if (this.isLogged) {
      this.isRefreshing = true
      const currentTime = new Date().getTime()
      if (currentTime - this.lastRefreshTime < this.refreshCooldown) {
        ToastUtil.showToast('操作过于频繁，请5秒后再试')
      } else {
        try {
          const result = await getPlayLists(0)
          this.playLists = result.playlist
          this.lastRefreshTime = currentTime
          ToastUtil.showToast('刷新成功')
        } catch (e) {
        }
      }
      this.isRefreshing = false
    }
    else return
  }
}