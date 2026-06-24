import { relationalStore } from '@kit.ArkData';
import { SearchHistoryItem } from '../model/SearchHistory';

const DB_NAME: string = 'weather_app.db';
const MAX_HISTORY: number = 20;

class SearchHistoryManager {
  private store: relationalStore.RdbStore | null = null;

  async init(context: Context): Promise<void> {
    if (this.store !== null) { return; }
    try {
      const config: relationalStore.StoreConfig = {
        name: DB_NAME,
        securityLevel: relationalStore.SecurityLevel.S1
      };
      this.store = await relationalStore.getRdbStore(context, config);
      await this.createTable();
    } catch (e) {
      console.error('SearchHistoryManager init error: ' + JSON.stringify(e));
    }
  }

  private async createTable(): Promise<void> {
    if (this.store === null) { return; }
    try {
      await this.store.executeSql(
        'CREATE TABLE IF NOT EXISTS search_history (' +
        'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
        'city_name TEXT NOT NULL UNIQUE, ' +
        'create_time TEXT NOT NULL' +
        ')'
      );
    } catch (e) {
      console.error('createTable error: ' + JSON.stringify(e));
    }
  }

  /**
   * 添加搜索记录：重复城市仅更新时间戳，不重复新增
   */
  async addHistory(cityName: string): Promise<void> {
    if (this.store === null || cityName.length === 0) { return; }
    try {
      let now: string = this.nowISO();
      // UPSERT: UNIQUE冲突时只更新create_time
      await this.store.executeSql(
        'INSERT OR REPLACE INTO search_history (id, city_name, create_time) VALUES (' +
        'COALESCE((SELECT id FROM search_history WHERE city_name = ?), ' +
        '(SELECT COALESCE(MAX(id), 0) + 1 FROM search_history)), ?, ?)',
        [cityName, cityName, now]
      );
      // 删除超出上限的旧记录
      await this.trimHistory();
    } catch (e) {
      console.error('addHistory error: ' + JSON.stringify(e));
      // 降级方案：直接用唯一键冲突处理
      try {
        // 先删除再插入，简单可靠
        await this.deleteHistory(cityName);
        let values: relationalStore.ValuesBucket = {
          'city_name': cityName,
          'create_time': this.nowISO()
        };
        await this.store!.insert('search_history', values);
        await this.trimHistory();
      } catch (e2) {
        console.error('addHistory fallback error: ' + JSON.stringify(e2));
      }
    }
  }

  /**
   * 读取历史按时间戳倒序，最多20条
   */
  async getHistory(): Promise<SearchHistoryItem[]> {
    if (this.store === null) { return []; }
    try {
      let predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('search_history');
      predicates.orderByDesc('create_time');
      predicates.limitAs(MAX_HISTORY);
      let rs: relationalStore.ResultSet = await this.store.query(predicates, ['id', 'city_name', 'create_time']);
      let result: SearchHistoryItem[] = [];
      while (rs.goToNextRow()) {
        result.push({
          id: rs.getLong(rs.getColumnIndex('id')),
          cityName: rs.getString(rs.getColumnIndex('city_name')),
          createTime: rs.getString(rs.getColumnIndex('create_time'))
        });
      }
      rs.close();
      return result;
    } catch (e) {
      console.error('getHistory error: ' + JSON.stringify(e));
      return [];
    }
  }

  /**
   * 删除单条历史记录
   */
  async deleteHistory(cityName: string): Promise<void> {
    if (this.store === null) { return; }
    try {
      let predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('search_history');
      predicates.equalTo('city_name', cityName);
      await this.store.delete(predicates);
    } catch (e) {
      console.error('deleteHistory error: ' + JSON.stringify(e));
    }
  }

  /**
   * 一键清空全部历史
   */
  async clearAll(): Promise<void> {
    if (this.store === null) { return; }
    try {
      await this.store.executeSql('DELETE FROM search_history');
    } catch (e) {
      console.error('clearAll error: ' + JSON.stringify(e));
    }
  }

  /**
   * 删除超出上限的最早记录，保留最近 MAX_HISTORY 条
   */
  private async trimHistory(): Promise<void> {
    if (this.store === null) { return; }
    try {
      await this.store.executeSql(
        'DELETE FROM search_history WHERE id NOT IN (' +
        'SELECT id FROM search_history ORDER BY create_time DESC LIMIT ?' +
        ')', [MAX_HISTORY]
      );
    } catch (e) {
      console.error('trimHistory error: ' + JSON.stringify(e));
    }
  }

  private nowISO(): string {
    let d: Date = new Date();
    return d.getFullYear() + '-' +
      String(d.getMonth() + 1).padStart(2, '0') + '-' +
      String(d.getDate()).padStart(2, '0') + ' ' +
      String(d.getHours()).padStart(2, '0') + ':' +
      String(d.getMinutes()).padStart(2, '0') + ':' +
      String(d.getSeconds()).padStart(2, '0');
  }
}

const searchHistoryManager: SearchHistoryManager = new SearchHistoryManager();
export default searchHistoryManager;
