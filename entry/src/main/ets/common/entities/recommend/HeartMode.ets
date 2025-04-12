import { Album } from "../song/Album"

/**
 * 心动模式
 */
interface Artist {
  name: string
  id: number
}

// interface Album {
//   id: number
//   picUrl: string
//   name: string
// }

interface SongInfo {
  id: number
  name: string
  ar: Artist[]
  dt: number
  al: Album
  fee: number
}

interface ResultData {
  songInfo: SongInfo
}

export interface HeartMode {
  code: number
  data: ResultData[]
}