interface Data {
  id: number
  url: string
  time: number
}

export interface SongPlay {
  data: Data[]
}

export const SongPlayClass: SongPlay = {
  data: [{
    id: -1,
    url: '',
    time: -1
  }]
}