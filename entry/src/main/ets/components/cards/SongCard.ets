import { getSongPicUrl } from "../../api/songApi"
import { Song, SongClass } from "../../common/entities/SongsResult"
import { changeDuration, getArtists } from "../../common/functions/commonFunction"
import PlayQueueUtils from "../../common/utils/play/PlayQueueUtils"
import { promptAction } from "@kit.ArkUI"
import { PlayList, playListClass } from "../../common/entities/PlayList"
import Constants from "../../common/constants/Constants"
import { playListToQueue } from "../../common/functions/play/playListOp"
import { playQueue } from "../../common/functions/play/playControl"
import { PasteboardUtil, ToastUtil } from "@pura/harmony-utils"
import { DownloadDialog } from "../dialog/DownloadDialog"
import { StorageConstants } from "../../common/constants/StorageConstants"

@Component
@Reusable
export struct SongCard {
  @StorageProp(StorageConstants.IS_PLAYER_LOADING) isPlayerLoading: boolean = false
  @StorageProp(StorageConstants.SONG_CLICK_ACTION) clickAction: number = 0
  @State showPlayButton: boolean = true
  @State showAddQueueButton: boolean = true
  @State showSid: boolean = true
  @State picUrl: string = ''
  @State isPlayList: boolean = false
  @State playList: PlayList = playListClass
  @State index: number = 0
  @State reason: string = ''
  @State isShowMenu: boolean = false
  song: Song = SongClass
  sid: number = -1
  artists: string = ''

  downloadDialogController: CustomDialogController = new CustomDialogController({
    builder: DownloadDialog({
      song: this.song,
      picUrl: this.picUrl,
      artists: this.artists,
      duration: changeDuration(this.song.duration)
    }),
  })

  async aboutToAppear(): Promise<void> {
    if(this.song.artists[0].id == 0) {
     this.artists = '未知'
      this.song.artists[0] = {"id": 0, "name": '未知'}
    }
    const artistsStr = await getArtists(this.song.artists)
    this.artists = artistsStr
    const picUrl = await getSongPicUrl(this.song)
    this.picUrl = picUrl
  }

  build() {
    Button() {
      Row() {
        Row() {
          Text(`${this.sid + 1}`)
            .width(40)
            .fontWeight(FontWeight.Bold)
          Image(this.picUrl + '?param=100y100')
            .width(50)
            .padding({ right: 10 })
            .borderRadius(5)
            .draggable(false)
          Column({ space: 5 }) {
            Row({ space: 5 }) {
              Text(this.song.name).textStyle(16)
              if(this.song.alias.length > 0) {
                Text(`(${this.song.alias[0]})`)
                  .layoutWeight(1)
                  .fontSize(Constants.FONT_SIZE_COMMON)
                  .fontColor(Color.Gray)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
            }
            .width('100%')

            Row({ space: 5 }) {
              if(this.reason) {
                Text(this.reason).reasonText()
              }
              Text(this.artists).textStyle(12).fontColor(Color.Gray).layoutWeight(1)
            }
            .width('100%')
          }
          .layoutWeight(1)
          .width(`100%`)
        }
        .layoutWeight(1)

        /**
         * 添加到播放列表
         */
        if(this.showAddQueueButton) {
          Button() {
            Image($r('app.media.ic_public_add_norm'))
              .draggable(false)
              .fillColor($r('app.color.reverse'))
              .width(15)
          }
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            PlayQueueUtils.queueAdd(1, this.song, this.artists, '')
            promptAction.showToast({ message: '成功添加至播放列表' })
          })
        }
      }
      .height(60)
    }
    .backgroundColor(Color.Transparent)
    .borderRadius(5)
    .type(ButtonType.Normal)
    .width('100%')
    .height(60)
    .padding({ left: 20, right: 20 })
    .onClick(async () => {
      if(this.clickAction == 0) {
        this.isShowMenu = true
      } else if(this.clickAction == 1) {
        this.playSingleSong()
      } else if(this.isPlayList) {
        this.playWithPlayList()
      } else {
        this.playSingleSong()
      }
    })
    .bindContextMenu(this.isShowMenu, this.ClickMenu, { onDisappear: () => { this.isShowMenu = false }})
    .gesture(
      LongPressGesture({
        duration: 500
      }).onAction(() => { this.isShowMenu = true })
    )
  }

  @Builder
  ClickMenu() {
    Menu() {
      MenuItem(this.MenuInfo())
      if(this.isPlayerLoading) {
        MenuItem(this.Loading())
      } else {
        MenuItem(this.MenuContent($r('app.media.ic_public_play_norm'), '单曲播放'))
          .onClick(() => {
            this.playSingleSong()
          })
        if(this.isPlayList) {
          MenuItem(this.MenuContent($r('app.media.ic_public_play_norm'), '播放歌单'))
            .onClick(() => {
              playListToQueue(this.playList.id, this.playList.trackCount, this.index)
            })
        }
        MenuItem(this.MenuContent($r('app.media.ic_public_cloud_download'), '缓存至应用沙箱'))
          .onClick(() => {
            this.downloadDialogController.open()
          })
        MenuItem() {
          Text('左滑歌曲卡片进行歌单操作').textStyle(12).textAlign(TextAlign.Center).width('100%')
        }
      }
    }
    .width('80%')
    .constraintSize({
      minWidth: 100,
      maxWidth: 300
    })
  }

  @Builder MenuInfo() {
    Row() {
      Image(this.picUrl + '?param=100y100')
        .width(Constants.SIZE_IMG_CARD)
        .padding({ right: Constants.PADDING_EDGE_DEFAULT })
        .borderRadius(Constants.RADIUS_IMG)
      Column({ space: 5 }) {
        Row({ space: 5 }) {
          Text(this.song.name)
            .fontSize(Constants.FONT_SIZE_COMMON)
            .alignSelf(ItemAlign.Start)
            .fontColor($r('app.color.reverse'))
          if(this.song.alias.length > 0) {
            Text(`(${this.song.alias[0]})`)
              .layoutWeight(1)
              .fontSize(Constants.FONT_SIZE_COMMON)
              .fontColor(Color.Gray)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .width('100%')

        Row({ space: 5 }) {
          Text(this.artists).textStyle(12).fontColor(Color.Gray)
        }
        .width('100%')
      }
      .layoutWeight(1)
      .width(`100%`)
    }
    .padding(Constants.PADDING_EDGE_DEFAULT)
    .layoutWeight(1)
    .onClick(() => {
      PasteboardUtil.setDataText(this.song.name + ' - ' + this.artists)
      ToastUtil.showToast('已复制歌名与歌手信息至剪贴板', { duration: 3000 })
    })
  }

  @Builder
  MenuContent(image: ResourceStr | string, title: string, contentColor: string | Color | ResourceStr = $r('app.color.reverse')) {
    Row({ space: 10 }) {
      Column() {
        Image(image)
          .fillColor(contentColor)
          .width(Constants.FONT_SIZE_COMMON)
      }
      Text(title)
        .fontColor(contentColor)
        .fontSize(Constants.FONT_SIZE_COMMON)
        .fontWeight(FontWeight.Bold)
    }
    .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT, top: 5, bottom: 5 })
    .height(Constants.HEIGHT_MENU_ITEM_DEFAULT)
  }

  @Builder Loading() {
    Row({ space: 10 }) {
      LoadingProgress().width(Constants.FONT_SIZE_COMMON)
      Text('当前有正在加载的播放任务').fontSize(Constants.FONT_SIZE_COMMON).fontColor($r('app.color.reverse'))
    }
    .justifyContent(FlexAlign.Center)
    .height(Constants.HEIGHT_MENU_ITEM_DEFAULT)
    .padding({ left: Constants.PADDING_EDGE_TEXT, right: Constants.PADDING_EDGE_TEXT })
  }

  private playSingleSong() {
    if(!this.isPlayerLoading) {
      AppStorage.setOrCreate('isPlayerLoading', true)
      PlayQueueUtils.queueAdd(1, this.song, this.artists, '')
      PlayQueueUtils.setIndex(PlayQueueUtils.currentQueueIndex + 1)
      playQueue(PlayQueueUtils.currentQueueIndex)
      setTimeout(() => {
        AppStorage.setOrCreate('isPlayerLoading', false)
      }, 1000)
    } else {
      ToastUtil.showToast('当前有正在加载的播放任务，请稍后再试', { duration: 5000 })
    }
  }

  private async playWithPlayList() {
    if(!this.isPlayerLoading) {
      this.isPlayerLoading = true
      await playListToQueue(this.playList.id, this.playList.trackCount, this.index)
      this.isPlayerLoading = false
    } else {
      ToastUtil.showToast('当前有正在加载的播放任务，请稍后再试', { duration: 5000 })
    }
  }
}

@Extend(Text) function textStyle(size:number) {
  .fontSize(size)
  .alignSelf(ItemAlign.Start)
  .fontColor($r('app.color.reverse'))
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}

@Extend(Text) function reasonText() {
  .fontColor('#ffff3232')
  .fontSize(10)
  .padding(2)
  .backgroundColor('#ffffd2d2')
  .borderRadius(5)
}


