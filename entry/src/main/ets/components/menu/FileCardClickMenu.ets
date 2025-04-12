import { PasteboardUtil, ToastUtil, LogUtil, DialogUtil, EmitterUtil } from "@pura/harmony-utils"
import Constants from "../../common/constants/Constants"
import { EmitterConstants } from "../../common/constants/EmitterConstants"
import { LocalSong, LocalSongItem } from "../../common/entities/local/LocalData"
import { Song } from "../../common/entities/song/Song"
import { fetchMetadata } from "../../common/functions/common/convert"
import { getLocalSongArtists } from "../../common/functions/common/get"
import { playQueue } from "../../common/functions/play/playControl"
import FileUtils from "../../common/utils/file/FileUtils"
import PlayQueueUtils from "../../common/utils/play/PlayQueueUtils"

@Component
export struct FileCardClickMenu {
  @Prop localSong: LocalSong = LocalSongItem
  @Prop artistsString: string = ''
  @Link showMatchSheet: boolean

  private handlePlay = async () => {
    try {
      const rootUrl = FileUtils.getFilesDir()
      const fileUrl = rootUrl + `/${this.localSong.songFile}`
      const metadata = await fetchMetadata(fileUrl)
      let artists = await getLocalSongArtists(this.localSong.artists)
      let song: Song = {
        id: this.localSong.songId,
        name: this.localSong.name,
        artists: artists,
        album: {
          id: 0,
          name: '',
          picUrl: '',
          artists: [],
          size: 0
        },
        duration: metadata ? ((metadata.duration) ? parseInt(metadata.duration) : 0) : 0,
        alias: [],
        fee: 0
      }
      PlayQueueUtils.queueAdd(0, song, this.artistsString, this.localSong.songFile)
      playQueue(PlayQueueUtils.currentQueueIndex + 1)
    } catch (e) {
      LogUtil.error('Play local song error: ' + e.message)
      ToastUtil.showToast('播放失败')
    }
  }

  private handleDelete = async () => {
    DialogUtil.showPrimaryDialog({
      title: '删除文件',
      message: `确定删除 "${this.localSong.songFile}" ?`,
      primaryButton: "取消",
      secondaryButton: {
        value: '删除',
        fontColor: Color.Red,
        action: async () => {
          try {
            await FileUtils.deleteFile([this.localSong])
            EmitterUtil.post(EmitterConstants.REFRESH_LOCALSONGS, () => {})
          } catch (e) {
            ToastUtil.showToast('删除时出错')
            LogUtil.error('Delete local song error: ' + e.message)
          }
        }
      }
    })
  }

  build() {
    Menu() {
      MenuItem({ content: this.localSong.songFile }).width('80%')
        .onClick(() => {
          PasteboardUtil.setDataText(`${this.localSong.name}`)
          ToastUtil.showToast('已复制歌名至剪切板')
        })
      MenuItem(this.MenuItem($r('app.media.ic_play_fill'), '播放', $r('app.color.reverse')))
        .onClick(this.handlePlay)

      MenuItem(this.MenuItem($r('app.media.ic_public_search_filled'), '匹配歌曲'))
        .onClick(() => {
          this.showMatchSheet = true
        })

      MenuItem(this.MenuItem($r('app.media.ic_public_folder_filled'), '保存歌曲至本地'))
        .onClick(() => {
          FileUtils.saveFile([this.localSong])
        })

      MenuItem(this.MenuItem($r('app.media.ic_public_app_filled'), '文件预览'))
        .onClick(() => {
          FileUtils.previewFile(this.localSong.songFile)
        })

      MenuItem(this.MenuItem($r('app.media.ic_public_delete_filled'), '删除歌曲', $r('app.color.app_red')))
        .onClick(this.handleDelete)
    }
    .constraintSize({
      minWidth: 100,
      maxWidth: 500
    })
  }

  @Builder
  MenuItem(image: ResourceStr, title: string, contentColor: string | Color | ResourceStr = $r('app.color.reverse')) {
    Row({ space: 10 }) {
      Column() {
        Image(image)
          .fillColor(contentColor)
          .width(20)
      }
      .width(22)
      Text(title)
        .fontColor(contentColor)
        .fontSize(Constants.FONT_SIZE_COMMON)
        .fontWeight(FontWeight.Medium)
    }
    .padding({ left: 15, right: 15, top: 5, bottom: 5 })
    .height(40)
  }
}