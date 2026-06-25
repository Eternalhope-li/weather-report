/**
 * theme — 全局统一主题常量
 * 所有页面统一导入使用，定义全项目磨砂卡片、文字、渐变配色
 */
// ==================== 卡片半透明磨砂背景 ====================
/** 日间主大卡片：rgba(255,255,255,0.22) backdropBlur(24vp) */
export const cardMainDay = 'rgba(255,255,255,0.15)';
/** 日间小卡片：rgba(255,255,255,0.16) backdropBlur(18vp) */
export const cardSubDay = 'rgba(255,255,255,0.10)';
/** 日间强调卡片 */
export const cardAccentDay = 'rgba(255,255,255,0.18)';
/** 夜间主大卡片：rgba(30,42,60,0.3) backdropBlur(24vp) */
export const cardMainNight = 'rgba(35,38,46,0.3)';
/** 夜间小卡片：rgba(30,42,60,0.22) backdropBlur(18vp) */
export const cardSubNight = 'rgba(35,38,46,0.2)';
/** 夜间强调卡片 */
export const cardAccentNight = 'rgba(42,46,55,0.4)';

// ==================== 边框 ====================
export const borderDay = 'rgba(255,255,255,0.3)';
export const borderSubDay = 'rgba(255,255,255,0.25)';
export const borderNight = 'rgba(200,195,185,0.15)';
export const borderSubNight = 'rgba(200,195,185,0.08)';
export const shadowDay = 'rgba(100,140,190,0.15)';
export const shadowNight = 'rgba(0,0,0,0)';

// ==================== 日间文字配色 ====================
/** 主文字深海军蓝 */
export const TC_DAY_PRIMARY = '#0F243D';
/** 主题蓝图标 */
export const TC_DAY_ACCENT = '#3B78C2';
/** 辅助浅灰蓝 */
export const TC_DAY_SECONDARY = '#4A6482';
export const TC_DAY_TERTIARY = '#4A6482';
export const TC_DAY_MUTED = '#6E87A0';
export const TC_DAY_TEMP = '#0F243D';
export const TC_DAY_TEMP_UNIT = '#3B78C2';
export const TC_DAY_HILO = '#4A6482';

// ==================== 夜间文字配色 ====================
export const TC_NIGHT_PRIMARY = '#E8E4DC';
export const TC_NIGHT_ACCENT = '#6BA3E0';
export const TC_NIGHT_SECONDARY = '#C8C3BA';
export const TC_NIGHT_TERTIARY = '#A8A39B';
export const TC_NIGHT_MUTED = '#88847C';
export const TC_NIGHT_TEMP = '#E8E4DC';
export const TC_NIGHT_TEMP_UNIT = '#6BA3E0';
export const TC_NIGHT_HILO = '#A8A39B';

// ==================== 函数接口 ====================
export function cardMain(isNight: boolean): string {
  return isNight ? cardMainNight : cardMainDay;
}
export function cardSub(isNight: boolean): string {
  return isNight ? cardSubNight : cardSubDay;
}
export function cardAccent(isNight: boolean): string {
  return isNight ? cardAccentNight : cardAccentDay;
}
export function cardSecondary(isNight: boolean): string {
  return cardSub(isNight);
}
export function cardFrost(isNight: boolean): string {
  return cardSub(isNight);
}
export function cardBg(isNight: boolean): string {
  return cardMain(isNight);
}
export function cardBgStrong(isNight: boolean): string {
  return cardAccent(isNight);
}
export function cardShadowColor(isNight: boolean): string {
  return isNight ? shadowNight : shadowDay;
}
export function cardBorder(isNight: boolean): string {
  return isNight ? borderNight : borderDay;
}
export function cardBorderSub(isNight: boolean): string {
  return isNight ? borderSubNight : borderSubDay;
}

export function tcPrimary(isNight: boolean): string {
  return isNight ? TC_NIGHT_PRIMARY : TC_DAY_PRIMARY;
}
export function tcSecondary(isNight: boolean): string {
  return isNight ? TC_NIGHT_SECONDARY : TC_DAY_SECONDARY;
}
export function tcTertiary(isNight: boolean): string {
  return isNight ? TC_NIGHT_TERTIARY : TC_DAY_TERTIARY;
}
export function tcMuted(isNight: boolean): string {
  return isNight ? TC_NIGHT_MUTED : TC_DAY_MUTED;
}
export function tcTemp(isNight: boolean): string {
  return isNight ? TC_NIGHT_TEMP : TC_DAY_TEMP;
}
export function tcTempUnit(isNight: boolean): string {
  return isNight ? TC_NIGHT_TEMP_UNIT : TC_DAY_TEMP_UNIT;
}
export function tcHiLo(isNight: boolean): string {
  return isNight ? TC_NIGHT_HILO : TC_DAY_HILO;
}

export const accentBlue = '#3B78C2';
export const accentBlueLight = '#73A9E8';
export const accentBlueDark = '#2D5B96';


