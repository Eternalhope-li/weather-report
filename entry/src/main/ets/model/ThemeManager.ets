// 深色/浅色主题配置 - 深蓝灰高级感主题
export function bgGradient(isDark: boolean, weatherBg: string): Array<[string, number]> {
  if (isDark) {
    switch (weatherBg) {
      case 'night': return [['#0B0E1A', 0], ['#0E1225', 0.4], ['#111630', 0.7], ['#0A0D1A', 1]];
      case 'cloudy': return [['#121E35', 0], ['#162540', 0.4], ['#1A2D48', 0.7], ['#121E35', 1]];
      case 'rain': return [['#0A1425', 0], ['#0E1A30', 0.4], ['#0C1628', 0.7], ['#080E1A', 1]];
      case 'fog': return [['#1A2238', 0], ['#1E263E', 0.4], ['#16202E', 0.7], ['#121A28', 1]];
      default: return [['#0A0D1E', 0], ['#0E1330', 0.3], ['#121A40', 0.6], ['#182250', 1]];
    }
  }
  // 浅色模式 - 柔和浅蓝渐变
  switch (weatherBg) {
    case 'night': return [['#0B0E2A', 0], ['#14183F', 0.5], ['#0A0D1E', 1]];
    case 'cloudy': return [['#B0C8E8', 0], ['#C8D8F0', 0.4], ['#D8E4F5', 0.7], ['#E8EFF8', 1]];
    case 'rain': return [['#8AA8C8', 0], ['#98B8D5', 0.5], ['#808EA0', 1]];
    case 'fog': return [['#C8D0DC', 0], ['#D0D8E4', 0.5], ['#B8C0CC', 1]];
    default: return [['#4A80D0', 0], ['#5C90D8', 0.2], ['#78A8E8', 0.5], ['#A0C4F0', 0.8], ['#C0D8F5', 1]];
  }
}

export function cardBg(isDark: boolean): string {
  return isDark ? 'rgba(255,255,255,0.05)' : 'rgba(255,255,255,0.12)';
}

export function cardBgStrong(isDark: boolean): string {
  return isDark ? 'rgba(255,255,255,0.08)' : 'rgba(255,255,255,0.18)';
}

// 卡片磨砂半透背景（用于主要信息卡片）
export function cardFrost(isDark: boolean): string {
  return isDark ? 'rgba(255,255,255,0.04)' : 'rgba(255,255,255,0.15)';
}

// 强调色 - 温度数字/高亮文字用浅蓝渐变
export const accentBlue: string = '#7BA4FD';
export const accentBlueLight: string = '#A0C4FF';
export const accentBlueDark: string = '#5A84D8';

// 文字色阶（深色模式）
export const textPrimary: string = 'rgba(255,255,255,0.92)';
export const textSecondary: string = 'rgba(255,255,255,0.55)';
export const textTertiary: string = 'rgba(255,255,255,0.32)';
export const textMuted: string = 'rgba(255,255,255,0.18)';

// 浅色模式文字
export const textPrimaryLight: string = 'rgba(0,0,0,0.87)';
export const textSecondaryLight: string = 'rgba(0,0,0,0.50)';
export const textTertiaryLight: string = 'rgba(0,0,0,0.30)';
