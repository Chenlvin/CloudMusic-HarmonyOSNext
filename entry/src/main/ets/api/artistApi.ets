import { ArtistInfo, ArtistInfoItem } from "../common/entities/song/ArtistInfo"
import { ArtistItem, ArtistsResult } from "../common/entities/song/ArtistsResult"
import { getApiUrl } from "../common/functions/common/get"
import { HttpRequest } from "../common/utils/request/HttpRequestUtils"

const TAG = '[artistApi] '

/**
 * 获取歌手信息
 * @param id
 * @returns
 */
export async function getArtistInfo(id: number): Promise<ArtistInfo> {
  const rootUrl = await getApiUrl()
  const url = `${rootUrl}/artists?id=${id}`
  const request = new HttpRequest(url)
  const data = await request.RequestInStream()
  const dataGot: ArtistInfo = data.result as ArtistInfo
  return dataGot ?? ArtistInfoItem
}

/**
 * 搜索歌手列表
 * @param keyword
 * @returns
 */
export async function searchArtists(keyword: string): Promise<Array<ArtistItem>> {
  const rootUrl = await getApiUrl()
  const url = `${rootUrl}/search?keywords=${encodeURIComponent(keyword)}&type=100`
  const request = new HttpRequest(url)
  const data = await request.Request()
  const dataGot: ArtistsResult = data.result as ArtistsResult
  return dataGot.result.artists ?? []
}