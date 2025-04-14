export interface LocalSong {
  id: number
  songId: number
  name: string
  artists: string
  picFile: string
  songFile: string
  lyricFile: string
}

export const LocalSongItem: LocalSong = {
  id: -1,
  songId: -1,
  name: "",
  artists: "",
  picFile: "",
  songFile: "",
  lyricFile: "",
}