/**
 * theme — 全局统一主题常量
 * 日间：通透蓝白磨砂玻璃
 * 夜间：真正深色模式 - Material Dark 风格
 */
// ==================== 日间卡片（磨砂玻璃）====================
export const cardMainDay = "rgba(255,255,255,0.35)";
export const cardSubDay = "rgba(255,255,255,0.22)";
export const cardAccentDay = "rgba(255,255,255,0.42)";
export const cardAuxDay = "rgba(59,120,194,0.10)";
// ==================== 夜间卡片（Material Dark 风格）====================
export const cardMainNight = "rgba(30,33,38,0.92)";
export const cardSubNight = "rgba(38,42,48,0.88)";
export const cardAccentNight = "rgba(46,50,56,0.95)";
export const cardAuxNight = "rgba(60,130,220,0.15)";
// 夜间纯色备用（当 backdropBlur 不可用时）
export const cardSolidNight = "#1E2126";
export const cardSolidSubNight = "#262A30";
// ==================== 边框 & 阴影 ====================
export const borderDay = "rgba(255,255,255,0.40)";
export const borderSubDay = "rgba(255,255,255,0.30)";
export const borderNight = "rgba(255,255,255,0.06)";
export const borderSubNight = "rgba(255,255,255,0.04)";
export const shadowDay = "rgba(60,100,150,0.12)";
export const shadowNight = "rgba(0,0,0,0.55)";
// ==================== 日间文字配色 ====================
export const TC_DAY_PRIMARY = "#0F243D";
export const TC_DAY_ACCENT = "#2B6CB2";
export const TC_DAY_SECONDARY = "#2C4A6E";
export const TC_DAY_TERTIARY = "#3A5A7A";
export const TC_DAY_MUTED = "#5A7A98";
export const TC_DAY_TEMP = "#0F243D";
export const TC_DAY_TEMP_UNIT = "#2B6CB2";
export const TC_DAY_HILO = "#2C4A6E";
// ==================== 夜间文字（高对比度）====================
export const TC_NIGHT_PRIMARY = "#F2F4F8";
export const TC_NIGHT_ACCENT = "#66B0FF";
export const TC_NIGHT_SECONDARY = "#D8DCE3";
export const TC_NIGHT_TERTIARY = "#B8BEC8";
export const TC_NIGHT_MUTED = "#9098A4";
export const TC_NIGHT_TEMP = "#F2F4F8";
export const TC_NIGHT_TEMP_UNIT = "#66B0FF";
export const TC_NIGHT_HILO = "#D8DCE3";
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
  return isNight ? cardSubNight : cardSubDay;
}
export function cardFrost(isNight: boolean): string {
  return isNight ? cardSubNight : cardSubDay;
}
export function cardBg(isNight: boolean): string {
  return cardMain(isNight);
}
export function cardBgStrong(isNight: boolean): string {
  return cardAccent(isNight);
}
export function cardAux(isNight: boolean): string {
  return isNight ? cardAuxNight : cardAuxDay;
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
export const accentBlue = "#2B6CB2";
export const accentBlueLight = "#66B0FF";
export const accentBlueDark = "#1A4A7A";
