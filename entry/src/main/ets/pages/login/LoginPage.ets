import { CommonHead } from '../../components/head/CommonHead'
import { promptAction, router } from '@kit.ArkUI';

/**
 * 登录页面
 */

@Entry
@Component
struct LoginPage {
  build() {
    Stack() {
      Column({ space: 30 }) {
        CommonHead({ title: '登录' })

        Text('登录账号')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.reverse'))
          .padding({ bottom: 10 })

        Row() {
          // 网页登录
          LoginTypeButton({
            icon: $r('app.media.ic_celiakeyboard_default'),
            bgColor: Color.Orange,
            text: '网页登录',
            ClickOp: () => {
              router.replaceUrl({ url:'pages/login/WebLogin' })
            }
          })

          // 二维码登录
          LoginTypeButton({
            icon: $r('app.media.ic_public_input_code'),
            bgColor: Color.Red,
            text: '二维码登录',
            ClickOp: () => {
              router.replaceUrl({ url:'pages/login/QrCodeLogin' })
            }
          })
        }
        .width('80%')
        .justifyContent(FlexAlign.SpaceEvenly)
      }
      .height('100%')
      .width('100%')
    }
    .backgroundColor($r('app.color.background'))
    .width('100%')
    .height('100%')
  }
}

@Component struct LoginTypeButton {
  @State icon: string | ResourceStr = ''
  @State bgColor: string | Color | ResourceStr = Color.Transparent
  @State text: string = ''
  ClickOp: () => void = () => {}

  build() {
    Column({ space: 15 }) {
      Button() {
        Image(this.icon)
          .fillColor(Color.White)
          .height('60%')
      }
      .backgroundColor(this.bgColor)
      .aspectRatio(1)
      .width('70%')
      .onClick(() => {
        this.ClickOp()
      })

      Text(this.text)
        .fontColor($r('app.color.reverse'))
        .fontSize(14)
    }
    .aspectRatio(1)
    .width(100)
    .backgroundColor(Color.Transparent)
  }
}
