import { preferences } from '@kit.ArkData'
import { Context } from '@kit.AbilityKit'
import { LogUtil } from '@pura/harmony-utils'

/**
 * 用户首选项工具
 */
const TAG = '[PreferenceUtils] '

class PreferencesUtils {
  preferencesMap: Map<string, preferences.Preferences> = new Map()
  // 加载数据
  async loadPreference(context:Context, name:string) {
    try {
      const preference = await preferences.getPreferences(context, name)
      this.preferencesMap.set(name,preference)
    } catch (e) {
      LogUtil.error(TAG, `加载 Preference ${name} 失败: ${JSON.stringify(e)}`)
      throw new Error(`加载 Preference ${name} 失败: ${JSON.stringify(e)}`)
    }
  }

  // 新增数据
  async putPreferenceValue(name: string, key: string, value: preferences.ValueType) {
    if(!this.preferencesMap.has(name)) {
      LogUtil.error(TAG, `Preference ${name} 尚未初始化`)
      return
    }
    try {
      const preference = this.preferencesMap.get(name)
      await preference?.put(key, value)
      await preference?.flush()
    } catch (e) {
      LogUtil.error(TAG, `保存 Preference ${name} 失败: ${JSON.stringify(e)}`)
    }
  }



  // 读取数据
  async getPreferenceValue<T extends preferences.ValueType>(name: string, key: string, defaultValue: T): Promise<T> {
    if (!this.preferencesMap.has(name)) {
      throw new Error(TAG + `Preference ${name} 尚未初始化`)
    }
    try {
      const preference = this.preferencesMap.get(name)
      const value = await preference?.get(key, defaultValue)
      return value as T;
    } catch (e) {
      LogUtil.error(TAG, `读取 Preference ${name} 失败: ${JSON.stringify(e)}`)
      throw new Error(TAG + `无法读取 Preference ${name}.${key}`)
    }
  }


  // 删除数据
  async delPreferenceValue(name: string, key: string) {
    if(!this.preferencesMap.has(name)) {
      LogUtil.error(TAG, `Preference ${name} 尚未初始化`)
      return
    }
    try {
      const preference = this.preferencesMap.get(name)
      await preference?.delete(key)
      await preference?.flush()
    } catch (e) {
      LogUtil.error(TAG, `删除 Preference ${name} 失败: ${JSON.stringify(e)}`)
    }
  }

  // 判断 Preference 中是否存在指定的 key
  async hasPreferenceValue(name: string, key: string): Promise<boolean> {
    if (!this.preferencesMap.has(name)) {
      LogUtil.error(TAG, `Preference ${name} 尚未初始化`)
      return false
    }
    try {
      const preference = this.preferencesMap.get(name)
      const value = await preference?.get(key, undefined)
      return value !== undefined
    } catch (e) {
      LogUtil.error(TAG, `判断 Preference ${name} 是否存在失败: ${JSON.stringify(e)}`)
      return false
    }
  }

}

const preferencesUtils = new PreferencesUtils()
export default preferencesUtils as PreferencesUtils
