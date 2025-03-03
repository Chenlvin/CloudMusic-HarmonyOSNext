import { Explore } from '../components/main/Explore'
import { BottomBarComponent } from '../components/play/BottomBarComponent';
import Constants from '../common/constants/Constants';
import { SettingsPage } from './SettingsPage';
import { CachedPage } from './CachedPage';
import { CloudPage } from './CloudPage';
import { DailyListPage } from './DailyListPage';
import { SearchPage } from './SearchPage';
import { PlayListPage } from './PlayListPage';
import { PlayListPageParam, WebPageParam } from '../common/entities/PageParams';
import { LoginPage } from './login/LoginPage';
import { QrCodeLogin } from './login/QrCodeLogin';
import { WebLogin } from './login/WebLogin';
import { WebPage } from './WebPage';
import { UserPlayLists } from '../components/main/UserPlayLists';
import { Me } from '../components/main/Me';
import { resourceManager } from '@kit.LocalizationKit';
import { StorageConstants } from '../common/constants/StorageConstants';
import PreferencesUtils from '../common/utils/data/PreferencesUtils';
import { WarrantyDialog } from '../components/dialog/WarrantyDialog';

@Entry
@Component
struct Index {
  warrantyDialogController: CustomDialogController = new CustomDialogController({
    builder: WarrantyDialog(),
    autoCancel: false
  })

  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp(StorageConstants.DEVICE_TYPE) deviceType: resourceManager.DeviceType = resourceManager.DeviceType.DEVICE_TYPE_PHONE
  @State index: number = AppStorage.get<number>(StorageConstants.DEFAULT_PAGE_INDEX) ?? 0;
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack()
  private menuItems: NavigationMenuItem[] = [
    {
      value: '搜索',
      icon: $r('app.media.ic_public_search_filled'),
      action: () => {
        this.pageInfos.clear()
        this.pageInfos.pushPathByName('SearchPage', null, true)
      }
    }
  ]

  async aboutToAppear(): Promise<void> {
    const isFirstLaunch = await PreferencesUtils.getPreferenceValue<boolean>(StorageConstants.USER_PREF, 'isFirstLaunch', true)
    if(isFirstLaunch) {
      this.warrantyDialogController.open()
      PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, 'isFirstLaunch', false)
    }
  }

  async build() {
    Navigation(this.pageInfos) {
      Stack({ alignContent: Alignment.Bottom }) {
        Explore()
          .visibility(this.index == 0 ? Visibility.Visible : Visibility.None)
        UserPlayLists()
          .visibility(this.index == 1 ? Visibility.Visible : Visibility.None)
        Me()
          .visibility(this.index == 2 ? Visibility.Visible : Visibility.None)

        BottomBarComponent()
          .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT, bottom: px2vp(this.bottomRectHeight) + 35 })
          .backgroundColor(Color.Transparent)
      }
    }
    .height('100%')
    .width('100%')
    .navBarWidthRange(['40%', '60%'])
    .navBarPosition(NavBarPosition.Start)
    .mode(NavigationMode.Auto)
    .titleMode(NavigationTitleMode.Mini)
    .title(this.index == 0 ? '发现' : this.index == 1 ? '歌单' : '我的')
    .menus(this.menuItems)
    .hideBackButton(true)
    .backgroundColor($r('app.color.background'))
    .navDestination(this.PageMap)
    .toolbarConfiguration(this.ToolBar(), { backgroundBlurStyle: BlurStyle.Regular, barStyle: BarStyle.STACK, backgroundColor: Color.Transparent })
  }

  @Builder PageMap(name: string, param: Object) {
    if(name === 'SettingsPage') {
      SettingsPage()
    }
    else if(name === 'DownloadPage') {
      CachedPage()
    }
    else if(name === 'CloudPage') {
      CloudPage()
    }
    else if(name === 'DailyListPage') {
      DailyListPage()
    }
    else if(name === 'SearchPage') {
      SearchPage()
    }
    else if(name === 'PLayListPage') {
      PlayListPage({ param: param as PlayListPageParam })
    }
    else if(name === 'LoginPage') {
      LoginPage()
    }
    else if(name === 'QrCodeLogin') {
      QrCodeLogin()
    }
    else if(name === 'WebLogin') {
      WebLogin()
    }
    else if(name === 'WebPage') {
      WebPage({ param: param as WebPageParam })
    }
  }

  @Builder ToolBar() {
    Row() {
      this.ToolBarItem(0, $r('app.media.ic_gallery_discover'), $r('app.media.ic_gallery_discover_filled'), '发现')
      this.ToolBarItem(1, $r('app.media.ic_public_drawer'), $r('app.media.ic_public_drawer_filled'),'歌单')
      this.ToolBarItem(2, $r('app.media.ic_public_contacts'), $r('app.media.ic_public_contacts_filled'), '我的')
    }
    .backgroundColor(Color.Transparent)
    .justifyContent(FlexAlign.SpaceEvenly)
    .width('100%')
  }

  @Builder ToolBarItem(index: number, icon: ResourceStr, activeIcon: ResourceStr, text: string) {
    Column({ space: 3 }) {
      Image(this.index == index ? activeIcon : icon)
        .width(Constants.SIZE_ICON_BUTTON_BAR)
        .fillColor(this.index == index ? $r('app.color.blue') : Color.Gray)
      Text(text)
        .fontSize(Constants.FONT_SIZE_BAR)
        .fontColor(this.index == index ? $r('app.color.blue') : Color.Gray)
    }
    .layoutWeight(1)
    .onClick(() => {
      this.index = index
    })
  }
}