import { DjRadio } from "../dj/DjResult";
import { PlayList } from "../playlist/PlayList";
import { Album } from "../song/Album";
import { Artist } from "../song/Song";

/**
 * 歌单详情页参数
 */
export interface PlayListPageParam {
  playList: PlayList
  isShowHeart: boolean
  useTimestamp: boolean
}

/**
 * 网页参数
 */
export interface WebPageParam {
  title: string
  url: string
}

/**
 * 歌手信息参数
 */
export interface ArtistParam {
  artist: Artist
}

/**
 * DjRadio信息参数
 */
export interface DjRadioParam {
  djRadio: DjRadio
}

/**
 * 专辑信息参数
 */
export interface AlbumParam {
  album: Album
}

/**
 * 评论页参数
 */
export interface CommentParam {
  songId: number
  songName: string
}
/**
 * 通用参数
 */
export interface CommonParam<T> {
  pageName: string
  param: T
  remove: boolean
}