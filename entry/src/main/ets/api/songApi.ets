import { LogUtil } from "@pura/harmony-utils"
import { PlayConstants } from "../common/constants/PlayConstants"
import { StorageConstants } from "../common/constants/StorageConstants"
import { HeartMode } from "../common/entities/recommend/HeartMode"
import { DailyListSongs } from "../common/entities/playlist/PlayListSongs"
import { PlayQueue } from "../common/entities/local/PlayQueue"
import { SongDetail } from "../common/entities/song/SongDetail"
import { QualityType } from "../common/entities/song/SongDownload"
import { SongPlay } from "../common/entities/song/SongPlay"
import { Song, SongItem, SongsData } from "../common/entities/song/Song"
import { User } from "../common/entities/user/User"
import { getApiUrl } from "../common/functions/common/get"
import PlayQueueUtils from "../common/utils/play/PlayQueueUtils"
import { HttpRequest } from "../common/utils/request/HttpRequestUtils"
import { DailySongRes } from "./playListApi"
import { Album } from "../common/entities/song/Album"

const TAG = '[Song API - songApi] '

export async function checkMusic(songId: number): Promise<boolean> {
  const rootUrl = await getApiUrl()
  const url: string = `${rootUrl}/check/music?id=${songId}`
  const request = new HttpRequest(url)
  const response = await request.Request()
  if(response.responseCode === 200) {
    return response.result["success"] as boolean ?? false
  }
  return false
}

export interface SearchReturn {
  list: Array<Song>
  hasMore: boolean
  songCount: number
}
/**
 * 搜素歌曲列表
 * @param searchKeyword 搜索词
 * @returns SearchReturn
 */
export async function searchSongs(searchKeyword: string, offset: number, limit: number = 30): Promise<SearchReturn> {
  let list:Array<Song> = new Array()
  let hasMore:boolean = false
  let songCount:number = 0

  const rootUrl = await getApiUrl()
  const url:string = `${rootUrl}/search?keywords=${encodeURIComponent(searchKeyword)}&limit=${limit}&offset=${offset}`
  const request = new HttpRequest(url)
  await request.Request().then((data) => {
    const dataGot: SongsData = data.result as SongsData
    hasMore = dataGot.result.hasMore
    songCount = dataGot.result.songCount
    list = dataGot.result.songs
  })
  let searchReturn:SearchReturn = {
    list: list,
    hasMore: hasMore,
    songCount: songCount
  }

  return searchReturn;
}

/**
 * 获取歌曲播放Url
 */
export async function getSongUrl(songId: number, quality:QualityType, isLogged:boolean): Promise<SongPlay> {
  const rootUrl = await getApiUrl()
  const url:string = `${rootUrl}/song/url/v1?id=${songId}&level=${quality}`
  const request = new HttpRequest(url)
  try {
    const data = await request.Request()
    if(data.result["code"] == 200) {
      const dataGot: SongPlay = data.result as SongPlay
      return dataGot
    } else {
      throw new Error(`${data.result["code"]} - ${data.result["message"]}`)
    }
  } catch (e) {
    LogUtil.error(TAG + '获取播放url失败: ' + e)
    throw new Error(e)
  }
}

/**
 * 获取歌曲图片Url
 * @param song 歌曲类
 * @returns string 歌曲Url
 */
export async function getSongPicUrl(songId: number): Promise<string> {
  const rootUrl = await getApiUrl()
  const url: string = `${rootUrl}/song/detail?ids=${songId}`
  const request = new HttpRequest(url)
  try {
    const data = await request.Request()
    const dataGot: SongDetail = data.result as SongDetail
    const songPicUrl = dataGot.songs[0].al.picUrl
    return songPicUrl
  } catch (e) {
    LogUtil.error(TAG + 'Error fetching song picUrl:', JSON.stringify(e))
    throw new Error(e)
  }
}

/**
 * 获取每日推荐歌单
 * @param useCookie
 * @returns
 */
export async function getDailySongs(useCookie: boolean = true): Promise<Array<DailySongRes>> {
  let list:Array<DailySongRes> = []
  const rootUrl = await getApiUrl()
  const url: string = `${rootUrl}/recommend/songs`
  const request = new HttpRequest(url)
  await request.RequestInStream(useCookie).then((data) => {
    const dataGot: DailyListSongs = data.result as DailyListSongs
    if(dataGot.data) {
      for (let song of dataGot.data.dailySongs) {
        list.push({
          song: {
            id: song.id,
            name: song.name,
            artists: song.ar,
            album: song.al as Album,
            duration: song.dt,
            alias: [],
            fee: song.fee
          },
          reason: song.reason,
          picUrl: song.al.picUrl
        })
      }
    }
  })
  return list
}

/**
 * 获取喜欢列表(songId 数组)
 * @param uid
 * @returns
 */
export async function getLikeList(): Promise<string[]> {
  let user = await AppStorage.get(StorageConstants.USER) as User
  let list:Array<string> = []
  const rootUrl = await getApiUrl()
  const url: string = `${rootUrl}/likelist?uid=${user.data.account.id}&timestamp=${new Date().getTime()}`
  const request = new HttpRequest(url)
  try {
    const data = await request.RequestInStream()
    const dataGot: string[] = data.result['ids'] as string[]
    list = dataGot
  } catch (e) {

  } finally {
    AppStorage.setOrCreate(StorageConstants.USER_LIKELIST, list)
    return list
  }
}

/**
 * 喜欢歌曲
 * @param songId
 * @returns
 */
export async function likeMusic(sid: number): Promise<boolean> {
  let code = -1
  const rootUrl = await getApiUrl()
  const url: string = `${rootUrl}/like?id=${sid}&timestamp=${new Date().getTime()}`
  const request = new HttpRequest(url)
  await request.Request().then((data) => {
    code = data.result['code'] as number
  })
  return code == 200 ? true : false
}

/**
 * 心动模式
 * @param id - 歌曲id
 * @param pid - 歌单id
 */
export async function setHeartMode(id: number, pid: number): Promise<void> {
  let queue: Array<PlayQueue> = []
  let tempSong: Song
  const rootUrl = await getApiUrl()
  const url: string = `${rootUrl}/playmode/intelligence/list?id=${id}&pid=${pid}`
  const request = new HttpRequest(url)
  let data = await request.RequestInStream()
  let dataGot = data.result as HeartMode
  for(let item of dataGot.data) {
    tempSong = {
      id: item.songInfo.id,
      name: item.songInfo.name,
      artists: item.songInfo.ar,
      album: item.songInfo.al,
      duration: item.songInfo.dt,
      alias: [],
      fee: item.songInfo.fee
    }
    queue.push({
      playmode: 1,
      song: tempSong,
      fileName: '',
      picUrl: item.songInfo.al.picUrl ?? $r('app.media.ic_public_music')
    })
  }
  await PlayQueueUtils.cleanQueue()
  await PlayQueueUtils.queueAdd_array(queue)
}

export async function getPersonalFmSong(mode: number): Promise<Song> {
  const rootUrl = await getApiUrl()
  const url: string = `${rootUrl}/personal/fm/mode?=${PlayConstants.PERSONAL_FM_MODE[mode]}&timestamps=${new Date().getTime()}`
  const request = new HttpRequest(url)
  let data = await request.RequestInStream()
  if(data.result["code"] == 200) {
    let dataGot = data.result["data"][0] as Song
    return dataGot
  } else return SongItem
}