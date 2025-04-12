import { UserPlayLists } from "./UserPlayLists";
import { UserDjRadioList } from "./UserDjRadioList";
import Constants from "../../constants/Constants";
import { UserAlbumList } from "./UserAlbumList";

/**
 * 用户歌单
 */
@Component
export struct UserLists {
  tabsController: TabsController = new TabsController()
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @Link contentTabIndex: number
  @Link categoryTabIndex: number

  build() {
    Column({ space: Constants.PADDING_EDGE_DEFAULT }) {
      Tabs({ controller: this.tabsController, index: this.contentTabIndex }) {
        TabContent() {
          UserPlayLists()
        }

        TabContent() {
          UserAlbumList()
        }

        TabContent() {
          UserDjRadioList()
        }
      }
      .barHeight(0)
      .width('100%')
      .height('100%')
      .onAnimationStart((start, end) => {
        this.categoryTabIndex = end
      })
      .onChange((index) => {
        this.contentTabIndex = index
      })
    }
    .width('100%')
    .height('100%')
  }
}

