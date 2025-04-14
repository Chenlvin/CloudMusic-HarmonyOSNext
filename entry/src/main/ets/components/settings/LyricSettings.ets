import Constants from "../../common/constants/Constants";
import { StorageConstants } from "../../common/constants/StorageConstants";
import { FloatLyric, FloatLyricItem,
  LyricPosition,
  LyricStyle, LyricStyleItem } from "../../common/entities/local/Settings";
import { changeSettings } from "../../common/functions/app/settings";
import WindowUtils from "../../common/utils/system/WindowUtils";

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
export struct SetFloatLyric {
  @StorageProp(StorageConstants.FLOAT_LYRIC_STYLE) floatLyric: FloatLyric = FloatLyricItem
  @State wid: number = 0
  @State fontsize: number = 0
  @State fontopacity: number = 0
  @State bgBlur: boolean = false
  @State isOn: boolean = false
  @State setPosition: LyricPosition = { x: 0, y: 0 }
  @State fontCenter: boolean = false
  @State lyricDraggable: boolean = false

  aboutToAppear(): void {
    this.isOn = this.floatLyric.on
    this.wid = this.floatLyric.width
    this.fontsize = this.floatLyric.size
    this.fontopacity = this.floatLyric.opacity
    this.bgBlur = this.floatLyric.bgBlur
    this.setPosition = this.floatLyric.position
    this.fontCenter = this.floatLyric.align === 'center' ? true : false
    this.lyricDraggable = this.floatLyric.touchable
  }

  build() {
    Column({ space: 20 }) {
      ToggleSettingItem({ name: '启用悬浮歌词', value: this.isOn,
        onaction: () => { this.floatLyric.on = true; WindowUtils.createLyricsFloatWindow() },
        offaction:() => { this.floatLyric.on = false; WindowUtils.destoryLyricFloatWindow() },
        action: () => { this.updateFloatLyric() }
      })

      ToggleSettingItem({ name: '背景模糊', value: this.bgBlur,
        action: () => {
          this.floatLyric.bgBlur = this.bgBlur
          this.updateFloatLyric()
        }})

      ToggleSettingItem({ name: '是否可拖动', value: this.lyricDraggable,
        action: () => {
          this.floatLyric.touchable = this.lyricDraggable
          this.updateFloatLyric()
        }})

      ToggleSettingItem({ name: '悬浮歌词居中', value: this.fontCenter,
        onaction: () => { this.floatLyric.align = 'center' },
        offaction: () => { this.floatLyric.align = 'end' },
        action: () => { this.updateFloatLyric() }
      })

      SliderSettingItem({ name: '悬浮歌词字体大小', min: 5, max: 22, targetValue: this.fontsize, changeAction: () => {
        this.floatLyric.size = this.fontsize; this.updateFloatLyric()
      }})

      SliderSettingItem({ name: '悬浮歌词宽度', min: 10, max: 100, isPercent: true, targetValue: this.wid, changeAction: () => {
        this.floatLyric.width = this.wid; this.updateFloatLyric()
      }})

      SliderSettingItem({ name: '悬浮歌词透明度', min: 0.1, max: 1, targetValue: this.fontopacity, changeAction: () => {
        this.floatLyric.opacity = this.fontopacity; this.updateFloatLyric()
      }})

      SliderSettingItem({ name: '上下调节', min: 0.1, max: 1, targetValue: this.fontopacity, changeAction: () => {
        this.floatLyric.opacity = this.fontopacity; this.updateFloatLyric()
      }})
    }
  }

  private updateFloatLyric() {
    changeSettings(StorageConstants.FLOAT_LYRIC_STYLE, this.floatLyric)
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

@Component struct ToggleSettingItem {
  name: string = ''
  onaction = () => {}
  offaction = () => {}
  action = () => {}
  @Link value: boolean

  build() {
    Row() {
      Text(this.name)
        .fontSize(Constants.FONT_SIZE_COMMON)
        .fontWeight(FontWeight.Bold)
      Toggle({ type: ToggleType.Switch, isOn: this.value })
        .height(24)
        .width(48)
        .onChange((isOn) => {
          this.value = isOn
          isOn ? this.onaction() : this.offaction()
          this.action()
        })
        .selectedColor($r('app.color.app_red'))
    }
    .height(Constants.HEIGHT_SETTINGS_ITEM)
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
  }
}

@Component struct SliderSettingItem {
  @Link targetValue: number
  name: string = ''
  isPercent: boolean = false
  min: number = 0
  max: number = 0
  changeAction = (): void => {}

  build() {
    Column() {
      Row() {
        Text(this.name)
          .fontSize(Constants.FONT_SIZE_COMMON)
          .fontWeight(FontWeight.Bold)
        Text(this.isPercent ? `${this.targetValue}%` : `${this.targetValue.toFixed(this.max === 1 ? 1 : 0)}`)
          .fontSize(Constants.FONT_SIZE_COMMON)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ top: 10, left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })

      Slider({
        value: this.targetValue,
        min: this.min,
        max: this.max,
        step: this.max === 1 ? 0.1 : 1
      })
        .selectedColor($r('app.color.app_red'))
        .width('100%')
        .onChange((value, mode) => {
          if (mode == SliderChangeMode.Moving) {
            animateTo({ duration: 100, curve: Curve.Linear }, () => {
              this.targetValue = value
              this.changeAction()
            })
            return
          }
        })
    }
  }
}
