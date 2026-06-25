// CitySwitch — 全局城市切换信号（跨页面共享状态）
// 使用 AppStorage 实现可靠的跨页面通信
// CityManage set → Index onPageShow read → clear

const PENDING_CITY_KEY: string = "pendingCity";

/** 确保 AppStorage 键已初始化 */
function ensureKey(): void {
  if (AppStorage.Get<string>(PENDING_CITY_KEY) === undefined) {
    AppStorage.SetOrCreate<string>(PENDING_CITY_KEY, "");
  }
}

export function setPendingCity(city: string): void {
  ensureKey();
  AppStorage.Set<string>(PENDING_CITY_KEY, city);
}

export function getPendingCity(): string {
  ensureKey();
  let val = AppStorage.Get<string>(PENDING_CITY_KEY);
  return val !== undefined ? val : "";
}

export function clearPendingCity(): void {
  ensureKey();
  AppStorage.Set<string>(PENDING_CITY_KEY, "");
}
