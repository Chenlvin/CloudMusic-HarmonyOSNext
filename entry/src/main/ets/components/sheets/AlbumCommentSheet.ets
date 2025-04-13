import { StorageConstants } from "../../common/constants/StorageConstants";
import { Album, AlbumItem } from "../../common/entities/song/Album";
import { Comment } from "../../common/entities/song/Comment";
import { COMMENT_TYPE } from "../../common/model/Enum";
import { CommentPage } from "../../pages/list/CommentPage";

@Component
export struct AlbumCommentSheet {
  @StorageProp(StorageConstants.BOTTOM_RECT_HEIGHT) bottomRectHeight: number = 0
  @State isLoading: boolean = true
  @State comments: Comment[] = []
  @Prop album: Album = AlbumItem

  build() {
    CommentPage({
      param: {
        id: this.album.id,
        name: this.album.name,
        type: COMMENT_TYPE.ALBUM
      },
      showMiniPlayer: false
    })
  }
}