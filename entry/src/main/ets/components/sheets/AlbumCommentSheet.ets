import { getAlbumComment } from "../../api/commentApi";
import Constants from "../../common/constants/Constants";
import { StorageConstants } from "../../common/constants/StorageConstants";
import { Album, AlbumItem } from "../../common/entities/song/Album";
import { Comment } from "../../common/entities/song/Comment";
import { CommentCard } from "../cards/CommentCard";

@Component
export struct AlbumCommentSheet {
  @StorageProp(StorageConstants.BOTTOM_RECT_HEIGHT) bottomRectHeight: number = 0
  @State isLoading: boolean = true
  @State comments: Comment[] = []
  @Prop album: Album = AlbumItem

  async aboutToAppear(): Promise<void> {
    try {
      if(this.album.id !== 0) {
        this.comments = (await getAlbumComment(this.album.id)).hotComments
      }
    } catch (e) {
    } finally {
      this.isLoading = false
    }
  }

  build() {
    Column() {
      Text('评论')
        .fontColor($r('app.color.reverse'))
        .fontWeight(Constants.FONT_WEIGHT_BOLD)
        .fontSize(Constants.FONT_SIZE_TITLE)
        .width('100%')
        .padding({ left: 20, right: 20, top: 10, bottom: 10 })
      if(this.isLoading) {
        Column() {
          LoadingProgress().width(40)
        }
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if(this.comments.length === 0) {
        Column() {
          Text('暂无评论')
            .fontColor(Color.Gray)
            .fontWeight(Constants.FONT_WEIGHT_BOLD)
            .fontSize(Constants.FONT_SIZE_TITLE)
        }
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 20 }) {
          ForEach(this.comments, (item: Comment, index) => {
            CommentCard({ comment: item })
              .padding({ left: 20, right: 20 })
          })
          ListItem().height(this.bottomRectHeight)
        }
        .width('100%')
        .height('100%')
      }
    }
  }
}