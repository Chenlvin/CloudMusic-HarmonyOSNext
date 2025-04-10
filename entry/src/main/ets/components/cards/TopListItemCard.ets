import Constants from "../../common/constants/Constants"
import { PlayListPageParam } from "../../common/entities/local/PageParams"
import { TopListItem } from "../../common/entities/recommend/TopList"

const cardHeight = Constants.HEIGHT_EXPLORE_LARGECARD

@Component
export struct TopListItemCard {
  @State topListItem: TopListItem = {
    id: 0,
    name: "",
    trackCount: 0,
    updateFrequency: "",
    coverImgUrl: "",
    description: "",
    playCount: 0,
    subscribedCount: 0
  }
  @Prop breakpoint: string = 'sm'
  @Consume('pageInfos') pageInfos: NavPathStack

  build() {
    Column({ space: 5 }) {
      Image(this.topListItem.coverImgUrl)
        .width('100%')
        .aspectRatio(1)
        .borderRadius(Constants.RADIUS_IMG)
        .draggable(false)
    }
    .width(cardHeight)
    .aspectRatio(1)
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
    .onClick(() => {
      let param: PlayListPageParam = {
        playList: {
          userId: 0,
          id: this.topListItem.id,
          name: this.topListItem.name,
          playCount: this.topListItem.playCount,
          coverImgUrl: this.topListItem.coverImgUrl,
          trackCount: this.topListItem.trackCount,
          subscribedCount: this.topListItem.subscribedCount,
          subscribed: false,
          creator: {
            userId: 0,
            nickname: '排行榜',
            avatarUrl: ''
          },
          description: ''
        },
        isShowHeart: false,
        useTimestamp: false
      }
      if(!this.pageInfos.getAllPathName().includes('PlayListPage')) {
        this.pageInfos.pushPathByName('PlayListPage', param, this.pageInfos.size() === 0 && this.breakpoint === 'lg' ? false : true)
      } else {
        this.pageInfos.replacePath({ name: 'PlayListPage', param: param }, { launchMode: LaunchMode.MOVE_TO_TOP_SINGLETON })
      }
    })
  }
}