import { Album } from "../song/Album"
import { Artist } from "../song/Song"

/**
 * 歌单内歌曲
 */
export interface PlayListSong {
  name: string
  id: number
  dt: number
  al: Album
  ar: Artist[]
  fee: number
}

export interface PlayListSongs {
  songs: PlayListSong[]
}

/**
 * 每日推荐歌单内歌曲
 */
interface DailySong {
  name: string
  id: number
  dt: number
  al: Album
  ar: Artist[]
  reason: string
  fee: number
}

interface Data {
  dailySongs: DailySong[]
}

export interface DailyListSongs {
  data: Data
}

/**
 * 云盘歌单内歌曲
 */
interface CloudData {
  simpleSong: PlayListSong
}

export interface CloudResult {
  data: CloudData[]
  hasMore: boolean
}

export const CloudResultItem: CloudResult = {
  data: [],
  hasMore: false
}