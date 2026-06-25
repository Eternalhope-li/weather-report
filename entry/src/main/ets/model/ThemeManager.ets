// ============================================================
// ThemeManager — 日夜双主题 · 毛玻璃半透卡片 · 7种天气渐变
// ============================================================

export enum WeatherType {
  SUNNY = 'sunny',
  CLOUDY = 'cloudy',
  OVERCAST = 'overcast',
  LIGHT_RAIN = 'lightRain',
  HEAVY_RAIN = 'heavyRain',
  SNOW = 'snow',
  FOG = 'fog'
}

const WEATHER_KEYWORDS: string[] = [
  '晴', '多云', '阴', '小雨', '中雨', '大雨', '暴雨', '雷阵雨',
  '雨夹雪', '小雪', '中雪', '大雪', '暴雪', '雾', '霾',
  '浮尘', '扬沙', '阵雨', '强阵雨', '强降雨', '零星小雨', '阵雪'
];
const WEATHER_VALUES: WeatherType[] = [
  WeatherType.SUNNY, WeatherType.CLOUDY, WeatherType.OVERCAST,
  WeatherType.LIGHT_RAIN, WeatherType.HEAVY_RAIN, WeatherType.HEAVY_RAIN, WeatherType.HEAVY_RAIN, WeatherType.LIGHT_RAIN,
  WeatherType.SNOW, WeatherType.SNOW, WeatherType.SNOW, WeatherType.SNOW, WeatherType.SNOW,
  WeatherType.FOG, WeatherType.FOG, WeatherType.FOG, WeatherType.FOG,
  WeatherType.LIGHT_RAIN, WeatherType.HEAVY_RAIN, WeatherType.HEAVY_RAIN, WeatherType.LIGHT_RAIN, WeatherType.SNOW
];

export function getWeatherType(desc: string): WeatherType {
  if (desc.length === 0) { return WeatherType.CLOUDY; }
  for (let i: number = 0; i < WEATHER_KEYWORDS.length; i++) {
    if (desc.indexOf(WEATHER_KEYWORDS[i]) >= 0) { return WEATHER_VALUES[i]; }
  }
  return WeatherType.CLOUDY;
}

export function needsParticles(wt: WeatherType): boolean {
  return wt === WeatherType.LIGHT_RAIN || wt === WeatherType.HEAVY_RAIN || wt === WeatherType.SNOW;
}

export function particleType(wt: WeatherType): string {
  if (wt === WeatherType.SNOW) { return 'snow'; }
  if (wt === WeatherType.LIGHT_RAIN || wt === WeatherType.HEAVY_RAIN) { return 'rain'; }
  return 'none';
}

// ============================================================
//  日间渐变（垂直 上→下）
// ============================================================
export function dayGradient(wt: WeatherType): Array<[ResourceColor, number]> {
  switch (wt) {
    case WeatherType.SUNNY:
      return [['#94C8F8', 0], ['#B0D8FA', 0.3], ['#D0E8FC', 0.6], ['#E6F2FF', 1]];
    case WeatherType.CLOUDY:
      return [['#B6D3F2', 0], ['#C8DFF5', 0.3], ['#DCEBF8', 0.6], ['#EDF5FF', 1]];
    case WeatherType.OVERCAST:
      return [['#D0E0F5', 0], ['#D8E6F8', 0.4], ['#E2EEFA', 0.7], ['#E8F2FC', 1]];
    case WeatherType.LIGHT_RAIN:
      return [['#A0B8D0', 0], ['#B0C8DE', 0.3], ['#C4D8EA', 0.6], ['#D4E1F0', 1]];
    case WeatherType.HEAVY_RAIN:
      return [['#8AA8C5', 0], ['#98B8D2', 0.3], ['#AEC8E0', 0.6], ['#C4D8EC', 1]];
    case WeatherType.SNOW:
      return [['#C6D8EB', 0], ['#D8E6F2', 0.3], ['#E8F0F8', 0.6], ['#F2F7FD', 1]];
    case WeatherType.FOG:
      return [['#D8E0EC', 0], ['#E0E8F0', 0.4], ['#E8F0F5', 0.7], ['#EEF4FA', 1]];
    default:
      return [['#B6D3F2', 0], ['#D0E4F8', 0.5], ['#EDF5FF', 1]];
  }
}

// ============================================================
//  夜间渐变
// ============================================================
export function nightGradient(wt: WeatherType): Array<[ResourceColor, number]> {
  switch (wt) {
    case WeatherType.SUNNY:
      return [['#0A1429', 0], ['#0E1A33', 0.3], ['#132240', 0.6], ['#1A2C47', 1]];
    case WeatherType.CLOUDY:
      return [['#0F1A30', 0], ['#14223B', 0.3], ['#182A45', 0.6], ['#20334E', 1]];
    case WeatherType.OVERCAST:
      return [['#131E33', 0], ['#17263D', 0.4], ['#1C2E47', 0.7], ['#24364F', 1]];
    case WeatherType.LIGHT_RAIN:
      return [['#0B1526', 0], ['#101C30', 0.3], ['#15243B', 0.6], ['#1C2D45', 1]];
    case WeatherType.HEAVY_RAIN:
      return [['#08101E', 0], ['#0C1628', 0.3], ['#111E35', 0.6], ['#182840', 1]];
    case WeatherType.SNOW:
      return [['#0E192E', 0], ['#132038', 0.3], ['#182842', 0.6], ['#1F304A', 1]];
    case WeatherType.FOG:
      return [['#162036', 0], ['#1A283E', 0.4], ['#1E3046', 0.7], ['#24384D', 1]];
    default:
      return [['#0F1A30', 0], ['#14223B', 0.5], ['#20334E', 1]];
  }
}

// ============================================================
//  毛玻璃半透卡片色阶（全新）
//  主卡 blur 24vp  小卡 blur 18vp
// ============================================================
/** 主温度大卡片背景 */
export function cardMain(isNight: boolean): string {
  return isNight ? 'rgba(30,42,60,0.3)' : 'rgba(255,255,255,0.22)';
}
/** 次要卡片（湿度/风力/逐小时格子） */
export function cardSecondary(isNight: boolean): string {
  return isNight ? 'rgba(30,42,60,0.22)' : 'rgba(255,255,255,0.16)';
}
/** 强调/选中状态卡片 */
export function cardAccent(isNight: boolean): string {
  return isNight ? 'rgba(30,42,60,0.35)' : 'rgba(255,255,255,0.25)';
}
/** 卡片细边框色 */
export function cardBorder(isNight: boolean): string {
  return isNight ? 'rgba(255,255,255,0.12)' : 'rgba(255,255,255,0.3)';
}
/** 次卡细边框 */
export function cardBorderSub(isNight: boolean): string {
  return isNight ? 'rgba(255,255,255,0.08)' : 'rgba(255,255,255,0.25)';
}
/** 卡片阴影 */
export function cardShadowColor(isNight: boolean): string {
  return isNight ? 'rgba(0,0,0,0)' : 'rgba(100,140,190,0.15)';
}

// ============================================================
//  文字色阶（适配半透明玻璃，保证对比度）
// ============================================================
// 日间
export const TC_DAY_PRIMARY: string = '#1A304B';
export const TC_DAY_SECONDARY: string = '#4A6482';
export const TC_DAY_TERTIARY: string = '#4A6482';
export const TC_DAY_MUTED: string = '#6E87A0';
export const TC_DAY_TEMP: string = '#0F243D';
export const TC_DAY_TEMP_UNIT: string = '#3B78C2';
export const TC_DAY_HILO: string = '#4A6482';

// 夜间
export const TC_NIGHT_PRIMARY: string = '#F0F6FF';
export const TC_NIGHT_SECONDARY: string = '#B0C4DC';
export const TC_NIGHT_TERTIARY: string = '#A1B4CD';
export const TC_NIGHT_MUTED: string = '#7A94B0';
export const TC_NIGHT_TEMP: string = '#F0F6FF';
export const TC_NIGHT_TEMP_UNIT: string = '#73A9E8';
export const TC_NIGHT_HILO: string = '#A1B4CD';

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

// ---- 兼容旧版函数别名 ----
export function bgGradient(isNight: boolean, weatherBg: string): Array<[ResourceColor, number]> {
  let wt: WeatherType = getWeatherType(weatherBg);
  if (isNight) { return nightGradient(wt); }
  return dayGradient(wt);
}
export function cardBg(isNight: boolean): string { return cardMain(isNight); }
export function cardBgStrong(isNight: boolean): string { return cardAccent(isNight); }
export function cardFrost(isNight: boolean): string { return cardSecondary(isNight); }
export function cardShadow(isNight: boolean): string { return cardShadowColor(isNight); }

export const lightBgBase: string = '#E6F2FF';
export const lightCardMain: string = 'rgba(255,255,255,0.22)';
export const lightCardSecondary: string = 'rgba(255,255,255,0.16)';
export const lightCardStrong: string = 'rgba(255,255,255,0.25)';
export const accentBlue: string = '#3B78C2';
export const accentBlueLight: string = '#73A9E8';
export const accentBlueDark: string = '#2D5B96';
export const textPrimaryDark: string = TC_NIGHT_PRIMARY;
export const textSecondaryDark: string = TC_NIGHT_SECONDARY;
export const textTertiaryDark: string = TC_NIGHT_TERTIARY;
export const textPrimaryLight: string = TC_DAY_PRIMARY;
export const textSecondaryLight: string = TC_DAY_SECONDARY;
export const textTertiaryLight: string = TC_DAY_TERTIARY;
export const textMutedLight: string = TC_DAY_MUTED;
export const tempNumLight: string = TC_DAY_TEMP;
export const tempUnitLight: string = TC_DAY_TEMP_UNIT;
export const tempHiLoLight: string = TC_DAY_HILO;
