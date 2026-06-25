/**
 * theme — 全局统一主题常量
 * 日间：通透蓝白磨砂玻璃
 * 夜间：深空静谧风 - 靛蓝深色基调，暖白文字，夜空沉浸感
 */
// ==================== 日间卡片 ====================
export const cardMainDay = "rgba(255,255,255,0.35)";
export const cardSubDay = "rgba(255,255,255,0.22)";
export const cardAccentDay = "rgba(255,255,255,0.42)";
export const cardAuxDay = "rgba(59,120,194,0.10)";

// ==================== 夜间卡片（夜空深蓝基调）====================
export const cardMainNight = "rgba(16,20,34,0.85)";
export const cardSubNight = "rgba(20,26,42,0.78)";
export const cardAccentNight = "rgba(26,32,52,0.90)";
export const cardAuxNight = "rgba(80,160,255,0.12)";
// 夜间纯色备用
export const cardSolidNight = "#0E1222";
export const cardSolidSubNight = "#141A2E";

// ==================== 边框 & 阴影 ====================
export const borderDay = "rgba(255,255,255,0.40)";
export const borderSubDay = "rgba(255,255,255,0.30)";
export const borderNight = "rgba(100,160,240,0.12)";
export const borderSubNight = "rgba(100,160,240,0.08)";
export const shadowDay = "rgba(60,100,150,0.12)";
export const shadowNight = "rgba(0,0,0,0.60)";

// ==================== 日间文字 ====================
export const TC_DAY_PRIMARY = "#0F243D";
export const TC_DAY_ACCENT = "#2B6CB2";
export const TC_DAY_SECONDARY = "#2C4A6E";
export const TC_DAY_TERTIARY = "#3A5A7A";
export const TC_DAY_MUTED = "#5A7A98";
export const TC_DAY_TEMP = "#0F243D";
export const TC_DAY_TEMP_UNIT = "#2B6CB2";
export const TC_DAY_HILO = "#2C4A6E";

// ==================== 夜间文字（夜空风：暖白+冰蓝）====================
export const TC_NIGHT_PRIMARY = "#F0F4FC";    // 暖白
export const TC_NIGHT_ACCENT = "#6CB8FF";     // 冰蓝（温度数值、图标）
export const TC_NIGHT_SECONDARY = "#D0D8EA";  // 浅灰蓝
export const TC_NIGHT_TERTIARY = "#A8B4CE";   // 灰蓝
export const TC_NIGHT_MUTED = "#7888A8";      // 暗灰蓝
export const TC_NIGHT_TEMP = "#F0F4FC";       // 温度主色
export const TC_NIGHT_TEMP_UNIT = "#6CB8FF";  // 温度单位
export const TC_NIGHT_HILO = "#D0D8EA";       // 高低温度

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
export const accentBlueLight = "#6CB8FF";
export const accentBlueDark = "#1A4A7A";
