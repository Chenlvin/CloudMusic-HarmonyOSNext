import { Song, SongItem } from "../entities/song/Song"
import { changeDuration } from "../functions/common/convert"
import { pauseMusic, playNext, playPre, resumeMusic, seekMusic } from "../functions/play/playControl"
import { AddToPlayListCircleButton } from "../../components/buttons/play/AddToPlayListButton"
import { LoopModeButton } from "../../components/buttons/play/LoopModeButton"
import { PlayQueueButton } from "../../components/buttons/play/PlayQueueButton"
import { DownloadDialog } from "../../components/dialog/DownloadDialog"
import { LyricComponent } from "../../components/play/LyricComponent"
import { AVCastPicker } from "@kit.AVSessionKit"
import { TimerButton } from "../../components/buttons/play/TimerButton"
import { StorageConstants } from "../constants/StorageConstants"
import Constants from "../constants/Constants"
import { ClickUtil, EmitterUtil, PasteboardUtil, ToastUtil } from "@pura/harmony-utils"
import { PlayerActionSheet } from "../../components/sheets/PlayerActionSheet"
import { likeThisSong } from "../functions/play/songLike"
import { resourceManager } from "@kit.LocalizationKit"
import { PlayConstants } from "../constants/PlayConstants"
import { ArtistsSheet } from "../../components/sheets/ArtistsSheet"
import { window } from "@kit.ArkUI"
import OrientationUtils from "../utils/system/WindowUtils"
import { PlaySettingsPage } from "../../pages/settings/PlaySettingsPage"
import { EmitterConstants } from "../constants/EmitterConstants"
import { PLAYMODE } from "../model/Enum"
import { PersonalFmMenu } from "../../components/menu/PersonalFmMenu"
import { BreakpointType } from "../model/Breakpoint"

@Component
export struct Player {
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp(StorageConstants.PLAY_MODE) playmode: PLAYMODE = PLAYMODE.SINGLE
  @StorageProp(StorageConstants.PLAY_SONG) song: Song = SongItem
  @StorageProp(StorageConstants.PLAY_ARTISTS) artists: string = ''
  @StorageProp(StorageConstants.IS_PAUSED) isPaused: boolean = false
  @StorageProp(StorageConstants.PIC_URL) picUrl: string = ''
  @StorageProp(StorageConstants.PLAY_TIME) time: number = 0
  @StorageProp(StorageConstants.ISLIKED) isLiked: boolean = false
  @StorageProp(StorageConstants.PLAY_COUNTDOWN_WORKING) isTimerWorking: boolean = false
  @StorageProp(StorageConstants.PLAY_IS_LOCALFILE) isLocalFile: boolean = false
  @StorageProp(StorageConstants.IS_PERSONAL_FM) isPersonalFm: boolean = false
  @StorageProp(StorageConstants.PERSONAL_FM_MODE) personalFmMode: number = 0
  @StorageProp(StorageConstants.BREAKPOINT_WIDTH) widBp: string = 'sm'
  @StorageProp(StorageConstants.BREAKPOINT_HEIGHT) heightBp: string = 'md'
  @StorageProp(StorageConstants.DEVICE_TYPE) deviceType: resourceManager.DeviceType = resourceManager.DeviceType.DEVICE_TYPE_PHONE
  @Link isShow: boolean
  @State sliderThickness: number = 10
  @State isMovingSlider: boolean = false
  @State sliderMovingTime: number = 0
  @State tabPageIndex: number = 0
  @State isShowMenu: boolean = false
  @State isShowTimer: boolean = false
  @State isShowAddSheet: boolean = false
  @State isShowArtists: boolean = false
  @State isShowSettings: boolean = false
  @State isLikeProcessing: boolean = false
  @State totalOpacity: number = 0
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: DownloadDialog({
      song: this.song,
      picUrl: this.picUrl,
      artists: this.artists,
      duration: changeDuration(this.song.duration)
    }),
  })

  private settingsSheetOptions: SheetOptions = {
    backgroundColor: Color.Transparent,
    showClose: true,
    height: SheetSize.LARGE,
    dragBar: false,
    blurStyle: BlurStyle.Regular,
    preferType: SheetType.CENTER,
    onDisappear: () => { this.isShowSettings = false }
  }

  private artistsSheetOptions: SheetOptions = {
    preferType: SheetType.CENTER,
    height: SheetSize.FIT_CONTENT,
    dragBar: false,
    showClose: false,
    backgroundColor: Color.Transparent,
    blurStyle: BlurStyle.Regular,
    onDisappear: () => { this.isShowArtists = false }
  }

  aboutToAppear(): void {
    setTimeout(() => {
      animateTo({ duration: 300, curve: Curve.EaseInOut }, () => {
        this.totalOpacity = 0.7
      })
      EmitterUtil.onSubscribe(EmitterConstants.PLAYING_COVER_TOGGLE, (toggle: boolean) => {
        this.isShow = toggle
      })
    }, 500)
  }

  aboutToDisappear(): void {
    OrientationUtils.setOrientation(window.Orientation.AUTO_ROTATION_UNSPECIFIED)
    EmitterUtil.unSubscribe(EmitterConstants.PLAYING_COVER_TOGGLE)
  }

  // Slider OnChange
  private handleSliderChange = (value: number, mode: SliderChangeMode) => {
    animateTo({ duration: 500, curve: Curve.Smooth, }, () => {
      if (mode == SliderChangeMode.Begin) {
        this.isMovingSlider = true
        this.sliderMovingTime = value
        this.sliderThickness = 15
      } else if (mode == SliderChangeMode.Moving) {
        this.sliderMovingTime = value
      } else if (mode == SliderChangeMode.End) {
        this.time = value
        this.sliderThickness = 10
        this.isMovingSlider = false
        seekMusic(this.sliderMovingTime)
      }
    })
  }

  build() {
   Stack() {
     // Background
     Stack() {
       Image(this.playmode === PLAYMODE.LOCAL ? $r('app.media.bg_default') : this.picUrl + '?param=512y512')
         .blur(100)
         .width('100%')
         .height('100%')
         .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
       Column()
         .width('100%')
         .height('100%')
         .opacity(0.6)
         .backgroundColor(Color.Black)
         .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
     }
     .width('100%')
     .height('100%')

     /**
      * 主内容
      */
     if(this.widBp !== 'sm' && this.heightBp === 'md') {
       this.LargeUI()
     } else if(this.heightBp === 'sm' && this.widBp !== 'sm') {
       this.PhoneLargeUI()
     } else {
       this.PhoneUI()
     }

     /**
      * Head栏
      */
     this.Head()
   }
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .bindSheet(this.isShowSettings, this.SettingsSheet(), this.settingsSheetOptions)
  }

  /**
   * 功能栏
   */
  @Builder
  ToolBar(size: number = 25, width: number | string = '100%') {
    Row() {
      /**
       * Clock-Timer
       */
      TimerButton({ isTimerWorking: this.isTimerWorking, isShow: this.isShowTimer })
        .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.7 })
      if (this.song.id !== 0) {
        /**
         * Download
         */
        Image($r('app.media.ic_arrow_down_o_icon'))
          .fillColor(Color.White)
          .height(size)
          .aspectRatio(1)
          .draggable(false)
          .backgroundColor(Color.Transparent)
          .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.7 })
          .onClick(() => {
            this.dialogController.open()
          })

        /**
         * AddToPlayList
         */
        AddToPlayListCircleButton({
          song: this.song,
          imgColor: Color.White,
          imgHeight: size + 4,
          isShowAddSheet: this.isShowAddSheet,
          isLarge: (this.widBp === 'md' && this.heightBp === 'sm')
        })
          .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.7 })
          .visibility(this.playmode !== 3 ? Visibility.Visible : Visibility.None)

        /**
         * Heart
         */
        Image(this.isLiked ? $r('app.media.ic_public_favor_filled') : $r('app.media.ic_public_favor'))
          .fillColor(Color.White)
          .height(size)
          .aspectRatio(1)
          .draggable(false)
          .backgroundColor(Color.Transparent)
          .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.7 })
          .visibility(this.playmode !== 3 ? Visibility.Visible : Visibility.None)
          .onClick(async () => {
            if(this.isLikeProcessing) return
            this.isLikeProcessing = true
            try {
              await likeThisSong()
            } finally {
              this.isLikeProcessing = false
            }
          })
      }

      /**
       * More
       */
      Image($r('app.media.ic_more_vertical_o_icon'))
        .fillColor(Color.White)
        .height(size - 2)
        .aspectRatio(1)
        .draggable(false)
        .backgroundColor(Color.Transparent)
        .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.7 })
        .bindSheet(this.isShowMenu, this.PlayerActionSheet(), {
          backgroundColor: Color.Transparent,
          showClose: false,
          height: (this.widBp === 'md' && this.heightBp === 'sm') ? SheetSize.LARGE : SheetSize.MEDIUM,
          dragBar: false,
          blurStyle: BlurStyle.Regular,
          preferType: SheetType.CENTER,
          onDisappear: () => { this.isShowMenu = false }
        })
        .onClick(() => {
          this.isShowMenu = true
        })
    }
    .justifyContent(FlexAlign.SpaceEvenly)
    .width(width)
    .height(size + 5)
    .opacity(0.6)
    .animation({ duration: 300, curve:Curve.Ease })
    .visibility(this.tabPageIndex == 0 ? Visibility.Visible : Visibility.None)
  }

  /**
   * 进度条组件
   */
  @Builder
  SliderContent(isPhoneLarge: boolean = false) {
    Column({ space: isPhoneLarge ? 0 : 5 }) {
      Row() {
        // 当前时间
        Text(`${changeDuration(this.time)}`)
          .fontSize(isPhoneLarge ? 12 : Constants.FONT_SIZE_COMMON)
          .textAlign(TextAlign.Start)
          .fontColor(Color.White)
          .opacity(this.tabPageIndex == 0 ? 0.7 : 0.1)
          .alignSelf(ItemAlign.Start)
          .layoutWeight(1)

        // 拖动进度条时，显示即将跳转的时间
        Text(`${changeDuration(this.sliderMovingTime)}`)
          .fontSize(isPhoneLarge ? 12 : Constants.FONT_SIZE_COMMON)
          .fontColor(Color.White)
          .backgroundColor(Color.Gray)
          .borderRadius(Constants.RADIUS_CARD)
          .textAlign(TextAlign.Center)
          .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
          .alignSelf(ItemAlign.Center)
          .visibility(this.isMovingSlider ? Visibility.Visible : Visibility.Hidden)

        // 总时间
        Text(`${changeDuration(this.song.duration)}`)
          .fontSize(isPhoneLarge ? 12 : Constants.FONT_SIZE_COMMON)
          .textAlign(TextAlign.End)
          .fontColor(Color.White)
          .opacity(this.tabPageIndex == 0 ? 0.7 : 0.1)
          .alignSelf(ItemAlign.End)
          .layoutWeight(1)
      }
      .width('90%')

      // 进度条
      Slider({
        value: this.time,
        min: 0,
        max: this.song.duration,
        step: 1,
        style: SliderStyle.InSet
      })
        .width('90%')
        .trackColor(Color.Gray)
        .trackThickness(this.sliderThickness)
        .selectedColor(Color.White)
        .showSteps(false)
        .showTips(false)
        .opacity(this.tabPageIndex == 0 ? 0.7 : 0.1)
        .onChange(this.handleSliderChange)
    }
    .width(isPhoneLarge ? '90%' : '100%')
  }
  /**
   * PlayButton
   * 控制上一首、下一首、播放和暂停
   */
  @Builder
  PlayButton(size: number) {
    // 上一首
    Image($r('app.media.ic_public_play_last')).buttonImgStyle(size)
    .onClick(() => {
      ClickUtil.throttle(() => {
        playPre()
      }, 500)
    })

    // 暂停、继续
    Image(!this.isPaused ? $r('app.media.ic_public_pause') : $r('app.media.ic_play_fill')).buttonImgStyle(size)
      .onClick(() => {
        if(this.isPaused) {
          resumeMusic()
        } else {
          pauseMusic()
        }
      })

    // 下一首
    Image($r('app.media.ic_public_play_next')).buttonImgStyle(size)
    .onClick(() => {
      ClickUtil.throttle(() => {
        playNext()
      }, 500)
    })
  }

  /**
   * Head
   */
  @Builder
  Head() {
    Row() {
      Button({ type: ButtonType.Circle }) { Image($r('app.media.ic_public_arrow_down_0')).draggable(false).fillColor(Color.White).width(Constants.SIZE_ICON_BUTTON_COMMON).aspectRatio(1) }
      .backgroundColor(Color.Transparent)
      .onClick(() => { this.isShow = false })

      /**
       * AVCastPicker
       */
      Column() {
        AVCastPicker({
          normalColor: Color.White,
          sessionType: 'audio'
        })
          .width(23)
          .height(23)
          .backgroundColor(Color.Transparent)
      }
    }
    .position({ top: 0 })
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ top: px2vp(this.topRectHeight) + 5 , left: 10, right: 10, bottom: 5 })
    .opacity(this.totalOpacity)
  }

  /**
   * Information
   */
  @Builder
  SongInfo() {
    Column({ space: 20 }) {
      this.PersonalFmButton()

      // 歌曲封面图片
      Column() {
        Image(this.playmode === 0 ? this.picUrl : this.picUrl + '?param=512y512')
          .height(this.song.id === 0 ? '70%' : '100%')
          .borderRadius(5)
          .aspectRatio(1)
      }
      .justifyContent(FlexAlign.Center)
      .constraintSize({
        minHeight: 0,
        maxHeight: new BreakpointType<number>(300, 300, 500).getValue(this.widBp)
      })
      .layoutWeight(1)
      .padding({ bottom: 30 })

      // 歌曲名称&艺术家
      Text(this.song.name)
        .textStyle(24)
        .fontWeight(FontWeight.Bold)
        .onClick(() => {
          PasteboardUtil.setDataText(this.song.name)
          ToastUtil.showToast('已复制歌名到剪贴板', { duration: 3000 })
        })
      Text(this.artists)
        .textStyle(16)
        .onClick(() => {
          if(this.song.id !== 0 && this.playmode !== 3) {
            this.isShowArtists = true
          }
        })
        .bindSheet(this.isShowArtists, this.ArtistsSheet(), this.artistsSheetOptions)
    }
    .layoutWeight(1)
    .height('100%')
    .width('100%')
    .padding({ left: 15, right: 15, top: px2vp(this.topRectHeight) + Constants.PADDING_EDGE_TEXT })
    .justifyContent(FlexAlign.Center)
    .gesture(
      SwipeGesture({
        fingers: 1,
        direction: SwipeDirection.Vertical
      }).onAction(() => { this.isShow = false })
    )
  }

  @Builder PhoneLargeSongInfo() {
    Column({ space: 5 }) {
      Column({ space: 5 }) {
        // 歌曲封面图片
        Stack({ alignContent: Alignment.Bottom }) {
          Image(this.playmode === 0 ? this.picUrl : this.picUrl + '?param=512y512')
            .height(this.song.id == 0 ? '70%' : '100%')
            .borderRadius(5)
            .aspectRatio(1)
        }
        .height('80%')
        .padding({ bottom: 10 })
      }
      .width('100%')

      // 歌曲名称&艺术家
      Row() {
        this.PersonalFmButton()
        Text(this.song.name + ' - ' + this.artists)
          .textStyle(18)
          .layoutWeight(1)
          .textAlign(this.isPersonalFm ? TextAlign.Start : TextAlign.Center )
          .fontWeight(Constants.FONT_WEIGHT_BOLD)
          .onClick(() => {
            if(this.song.id !== 0 && this.playmode !== 3) {
              this.isShowArtists = true
            }
          })
          .bindSheet(this.isShowArtists, this.ArtistsSheet(), this.artistsSheetOptions)
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
      .justifyContent(FlexAlign.Center)
    }
    .layoutWeight(1)
    .padding(10)
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .gesture(
      SwipeGesture({
        fingers: 1,
        direction: SwipeDirection.Vertical
      }).onAction(() => { this.isShow = false })
    )
  }

  @Builder ControllButtons() {
    Row() {
      LoopModeButton({ imgWidth: 30, btnWidth: 30, imgColor: Color.White }).opacity(0.8)
      this.PlayButton(45)
      PlayQueueButton({ imgWidth: 30, imgColor: Color.White }).opacity(0.8)
    }
    .opacity(this.tabPageIndex == 0 ? 0.8 : 0.2)
    .padding({ top: Constants.PADDING_EDGE_DEFAULT, bottom: Constants.PADDING_EDGE_DEFAULT })
    .justifyContent(FlexAlign.SpaceEvenly)
    .width('90%')
  }

  @Builder PhoneUI() {
    Column() {
      Swiper() {
        this.SongInfo()
        LyricComponent()
          .padding({ top: px2vp(this.topRectHeight) })
          .width('100%')
      }
      .indicator(
        new DotIndicator()
          .top(px2vp(this.topRectHeight) + 5)
          .selectedColor(Color.White)
          .color(Color.Gray)
      )
      .clip(false)
      .loop(false)
      .layoutWeight(1)
      .onAnimationStart((from, target) => {
        animateTo({ duration: 300, curve: Curve.EaseInOut }, () => {
          this.tabPageIndex = target
        })
      })

      Column({ space: 10 }) {
        this.SliderContent()
        this.ToolBar()
        this.ControllButtons()

        if(this.tabPageIndex == 0) {
          Row({ space: 15 }) {
            if(this.isLocalFile || this.playmode == 0) { Text('本地文件播放中').fontSize(10).fontColor(Color.Gray) }
            if(this.isTimerWorking) { Text('已设置定时关闭').fontSize(10).fontColor(Color.Gray) }
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .height(20)
          .backgroundColor(Color.Transparent)
        }
      }
      .constraintSize({
        minWidth: 200,
        maxWidth: 500
      })
      .width('100%')
    }
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder LargeUI() {
    Row() {
      Column({ space: 5 }) {
        Column() {
          this.SongInfo()
        }
        .layoutWeight(1)

        Column({ space: 10 }) {
          this.SliderContent()
          this.ToolBar()
          this.ControllButtons()
          Row({ space: 15 }) {
            if(this.isLocalFile || this.playmode == 0) { Text('本地文件播放中').fontSize(10).fontColor(Color.Gray) }
            if(this.isTimerWorking) { Text('已设置定时关闭').fontSize(10).fontColor(Color.Gray) }
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .height(10)
          .backgroundColor(Color.Transparent)
        }
        .width(this.deviceType === resourceManager.DeviceType.DEVICE_TYPE_TABLET ? '70%' : '90%')
      }
      .layoutWeight(1)

      LyricComponent()
        .width('100%')
        .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .onAppear(() => { this.tabPageIndex = 0 })
  }

  @Builder PhoneLargeUI() {
    Row() {
      Column() {
        Row({ space: 15 }) {
          if(this.isLocalFile || this.playmode == 0) { Text('本地文件播放中').fontSize(10).fontColor(Color.Gray) }
          if(this.isTimerWorking) { Text('已设置定时关闭').fontSize(10).fontColor(Color.Gray) }
        }
        .padding({ top: 5 })
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .height(10)
        .backgroundColor(Color.Transparent)
        this.PhoneLargeSongInfo()
        Column({ space: 5 }) {
          this.SliderContent(true)
          this.ToolBar(20, '90%')
        }
        .width('90%')
      }
      .padding({ bottom: 5 })
      .width('100%')
      .layoutWeight(1)

      Stack({ alignContent: Alignment.Bottom }) {
        LyricComponent()
          .width('100%')
          .layoutWeight(1)
        Row() {
          LoopModeButton({ imgWidth: 25, btnWidth: 25, imgColor: Color.White }).opacity(0.8)
          this.PlayButton(35)
          PlayQueueButton({ imgWidth: 25, imgColor: Color.White }).opacity(0.8)
        }
        .opacity(0.6)
        .justifyContent(FlexAlign.SpaceEvenly)
        .width('80%')
      }
      .layoutWeight(1)
    }
    .padding({ left: Constants.PADDING_EDGE_TEXT, right: Constants.PADDING_EDGE_TEXT })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .onAppear(() => { this.tabPageIndex = 0 })
  }

  @Builder PersonalFmButton() {
    Button(PlayConstants.PERSONAL_FM_MODE_NAME[this.personalFmMode])
      .fontColor(Color.White)
      .fontSize(Constants.FONT_SIZE_COMMON)
      .backgroundColor(Color.Transparent)
      .backdropBlur(BlurStyle.Regular)
      .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.8 })
      .borderRadius(1)
      .shadow({ radius: 10 })
      .scale((this.widBp === 'md' && this.heightBp === 'sm') ? { centerX: 0.8, centerY: 0.8 } : { centerX: 1, centerY: 1 })
      .visibility(this.isPersonalFm && this.playmode === 1 ? Visibility.Visible : Visibility.None)
      .bindMenu(PersonalFmMenu(this.personalFmMode))
  }

  @Builder PlayerActionSheet() {
    PlayerActionSheet({
      isShow: this.isShowMenu,
      isShowTimer: this.isShowTimer,
      isShowAddSheet: this.isShowAddSheet,
      isShowArtists: this.isShowArtists,
      isShowSettings: this.isShowSettings,
      showOrientation: (this.widBp === 'md' && this.heightBp === 'sm') || (this.widBp === 'sm' && this.heightBp === 'md')
    })
  }

  @Builder ArtistsSheet() {
    ArtistsSheet({ artists: this.song.artists, isShow: this.isShowArtists, isShowCover: this.isShow })
  }

  @Builder SettingsSheet() {
    PlaySettingsPage()
  }
}

@Extend(Text) function textStyle(size:number) {
  .fontSize(size)
  .fontColor(Color.White)
  .maxLines(1)
  .padding({ left: 5, right: 5 })
  .textAlign(TextAlign.Center)
  .textOverflow({ overflow: TextOverflow.MARQUEE })
}

@Extend(Image) function buttonImgStyle(size: number = 50) {
  .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.8 })
  .width(size)
  .fillColor(Color.White)
  .draggable(false)
}

