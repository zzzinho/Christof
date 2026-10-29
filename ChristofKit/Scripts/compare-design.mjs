// 시안의 그리기 JS 로 ChristofSnapshots 가 쓴 장면을 다시 그려, Swift 격자(.grid)와 칸 단위로 비교한다.
// 시안 옆 design.css 의 --lofi-* 색과 LofiPalette.swift 도 견준다. 시안 위치는 디자인 세션이 넘길 때 알려 주므로 인자로 받는다.
// node ChristofKit/Scripts/compare-design.mjs <스냅샷 폴더> <시안 html>
import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';

const [dir, html] = process.argv.slice(2);
if (!dir || !html) throw new Error('스냅샷 폴더와 시안 html 경로를 주세요');
const css = fs.readFileSync(path.join(path.dirname(html), 'design.css'), 'utf8');

const designColors = Object.fromEntries([...css.matchAll(/--lofi-([a-z0-9-]+):\s*#([0-9A-Fa-f]{6})/g)].map(([, k, v]) => [k, v.toUpperCase()]));
const swiftPalette = fs.readFileSync(path.join(import.meta.dirname, '../Sources/ChristofKit/Rendering/LofiPalette.swift'), 'utf8');
const swiftColors = Object.fromEntries([...swiftPalette.matchAll(/"([a-z0-9-]+)":\s*0x([0-9A-Fa-f]{6})/g)].map(([, k, v]) => [k, v.toUpperCase()]));
const paletteDiffs = [...new Set([...Object.keys(designColors), ...Object.keys(swiftColors)])]
  .filter(k => designColors[k] !== swiftColors[k])
  .map(k => `${k} 시안 ${designColors[k] ?? '없음'} Swift ${swiftColors[k] ?? '없음'}`);
if (!Object.keys(designColors).length) paletteDiffs.push('design.css 에 --lofi-* 색이 없다');
console.log(paletteDiffs.length ? `✗ 팔레트 ${paletteDiffs.length}개 다름\n    ${paletteDiffs.join('\n    ')}` : `✓ 팔레트 ${Object.keys(designColors).length}색`);
const tokens = Object.fromEntries([...css.matchAll(/(--[\w-]+):\s*([^;]+);/g)].map(([, k, v]) => [k, v.trim()]));
const script = fs.readFileSync(html, 'utf8').match(/<script>([\s\S]*)<\/script>/)[1];

// 페이지 DOM 은 그리기와 관계없어서 무엇이든 받아 주는 빈 객체로 둔다.
const dom = new Proxy(function () {}, { get: (t, k) => (k === Symbol.toPrimitive ? () => '' : dom), apply: () => dom, set: () => true });
const context = vm.createContext({ document: dom, getComputedStyle: () => ({ getPropertyValue: name => tokens[name] ?? '' }) });
const page = vm.runInContext(`${script}\n;({ render, SIZES, HEADWEAR, CAT_STATES, OUTFITS })`, context);

const scenes = JSON.parse(fs.readFileSync(path.join(dir, 'scenes.json'), 'utf8'));
const files = { small: 'small', medium: 'medium', large: 'large' };
let failed = 0;
for (const scene of scenes) {
  const results = Object.entries(files).map(([size, suffix]) => {
    const { g, s } = page.render(scene, page.SIZES[size]);
    const swift = fs.readFileSync(path.join(dir, `${scene.title}-${suffix}.grid`), 'utf8').trim().split('\n').map(row => row.split(' '));
    const diffs = [];
    if (swift.length !== g.rows || swift[0].length !== g.cols) return { size, s, diffs: [`격자 크기 ${swift[0].length}×${swift.length}, 시안 ${g.cols}×${g.rows}`] };
    g.cells.forEach((c, n) => {
      const x = n % g.cols, y = Math.floor(n / g.cols), mine = swift[y][x];
      if ((c ?? '#------').slice(1).toUpperCase() !== mine) diffs.push(`(${x},${y}) 시안 ${c} Swift #${mine}`);
    });
    return { size, s, diffs };
  });
  const { s } = results[0];
  const look = `${page.HEADWEAR[s.headwear]} · ${page.CAT_STATES[s.catState]} · ${page.OUTFITS[s.outfit].name}`;
  const bad = results.filter(r => r.diffs.length);
  failed += bad.length;
  console.log(`${bad.length ? '✗' : '✓'} ${scene.title} (${look})${bad.map(r => `\n    ${r.size}: ${r.diffs.length}칸 다름 ${r.diffs.slice(0, 4).join(', ')}`).join('')}`);
}
console.log(failed ? `${failed}개 격자가 시안과 다르다` : `${scenes.length * 3}개 격자가 모두 시안과 같다`);
process.exit(failed || paletteDiffs.length ? 1 : 0);
