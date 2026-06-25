/**
 * theme — 全局统一主题常量
 * 所有页面统一导入使用，定义全项目磨砂卡片、文字、渐变配色
 * 日间：通透蓝白磨砂玻璃风格
 * 夜间：深色护眼模式，卡片足够暗以从背景中分离
 */
// ==================== 卡片半透明磨砂背景 ====================
/** 日间主大卡片：半透磨砂，背景可见 */
export const cardMainDay = "rgba(255,255,255,0.35)";
/** 日间小卡片 */
export const cardSubDay = "rgba(255,255,255,0.22)";
/** 日间强调卡片（选中/悬停态） */
export const cardAccentDay = "rgba(255,255,255,0.42)";
/** 日间辅助色 */
export const cardAuxDay = "rgba(59,120,194,0.10)";

/** 夜间主大卡片：深色不透，清晰从背景分离 */
export const cardMainNight = "rgba(22,27,34,0.85)";
/** 夜间小卡片 */
export const cardSubNight = "rgba(30,36,44,0.75)";
/** 夜间强调卡片 */
export const cardAccentNight = "rgba(38,46,55,0.90)";
/** 夜间辅助色 */
export const cardAuxNight = "rgba(59,120,194,0.18)";

// ==================== 边框 & 阴影 ====================
export const borderDay = "rgba(255,255,255,0.40)";
export const borderSubDay = "rgba(255,255,255,0.30)";
export const borderNight = "rgba(255,255,255,0.08)";
export const borderSubNight = "rgba(255,255,255,0.05)";
export const shadowDay = "rgba(60,100,150,0.15)";
export const shadowNight = "rgba(0,0,0,0.50)";

// ==================== 日间文字配色 ====================
export const TC_DAY_PRIMARY = "#0F243D";
export const TC_DAY_ACCENT = "#2B6CB2";
export const TC_DAY_SECONDARY = "#2C4A6E";
export const TC_DAY_TERTIARY = "#3A5A7A";
export const TC_DAY_MUTED = "#5A7A98";
export const TC_DAY_TEMP = "#0F243D";
export const TC_DAY_TEMP_UNIT = "#2B6CB2";
export const TC_DAY_HILO = "#2C4A6E";

// ==================== 夜间文字配色（护眼模式）====================
export const TC_NIGHT_PRIMARY = "#F0F4F8";
export const TC_NIGHT_ACCENT = "#5BA3E6";
export const TC_NIGHT_SECONDARY = "#D0D7DF";
export const TC_NIGHT_TERTIARY = "#B0B8C5";
export const TC_NIGHT_MUTED = "#88909E";
export const TC_NIGHT_TEMP = "#F0F4F8";
export const TC_NIGHT_TEMP_UNIT = "#5BA3E6";
export const TC_NIGHT_HILO = "#D0D7DF";

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
  return isNight ? cardMainNight : cardMainDay;
}
export function cardBgStrong(isNight: boolean): string {
  return isNight ? cardAccentNight : cardAccentDay;
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
export const accentBlueLight = "#5BA3E6";
export const accentBlueDark = "#1A4A7A";
