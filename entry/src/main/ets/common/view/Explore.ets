import { DialogUtil, ToastUtil} from "@pura/harmony-utils";
import Constants from "../constants/Constants";
import { TopListItem } from "../entities/recommend/TopList";
import { getTopList } from "../../api/topListApi";
import { TopListItemCard } from "../../components/cards/TopListItemCard";
import { StorageConstants } from "../constants/StorageConstants";
import { getPersonalizedList } from "../../api/playListApi";
import { PersonalListItem } from "../entities/recommend/Personalized";
import { PersonalizedCard } from "../../components/cards/PersonalizedCard";
import { AppInfo, AppInfoClass } from "../entities/local/AppInfo";
import { RecommendDjRadio } from "../entities/dj/DjRecommend";
import { IndexRecommend } from "./IndexRecommend";

@Component
export struct Explore {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp(StorageConstants.IS_LOGGED) @Watch('getContent') isLogged: boolean = false
  @StorageProp(StorageConstants.VALID_API_URL) validApiUrl: boolean = true
  @StorageProp(StorageConstants.APP_INFO) appInfo: AppInfo = AppInfoClass
  @StorageLink(StorageConstants.TOPLISTS) topList: Array<TopListItem> = []
  @StorageLink(StorageConstants.PERSONALIZED_LIST) personalizedList: Array<PersonalListItem> = []
  @StorageLink(StorageConstants.RECOMMENDED_DJ) recommendDjRadioList: Array<RecommendDjRadio> = []
  @StorageProp(StorageConstants.BREAKPOINT_WIDTH) breakpoint: string = 'sm'
  @State isLoadingTopList: boolean = false
  @State isLoadingPersonalized: boolean = false
  @State isLoadingRecommendDjRadio: boolean = false
  @State isRefreshing: boolean = false
  @State lastRefreshTime: number = 0
  @Prop currentHour: number = 0
  @State totalOpacity: number = 0
  @Consume('pageInfos') pageInfos: NavPathStack
  private refreshCooldown: number = 5000

  aboutToAppear() {
    animateTo({ duration: 300, curve: Curve.Ease, delay: 100}, () => {
      this.totalOpacity = 1
    })
  }

  async getContent() {
    this.getTopLists()
    this.getPersonalizedList()
  }

  private async getTopLists() {
    if(this.topList.length == 0 && this.validApiUrl) {
      this.isLoadingTopList = true
      this.topList = await getTopList()
      this.isLoadingTopList = false
    }
    else return
  }

  private async getPersonalizedList() {
    if(this.isLogged && this.personalizedList.length == 0 && this.validApiUrl) {
      this.isLoadingPersonalized = true
      this.personalizedList = await getPersonalizedList()
      this.isLoadingPersonalized = false
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
        Promise.all([
          this.topList = await getTopList(),
          this.personalizedList = await getPersonalizedList(),
        ])
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
      Refresh({ refreshing: this.isRefreshing }) {
        Grid() {
          if(this.appInfo.data.Announcement.isShow) {
            GridItem() {
              this.Announcement()
            }
          }
          GridItem() {
            Search({
              placeholder: $r('app.string.Search_content'),
              icon: '/resources/base/media/ic_public_search_filled.svg',
            })
              .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
              .focusable(false)
              .onClick(() => {
                this.pageInfos.clear()
                this.pageInfos.pushPathByName('SearchPage', null, this.breakpoint === 'lg' && this.pageInfos.size() === 0 ? false : true)
              })
              .layoutWeight(1)
          }
          .padding({ left: 20, right: 20 })

          GridItem() {
            Column({ space: 5 }) {
              this.Intro(this.getGreeting(this.currentHour), () => {})
              IndexRecommend({ isLogged: this.isLogged })
            }
          }

          if(this.validApiUrl) {
            GridItem() {
              Column({ space: 5 }) {
                this.Intro('推荐歌单', () => {})
                // 推荐歌单
                List() {
                  ListItem().width(5)
                  ListItem().width(5)
                  ForEach(this.personalizedList, (item: PersonalListItem, index) => {
                    ListItem() {
                      PersonalizedCard({ item: item, breakpoint: this.breakpoint }).padding(5)
                    }
                  }, (item: PersonalListItem) => item.id.toString())
                  ListItem().width(5)
                  ListItem().width(5)
                }
                .lanes(2)
                .listDirection(Axis.Horizontal)
                .scrollBar(BarState.Off)
                .width('100%')
              }
            }
            .padding({ top: 20 })

            // GridItem() {
            //   Column({ space: 5 }) {
            //     this.Intro('推荐电台', () => {})
            //     // 推荐歌单
            //     List() {
            //       ListItem().width(5)
            //       ListItem().width(5)
            //       ForEach(this.recommendDjRadioList, (item: RecommendDjRadio) => {
            //         ListItem() {
            //           DjRadioRecommendCard({ djRadio: item }).padding(10)
            //         }
            //       }, (item: PersonalListItem) => item.id.toString())
            //       ListItem().width(5)
            //       ListItem().width(5)
            //     }
            //     .listDirection(Axis.Horizontal)
            //     .scrollBar(BarState.Off)
            //     .width('100%')
            //   }
            // }
            // .padding({ top: 20 })

            GridItem() {
              Column({ space: 15 }) {
                this.Intro('排行榜', () => {
                  this.pageInfos.pushPathByName('TopListPage', null, this.breakpoint === 'lg' && this.pageInfos.size() === 0 ? false : true)
                })
                // 排行榜
                List() {
                  ListItem().width(15)
                  ForEach(this.topList.slice(0, 10), (item: TopListItem) => {
                    ListItem() {
                      TopListItemCard({ topListItem: item, breakpoint: this.breakpoint }).padding(5)
                    }
                  })
                  ListItem() {
                    Button() {
                      Column({ space: 5 }) {
                        Stack({ alignContent: Alignment.Center }) {
                          Image($r('app.media.bg4'))
                            .width(120)
                            .aspectRatio(1)
                            .borderRadius(Constants.RADIUS_CARD)
                            .draggable(false)
                          Text('更多排行')
                            .fontSize(Constants.FONT_SIZE_COMMON + 3)
                            .fontWeight(FontWeight.Bold)
                            .fontColor(Color.White)
                        }
                        .width(120)
                        .aspectRatio(1)
                        .backgroundColor(Color.Transparent)
                      }
                    }
                    .backgroundColor(Color.Transparent)
                    .borderRadius(Constants.RADIUS_CARD)
                    .type(ButtonType.Normal)
                    .width(120)
                    .aspectRatio(1)
                    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
                    .onClick(() => { this.pageInfos.pushPathByName('TopListPage', null, this.breakpoint === 'lg' && this.pageInfos.size() === 0 ? false : true) })
                  }.padding(5)
                  ListItem().width(15)
                }
                .listDirection(Axis.Horizontal)
                .scrollBar(BarState.Off)
                .width('100%')
                .height('auto')
              }
            }
            .padding({ top: 20 })
          }

          GridItem()
            .height(px2vp(this.bottomRectHeight) + 115)
        }
        .height('100%')
        .width('100%')
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Off)
        .rowsGap(15)
        .columnsTemplate('1fr')
        .layoutDirection(GridDirection.Column)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .backToTop(true)
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .onRefreshing(async () => {
        await this.refreshContent()
      })
    }
    .width('100%')
    .height('100%')
    .opacity(this.totalOpacity)
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
      Text(this.appInfo.data.Announcement.message)
        .width('100%')
        .textAlign(TextAlign.Center)
        .fontColor($r('app.color.main'))
        .fontSize(Constants.FONT_SIZE_COMMON)
        .padding({ top: 5, bottom: 5 })
        .layoutWeight(1)
        .textOverflow({ overflow: TextOverflow.MARQUEE })
        .onClick(() => {
          DialogUtil.showConfirmDialog({
            title: this.appInfo.data.Announcement.title,
            message: this.appInfo.data.Announcement.message
          })
        })
    }
    .backgroundColor('#fff8b8b8')
  }

  @Builder Intro(title: string, action: () => void) {
    Row({ space: 5 }) {
      Text(title)
        .textStyle(18)
      Image($r('app.media.ic_public_arrow_right'))
        .width(Constants.SIZE_ICON_BUTTON_BAR)
        .fillColor($r('app.color.reverse'))
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
    .onClick(action)
  }

  private getGreeting(hour: number): string {
    if (hour >= 5 && hour < 7) return '清晨好'
    if (hour >= 7 && hour < 9) return '早上好'
    if (hour >= 9 && hour < 11) return '上午好'
    if (hour >= 11 && hour < 13) return '中午好'
    if (hour >= 13 && hour < 18) return '下午好'
    if (hour >= 18 && hour < 24) return '晚上好'
    if (hour >= 0 && hour < 5) return '夜已深, 注意休息'
    return '探索您喜爱的内容'
  }
}

@Extend(Text) function textStyle(size: number) {
  .fontSize(size)
  .fontWeight(FontWeight.Bold)
  .fontColor($r('app.color.reverse'))
  .padding({ left: 20 })
}