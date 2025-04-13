import Constants from "../../common/constants/Constants";
import { StorageConstants } from "../../common/constants/StorageConstants";
import { LyricStyle, LyricStyleItem } from "../../common/entities/local/Settings";
import { changeSettings } from "../../common/functions/app/settings";

@Component
export struct LyricTranslate {
  @StorageProp(StorageConstants.LYRIC_STYLE) lyricStyle: LyricStyle = LyricStyleItem

  build() {
    Row() {
      Text('启用歌词翻译')
        .fontSize(Constants.FONT_SIZE_COMMON)
        .fontWeight(FontWeight.Bold)
      Toggle({ type: ToggleType.Switch, isOn: this.lyricStyle.mode == 1 })
        .height(24)
        .width(48)
        .onChange((isOn) => {
          if(!isOn) {
            this.lyricStyle.mode = 0
          } else {
            this.lyricStyle.mode = 1
          }
          changeSettings(StorageConstants.LYRIC_STYLE, this.lyricStyle)
        })
        .selectedColor($r('app.color.app_red'))
    }
    .height(Constants.HEIGHT_SETTINGS_ITEM)
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
}

@Component
export struct SetLyricStyle {
  @StorageProp(StorageConstants.LYRIC_STYLE) lyricStyle: LyricStyle = LyricStyleItem
  @State style: LyricStyle = LyricStyleItem

  aboutToAppear(): void {
    this.style = this.lyricStyle
  }

  build() {
    Column({ space: 20 }) {
      Row() {
        Text('歌词居中显示')
          .fontSize(Constants.FONT_SIZE_COMMON)
          .fontWeight(FontWeight.Bold)
        Toggle({ type: ToggleType.Switch, isOn: this.lyricStyle.align === 'center' })
          .height(24)
          .width(48)
          .onChange((isOn) => {
            if(isOn) {
              this.lyricStyle.align = 'center'
            } else {
              this.lyricStyle.align = 'start'
            }
            changeSettings(StorageConstants.LYRIC_STYLE, this.lyricStyle)
          })
          .selectedColor($r('app.color.app_red'))
      }
      .height(Constants.HEIGHT_SETTINGS_ITEM)
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ top: 10, left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })

      Row() {
        Text('歌词字体大小')
          .fontSize(Constants.FONT_SIZE_COMMON)
          .fontWeight(FontWeight.Bold)
        Text(this.lyricStyle.size.toString())
          .fontSize(Constants.FONT_SIZE_COMMON)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ top: 10, left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })

      Slider({
        value: this.style.size,
        min: 10,
        max: 30
      })
        .selectedColor($r('app.color.app_red'))
        .width('100%')
        .onChange((value, mode) => {
          if(mode == SliderChangeMode.Moving) {
            animateTo({ duration: 100, curve: Curve.Linear}, () => {
              this.style.size = value
            })
            return
          }
          this.lyricStyle.size = value
          this.updateLyricStyle()
        })

      Text('效果预览')
        .fontSize(Constants.FONT_SIZE_COMMON)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Start)
        .padding(Constants.PADDING_EDGE_DEFAULT)

      Column({ space: 15 }) {
        Text('When your dreams come alive you\'re unstoppable')
          .lyricStyle(this.lyricStyle.size, this.lyricStyle.align).scale({ x: 0.9, y: 0.9, centerX: this.lyricStyle.align === 'center' ? '50%' : 0 })
        Text('我一路向北 离开有你的季节')
          .lyricStyle(this.lyricStyle.size, this.lyricStyle.align).opacity(1)
        Text('君と集まって星座になれたら')
          .lyricStyle(this.lyricStyle.size, this.lyricStyle.align).scale({ x: 0.9, y: 0.9, centerX: this.lyricStyle.align === 'center' ? '50%' : 0})
      }
      .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
    }

  }

  private updateLyricStyle() {
    this.style = this.lyricStyle
    changeSettings(StorageConstants.LYRIC_STYLE, this.style)
  }
}

@Component
export struct FloatLyrics {
  @StorageProp(StorageConstants.FLOAT_LYRICS_TOUCHABLE) lyricsTouchable: boolean = true

  build() {
    Row() {
      Text('悬浮歌词是否可拖动')
        .fontSize(Constants.FONT_SIZE_COMMON)
        .fontWeight(FontWeight.Bold)
      Toggle({ type: ToggleType.Switch, isOn: this.lyricsTouchable === true })
        .height(24)
        .width(48)
        .onChange((isOn) => {
          if(!isOn) {
            this.lyricsTouchable = false;
          } else {
            this.lyricsTouchable = true;
          }
          changeSettings(StorageConstants.FLOAT_LYRICS_TOUCHABLE, this.lyricsTouchable)
        })
        .selectedColor($r('app.color.app_red'))
    }
    .height(Constants.HEIGHT_SETTINGS_ITEM)
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
}

@Extend(Text) function lyricStyle(size: number, align: string) {
  .width('100%')
  .textAlign(TextAlign.Center)
  .fontSize(size)
  .fontColor($r('app.color.reverse'))
  .opacity(0.35)
  .fontWeight(FontWeight.Bold)
  .textAlign(align === 'center' ? TextAlign.Center : TextAlign.Start)
}
