/**
 * theme — 全局统一主题常量
 * 日间：通透蓝白磨砂玻璃
 * 夜间：纯黑基底 + 纯白文字（最高对比度）
 */
// ==================== 日间卡片 ====================
export const cardMainDay = "rgba(255,255,255,0.22)";
export const cardSubDay = "rgba(255,255,255,0.14)";
export const cardAccentDay = "rgba(255,255,255,0.28)";
export const cardAuxDay = "rgba(59,120,194,0.10)";

// ==================== 夜间卡片（纯黑半透）====================
export const cardMainNight = "rgba(20,20,25,0.35)";
export const cardSubNight = "rgba(20,20,25,0.25)";
export const cardAccentNight = "rgba(20,20,25,0.40)";
export const cardAuxNight = "rgba(60,140,240,0.12)";
export const cardSolidNight = "#1A1A1E";
export const cardSolidSubNight = "#1A1A1E";

// ==================== 边框 & 阴影 ====================
export const borderDay = "rgba(255,255,255,0.40)";
export const borderSubDay = "rgba(255,255,255,0.30)";
export const borderNight = "rgba(255,255,255,0.12)";
export const borderSubNight = "rgba(255,255,255,0.08)";
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

// ==================== 夜间文字（纯白全系列）====================
export const TC_NIGHT_PRIMARY = "#FFFFFF";       // 纯白
export const TC_NIGHT_ACCENT = "#D0D0D0";        // 浅灰
export const TC_NIGHT_SECONDARY = "#F0F0F0";     // 近白
export const TC_NIGHT_TERTIARY = "#E0E0E0";      // 亮灰
export const TC_NIGHT_MUTED = "#C0C0C0";         // 中灰
export const TC_NIGHT_TEMP = "#FFFFFF";           // 纯白
export const TC_NIGHT_TEMP_UNIT = "#FFFFFF";      // 纯白
export const TC_NIGHT_HILO = "#F0F0F0";           // 近白

// ==================== 图标 & 分割线 ====================
export const iconNight = "rgba(200,200,210,0.80)";
export const splitLineNight = "rgba(255,255,255,0.15)";

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
export const accentBlueLight = "#7BB8E8";
export const accentBlueDark = "#1A4A7A";

