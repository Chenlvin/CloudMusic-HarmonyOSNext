import { PlayListSong } from "../playlist/PlayListSongs"
import { Artist } from "./Song"

interface AlbumDetail {
  company: string
  picUrl: string
  description: string
  name: string
  id: number
}

export interface AlbumResult {
  code: number
  resourceState: boolean
  songs: PlayListSong[]
  album: AlbumDetail
}

export interface Album {
  artists: Artist[]
  picUrl: string
  name: string
  id: number
  size: number
}

export interface SubAlbumResult {
  data: Album[]
}

interface SearchResult {
  albums: Album[]
}

export interface AlbumSearchResult {
  result: SearchResult
}

export const AlbumResultItem: AlbumResult = {
  code: 200,
  resourceState: false,
  songs: [],
  album: {
    company: '',
    picUrl: '',
    description: '',
    name: '',
    id: 0
  }
}

export const SubAlbumResultItem: SubAlbumResult = {
  data: []
}

export const AlbumItem: Album = {
  artists: [],
  picUrl: "",
  name: "",
  id: 0,
  size: 0
}

export const AlbumSearchResultItem: AlbumSearchResult = {
  result: {
    albums: []
  }
}