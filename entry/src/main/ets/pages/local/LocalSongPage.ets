import FileUtils from '../../common/utils/file/FileUtils';
import { FileCard } from '../../components/cards/FileCard';
import { BottomBarComponent } from '../../components/play/BottomBarComponent';
import Constants from '../../common/constants/Constants';
import { StorageConstants } from '../../common/constants/StorageConstants';
import { DialogUtil, EmitterUtil, LogUtil, ToastUtil } from '@pura/harmony-utils';
import { LocalSong } from '../../common/entities/local/LocalData';
import RelationalStoreUtils from '../../common/utils/data/RelationalStoreUtils';
import { LocalMigrationSheet } from '../../components/sheets/LocalMigrationSheet';
import { LazyData } from '@pie/lazy-data';
import { PickerUtil } from '@pura/picker_utils';
import { EmitterConstants } from '../../common/constants/EmitterConstants';

/**
 * 缓存管理页
 * DownloadPage
 */
const TAG = '[LocalSongPage]] '

@Component
export struct LocalSongPage {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp(StorageConstants.BREAKPOINT_WIDTH) breakpoint: string = 'sm'
  @State filesList: string[] = []
  @State searchKeyword: string = ''
  @State filteredSongs: LocalSong[] = new Array()
  @State isSorted: boolean = false
  @State isSelecting: boolean = false
  @State selectedSongs: LocalSong[] = []
  @State localSongs: LocalSong[] = []
  @State isShowMigration: boolean = false
  @State dataSource: LazyData<LocalSong> = new LazyData()
  @State dataSourceFiltered: LazyData<LocalSong> = new LazyData()
  @State isLoading: boolean = false
  private originalOrderList: LocalSong[] = []
  @Consume('pageInfos') pageInfos: NavPathStack

  menus: NavigationMenuItem[] = [
    {
      value: 'Search',
      icon: $r('app.media.ic_public_search_filled'),
      action: () => {
        this.getUIContext().getFocusController().requestFocus('search')
      }
    },
    {
      value: 'Upload',
      icon: $r('app.media.ic_public_upload_filled'),
      action: () => {
        DialogUtil.showPrimaryDialog({
          title: '上传文件',
          message: '支持上传本机音频文件至缓存目录\n' +
            '支持格式为.mp3 .flac\n\n' +
            '* 文件名格式：歌手 - 歌名.flac* \n\n' +
            '文件名格式不正确会导致无法识别\n' +
            '在线播放时，将自动匹配文件名调取本地文件进行播放',
          primaryButton: "取消",
          secondaryButton: {
            value: '上传',
            action: () => {
              this.handleUpload()
            }
          }
        })
      }
    }
  ]

  async aboutToAppear(): Promise<void> {
    this.isLoading = true
    this.refreshList()
    this.filesList = await FileUtils.getFileName()
    this.isLoading = false
    EmitterUtil.onSubscribe(EmitterConstants.REFRESH_LOCALSONGS, () => {
      this.refreshList()
    })
  }

  aboutToDisappear(): void {
    EmitterUtil.unSubscribe(EmitterConstants.REFRESH_LOCALSONGS)
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        if(this.isLoading) {
          Column() {
            LoadingProgress()
              .width(Constants.SIZE_LOADING_PROGRESS_DEFAULT)
          }
          .height('100%')
          .width('100%')
          .justifyContent(FlexAlign.Center)
        } else {
          Column() {
            Column() {
              Grid() {
                GridItem() {
                  Search({
                    placeholder: $r('app.string.Search_content'),
                    icon: '/resources/base/media/ic_public_search_filled.svg'
                  })
                    .id('search')
                    .height(Constants.HEIGHT_SEARCH)
                    .width('100%')
                    .searchButton('搜索')
                    .onChange((value) => {
                      if(value == '') {
                        this.filteredSongs = []
                        this.selectedSongs = []
                        this.searchKeyword = ''
                      }
                    })
                    .onSubmit((value) => {
                      this.searchKeyword = value
                      this.handelSearch()
                    })
                }
                GridItem() {
                  if (this.localSongs.length > 0) {
                    Row() {
                      Text(this.isSelecting ? `已选 ${this.selectedSongs.length} 项` : `共 ${this.localSongs.length} 首歌曲`)
                        .fontSize(Constants.FONT_SIZE_COMMON)
                      Row({ space: 20 }) {
                        if(!this.isSelecting) {
                          // Image($r('app.media.ic_files_name_drive'))
                          //   .width(Constants.SIZE_ICON_BUTTON_BAR)
                          //   .aspectRatio(1)
                          //   .fillColor(this.isSorted ? $r('app.color.blue') : Color.Gray)
                          //   .onClick(() => {
                          //     this.isSorted = !this.isSorted
                          //     if (this.searchKeyword) {
                          //       this.filteredSongs = this.getSortedList(this.filteredSongs)
                          //     }
                          //   })
                        } else {
                          if(this.selectedSongs.length > 0) {
                            Image($r('app.media.ic_public_delete'))
                              .width(Constants.SIZE_ICON_BUTTON_BAR)
                              .aspectRatio(1)
                              .fillColor(Color.Gray)
                              .onClick(() => {
                                this.handleDelete()
                              })
                            Image($r('app.media.ic_public_folder'))
                              .width(Constants.SIZE_ICON_BUTTON_BAR)
                              .aspectRatio(1)
                              .fillColor(Color.Gray)
                              .onClick(() => {
                                FileUtils.saveFile(this.selectedSongs)
                              })
                          }
                          CheckboxGroup({ group: 'fileCard' })
                            .width(Constants.SIZE_ICON_BUTTON_BAR - 5)
                            .height(Constants.SIZE_ICON_BUTTON_BAR - 5)
                        }

                        Image($r('app.media.ic_gallery_material_select_checkbox'))
                          .width(Constants.SIZE_ICON_BUTTON_BAR)
                          .aspectRatio(1)
                          .fillColor(this.isSelecting ? $r('app.color.blue') : Color.Gray)
                          .onClick(() => {
                            animateTo({ duration: 100, curve: Curve.EaseInOut }, () => {
                              this.isSelecting = !this.isSelecting
                              this.selectedSongs = []
                            })
                          })
                      }
                      .height(30)
                    }
                    .justifyContent(FlexAlign.SpaceBetween)
                    .width('100%')
                  }
                  else {
                    Column({ space: 20 }) {
                      Text('本地文件列表为空\n\n右上方入口支持上传本地音频').width('100%').textAlign(TextAlign.Center).padding({ left: 30, right: 30, top: 10 })
                      if(this.filesList.length > 0) {
                        Button('迁移旧版本数据').padding({ left: 10, right: 10, top: 5, bottom: 5 })
                          .onClick(() => { this.isShowMigration = true })
                          .bindSheet(this.isShowMigration, this.Migration(), {
                            preferType: SheetType.CENTER,
                            height: SheetSize.MEDIUM,
                            dragBar: false,
                            showClose: false,
                            backgroundColor: Color.Transparent,
                            blurStyle: BlurStyle.Regular,
                            onDisappear: () => { this.isShowMigration = false }
                          })
                      }
                    }
                  }
                }

                GridItem() {
                  GridRow({ columns: { xs: 1, sm: 1, md: 1, lg: 2, xl: 2 } }) {
                    if(!this.searchKeyword) {
                      this.ListContent(this.dataSource)
                    } else {
                      this.ListContent(this.dataSourceFiltered)
                    }
                  }
                }
                .width('100%')

                GridItem()
                  .height(px2vp(this.bottomRectHeight) + Constants.HEIGHT_MINI)
              }
              .edgeEffect(EdgeEffect.Spring)
              .scrollBar(BarState.Off)
              .rowsGap(10)
              .columnsGap(10)
              .columnsTemplate('1fr')
              .layoutDirection(GridDirection.Column)
              .backgroundColor($r('app.color.background'))
              .height('100%')
              .width('100%')
              .padding({ left: 10, right: 10 })
              .layoutWeight(1)
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
              .backToTop(true)
            }
            .justifyContent(FlexAlign.Center)
            .layoutWeight(1)
            .width('100%')
          }
          .width('100%')
          .height('100%')
        }

        BottomBarComponent()
          .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
          .backgroundColor(Color.Transparent)
          .visibility(this.breakpoint === 'lg' ? Visibility.None : Visibility.Visible)
      }
      .backgroundColor($r('app.color.background'))
      .height('100%')
    }
    .title($r('app.string.LocalSongs'))
    .menus(this.menus)
    .backgroundColor($r('app.color.background'))
  }

  private handelSearch() {
    try {
      this.selectedSongs = []
      if (!this.searchKeyword) {
        this.dataSourceFiltered.setData([])
      }
      const keyword = this.searchKeyword.trim().toLowerCase()
      this.dataSourceFiltered.setData(this.localSongs.filter((item: LocalSong) => {
        return item.songFile.toString().toLowerCase().includes(keyword)
      }))
    } catch (e) {
      ToastUtil.showToast('搜索时出错')
      LogUtil.error(TAG, 'Error while handelSearch: ' + e.message)
    }
  }

  private async refreshList() {
    this.localSongs = (await RelationalStoreUtils.getAllSongs()).reverse()
    this.originalOrderList = [...this.localSongs]
    this.isSelecting = false
    this.selectedSongs = []
    this.dataSource.setData(this.localSongs)
    this.dataSource.notifyDataReload()
  }

  private async handleUpload() {
    PickerUtil.selectDocument({
      maxSelectNumber: 99,
      fileSuffixFilters: ['音频 | .mp3,.flac,.MP3,.FLAC']
    }).then((uris) => {
      FileUtils.saveFilesToDirectory(uris).then(async (result) => {
        if(result) {
          ToastUtil.showToast(`上传 ${result} 个文件`)
          await this.refreshList()
        }
      })
    })
  }

  private getSortedList(list: LocalSong[]): LocalSong[] {
    return this.isSorted ?
    [...list].sort((a, b) => a.songFile.localeCompare(b.songFile)) :
    this.originalOrderList.filter(f => list.some(l => l.songFile === f.songFile))
  }

  private handleDelete() {
    DialogUtil.showPrimaryDialog({
      title: '确认',
      message: `是否删除选中的 ${this.selectedSongs.length} 个文件?`,
      primaryButton: "取消",
      secondaryButton: {
        value: '删除',
        fontColor: Color.Red,
        action: async () => {
          await FileUtils.deleteFile(this.selectedSongs)
          setTimeout(async () => {
            await this.refreshList()
          }, 100)
        }
      }
    })
  }

  @Builder ListContent(dataSource: LazyData<LocalSong>) {
    LazyForEach(dataSource,
      (item: LocalSong, index: number) => {
        GridCol() {
          Row({ space: 5 }) {
            FileCard({
              localSong: item
            })
              .padding({ left: 5, right: 5 })
              .layoutWeight(1)
            if(this.isSelecting) {
              this.CardCheckBox(item)
            }
          }
          .width('100%')
          .padding({ bottom: Constants.PADDING_EDGE_DEFAULT })
        }
        .key(item.id + this.searchKeyword)
      },(item: LocalSong) => item.songFile.toString() + this.searchKeyword)
  }
  @Builder Migration() {
    LocalMigrationSheet({ isShowMigration: this.isShowMigration })
  }

  @Builder CardCheckBox(localSong: LocalSong) {
    Checkbox({ group: 'fileCard' })
      .shape(CheckBoxShape.ROUNDED_SQUARE)
      .width(Constants.SIZE_ICON_BUTTON_BAR)
      .aspectRatio(1)
      .onChange((value) => {
        if(value) {
          animateTo({ duration: 100, curve: Curve.Ease }, () => {
            this.selectedSongs.push(localSong)
          })
        } else {
          animateTo({ duration: 100, curve: Curve.Ease }, () => {
            this.selectedSongs = this.selectedSongs.filter(item => item.name !== localSong.name)
          })
        }
      })
  }
}