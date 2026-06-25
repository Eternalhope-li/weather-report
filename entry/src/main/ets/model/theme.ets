/**
 * 全局主题色常量 - 磨砂卡片半透明色值
 */
export const cardMainDay = 'rgba(255,255,255,0.22)';
export const cardSubDay = 'rgba(255,255,255,0.16)';
export const cardMainNight = 'rgba(30,42,60,0.3)';
export const cardSubNight = 'rgba(30,42,60,0.22)';

export function cardMain(isNight: boolean): string {
  return isNight ? cardMainNight : cardMainDay;
}
export function cardSub(isNight: boolean): string {
  return isNight ? cardSubNight : cardSubDay;
}
