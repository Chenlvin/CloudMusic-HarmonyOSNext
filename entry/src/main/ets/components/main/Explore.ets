import { DialogUtil, LogUtil, ToastUtil} from "@pura/harmony-utils";
import { RecommendCards, RecommendCards_Skeleton } from "../cards/RecommendCards";
import { Announcement } from "../../common/entities/Announcement";
import { User, UserClass } from "../../common/entities/User";
import Constants from "../../common/constants/Constants";
import { TopListItem } from "../../common/entities/TopList";
import { getTopList } from "../../api/topListApi";
import { TopListItemCard } from "../cards/TopListItemCard";
import { StorageConstants } from "../../common/constants/StorageConstants";
import { PlayList } from "../../common/entities/PlayList";
import { getPlayLists } from "../../api/playListApi";

@Component
export struct Explore {
  @StorageProp(StorageConstants.IS_LOGGED) @Watch('getPlayLists') isLogged: boolean = false
  @StorageProp(StorageConstants.USER) user: User = UserClass
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('Announcement') announcement: Announcement = {
    code: -1,
    data: { title:'', content: '' },
    visible: false
  }
  @StorageLink(StorageConstants.USER_PLAYLISTS) playLists: Array<PlayList> = []
  @StorageLink(StorageConstants.TOPLISTS) topList: Array<TopListItem> = []
  @State isLoading: boolean = false
  @State isLoadingMore: boolean = false
  @State columnsTemplate: string = '1fr'
  @State isRefreshing: boolean = false
  @State lastRefreshTime: number = 0
  @Consume('pageInfos') pageInfos: NavPathStack
  private refreshCooldown: number = 5000

  async aboutToAppear(): Promise<void> {
    try {
      setTimeout(async () => {
        await this.getTopLists()
        await this.getPlayLists()
      }, 500)
    } catch (e) {
      LogUtil.error('Error: ' + e.message)
    }
  }

  private async getTopLists() {
    if(this.topList.length == 0) {
      this.isLoading = true
      const toplist = await getTopList()
      this.topList = toplist
      this.isLoading = false
    }
    else return
  }

  async getPlayLists() {
    if(this.isLogged && this.playLists.length == 0) {
      this.isLoading = true
      const playlist = await getPlayLists(0)
      this.playLists = playlist.playlist
      this.isLoading = false
    }
    else return
  }

  private async refreshContent() {
    this.isRefreshing = true
    const currentTime = new Date().getTime()
    if (currentTime - this.lastRefreshTime < this.refreshCooldown) {
      ToastUtil.showToast('操作过于频繁，请5秒后再试')
    } else {
      try {
        const toplist = await getTopList()
        this.topList = toplist
        this.lastRefreshTime = currentTime
        ToastUtil.showToast('刷新成功')
      } catch (e) {
        ToastUtil.showToast('内容刷新失败: ' + e.message)
      }
    }
    this.isRefreshing = false
  }

  build() {
    Column() {
      Refresh({ refreshing: this.isRefreshing}) {
        Column({ space: 5 }) {
          if (this.announcement.visible) {
            this.Announcement()
          }
          Grid() {
            GridItem() {
              Search({
                placeholder: '搜索内容',
                icon: '/resources/base/media/ic_public_search_filled.svg',
              })
                .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
                .focusable(false)
                .onClick(() => {
                  this.pageInfos.clear()
                  this.pageInfos.pushPathByName('SearchPage', null, true)
                })
                .layoutWeight(1)
            }
            .columnStart(0)
            .columnEnd(1)
            .padding({ left: 20, right: 20 })

            GridItem() {
              Column({ space: 10 }) {
                if (this.isLoading) {
                  RecommendCards_Skeleton()
                } else {
                  RecommendCards({ isLogged: this.isLogged })
                }
              }
              .width('100%')
            }
            .columnStart(0)
            .columnEnd(1)

            GridItem() {
              Text(`排行榜`).textStyle(18)
            }
            .columnStart(0)
            .columnEnd(1)
            .padding({ top: 20 })

            if (this.isLoading) {
              GridItem() {
                this.Loading(300)
              }
              .columnStart(0)
              .columnEnd(1)
            } else {
              GridItem() {
                GridRow({
                  columns: {
                    xs: 2,
                    sm: 3,
                    md: 2,
                    lg: 3,
                    xl: 3
                  }
                }) {
                  ForEach(this.topList, (item: TopListItem) => {
                    GridCol() {
                      TopListItemCard({ topListItem: item }).padding(Constants.PADDING_EDGE_DEFAULT)
                    }
                  })
                }
              }
              .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
              .width('100%')
            }

            GridItem()
              .height(px2vp(this.bottomRectHeight) + 115)
              .columnStart(0)
              .columnEnd(1)
          }
          .height('100%')
          .width('100%')
          .edgeEffect(EdgeEffect.Spring)
          .scrollBar(BarState.On)
          .rowsGap(15)
          .columnsTemplate(this.columnsTemplate)
          .layoutDirection(GridDirection.Column)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        }
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .onRefreshing(async () => {
        await this.refreshContent()
      })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  Loading(ht: number | string = '100%') {
    Column() {
      LoadingProgress().width(Constants.SIZE_LOADING_PROGRESS_DEFAULT)
    }
    .height(ht)
    .padding({ bottom: px2vp(this.topRectHeight) + 60 })
    .width('100%')
    .justifyContent(FlexAlign.Center)
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
}

@Extend(Text) function textStyle(size: number) {
  .width('100%')
  .fontSize(size)
  .fontWeight(FontWeight.Bold)
  .fontColor($r('app.color.reverse'))
  .padding({ left: 20, right: 20 })
}