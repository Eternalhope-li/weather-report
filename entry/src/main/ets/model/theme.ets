/**
 * theme — 全局统一主题常量
 * 所有页面统一导入使用，定义全项目磨砂卡片、文字、渐变配色
 * 日间：蓝白通透风格 / 夜间：护眼深色模式
 */
// ==================== 卡片半透明磨砂背景 ====================
/** 日间主大卡片：更高透明度，背景更通透 */
export const cardMainDay = 'rgba(255,255,255,0.20)';
/** 日间小卡片 */
export const cardSubDay = 'rgba(255,255,255,0.13)';
/** 日间强调卡片 */
export const cardAccentDay = 'rgba(255,255,255,0.25)';
/** 夜间主大卡片（护眼深色，更高透明度让背景渐变可见） */
export const cardMainNight = 'rgba(26,30,36,0.35)';
/** 夜间小卡片 */
export const cardSubNight = 'rgba(26,30,36,0.20)';
/** 夜间强调卡片 */
export const cardAccentNight = 'rgba(30,34,44,0.50)';

// ==================== 边框 ====================
export const borderDay = 'rgba(255,255,255,0.35)';
export const borderSubDay = 'rgba(255,255,255,0.28)';
export const borderNight = 'rgba(255,255,255,0.10)';
export const borderSubNight = 'rgba(255,255,255,0.06)';
export const shadowDay = 'rgba(80,120,170,0.12)';
export const shadowNight = 'rgba(0,0,0,0.40)';

// ==================== 日间文字配色 ====================
/** 主文字深海军蓝 - 高对比度 */
export const TC_DAY_PRIMARY = '#0F243D';
/** 主题蓝图标 */
export const TC_DAY_ACCENT = '#2B6CB2';
/** 辅助文字 */
export const TC_DAY_SECONDARY = '#2C4A6E';
export const TC_DAY_TERTIARY = '#3A5A7A';
export const TC_DAY_MUTED = '#5A7A98';
export const TC_DAY_TEMP = '#0F243D';
export const TC_DAY_TEMP_UNIT = '#2B6CB2';
export const TC_DAY_HILO = '#2C4A6E';

// ==================== 夜间文字配色（护眼模式）====================
/** 主文字 - 柔白高对比 */
export const TC_NIGHT_PRIMARY = '#F0F2F5';
/** 主题蓝图标 - 亮蓝 */
export const TC_NIGHT_ACCENT = '#5BA3E6';
/** 辅助文字 - 浅灰白 */
export const TC_NIGHT_SECONDARY = '#D0D4DA';
export const TC_NIGHT_TERTIARY = '#B0B6C2';
export const TC_NIGHT_MUTED = '#8A92A0';
export const TC_NIGHT_TEMP = '#F0F2F5';
export const TC_NIGHT_TEMP_UNIT = '#5BA3E6';
export const TC_NIGHT_HILO = '#D0D4DA';

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

export const accentBlue = '#2B6CB2';
export const accentBlueLight = '#5BA3E6';
export const accentBlueDark = '#1A4A7A';
