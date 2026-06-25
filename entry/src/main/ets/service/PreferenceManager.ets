import { relationalStore } from '@kit.ArkData';

interface SettingsMap {
  tempUnit: string;
  refreshInterval: string;
  darkMode: string;
}

const DB_NAME: string = 'weather_app.db';
const DB_VERSION: number = 1;
const HISTORY_LIMIT: number = 200;

function nowISO(): string {
  let d: Date = new Date();
  return d.getFullYear() + '-' +
    String(d.getMonth() + 1).padStart(2, '0') + '-' +
    String(d.getDate()).padStart(2, '0') + ' ' +
    String(d.getHours()).padStart(2, '0') + ':' +
    String(d.getMinutes()).padStart(2, '0') + ':' +
    String(d.getSeconds()).padStart(2, '0');
}

class PreferenceManager {
  private store: relationalStore.RdbStore | null = null;

  async init(context: Context): Promise<void> {
    try {
      const config: relationalStore.StoreConfig = {
        name: DB_NAME,
        securityLevel: relationalStore.SecurityLevel.S1
      };
      this.store = await relationalStore.getRdbStore(context, config);
      await this.createTables();
    } catch (e) {
      console.error('DB init failed: ' + JSON.stringify(e));
    }
  }

  private async createTables(): Promise<void> {
    if (this.store === null) return;
    try {
      await this.store.executeSql(
        'CREATE TABLE IF NOT EXISTS history (city TEXT PRIMARY KEY, visited_at TEXT NOT NULL)'
      );
      await this.store.executeSql(
        'CREATE TABLE IF NOT EXISTS weather_cache (city TEXT PRIMARY KEY, data TEXT NOT NULL, updated_at TEXT NOT NULL)'
      );
      await this.store.executeSql(
        'CREATE TABLE IF NOT EXISTS location_cache (city TEXT PRIMARY KEY, location_id TEXT NOT NULL)'
      );
      await this.store.executeSql(
        'CREATE TABLE IF NOT EXISTS kv_settings (key TEXT PRIMARY KEY, value TEXT NOT NULL)'
      );
    } catch (e) {
      console.error('createTables error: ' + JSON.stringify(e));
    }
  }

  // ========== 城市历史记录 ==========

  async getLastCity(): Promise<string> {
    let val: string = await this.getSetting('last_city', '');
    if (val.length > 0) { return val; }
    return '深圳';
  }
  async saveLastCity(city: string): Promise<void> {
    await this.saveSetting('last_city', city);
  }

  async getHistory(): Promise<string[]> {
    if (this.store === null) return [];
    try {
      let predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('history');
      predicates.orderByDesc('visited_at');
      let rs: relationalStore.ResultSet = await this.store.query(predicates, ['city']);
      let result: string[] = [];
      while (rs.goToNextRow()) {
        result.push(rs.getString(rs.getColumnIndex('city')));
      }
      rs.close();
      return result;
    } catch (e) {
      console.error('getHistory error: ' + JSON.stringify(e));
      return [];
    }
  }

  async saveHistory(history: string[]): Promise<void> {
    if (this.store === null) return;
    try {
      await this.store.executeSql('DELETE FROM history');
      let now: string = nowISO();
      for (let i: number = 0; i < history.length && i < HISTORY_LIMIT; i++) {
        let values: relationalStore.ValuesBucket = {
          'city': history[i],
          'visited_at': now
        };
        await this.store.insert('history', values);
      }
    } catch (e) {
      console.error('saveHistory error: ' + JSON.stringify(e));
    }
  }

  async addToHistory(city: string): Promise<string[]> {
    if (this.store === null) return [city];
    try {
      // UPSERT: INSERT OR REPLACE
      let now: string = nowISO();
      await this.store.executeSql(
        'INSERT OR REPLACE INTO history (city, visited_at) VALUES (?, ?)',
        [city, now]
      );
      // 删掉超过上限的旧记录
      await this.store.executeSql(
        'DELETE FROM history WHERE city NOT IN (SELECT city FROM history ORDER BY visited_at DESC LIMIT ?)',
        [HISTORY_LIMIT]
      );
    } catch (e) {
      console.error('addToHistory error: ' + JSON.stringify(e));
    }
    return this.getHistory();
  }

  async removeFromHistory(city: string): Promise<string[]> {
    if (this.store === null) return [];
    try {
      let predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('history');
      predicates.equalTo('city', city);
      await this.store.delete(predicates);
    } catch (e) {
      console.error('removeFromHistory error: ' + JSON.stringify(e));
    }
    return this.getHistory();
  }

  // ========== 设置 ==========

  private async getSetting(key: string, defaultVal: string): Promise<string> {
    if (this.store === null) return defaultVal;
    try {
      let predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('kv_settings');
      predicates.equalTo('key', key);
      let rs: relationalStore.ResultSet = await this.store.query(predicates, ['value']);
      let result: string = defaultVal;
      if (rs.rowCount > 0 && rs.goToFirstRow()) {
        result = rs.getString(rs.getColumnIndex('value'));
      }
      rs.close();
      return result;
    } catch (e) {
      return defaultVal;
    }
  }

  private async saveSetting(key: string, value: string): Promise<void> {
    if (this.store === null) return;
    try {
      await this.store.executeSql(
        'INSERT OR REPLACE INTO kv_settings (key, value) VALUES (?, ?)',
        [key, value]
      );
    } catch (e) {
      console.error('saveSetting error: ' + JSON.stringify(e));
    }
  }

  async getSettings(): Promise<SettingsMap> {
    let tempUnit: string = await this.getSetting('tempUnit', 'C');
    let refreshInterval: string = await this.getSetting('refreshInterval', '30');
    let darkMode: string = await this.getSetting('darkMode', 'false');
    return { tempUnit: tempUnit, refreshInterval: refreshInterval, darkMode: darkMode };
  }

  async saveTempUnit(unit: string): Promise<void> {
    await this.saveSetting('tempUnit', unit);
  }

  async saveRefreshInterval(interval: string): Promise<void> {
    await this.saveSetting('refreshInterval', interval);
  }

  async saveDarkMode(darkMode: string): Promise<void> {
    await this.saveSetting('darkMode', darkMode);
  }

  // ========== 天气数据缓存 ==========

  async saveWeatherCache(city: string, dataJson: string): Promise<void> {
    if (this.store === null) return;
    try {
      let now: string = nowISO();
      await this.store.executeSql(
        'INSERT OR REPLACE INTO weather_cache (city, data, updated_at) VALUES (?, ?, ?)',
        [city, dataJson, now]
      );
    } catch (e) {
      console.error('saveWeatherCache error: ' + JSON.stringify(e));
    }
  }

  async getWeatherCache(city: string): Promise<string | null> {
    if (this.store === null) return null;
    try {
      let predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('weather_cache');
      predicates.equalTo('city', city);
      let rs: relationalStore.ResultSet = await this.store.query(predicates, ['data']);
      let result: string | null = null;
      if (rs.rowCount > 0 && rs.goToFirstRow()) {
        result = rs.getString(rs.getColumnIndex('data'));
      }
      rs.close();
      return result;
    } catch (e) {
      console.error('getWeatherCache error: ' + JSON.stringify(e));
      return null;
    }
  }

  async clearAllCache(): Promise<void> {
    if (this.store === null) return;
    try {
      await this.store.executeSql('DELETE FROM weather_cache');
    } catch (e) {
      console.error('clearAllCache error: ' + JSON.stringify(e));
    }
  }

  // ========== 位置ID缓存 ==========

  async saveLocationId(city: string, locId: string): Promise<void> {
    if (this.store === null) return;
    try {
      await this.store.executeSql(
        'INSERT OR REPLACE INTO location_cache (city, location_id) VALUES (?, ?)',
        [city, locId]
      );
    } catch (e) {
      console.error('saveLocationId error: ' + JSON.stringify(e));
    }
  }

    // ========== ???? ==========

  async getFavorites(): Promise<string[]> {
    if (this.store === null) return [];
    try {
      let val: string = await this.getSetting('favorites', '[]');
      return JSON.parse(val) as string[];
    } catch (e) {
      console.error('getFavorites error: ' + JSON.stringify(e));
      return [];
    }
  }

  async toggleFavorite(city: string): Promise<string[]> {
    if (this.store === null) return [];
    try {
      let val: string = await this.getSetting('favorites', '[]');
      let list: string[] = JSON.parse(val) as string[];
      let idx: number = list.indexOf(city);
      if (idx >= 0) {
        list.splice(idx, 1);
      } else {
        list.push(city);
      }
      await this.saveSetting('favorites', JSON.stringify(list));
      return list;
    } catch (e) {
      console.error('toggleFavorite error: ' + JSON.stringify(e));
      return [];
    }
  }

  /** 从收藏列表删除单个城市 */
  async removeFavorite(city: string): Promise<string[]> {
    if (this.store === null) return [];
    try {
      let val: string = await this.getSetting('favorites', '[]');
      let list: string[] = JSON.parse(val) as string[];
      let idx: number = list.indexOf(city);
      if (idx >= 0) {
        list.splice(idx, 1);
        await this.saveSetting('favorites', JSON.stringify(list));
      }
      return list;
    } catch (e) {
      console.error('removeFavorite error: ' + JSON.stringify(e));
      return [];
    }
  }

  async isFavorite(city: string): Promise<boolean> {
    if (this.store === null) return false;
    try {
      let val: string = await this.getSetting('favorites', '[]');
      let list: string[] = JSON.parse(val) as string[];
      return list.indexOf(city) >= 0;
    } catch (e) {
      return false;
    }
  }

async getLocationId(city: string): Promise<string | null> {
    if (this.store === null) return null;
    try {
      let predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('location_cache');
      predicates.equalTo('city', city);
      let rs: relationalStore.ResultSet = await this.store.query(predicates, ['location_id']);
      let result: string | null = null;
      if (rs.rowCount > 0 && rs.goToFirstRow()) {
        result = rs.getString(rs.getColumnIndex('location_id'));
      }
      rs.close();
      return result;
    } catch (e) {
      console.error('getLocationId error: ' + JSON.stringify(e));
      return null;
    }
  }
}

const prefManager: PreferenceManager = new PreferenceManager();
export default prefManager;



