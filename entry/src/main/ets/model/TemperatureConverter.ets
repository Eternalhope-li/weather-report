export function celsiusToFahrenheit(celsius: number): number {
  return celsius * 1.8 + 32;
}

export function fahrenheitToCelsius(fahrenheit: number): number {
  return (fahrenheit - 32) / 1.8;
}

export function convertTempStr(value: string, toUnit: string): string {
  let num: number = Number(value);
  if (isNaN(num)) {
    return value;
  }
  if (toUnit === 'F') {
    return String(Math.round(celsiusToFahrenheit(num)));
  }
  return String(Math.round(num));
}

export function tempUnitLabel(unit: string): string {
  return unit === 'F' ? '\u2109' : '\u2103';
}


export function cleanCityName(name: string): string {
  let result: string = name.trim();
  let len: number = result.length;
  if (len <= 1) { return result; }
  let lastChar: string = result.charAt(len - 1);
  // "市"=市, "县"=县, "区"=区, "镇"=镇, "乡"=乡, "省"=省
  if (lastChar === '市' || lastChar === '县' || lastChar === '区' || lastChar === '镇' || lastChar === '乡' || lastChar === '省') {
    return result.substring(0, len - 1);
  }
  // "街道"=街道 (2 characters)
  if (len >= 2 && result.substring(len - 2) === '街道') {
    return result.substring(0, len - 2);
  }
  return result;
}
