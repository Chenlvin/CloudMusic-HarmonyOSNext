import { BusinessError } from '@kit.BasicServicesKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { WantAgent, wantAgent } from '@kit.AbilityKit';
import { LogUtil } from '@pura/harmony-utils';

/**
 * 长时任务
 */
const TAG = '[ContinuousTask] '

class ContinuousTask {
  private context: Context = getContext(this)

  async startTask() {
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: "cc.chenlvin.cloudmusic",
          abilityName: "EntryAbility"
        }
      ],
      actionType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      actionFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };

    wantAgent.getWantAgent(wantAgentInfo).then((wantAgentObj: WantAgent) => {
      backgroundTaskManager.startBackgroundRunning(this.context,
        backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK, wantAgentObj).then(async () => {
      }).catch((err: BusinessError) => {
        // LogUtil.error(TAG, `启动长时任务 Start Background Running 失败：Code - ${err.code}, Message - ${err.message}`)
      })
    })
  }

  async stopTask() {
    backgroundTaskManager.stopBackgroundRunning(this.context).then(() => {
    }).catch((err: BusinessError) => {
      LogUtil.error(TAG, `结束长时任务 Stop Background Running 失败：Code - ${err.code}, Message - ${err.message}`);
    })
  }
}

const conTask = new ContinuousTask()
export default conTask as ContinuousTask