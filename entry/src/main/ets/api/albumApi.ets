import { StorageConstants } from "../common/constants/StorageConstants";
import {
  Album,
  AlbumResult, AlbumResultItem,
  AlbumSearchResult,
  SubAlbumResult, SubAlbumResultItem } from "../common/entities/song/Album";
import { getApiUrl } from "../common/functions/common/get";
import PreferencesUtils from "../common/utils/data/PreferencesUtils";
import { HttpRequest } from "../common/utils/request/HttpRequestUtils";
import data from "@ohos.telephony.data";

const TAG = '[albumApi] '
/**
 * 获取专辑信息和歌曲
 * @param id
 * @returns
 */
export async function getAlbumInfo(id: number): Promise<AlbumResult> {
  const rootUrl = await getApiUrl()
  const url = `${rootUrl}/album?id=${id}`
  const request = new HttpRequest(url)
  const response = await request.RequestInStream()
  const dataGot = response.result as AlbumResult
  return dataGot ?? AlbumResultItem
}

/**
 * 获取收藏的专辑
 * @returns
 */
export async function getSubAlbum(): Promise<SubAlbumResult> {
  const rootUrl = await getApiUrl()
  const url = `${rootUrl}/album/sublist`
  const request = new HttpRequest(url)
  const response = await request.RequestInStream()
  const dataGot = response.result as SubAlbumResult
  PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.USER_SUB_ALBUM, dataGot.data)
  return dataGot ?? SubAlbumResultItem
}

/**
 * 搜索专辑
 * @param keyword
 * @returns Album[]
 */
export async function searchAlbums(keyword: string): Promise<Array<Album>> {
  const rootUrl = await getApiUrl()
  const url = `${rootUrl}/search?keywords=${encodeURIComponent(keyword)}&type=10`
  const request = new HttpRequest(url)
  const data = await request.Request()
  const dataGot: AlbumSearchResult = data.result as AlbumSearchResult
  return dataGot.result.albums ?? []
}