import { getDownloadInfo } from "../../api/getDownloadInfo"
import { SongDownload, SongDownloadClass } from "../../common/entities/SongDownload"
import { Song, SongClass } from "../../common/entities/SongsResult"
import { pasteboard } from "@kit.BasicServicesKit"
import { promptAction } from "@kit.ArkUI"
import FileDownloadUtils from "../../common/utils/file/FileDownloadUtils"
import { LogUtil, ToastUtil } from "@pura/harmony-utils"
import { PlayConstants } from "../../common/constants/PlayConstants"
import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"

@CustomDialog
export struct DownloadDialog {
  @StorageProp(StorageConstants.IS_LOGGED) isLogged: boolean = false
  @State isLoading:boolean = false
  @State songDownload:SongDownload = SongDownloadClass
  @State succ:boolean = true
  @State song: Song = SongClass
  @State picUrl: string = ''
  @State artists: string = ''
  @State duration: string = ''
  @State quality: number = 3 // Constants.QUALITY[quality] -> string
  fileSize: number = -1

  controller: CustomDialogController

  async handleInfo() {
    this.isLoading = true
    try {
      const gotDownloadData: SongDownload =
        await getDownloadInfo(this.song.id, PlayConstants.QUALITY[this.quality], this.isLogged)
      this.songDownload = gotDownloadData
      if (this.songDownload.data[0].url == null) {
        this.succ = false
      }
      this.fileSize = await convertSize(this.songDownload.data[0].size)
    } catch (e) {
      this.succ = false
      LogUtil.error('Download Dialog Error: ' + e.message)
    } finally {
      this.isLoading = false
    }
  }

  async aboutToAppear(): Promise<void> {
    await this.handleInfo()
  }

  build() {
    Column({ space: 10 }) {
      Select([{ value: '标准' }, { value: '高' }, { value: '极高' }, { value: '无损' }])
        .selected(this.quality)
        .value(this.quality ? PlayConstants.QUALITY_NAME[this.quality] : '标准')
        .onSelect((index) => {
          if(index != this.quality) {
            this.quality = index
            this.handleInfo()
          }
        })
      Divider()
      if(this.succ) {
        Stack() {
          if (this.isLoading) {
            LoadingProgress().width(Constants.SIZE_LOADING_PROGRESS_CARD)
          }
          Column({ space: 10 }) {
            Stack() {
              LoadingProgress().width(40)
              Image(this.picUrl)
                .width(128)
                .aspectRatio(1)
            }
            .width(128)
            .aspectRatio(1)

            Text(this.song.name).textStyle(20)
            Text(this.artists).textStyle(14)
            Divider()
            Text(`时长 ${this.duration}`).textStyle(12)
            Text(`音质: ${this.songDownload.data[0].level}     格式: ${this.songDownload.data[0].type}     大小: ${this.fileSize}MB`)
              .textStyle(12)
            Button('获取文件地址').ButtonStyle()
              .onClick(() => {
                copyDownloadUrl(this.songDownload.data[0].url)
              })
            Button('缓存至应用沙箱').ButtonStyle()
              .onClick(() => {
                ToastUtil.showToast(`开始缓存：${this.song.name}.${this.songDownload.data[0].type}`)
                this.controller.close()
                FileDownloadUtils.download(this.songDownload,this.song,this.artists)
              })
            if (!this.isLogged) {
              Text('你尚未登录，将无法完整获取部分会员歌曲')
            }
          }
          .opacity(this.isLoading ? 0 : 1)
        }
      } else {
        Text('获取歌曲内容失败，原因可能如下：').textStyle(18)
        Text('- 此歌曲需要单曲付费或为数字专辑曲目\n' +
          '- 当前未登录账号，无法获取试听链接\n' +
          '- 当前登录账号非会员，公共Cookie失效').textStyle(14)
      }
    }
    .backgroundColor(Color.Transparent)
    .backdropBlur(20)
    .margin({ left:10, right:10, top:20, bottom:20})
    .borderRadius(5)
  }
}



@Extend(Text) function textStyle(size:number) {
  .fontSize(size)
  .fontColor($r('app.color.reverse'))
  .textAlign(TextAlign.Center)
}

@Extend(Button) function ButtonStyle() {
  .backgroundColor(Color.Transparent)
  .borderWidth(2)
  .borderColor(Color.Gray)
  .fontColor($r('app.color.reverse'))
}

async function convertSize(size: number): Promise<number> {
  if (size < 0) {
    throw new Error("输入值不能为负数");
  }
  const mb = size / 1024 / 1024;
  return parseFloat(mb.toFixed(2));
}

function copyDownloadUrl(url:string) {
  const pasteboardData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, url)
  const systemPasteboard = pasteboard.getSystemPasteboard()
  systemPasteboard.setData(pasteboardData)
  promptAction.showToast({ message: '成功复制到剪切板' })
}