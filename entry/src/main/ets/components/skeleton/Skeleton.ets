import { AnimateType, SkeletonTheme, UISkeleton } from "@hw-agconnect/ui-skeleton";
import Constants from "../../common/constants/Constants";

const animate: AnimateType = AnimateType.GRADIENT

@ComponentV2
export struct PlayListSkeleton {
  build() {
    Row({ space: 15 }) {
      UISkeleton({
        theme: SkeletonTheme.IMAGE,
        animate: animate,
        options: [{ size: Constants.SIZE_IMG_CARD, radius: Constants.RADIUS_IMG }]
      })
        .width(Constants.SIZE_IMG_CARD)
      UISkeleton({
        theme: SkeletonTheme.TEXT,
        animate: animate,
        options: [{ width: '90%', height: Constants.FONT_SIZE_COMMON }, { width: '70%', height: Constants.FONT_SIZE_COMMON }],
        alignCol: FlexAlign.Center
      })
      .layoutWeight(1)
    }
    .height(60)
    .padding({ left: 20, right: 20, bottom: 10 })
  }
}