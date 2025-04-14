/**
 * 歌词类
 */

/**
 * 歌词格式 time + content
 */
export interface Lyric {
  time: number
  content: string
}

/**
 * HTTP Result
 */
interface Lrc {
  lyric: string
}

export interface LyricResult {
  code: number
  lrc: Lrc
  tlyric: Lrc // 译
  klyric: Lrc
  romalrc: Lrc // 音
}

export const LyricResultClass: LyricResult = {
  code: 200,
  lrc: {
    lyric: ''
  },
  tlyric: {
    lyric: ''
  },
  klyric: {
    lyric: ''
  },
  romalrc: {
    lyric: ''
  },
}

export const EmptyLrcItem: Lrc = {
  lyric: '[00:00:00] 暂无歌词'
}