/**
 * theme — 全局统一主题常量
 * 日间：通透蓝白磨砂玻璃
 * 夜间：半透深蓝磨砂 + 3档淡蓝白文字 + 冰蓝图标
 */
// ==================== 日间卡片 ====================
export const cardMainDay = "rgba(255,255,255,0.35)";
export const cardSubDay = "rgba(255,255,255,0.22)";
export const cardAccentDay = "rgba(255,255,255,0.42)";
export const cardAuxDay = "rgba(59,120,194,0.10)";

// ==================== 夜间卡片（半透深蓝，用户指定）====================
export const cardMainNight = "rgba(30,45,80,0.45)";
export const cardSubNight = "rgba(30,45,80,0.40)";
export const cardAccentNight = "rgba(30,50,85,0.50)";
export const cardAuxNight = "rgba(80,160,255,0.12)";
// 夜间纯色备用
export const cardSolidNight = "#0E1222";
export const cardSolidSubNight = "#141A2E";

// ==================== 边框 & 阴影 ====================
export const borderDay = "rgba(255,255,255,0.40)";
export const borderSubDay = "rgba(255,255,255,0.30)";
export const borderNight = "rgba(145,175,255,0.18)";   // 1vp淡蓝描边
export const borderSubNight = "rgba(145,175,255,0.12)"; // 弱化描边
export const shadowDay = "rgba(60,100,150,0.12)";
export const shadowNight = "rgba(0,0,0,0.50)";

// ==================== 日间文字 ====================
export const TC_DAY_PRIMARY = "#0F243D";
export const TC_DAY_ACCENT = "#2B6CB2";
export const TC_DAY_SECONDARY = "#2C4A6E";
export const TC_DAY_TERTIARY = "#3A5A7A";
export const TC_DAY_MUTED = "#5A7A98";
export const TC_DAY_TEMP = "#0F243D";
export const TC_DAY_TEMP_UNIT = "#2B6CB2";
export const TC_DAY_HILO = "#2C4A6E";

// ==================== 夜间文字（3档淡蓝白，用户指定）====================
export const TC_NIGHT_PRIMARY = "rgba(255,255,255,0.96)";       // 第1档：接近纯白（大温度、湿度值等）
export const TC_NIGHT_ACCENT = "rgba(150,190,255,0.85)";        // 冰蓝（图标、装饰）
export const TC_NIGHT_SECONDARY = "rgba(220,235,255,0.82)";     // 第2档：浅天蓝（天气描述、标签）
export const TC_NIGHT_TERTIARY = "rgba(180,200,240,0.60)";      // 第3档：淡蓝灰（体感、云量、时间戳）
export const TC_NIGHT_MUTED = "rgba(150,175,220,0.40)";         // 最弱（水印类）
export const TC_NIGHT_TEMP = "rgba(255,255,255,0.96)";          // 大温度（同第1档）
export const TC_NIGHT_TEMP_UNIT = "rgba(150,190,255,0.85)";     // 温度单位（冰蓝）
export const TC_NIGHT_HILO = "rgba(220,235,255,0.82)";          // 高低温度（第2档）

// ==================== 图标统一色 ====================
export const iconNight = "rgba(150,190,255,0.85)";               // 柔和冰蓝图标
export const splitLineNight = "rgba(130,160,240,0.22)";         // 分割线

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
export const accentBlueLight = "#80C0FF";
export const accentBlueDark = "#1A4A7A";
