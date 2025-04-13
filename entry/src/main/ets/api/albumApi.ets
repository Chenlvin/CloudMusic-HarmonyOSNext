import { StorageConstants } from "../common/constants/StorageConstants";
import {
  Album,
  AlbumResult,
  AlbumSearchResult,
  SubAlbumResult, SubAlbumResultItem } from "../common/entities/song/Album";
import PreferencesUtils from "../common/utils/data/PreferencesUtils";
import commonRequest from "../common/utils/request/RequestUtil";

/**
 * 获取专辑信息和歌曲
 * @param id
 * @returns
 */
export const getAlbumInfo = async (id: number): Promise<AlbumResult> =>
  commonRequest({
    url: '/album',
    params: { id }
})


/**
 * 获取收藏的专辑
 * @returns
 */
export const getSubAlbum = async (): Promise<SubAlbumResult> => {
  const result = await commonRequest<SubAlbumResult>({
    url: '/album/sublist',
    params: {}
  })
  PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.USER_SUB_ALBUM, result.data)
  return result ?? SubAlbumResultItem
}

/**
 * 搜索专辑
 * @param keyword
 * @returns Album[]
 */
export const searchAlbums = async (keywords: string): Promise<Album[]> => {
  const result = await commonRequest<AlbumSearchResult>({
    url: '/search',
    params: { keywords, type: 10 }
  })
  return result.result.albums ?? []
}