export enum PLAYMODE {
  LOCAL = 0,
  SINGLE = 1,
  PLAYLIST = 2,
  DJRADIO = 3,
  ALBUM = 4,
  CLOUD = 5,
  DAILY = 6
}

// 0-歌曲, 2-歌单, 3-专辑, 4-电台节目, 7-电台
export enum COMMENT_TYPE {
  SONG = 0,
  PLAYLIST = 2,
  ALBUM = 3,
  PROGRAM = 4,
  RADIO = 7,
}

// 1-按推荐排序, 2-按热度排序, 3-按时间排序
export enum COMMENT_SORT_TYPE {
  RECOMMEND = 1,
  HOT = 2,
  TIME = 3
}