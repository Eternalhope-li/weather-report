import os, re

path = 'D:/harmonycode/MyAppDemo2/entry/src/main/ets/service/WeatherService.ets'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace all Record<string, Object> with object
content = content.replace('Record<string, Object>', 'object')

# Replace bracket notation on known variables with temporary markers
# We need to transform: json['xxx'] -> JsonHelper.getStr/Obj(jsonStr, 'xxx')
# But the variable names differ... Let me use a simpler approach

# Direct replacements for all known patterns
pairs = [
    ("json['error_code']", "error_code"),
    ("json['reason']", "reason"),
    ("json['result']", "result_obj"),
]

# Actually the simplest approach: replace all bracket accesses with function calls
# We'll transform any pattern: varName['key'] -> JsonHelper.getXX(varNameStr, 'key')
# where getXX is determined by context

# For now, let's just do a direct approach: find and replace all occurrences

# Mark: replace obj['key'] -> getValue(obj, 'key')
# We'll use a simple regex-like approach
import re

# Pattern: word['word'] -> replacement
# We'll find all and replace each
pattern = re.compile(r"([a-zA-Z_]\w*)\['([a-zA-Z_]+)'\]")

def replace_match(m):
    var = m.group(1)
    key = m.group(2)
    # Use JsonHelper based on key or context
    if key in ('error_code', 'reason', 'temperature', 'humidity', 'direct', 'power', 'info', 'aqi', 'wid', 'city', 'date', 'weather', 'day', 'temperature'):
        return f"JsonHelper.getStr({var}, '{key}', '--')"
    elif key in ('result', 'realtime', 'wid', 'address'):
        return f"JsonHelper.getObj({var}, '{key}')"
    elif key == 'future':
        return f"JsonHelper.getArr({var}, 'future')"
    else:
        return f"JsonHelper.getStr({var}, '{key}', '')"

content = pattern.sub(replace_match, content)
print('Bracket notation replaced')

# Add JsonHelper class if not present
helper_code = '''
class JsonHelper {
  static getStr(jsonStr: string, key: string, fallback: string): string {
    let search: string = '"' + key + '":"';
    let idx: number = jsonStr.indexOf(search);
    if (idx >= 0) {
      let start: number = idx + search.length;
      let end: number = jsonStr.indexOf('"', start);
      if (end > start) { return jsonStr.substring(start, end); }
    }
    search = '"' + key + '":';
    idx = jsonStr.indexOf(search);
    if (idx >= 0) {
      let start: number = idx + search.length;
      let end: number = start;
      while (end < jsonStr.length && jsonStr[end] !== ',' && jsonStr[end] !== '}' && jsonStr[end] !== ']') { end++; }
      if (end > start) { return jsonStr.substring(start, end).trim(); }
    }
    return fallback;
  }

  static getObj(jsonStr: string, key: string): string {
    let search: string = '"' + key + '":{';
    let idx: number = jsonStr.indexOf(search);
    if (idx >= 0) {
      let start: number = idx + search.length - 1;
      let depth: number = 1;
      let end: number = start + 1;
      while (end < jsonStr.length && depth > 0) {
        if (jsonStr[end] === '{') { depth++; }
        else if (jsonStr[end] === '}') { depth--; }
        end++;
      }
      if (depth === 0) { return jsonStr.substring(start, end); }
    }
    return '{}';
  }

  static getArr(jsonStr: string, key: string): string[] {
    let search: string = '"' + key + '":[';
    let idx: number = jsonStr.indexOf(search);
    if (idx >= 0) {
      let start: number = idx + search.length - 1;
      let depth: number = 1;
      let end: number = start + 1;
      while (end < jsonStr.length && depth > 0) {
        if (jsonStr[end] === '[') { depth++; }
        else if (jsonStr[end] === ']') { depth--; }
        end++;
      }
      if (depth === 0) {
        let inner: string = jsonStr.substring(start + 1, end - 1);
        let items: string[] = [];
        let d: number = 0;
        let si: number = 0;
        for (let ci: number = 0; ci < inner.length; ci++) {
          if (inner[ci] === '{') { d++; }
          else if (inner[ci] === '}') { d--; }
          else if (inner[ci] === ',' && d === 0) {
            items.push(inner.substring(si, ci));
            si = ci + 1;
          }
        }
        if (si < inner.length - 1) {
          let last: string = inner.substring(si).trim();
          if (last.length > 0) { items.push(last); }
        }
        return items;
      }
    }
    return [];
  }
}
'''

if 'class JsonHelper' not in content:
    pos = content.find('const JUHE_URL')
    if pos < 0:
        pos = content.find('interface TempRange')
    content = content[:pos] + '\\n' + helper_code + '\\n' + content[pos:]
    print('Helper inserted')

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
print('Done!')
