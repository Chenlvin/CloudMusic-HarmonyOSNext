import { router } from '@kit.ArkUI'
import { Song } from '../common/entities/SongsResult'
import { SongCard } from '../components/cards/SongCard'
import { PlayList } from '../common/entities/PlayList'
import { ListHead } from '../components/head/ListHead'
import { SpinKit, SpinType } from '@pura/spinkit'
import { DialogUtil, LogUtil, ToastUtil } from '@pura/harmony-utils'
import { getPlayListSongs, PlayListOperation, subscribePlayList } from '../api/playListApi'
import { BottomBarComponent } from '../components/play/BottomBarComponent'
import { CommonCircleButton } from '../components/buttons/CircleButton'
import { DialogAction } from '@pura/harmony-utils/src/main/ets/entity/constraint'
import { formatNumber } from '../common/functions/commonFunction'
import { playListToQueue } from '../common/functions/play/playListOp'
import { AddToPlayListButton } from '../components/buttons/play/AddToPlayListButton'
import { QuestionButton } from '../components/buttons/QuestionButton'

/**
 * 歌单二级页面
 */

const TAG = '[PlayListPage] '

@Entry
@Component
struct PlayListPage {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('set-hasAnimation') hasAnimation: boolean = true
  @StorageProp('isPlayerLoading') isPlayerLoading:boolean = false

  private playList: PlayList = Object(router.getParams())['playList']
  private trackCount: number = Object(router.getParams())['trackCount']
  private isShowHeart: boolean = Object(router.getParams())['isShowHeart']
  private currentOffset: number = 0 // 歌曲偏移量
  @State isSubscribed: boolean = this.playList.subscribed
  @State list: Array<Song> = new Array()
  @State hasMore: boolean = true
  @State hasLoaded: boolean = false // 判定是否已加载 避免重复加载
  @State isLoading: boolean = true
  @State isLoadingMore: boolean = false
  @State pageOpacity: number = 1

  async onPageShow(): Promise<void> {
    if (!this.hasLoaded) {
      await this.loadSongs(30, 0)
    }
  }

  async loadSongs(limit: number, offset: number): Promise<void> {
    if (!this.hasMore) return // 没有更多歌曲直接返回
    if (offset == 0) {
      this.isLoading = true // 初次加载
    } else {
      this.isLoadingMore = true // 加载更多
    }

    try {
      const result = await getPlayListSongs(this.playList.id, offset)
      this.list = [...this.list, ...result] // 合并歌曲列表
      this.currentOffset += limit

      if (this.list.length >= this.trackCount) {
        this.hasMore = false
      }
    } catch (e) {
      LogUtil.error(TAG + 'Error fetching songs: ', e)
    } finally {
      this.isLoading = false
      this.isLoadingMore = false
      this.hasLoaded = true
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
        Stack({ alignContent: Alignment.Top }) {
          if (this.isLoading) {
            Column() {
              SpinKit({ spinType: SpinType.spinO, spinSize: 60, spinColor: Color.Gray }).width(60)
            }.height('100%').width('100%').justifyContent(FlexAlign.Center)
          } else {
            List() {
              ListItem().height( px2vp(this.topRectHeight) + 50 )
              ListItem() {
                this.PlayListInfo()
              }
              .padding({ bottom: 15 })
              ListItem() {
                Row() {
                  Button() {
                    Row({ space: 5 }) {
                      if (this.isPlayerLoading) {
                        LoadingProgress().height(35).padding({ left: 30 })
                      } else {
                        Image($r('app.media.ic_play_fill')).width(15).fillColor(Color.Gray)
                        Text(`播放全部 (${this.trackCount})`).fontSize(15)
                      }
                    }
                    .height(40)
                  }
                  .type(ButtonType.Normal)
                  .backgroundColor(Color.Transparent)
                  .borderRadius(15)
                  .onClick(async () => {
                    if (this.isPlayerLoading) {
                      ToastUtil.showToast('当前有正在加载的播放任务，请稍后再试')
                    } else {
                      playListToQueue(this.playList.id, this.trackCount, 0)
                    }
                  })

                  Text(`左滑操作歌曲`).fontSize(15)

                }
                .justifyContent(FlexAlign.SpaceBetween)
                .width('100%')
              }
              .padding({ left: 20, bottom: 10, right: 20 })

              ForEach(this.list, (item: Song, index) => {
                ListItem() {
                  SongCard({ song: item, sid: index, hasAnimation: this.hasAnimation,
                    isPlayList: true, playList: this.playList, index: index })
                }
                .swipeAction({ end: this.SwipeItem(item, index), edgeEffect: SwipeEdgeEffect.None })
              });
              // 添加加载更多
              if (this.isLoadingMore) {
                ListItem() {
                  Column() {
                    SpinKit({ spinType: SpinType.spinO, spinSize: 30, spinColor: Color.Gray }).width(30)
                  }.justifyContent(FlexAlign.Center).width('100%').height(50)
                }
              } else if (this.hasMore) {
                ListItem() {
                  Text("点击加载更多")
                    .onClick(() => {
                      this.loadSongs(30, this.currentOffset)
                    })
                    .padding({ top: 10, bottom: px2vp(this.bottomRectHeight) })
                    .fontColor($r('app.color.reverse'))
                    .width('100%')
                    .textAlign(TextAlign.Center)
                }
              } else if (!this.hasMore) {
                ListItem() {
                  Text('没有更多了~').fontSize(16).textAlign(TextAlign.Center).width('100%').height(50);
                }
              }
              ListItem().height(px2vp(this.bottomRectHeight) + 80)
            }
            .height('100%')
            .layoutWeight(1)
            .width('100%')
            .scrollBar(BarState.Off)
          }
          ListHead({
            title: this.playList.name,
            slot: this.HeadSlot.bind(this)
          })
        }
        .height('100%')

      BottomBarComponent()
      .padding({ left: 10, right: 10, bottom: px2vp(this.bottomRectHeight)})
      .backgroundColor(Color.Transparent)
    }
    .opacity(this.pageOpacity)
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'));
  }

  // 更多菜单
  @Builder
  PlayListMenu() {
    Row() {
      QuestionButton({ title: '歌单', msg: '歌单详情页支持左滑歌曲卡片进行操作', comSize: 25 })
      Text('帮助')
    }
    .onClick(() => {
      DialogUtil.showConfirmDialog({
        title: '歌单',
        message: '歌单详情页支持左滑歌曲卡片进行操作'
      })
    })
    .padding({ left: 10, right: 10, top: 5, bottom: 5})
  }

  @Builder
  HeadSlot() {
    CommonCircleButton({ ButtonImageName: 'ic_public_more_filled' })
      .bindMenu(this.PlayListMenu())
  }

  @Builder PlayListInfo() {
    Column() {
      Row({ space: 15 }) {
        Column() {
          Stack() {
            Image('')
              .width('100%')
              .borderRadius(10)
            LoadingProgress().width(40)
            Image(`${this.playList.coverImgUrl}?parm=256y256`)
              .width('100%')
              .borderRadius(10)
          }
          .height('100%')
          .width('100%')
        }
        .height(80)
        .width(80)

        Column() {
          Text(this.playList.name)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .padding({ bottom: 5 })
          Text(`由 ${this.playList.creator.nickname} 创建`)
            .fontSize(12)
            .width('100%')
            .textAlign(TextAlign.Start)
          Text(`${this.playList.trackCount}首歌曲     ${formatNumber(this.playList.playCount)}次播放`)
            .fontSize(12)
            .width('100%')
            .textAlign(TextAlign.Start)
        }
        .height(80)
        .layoutWeight(1)
        .justifyContent(FlexAlign.SpaceEvenly)

        if(this.isShowHeart) {
          if (this.isSubscribed) {
            Image($r('app.media.ic_heart_filled')).fillColor(Color.Pink).width(25)
              .onClick(async () => {
                DialogUtil.showPrimaryDialog({
                  title: '取消收藏',
                  message: '确认取消收藏歌单\n' + `《${this.playList.name}》`,
                  primaryButton: "取消",
                  secondaryButton: "确认",
                  onAction: async (action) => {
                    if(action == DialogAction.TWO) {
                      let res: boolean = await subscribePlayList(this.playList.id, 2)
                      LogUtil.info(TAG + 'res: ' + res)
                      if(res) {
                        ToastUtil.showToast('取消收藏歌单')
                        this.isSubscribed = false
                      }
                    }
                  }
                })

              })
          } else {
            Image($r('app.media.ic_heart_filled')).fillColor($r('app.color.main')).width(25)
              .onClick(async () => {
                let res:boolean = await subscribePlayList(this.playList.id, 1)
                if(res) {
                  ToastUtil.showToast('成功收藏歌单')
                  this.isSubscribed = true
                }
              })
          }
        }
      }
      .width('90%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder SwipeItem(song: Song, index: number) {
    Row() {
      AddToPlayListButton({ song: song })
      // Delete button
      if (!this.isShowHeart) {
        Button() {
          Text('从歌单删除')
            .height('100%')
            .fontColor(Color.White)
            .padding({ left: 10, right: 10 })
            .textAlign(TextAlign.Center)
        }
        .type(ButtonType.Normal)
        .height('100%')
        .backgroundColor('#ffee4c51')
        .onClick(() => {
          DialogUtil.showPrimaryDialog({
            title: '从歌单删除歌曲',
            message: `${song.name}`,
            primaryButton: "取消",
            secondaryButton: "删除",
            onAction: async (action) => {
              if (action == DialogAction.TWO) {
                try {
                  await PlayListOperation('del', this.playList.id, song.id)
                  ToastUtil.showToast('删除成功')
                  this.list.splice(index, 1)
                } catch (e) {
                  ToastUtil.showToast('删除失败: ' + e)
                }
              }
            }
          })
        })
      }
    }
  }
}