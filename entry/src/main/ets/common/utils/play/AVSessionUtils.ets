import { avSession } from "@kit.AVSessionKit";
import { AppUtil, LogUtil } from "@pura/harmony-utils";
import { StorageConstants } from "../../constants/StorageConstants";
import { Song, SongItem } from "../../entities/song/Song";
import { changeCycleMode,
  pauseMusic, playNext, playPre, resumeMusic, seekMusic } from "../../functions/play/playControl";
import { likeThisSong } from "../../functions/play/songLike";
import AVPlayerUtils from "./AVPlayerUtils";
import LyricUtils from "./LyricUtils";

/**
 * AVSession 播控中心工具类
 */
const TAG = '[AVSessionUtils] '

class AVSessionUtils {
  context = AppUtil.getContext()
  session = this.createSession()

  private isActivating = false
  private cycleMode: number = 0
  private currentSong: Song = SongItem
  private currentArtists: string = ''
  private currentPic: string | ResourceStr  = ''
  private lyric: string = ''

  async createSession(): Promise<avSession.AVSession> {
    if(this.session) {
      return this.session
    }
    let session = await avSession.createAVSession(this.context, 'cloudmusic', 'audio')
    try {
      let cycleMode: number | undefined = AppStorage.get('cycleMode')
      if(cycleMode) this.cycleMode = this.cycleMode
      else this.cycleMode = 0

      session.on('play', () => {
        resumeMusic()
      });
      session.on('pause', () => {
        pauseMusic()
      });
      session.on('playNext', () => {
        playNext()
      });
      session.on('playPrevious', () => {
        playPre()
      });
      session.on('seek', (time) => {
        seekMusic(time)
      });
      session.on('toggleFavorite', (isFavor) => {
        likeThisSong().then(async () => {
          (await this.session).setAVPlaybackState({ isFavorite: this.isFavorite() })
        })
      })
      session.on('setLoopMode', (loopMode) => {
        if(loopMode == 0) { changeCycleMode(1) }
        else if(loopMode == 1) { changeCycleMode(2) }
        else if(loopMode == 2) { changeCycleMode(3) }
        else { changeCycleMode(0) }
      })

    } catch (e) {
      LogUtil.error(TAG, '创建session失败 / create session error: ' + JSON.stringify(e))
    } finally {
      return session
    }
  }

  /**
   * 设置媒体信息
   * @param song
   * @param artists
   * @param picUrl
   */
  async setMetadata(song: Song, artists: string, picUrl: string | ResourceStr) {
    this.currentSong = song
    this.currentArtists = artists
    this.currentPic = picUrl
    this.lyric = LyricUtils.lyric.lrc.lyric

    let metadata: avSession.AVMetadata = {
      assetId: `${song.id}`,
      title: song.name,
      mediaImage: typeof picUrl === 'string' ? picUrl : '/resources/base/media/app.media.ic_public_music.svg',
      artist: artists != 'null' ? artists : '未知',
      duration: song.duration,
      lyric: this.lyric
    };

    (await this.session).setAVMetadata(metadata)
  }

  /**
   * 启用
   */
  async activate() {
    if (this.isActivating) return // 防止重复调用
    this.isActivating = true
    try {
      await (await this.session).activate()
    } finally {
      this.isActivating = false
    }
  }

  /**
   * 停用
   */
  async deactive() {
    if (this.isActivating) return // 等待激活完成
    try {
      (await this.session).deactivate()
    } catch (e) {
      LogUtil.error(TAG, '停用失败: ' + e)
    }
  }

  private isFavorite(): boolean {
    const is: boolean = AppStorage.get(StorageConstants.ISLIKED) as boolean
    return is
  }
  /**
   * 设置为播放状态
   */
  async playState(time: number) {
    let loopMode = await getLoopMode()
    let playbackState: avSession.AVPlaybackState = {
      state: avSession.PlaybackState.PLAYBACK_STATE_PLAY,
      loopMode: loopMode,
      isFavorite: this.isFavorite(),
      position: {
        elapsedTime: time,
        updateTime: new Date().getTime()
      }
    };

    (await this.session).setAVPlaybackState(playbackState)
  }

  /**
   * 设置为暂停状态
   */
  async pauseState(time: number) {
    let pausedState: avSession.AVPlaybackState = {
      state: avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
      position: {
        elapsedTime: time,
        updateTime: new Date().getTime()
      }
    };
    (await this.session).setAVPlaybackState(pausedState)
  }

  /**
   * 设置为缓冲状态
   */
  async bufferingState() {
    let playbackState: avSession.AVPlaybackState = {
      state: avSession.PlaybackState.PLAYBACK_STATE_BUFFERING,
      position: {
        elapsedTime: 0,
        updateTime: new Date().getTime(),
      }
    };
    (await this.session).setAVPlaybackState(playbackState)
  }
}

async function getLoopMode(): Promise<number> {
  let loopMode = 0
  let cycleMode: number | undefined = await AppStorage.get('cycleMode')
  if(cycleMode) {
    loopMode = cycleMode
  }
  return loopMode
}

const avSessionUtils = new AVSessionUtils()
export default avSessionUtils as AVSessionUtils