// CitySwitch — 全局城市切换信号（跨页面共享状态）
// CityManage set → Index onPageShow read → clear
let gPendingCity: string = "";

export function setPendingCity(city: string): void {
  gPendingCity = city;
}

export function getPendingCity(): string {
  return gPendingCity;
}

export function clearPendingCity(): void {
  gPendingCity = "";
}
