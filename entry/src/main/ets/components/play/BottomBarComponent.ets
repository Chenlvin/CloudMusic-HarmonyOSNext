import { ToastUtil } from "@pura/harmony-utils"
import { Song, SongClass } from "../../common/entities/SongsResult"
import { pauseMusic, playQueue, resumeMusic } from "../../common/functions/play/playControl"
import playQueueUtils from "../../common/utils/play/PlayQueueUtils"
import { PlayQueueButton } from "../buttons/play/PlayQueueButton"
import { PlayingCover } from "../sheets/PlayingCover"
import { StorageConstants } from "../../common/constants/StorageConstants"

/**
 * 底部播控组件
 */
@Component
export struct BottomBarComponent {
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageLink(StorageConstants.IS_PLAYING) isPlaying: boolean = false
  @StorageProp(StorageConstants.PLAY_MODE) playmode: number = 1
  @StorageProp(StorageConstants.PLAY_FILE_NAME) fileName: string = ''
  @StorageProp(StorageConstants.PLAY_SONG) song: Song = SongClass
  @StorageProp(StorageConstants.PLAY_ARTISTS) artists: string = ''
  @StorageProp(StorageConstants.IS_PAUSED) isPaused: boolean = true
  @StorageProp(StorageConstants.PIC_URL) picUrl: string = ''
  @StorageProp(StorageConstants.PLAY_TIME) time: number = 0
  @StorageProp('player-currentLyric') currentLyric: string = ''
  @State componentOpacity: number = 0.8
  @State isShow: boolean = false
  @Consume('pageInfos') pageInfos: NavPathStack

  build() {
    Row() {
      if(this.playmode == 0) { Image($r('app.media.ic_public_music')).fillColor($r('app.color.reverse')).songImg() }
      else { Image(this.picUrl + '?param=512y512').songImg() }

      Column({ space: 5 }) {
        Text(this.song.name).textStyle(18).textOverflow({ overflow: TextOverflow.MARQUEE }).fontWeight(FontWeight.Medium)
        if(!this.currentLyric || this.currentLyric === '暂无歌词') {
          Text(this.artists).textStyle(14).textOverflow({ overflow: TextOverflow.MARQUEE }).layoutWeight(1)
        }
        else {
          Text(this.currentLyric).textStyle(14).textOverflow({ overflow: TextOverflow.MARQUEE }).layoutWeight(1)
        }
      }
      .padding({ top: 15, bottom: 15 })
      .layoutWeight(1)

      ControlButtons({ isPaused: this.isPaused, isPlaying: this.isPlaying })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .layoutWeight(1)
    .backdropBlur(50)
    .padding({ left:10, right:10 })
    .width('100%')
    .borderRadius(20)
    .backgroundColor($r('app.color.main'))
    .opacity(this.isShow ? this.componentOpacity : this.componentOpacity)
    .height(80)
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
    .onClick(() => {
      if(this.isPlaying) {
        this.isShow = true
      }
      else { ToastUtil.showToast('当前无正在播放歌曲') }
    })
    .bindContentCover(this.isShow, this.Cover(), {
      modalTransition: ModalTransition.DEFAULT,
      backgroundColor: $r('app.color.background'),
      onDisappear: () => {
        this.isShow = false
      }
    })
  }

  @Builder
  Cover() {
    PlayingCover({ isShow: this.isShow })
      .height('100%')
  }
}

@Component
struct ControlButtons {
  @Link isPaused: boolean
  @Link isPlaying: boolean
  build() {
    Row({ space: 10 }) {
      if (!this.isPaused) {
        Button() {
          Image($r('app.media.ic_public_pause')).fillColor(Color.Gray).buttonImgStyle()
        }.onClick(() => {
          pauseMusic()
        }).backgroundColor(Color.Transparent)
      } else {
        Button() {
          Image($r('app.media.ic_play_fill')).fillColor(Color.Gray).buttonImgStyle()
        }
        .onClick(() => {
          if(!this.isPlaying) playQueue(playQueueUtils.currentQueueIndex)
          else resumeMusic()
        })
        .backgroundColor(Color.Transparent)
      }
      PlayQueueButton()
    }
  }
}

@Extend(Image) function buttonImgStyle() {
  .aspectRatio(1)
  .width(30)
  .fillColor($r('app.color.reverse'))
}

@Extend(Text) function textStyle(size:number) {
  .fontSize(size)
  .fontColor($r('app.color.reverse'))
  .maxLines(1)
  .padding({ left:10, right:10 })
  .textOverflow({ overflow: TextOverflow.MARQUEE })
}

@Extend(Image) function songImg() {
  .sharedTransition('PlayerPic', { duration: 500 })
  .geometryTransition('PlayerPic')
  .width(50)
  .height(50)
  .borderRadius(10)
}