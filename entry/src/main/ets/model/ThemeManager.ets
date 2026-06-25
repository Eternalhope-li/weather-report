// ============================================================
// ThemeManager — 日夜双主题 · 毛玻璃半透卡片 · 7种天气渐变
// 所有卡片色值函数从 theme.ets 导入，保证全局统一
// ============================================================
import {
  cardMain, cardSub, cardAccent, cardSecondary, cardFrost,
  cardBg, cardBgStrong, cardAux, cardShadowColor, cardBorder, cardBorderSub,
  tcPrimary, tcSecondary, tcTertiary, tcMuted, tcTemp, tcTempUnit, tcHiLo,
  accentBlue, accentBlueLight, accentBlueDark,
  TC_DAY_PRIMARY, TC_DAY_SECONDARY, TC_DAY_TERTIARY, TC_DAY_MUTED,
  TC_DAY_TEMP, TC_DAY_TEMP_UNIT, TC_DAY_HILO,
  TC_NIGHT_PRIMARY, TC_NIGHT_SECONDARY, TC_NIGHT_TERTIARY, TC_NIGHT_MUTED,
  TC_NIGHT_TEMP, TC_NIGHT_TEMP_UNIT, TC_NIGHT_HILO
} from "./theme";

export { 
  cardMain, cardSub, cardAccent, cardSecondary, cardFrost,
  cardBg, cardBgStrong, cardAux, cardShadowColor, cardBorder, cardBorderSub,
  tcPrimary, tcSecondary, tcTertiary, tcMuted, tcTemp, tcTempUnit, tcHiLo,
  accentBlue, accentBlueLight, accentBlueDark,
  TC_DAY_PRIMARY, TC_DAY_SECONDARY, TC_DAY_TERTIARY, TC_DAY_MUTED,
  TC_DAY_TEMP, TC_DAY_TEMP_UNIT, TC_DAY_HILO,
  TC_NIGHT_PRIMARY, TC_NIGHT_SECONDARY, TC_NIGHT_TERTIARY, TC_NIGHT_MUTED,
  TC_NIGHT_TEMP, TC_NIGHT_TEMP_UNIT, TC_NIGHT_HILO
};

export enum WeatherType {
  SUNNY = "sunny",
  CLOUDY = "cloudy",
  OVERCAST = "overcast",
  LIGHT_RAIN = "lightRain",
  HEAVY_RAIN = "heavyRain",
  SNOW = "snow",
  FOG = "fog"
}

const WEATHER_KEYWORDS: string[] = [
  "晴", "多云", "阴", "小雨", "中雨", "大雨", "暴雨", "雷阵雨",
  "雨夹雪", "小雪", "中雪", "大雪", "暴雪", "雾", "霾",
  "浮尘", "扬沙", "阵雨", "强阵雨", "强降雨", "零星小雨", "阵雪"
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
  if (wt === WeatherType.SNOW) { return "snow"; }
  if (wt === WeatherType.LIGHT_RAIN || wt === WeatherType.HEAVY_RAIN) { return "rain"; }
  return "none";
}

// ============================================================
//  日间渐变（垂直 上→下）
// ============================================================
export function dayGradient(wt: WeatherType): Array<[ResourceColor, number]> {
  switch (wt) {
    case WeatherType.SUNNY:
      return [["#8AC0F5", 0], ["#A8D4F8", 0.3], ["#C8E4FA", 0.6], ["#E0EFFE", 1]];
    case WeatherType.CLOUDY:
      return [["#B0CFEE", 0], ["#C4DBF2", 0.3], ["#D8E8F6", 0.6], ["#EAF2FC", 1]];
    case WeatherType.OVERCAST:
      return [["#CCDCF2", 0], ["#D4E2F5", 0.4], ["#E0ECF8", 0.7], ["#E6F0FA", 1]];
    case WeatherType.LIGHT_RAIN:
      return [["#9CB4CC", 0], ["#ACC4DA", 0.3], ["#C0D4E6", 0.6], ["#D0DEEE", 1]];
    case WeatherType.HEAVY_RAIN:
      return [["#86A4C1", 0], ["#94B4CE", 0.3], ["#AAC4DC", 0.6], ["#C0D4E8", 1]];
    case WeatherType.SNOW:
      return [["#C2D4E7", 0], ["#D4E2EE", 0.3], ["#E4ECF4", 0.6], ["#EEF4FA", 1]];
    case WeatherType.FOG:
      return [["#D4DCE8", 0], ["#DCE4EC", 0.4], ["#E4ECF2", 0.7], ["#EAF0F6", 1]];
    default:
      return [["#B0CFEE", 0], ["#CCE0F5", 0.5], ["#EAF2FC", 1]];
  }
}

// ============================================================
//  夜间渐变
// ============================================================
export function nightGradient(wt: WeatherType): Array<[ResourceColor, number]> {
  // 真正深色模式：近黑背景，卡片(30-38)在其上清晰浮起
  switch (wt) {
    case WeatherType.SUNNY:
      return [["#0C0E12", 0], ["#0F1218", 0.3], ["#12161E", 0.6], ["#161A24", 1]];
    case WeatherType.CLOUDY:
      return [["#0D0F14", 0], ["#10141A", 0.3], ["#14181E", 0.6], ["#181C26", 1]];
    case WeatherType.OVERCAST:
      return [["#0E1016", 0], ["#12161C", 0.4], ["#161A22", 0.7], ["#1A1E28", 1]];
    case WeatherType.LIGHT_RAIN:
      return [["#0B0D12", 0], ["#0E1218", 0.3], ["#12161C", 0.6], ["#161A22", 1]];
    case WeatherType.HEAVY_RAIN:
      return [["#090B0E", 0], ["#0C1014", 0.3], ["#0F1318", 0.6], ["#13171E", 1]];
    case WeatherType.SNOW:
      return [["#0E1016", 0], ["#12161C", 0.3], ["#161A22", 0.6], ["#1A1E28", 1]];
    case WeatherType.FOG:
      return [["#101218", 0], ["#14181E", 0.4], ["#181C24", 0.7], ["#1C202A", 1]];
    default:
      return [["#0C0E12", 0], ["#10141A", 0.5], ["#181C26", 1]];
  }
}

// ---- 兼容函数别名 ----
export function bgGradient(isNight: boolean, weatherBg: string): Array<[ResourceColor, number]> {
  let wt: WeatherType = getWeatherType(weatherBg);
  if (isNight) { return nightGradient(wt); }
  return dayGradient(wt);
}


