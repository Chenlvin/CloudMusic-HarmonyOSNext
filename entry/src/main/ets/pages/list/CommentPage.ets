import { getComment } from "../../api/commentApi"
import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { CommentParam } from "../../common/entities/local/PageParams"
import { Comment } from "../../common/entities/song/Comment"
import { CommentCard } from "../../components/cards/CommentCard"
import { BottomBarComponent } from "../../components/play/BottomBarComponent"

@Component
export struct CommentPage {
  @StorageProp(StorageConstants.BREAKPOINT_WIDTH) breakpoint: string = 'sm'
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @State param: CommentParam = { id: 0, name: '', type: 0 }
  @State comments: Comment[] = []
  @State isLoading: boolean = false
  @State currentPage: number = 1
  @State sortType: 1 | 2 | 3 = 1 // 1-按推荐排序, 2-按热度排序, 3-按时间排序
  showMiniPlayer: boolean = true
  pageSize: number = 20

  async aboutToAppear(): Promise<void> {
    try {
      if(this.param.id !== 0) {
        this.isLoading = true
        this.comments = (await getComment(
          this.param.id,
          this.param.type,
          this.currentPage,
          this.pageSize,
          this.sortType
        ))
          .data.comments
      }
    } catch (e) {
      throw new Error(e.stack)
    } finally {
      this.isLoading = false
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        if(this.isLoading) {
          Column() {
            LoadingProgress().width(Constants.SIZE_LOADING_PROGRESS_DEFAULT)
          }
          .height('100%')
          .width('100%')
          .padding({ bottom: px2vp(this.bottomRectHeight) })
          .justifyContent(FlexAlign.Center)
        } else {
          List({ space: Constants.PADDING_EDGE_TEXT }) {
            ForEach(this.comments, (item: Comment) => {
              CommentCard({ comment: item })
                .padding({ left: 20, right: 20 })
            })

            ListItem().height(px2vp(this.bottomRectHeight) + Constants.HEIGHT_MINI)
          }
          .height('100%')
          .width('100%')
          .scrollBar(BarState.Auto)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
          .backToTop(true)
        }
        BottomBarComponent()
          .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
          .visibility(this.breakpoint !== 'lg' && this.showMiniPlayer ? Visibility.Visible : Visibility.None)
      }
      .height('100%')
      .width('100%')
    }
    .title(`评论 - ${this.param.name}`)
    .backgroundColor($r('app.color.background'))
  }
}