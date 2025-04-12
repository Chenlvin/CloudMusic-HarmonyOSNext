import { CommentResult, CommentResultItem } from "../common/entities/song/Comment";
import { getApiUrl } from "../common/functions/common/get";
import { HttpRequest } from "../common/utils/request/HttpRequestUtils";

const TAG = '[commentApi] '
/**
 * 获取歌曲评论信息
 * @param id
 * @returns CommentResult
 */
export async function getSongComment(id: number): Promise<CommentResult> {
  const rootUrl = await getApiUrl()
  const url = `${rootUrl}/comment/music?id=${id}&limit=30`
  const request = new HttpRequest(url)
  const response = await request.RequestInStream(false)
  const dataGot = response.result as CommentResult
  return dataGot ?? CommentResultItem
}

/**
 * 获取专辑评论信息
 * @param id
 * @returns CommentResult
 */
export async function getAlbumComment(id: number): Promise<CommentResult> {
  const rootUrl = await getApiUrl()
  const url = `${rootUrl}/comment/album?id=${id}&limit=30`
  const request = new HttpRequest(url)
  const response = await request.RequestInStream(false)
  const dataGot = response.result as CommentResult
  return dataGot ?? CommentResultItem
}