// 07-composition-*.html 이 함께 쓰는 그리기 코드. 파일마다 script 태그의 data-composition 만 다르다.
// ponytail: 06-lofi.html 그리기 코드에서 크리스마스 모양만 남겨 복사했다. 구도를 고르면 06 에 옮기고 이 파일과 07 비교안은 지운다.

const DOT = 3;
const COMPOSITION = document.currentScript.dataset.composition;

// 06-lofi 의 크리스마스 장면 둘. 둘 다 방 불을 켠 때(night, grey)라 불 끈 색은 두지 않았다.
const SCENES = [
  { title: '크리스마스 이브 밤', region: '서울', date: '12월 24일', time: '오후 9:00', hour: 21, season: 'winter', sun: [-43, 272], moon: [0.52, 39, 84], weather: ['clear', 0, 0.1, -5], occasions: ['KR.christmasEve', 'sky.fullMoon'] },
  { title: '눈 오는 크리스마스', region: '서울', date: '12월 25일', time: '오전 10:00', hour: 10, season: 'winter', sun: [19, 143], moon: [0.54, -10, 313], weather: ['snow', 0.6, 0.9, -2], occasions: ['KR.christmas'] },
];
const OCCASION_NAMES = { 'KR.christmasEve': '크리스마스 이브', 'KR.christmas': '크리스마스', 'sky.fullMoon': '보름달' };

const SIZES = { small: [170, 170], medium: [364, 170], large: [364, 382] };

const rootStyle = getComputedStyle(document.documentElement);
const colorCache = {};
function color(name) {
  if (colorCache[name]) return colorCache[name];
  const value = rootStyle.getPropertyValue('--lofi-' + name).trim();
  if (!/^#[0-9a-f]{6}$/i.test(value)) throw new Error(`design.css 에 --lofi-${name} (#RRGGBB) 이 없다`);
  return (colorCache[name] = value);
}
const pc = (s, name) => color(`${s.phase}-${name}`);

// 시드 고정 난수 (Swift SeededRandom 과 같은 수열)
const MASK64 = (1n << 64n) - 1n;
class Rand {
  constructor(seed) { this.state = BigInt(seed); }
  next() {
    this.state = (this.state + 0x9E3779B97F4A7C15n) & MASK64;
    let z = this.state;
    z = ((z ^ (z >> 30n)) * 0xBF58476D1CE4E5B9n) & MASK64;
    z = ((z ^ (z >> 27n)) * 0x94D049BB133111EBn) & MASK64;
    return z ^ (z >> 31n);
  }
  below(bound) {
    let m = this.next() * bound;
    if ((m & MASK64) < bound) {
      const t = ((1n << 64n) - bound) % bound;
      while ((m & MASK64) < t) m = this.next() * bound;
    }
    return m >> 64n;
  }
  range(lower, upper) {
    const max = 1n << 53n;
    const r = this.below(max + 1n);
    if (r === max) return upper;
    return (upper - lower) * (Number(r) * (Number.EPSILON / 2)) + lower;
  }
  int(lower, upper) { return Math.floor(this.range(lower, upper + 0.999)); }
}

const BAYER = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]];
const bayer = (x, y) => (BAYER[((y % 4) + 4) % 4][((x % 4) + 4) % 4] + 0.5) / 16;
const clamp = (v, lo, hi) => Math.min(hi, Math.max(lo, v));
const pt = v => v / DOT;
const blend = (a, b, f, x, y) => (clamp((f - 0.5) / 0.3 + 0.5, 0, 1) > bayer(x, y) ? b : a);

class Grid {
  constructor(cols, rows) {
    this.cols = cols;
    this.rows = rows;
    this.cells = new Array(cols * rows).fill(null);
    this.ox = 0;
    this.oy = 0;
    this.bounds = [0, 0, cols, rows];
  }
  set(x, y, c) {
    if (!c) return;
    const ax = Math.floor(x) + this.ox, ay = Math.floor(y) + this.oy;
    const [x0, y0, x1, y1] = this.bounds;
    if (ax < x0 || ay < y0 || ax >= x1 || ay >= y1) return;
    this.cells[ay * this.cols + ax] = c;
  }
  within(x, y, w, h, draw) {
    const saved = [this.ox, this.oy, this.bounds];
    const [x0, y0, x1, y1] = this.bounds;
    this.ox += x;
    this.oy += y;
    this.bounds = [Math.max(x0, this.ox), Math.max(y0, this.oy), Math.min(x1, this.ox + w), Math.min(y1, this.oy + h)];
    draw();
    [this.ox, this.oy, this.bounds] = saved;
  }
  rect(x, y, w, h, c) {
    for (let j = Math.round(y); j < Math.round(y + h); j++) for (let i = Math.round(x); i < Math.round(x + w); i++) this.set(i, j, c);
  }
  shape(x0, y0, x1, y1, inside, c) {
    for (let y = Math.floor(y0); y <= Math.ceil(y1); y++) {
      for (let x = Math.floor(x0); x <= Math.ceil(x1); x++) {
        if (inside(x + 0.5, y + 0.5)) this.set(x, y, typeof c === 'function' ? c(x, y) : c);
      }
    }
  }
  sprite(x, bottom, rows, map) {
    const left = Math.round(x - rows[0].length / 2), top = bottom - rows.length;
    rows.forEach((row, j) => [...row].forEach((ch, i) => { if (map[ch]) this.set(left + i, top + j, color(map[ch])); }));
  }
  canvas() {
    const canvas = document.createElement('canvas');
    canvas.width = this.cols;
    canvas.height = this.rows;
    const ctx = canvas.getContext('2d');
    this.cells.forEach((c, i) => {
      if (!c) return;
      ctx.fillStyle = c;
      ctx.fillRect(i % this.cols, Math.floor(i / this.cols), 1, 1);
    });
    return canvas;
  }
}

function disc(g, cx, cy, r, c) {
  g.shape(cx - r, cy - r, cx + r, cy + r, (x, y) => Math.hypot(x - cx, y - cy) <= r, c);
}

function ring(g, cx, cy, r, thickness, c) {
  const dist = (x, y) => Math.hypot(x - cx, y - cy);
  g.shape(cx - r - thickness, cy - r - thickness, cx + r + thickness, cy + r + thickness,
    (x, y) => dist(x, y) > r && dist(x, y) <= r + thickness,
    (x, y) => ((1 - (dist(x + 0.5, y + 0.5) - r) / (thickness + 0.5)) * 0.75 > bayer(x, y) ? c : null));
}

// ---- 장면 값 ----

const CLOUD_DECK = new Set(['overcast', 'drizzle', 'rain', 'snow', 'thunderstorm']);
const STARS = new Set(['clear', 'partlyCloudy']);

function celestialPoint(altitude, azimuth) {
  if (altitude <= -2) return null;
  const d = ((azimuth % 360) + 360) % 360 - 180;
  const base = 0.72 - 0.035;
  return [clamp(0.5 + d / 135 * 0.45, 0.05, 0.95), base - Math.pow(clamp(altitude, 0, 75) / 75, 0.75) * (base - 0.1)];
}

function sceneContext(scene) {
  const weather = { condition: scene.weather[0], intensity: scene.weather[1], cloudCover: scene.weather[2], temperature: scene.weather[3] };
  const [sunAltitude, sunAzimuth] = scene.sun;
  const gloomy = CLOUD_DECK.has(weather.condition) || weather.condition === 'fog';
  const phase = sunAltitude < -6 ? 'night' : gloomy ? 'grey' : sunAltitude < 6 ? 'dusk' : 'day';
  return {
    ...scene,
    weather,
    phase,
    minute: Number(scene.time.split(':')[1]),
    snowing: weather.condition === 'snow',
    sunPoint: gloomy ? null : celestialPoint(sunAltitude, sunAzimuth),
    moonPoint: gloomy || sunAltitude >= 0 ? null : celestialPoint(scene.moon[1], scene.moon[2]),
    snowCovered: weather.condition === 'snow' || weather.temperature <= 0,
  };
}

// ---- 창밖 (06-lofi 와 같다) ----

function drawView(g, w, h, s) {
  const bands = [1, 2, 3, 4].map(i => pc(s, `sky-${i}`));
  for (let y = 0; y < h; y++) {
    const t = clamp((y + 0.5) / (h * 0.8), 0, 1) * (bands.length - 1);
    const i = Math.min(bands.length - 2, Math.floor(t));
    for (let x = 0; x < w; x++) g.set(x, y, blend(bands[i], bands[i + 1], t - i, x, y));
  }
  if (s.phase === 'night' && STARS.has(s.weather.condition)) drawStars(g, w, h);
  drawClouds(g, w, h, s);
  if (s.sunPoint) drawSun(g, w, h, s);
  if (s.moonPoint) drawMoon(g, w, h, s);
  drawCity(g, w, h, s);
  drawStreetTrees(g, w, h, s);
}

// 유리 안: 창밖, 눈, 성에(크리스마스 창문 모양)
function drawGlass(g, w, h, s) {
  drawView(g, w, h, s);
  if (s.snowing) drawSnow(g, w, h, s);
  drawFrost(g, w, h);
}

function drawStars(g, w, h) {
  const stars = new Rand(3);
  const count = Math.round(w * h * DOT * DOT * 0.001);
  for (let i = 0; i < count; i++) {
    g.set(Math.floor(stars.range(0, 1) * w), Math.floor(stars.range(0, 0.55) * h), color(stars.range(0, 1) < 0.3 ? 'star' : 'star-dim'));
  }
}

const bodyCircle = (point, w, h, radius) => [Math.floor(point[0] * w) + 0.5, Math.floor(point[1] * h) + 0.5, pt(radius) + 0.3];

function drawSun(g, w, h, s) {
  const [cx, cy, r] = bodyCircle(s.sunPoint, w, h, 9);
  ring(g, cx, cy, r, 2, pc(s, 'sky-4'));
  disc(g, cx, cy, r, color(s.sun[0] < 10 ? 'sun-low' : 'sun-high'));
}

function drawMoon(g, w, h, s) {
  const [cx, cy, r] = bodyCircle(s.moonPoint, w, h, 10);
  ring(g, cx, cy, r, 2, color('halo'));
  const phase = s.moon[0], k = Math.cos(phase * 2 * Math.PI);
  disc(g, cx, cy, r, (x, y) => {
    const dy = y + 0.5 - cy, half = Math.sqrt(Math.max(0, r * r - dy * dy));
    const u = half ? (x + 0.5 - cx) / half : 0;
    return color((phase < 0.5 ? u >= k : u <= -k) ? 'moon' : 'halo');
  });
}

function drawClouds(g, w, h, s) {
  const light = pc(s, 'cloud'), dark = pc(s, 'cloud-dark');
  if (CLOUD_DECK.has(s.weather.condition)) {
    const depth = h * 0.55;
    for (let y = 0; y < depth; y++) {
      const t = y / depth;
      for (let x = 0; x < w; x++) if ((1 - t) * 1.5 > bayer(x, y)) g.set(x, y, t < 0.5 ? light : dark);
    }
  }
  const random = new Rand(5);
  const count = Math.round(s.weather.cloudCover * 5);
  for (let i = 0; i < count; i++) {
    const cx = random.range(-0.05, 1.05) * w, cy = random.range(0.1, 0.4) * h, size = random.range(3, 5);
    const puffs = [[-size, 0, size * 0.7], [0, -size * 0.4, size], [size, 0, size * 0.75]];
    g.shape(cx - size * 2, cy - size * 1.5, cx + size * 2, cy + size,
      (x, y) => y <= cy + size * 0.5 && puffs.some(([dx, dy, r]) => Math.hypot(x - cx - dx, y - cy - dy) <= r),
      (x, y) => (y + 0.5 > cy + size * 0.1 ? dark : light));
  }
}

function drawCity(g, w, h, s) {
  const city = new Rand(7);
  const lit = s.phase === 'day' ? 0 : s.phase === 'grey' ? 0.4 : 1;
  for (const [layer, bottomF, minH, maxH, density] of [['city-far', 0.86, 14, 30, 0.12], ['city', 0.95, 8, 20, 0.25]]) {
    let x = city.range(-3, 0);
    while (x < w) {
      const bw = city.int(Math.round(pt(14)), Math.round(pt(30)));
      const bh = Math.round(pt(city.range(minH, maxH)) + h * 0.08);
      const bottom = Math.round(h * bottomF), top = bottom - bh;
      g.rect(x, top, bw, h - top, pc(s, layer));
      if (layer === 'city' && s.snowCovered) g.rect(x, top, bw, 1, pc(s, 'snow'));
      for (let wy = top + 2; wy < h; wy += 2) {
        for (let wx = Math.round(x) + 1; wx < x + bw - 1; wx += 2) if (city.range(0, 1) < density * lit) g.set(wx, wy, color('window-lit'));
      }
      x += bw + city.int(0, 2);
    }
  }
}

// 겨울 가로수: 잎 없는 가지. 해가 진 뒤에는 실루엣이다.
function drawStreetTrees(g, w, h, s) {
  const random = new Rand(13);
  const bark = s.phase === 'night' || s.phase === 'dusk' ? pc(s, 'city') : color('branch');
  for (let x = random.range(1, 4); x < w + 4;) {
    const r = random.range(3, 4.6), cx = Math.round(x), top = h - random.int(7, 10);
    g.rect(cx, top, 1, h - top, bark);
    for (let k = 1; k <= 3; k++) {
      g.set(cx - k, top + 3 - k, bark);
      g.set(cx + k, top + 4 - k, bark);
    }
    g.rect(cx, top - 3, 1, 3, bark);
    x += r * 2 + random.range(1, 4);
  }
}

function drawSnow(g, w, h, s) {
  const count = Math.round(w * h * 0.02 * (0.5 + s.weather.intensity)), random = new Rand(23);
  for (let i = 0; i < count; i++) g.set(Math.floor(random.range(0, w)), Math.floor(random.range(0, h)), pc(s, 'snow'));
}

// 크리스마스 창문 모양: 유리 모서리와 아래쪽에 낀 성에
function drawFrost(g, w, h) {
  for (let y = 0; y < h; y++) {
    for (let x = 0; x < w; x++) {
      const corner = Math.min(Math.hypot(x, y), Math.hypot(w - 1 - x, y), Math.hypot(x, h - 1 - y), Math.hypot(w - 1 - x, h - 1 - y));
      if (Math.max(1 - corner / 7, 1 - (h - 1 - y) / 3) * 0.85 > bayer(x, y)) g.set(x, y, color('frost'));
    }
  }
}

// ---- 스프라이트. 불빛(트리)이 오른쪽에 있어 오른쪽 가장자리에 테두리 빛이 진다 ----

// 옆모습 머리(왼쪽을 본다). 책상 자세와 창가 자세가 함께 쓴다.
const SIDE_HEAD = [
  '.........hh...',
  '........hhhh..',
  '.....hhhhhhH..',
  '...hhhhhkhhhH.',
  '..hhhhhhkhhhH.',
  '..hhssskkkhhH.',
  '..sessskKkhhH.',
  '.sssssskKkhhH.',
  '..ssssskkkhH..',
  '..sssssshhH...',
  '....ssss......',
  '.....sss......',
  '.....sss......',
];

// rows: 사람, hat: 산타 모자(사람과 폭이 같다), hatBottom: 모자 아랫줄이 닿는 사람 줄
const PEOPLE = {
  back: {
    rows: [
      '......hhh.......',
      '.....hhhhh......',
      '......hhhH......',
      '....kkkkkkkk....',
      '...khhhhhhhhk...',
      '..khhhhhhhhhHk..',
      '..khhhhhhhhhHk..',
      '.KKhhhhhhhhhHKK.',
      '.KKhhhhhhhhhHKK.',
      '.KKhhhhhhhhhHKK.',
      '...hhhhhhhhhH...',
      '....hhhhhhhH....',
      '.....hhhhhh.....',
      '......sssS......',
      '...dddddddddd...',
      '.ooddddddddddoo.',
      'ooooddddddddooor',
      'oooooddddddoooor',
      'ooooooddddooooor',
      'oooooooooooooorr',
      'oooooodooooooorr',
      'oooooodooooooorr',
      'oooooodooooooorr',
      'oooooodooooooorr',
      'oooooodooooooorr',
      'oooooodooooooorr',
    ],
    hat: [
      '.............ww.',
      '...........RRww.',
      '........RRRRR...',
      '......RRRRRRR...',
      '.....RRRRRRRRR..',
      '....RRRRRRRRRR..',
      '..wwwwwwwwwwwww.',
      '..wwwwwwwwwwwww.',
    ],
    hatBottom: 5,
  },
  // 책상 앞 의자에 앉아 왼쪽 책상에 팔을 올렸다. 18번 줄(손 아래)이 책상 윗면이다.
  desk: {
    rows: [
      ...SIDE_HEAD,
      '....oooooo....',
      '...ooooooooor.',
      '...ooooooooor.',
      '..ddoooooooor.',
      'ssdddddooooor.',
      '....ooooooooor',
      '....ooooooooor',
      '....ooooooooor',
      '.jjjjjjjjjjjj.',
      '.jjjjjjjjjjjj.',
      '.jjj..........',
      '.jjj..........',
      '.jjj..........',
      '.jjj..........',
      '.jjj..........',
      'ffff..........',
    ],
    hat: [
      '...........ww.',
      '.........RRww.',
      '......RRRRR...',
      '.....RRRRRRR..',
      '....RRRRRRRRR.',
      '..wwwwwwwwwww.',
      '..wwwwwwwwwww.',
    ],
    hatBottom: 5,
  },
  // 창가 벤치에 무릎을 세우고 앉아 두 손으로 머그를 든다.
  seat: {
    rows: [
      ...SIDE_HEAD,
      '....oooooo....',
      '..MMooooooor..',
      '.MMMsdoooooor.',
      '.mMMjjjooooor.',
      '..jjjjjjoooor.',
      '..jjj.jjjjoor.',
      '..jjj..jjjjjr.',
      '..jjj...jjjjj.',
      '.ffff...jjjjj.',
    ],
    hat: null,
    hatBottom: 5,
  },
  // 이쪽을 본다. 눈은 감은 듯한 점 하나씩.
  front: {
    rows: [
      '......hhhh......',
      '.....hhhhhh.....',
      '......hhhh......',
      '....kkkkkkkk....',
      '...khhhhhhhhk...',
      '..khhhhhhhhhhk..',
      '..khhhhhhhhhhk..',
      '.KKhssssssssHKK.',
      '.KKhsessssesHKK.',
      '.KKhssssssssHKK.',
      '...hssssssssH...',
      '...hhssssssHH...',
      '......ssss......',
      '...oooooooooor..',
      '..ooooooooooorr.',
      '.ooooodoodoooorr',
      '.ooooodoodoooorr',
      '.oooooooooooooor',
      '.oooooooooooooor',
      '.oooooooooooooor',
      '.oooooooooooooor',
      '.oooooooooooooor',
    ],
    hat: [
      '............ww..',
      '.........RRRww..',
      '.......RRRRR....',
      '.....RRRRRRRR...',
      '....RRRRRRRRRR..',
      '..wwwwwwwwwwww..',
      '..wwwwwwwwwwww..',
    ],
    hatBottom: 7,
  },
};
PEOPLE.seat.hat = PEOPLE.desk.hat;

// rows: 고양이, scarf: 빨간 목도리(고양이와 폭이 같다), scarfBottom: 목도리 아랫줄이 닿는 고양이 줄
const CATS = {
  back: {
    rows: [
      '.c....c....',
      '.cc..cc....',
      '.ccccccR...',
      '.ccccccR...',
      '..ccccR....',
      '..ccccc....',
      '.cccccccR..',
      'ccccccccR..',
      'ccccccccR..',
      'cccccccccR.',
      'cccccccccRc',
      '.cccccccccc',
    ],
    scarf: ['..SSSSS....', '..S........', '..S........', '.S.........'],
    scarfBottom: 9,
  },
  front: {
    rows: [
      '.c.....c..',
      '.cc...cc..',
      '.cccccccR.',
      '.cgcccgcR.',
      '.cccccccR.',
      '..cccccR..',
      '..cccccR..',
      '.cccccccR.',
      '.cccccccR.',
      'ccccccccRc',
      'cccccccccc',
    ],
    scarf: ['..SSSSS...', '......S...', '......S...'],
    scarfBottom: 8,
  },
  curled: {
    rows: [
      '.c.c........',
      '.cccccccccR.',
      'cccccccccccR',
      'cccccccccccR',
      '.ccccccccccc',
    ],
    scarf: ['...SS.......', '...SS.......', '....S.......'],
    scarfBottom: 4,
  },
};

const SPRITES = {
  mug: ['.t.t...', 't.t....', '.t.t...', '.......', 'mmmmm..', 'mMMMmmm', 'mMMMm.m', 'mMMMmmm', '.mmm...'],
  books: ['.11111111.', '2222222222', '.33333333.', '1111111111'],
  plant: ['.l.l.', 'lLlLl', '.lLl.', 'ppppp', '.ppp.'],
};
const SPRITE_COLORS = {
  h: 'hair', H: 'hair-rim', k: 'headphone', K: 'headphone-accent', s: 'skin', S: 'hoodie-rim', e: 'hair',
  o: 'hoodie', d: 'hoodie-dark', r: 'hoodie-rim', j: 'curtain-dark', f: 'wood-dark',
  c: 'cat', R: 'cat-rim', g: 'pouch-gold',
  L: 'lamp', m: 'mug-dark', M: 'mug', t: 'steam',
  1: 'book-1', 2: 'book-2', 3: 'book-3', l: 'plant', p: 'pot',
};

// ---- 구성 요소 ----

function drawPerson(g, pose, x, bottom) {
  const { rows, hat, hatBottom } = PEOPLE[pose];
  g.sprite(x, bottom, rows, SPRITE_COLORS);
  g.sprite(x, bottom - rows.length + hatBottom, hat, { R: 'santa', w: 'santa-trim' });
}

function drawCat(g, pose, x, bottom) {
  const { rows, scarf, scarfBottom } = CATS[pose];
  g.sprite(x, bottom, rows, SPRITE_COLORS);
  g.sprite(x, bottom - rows.length + scarfBottom, scarf, { S: 'santa' });
}

// 불빛에서 멀어질수록 차가운 색. 거친 질감은 성긴 어두운 점.
function drawWall(g, W, H, s, light) {
  const grain = new Rand(41), reach = pt(W > H ? 110 : 90);
  for (let y = 0; y < H; y++) {
    for (let x = 0; x < W; x++) {
      let c = pc(s, 'wall');
      const d = Math.hypot(x + 0.5 - light[0], (y + 0.5 - light[1]) * 1.2) / reach;
      if (d < 0.35) c = blend(pc(s, 'wall-warmer'), pc(s, 'wall-warm'), d / 0.35, x, y);
      else if (d < 0.75) c = blend(pc(s, 'wall-warm'), c, (d - 0.35) / 0.4, x, y);
      if (grain.range(0, 1) < 0.04) c = pc(s, 'wall-dark');
      g.set(x, y, c);
    }
  }
}

// 창틀(두께 2, 십자 창살)과 창턱. 유리는 x0+2 ~ x1-2, y0+2 ~ sill.
function drawWindow(g, x0, y0, x1, sill, s, mullions = true) {
  const vw = x1 - x0 - 4, vh = sill - y0 - 2;
  g.within(x0 + 2, y0 + 2, vw, vh, () => drawGlass(g, vw, vh, s));
  for (let y = y0; y < sill; y++) {
    for (let x = x0; x < x1; x++) {
      if (x >= x0 + 2 && x < x1 - 2 && y >= y0 + 2) continue;
      g.set(x, y, color(y === y0 ? 'wood-light' : 'wood'));
    }
  }
  if (mullions) {
    g.rect(Math.round((x0 + x1) / 2), y0 + 2, 1, vh, color('wood'));
    g.rect(x0 + 2, Math.round(y0 + (sill - y0) * 0.42), vw, 1, color('wood'));
  }
  g.rect(x0 - 2, sill, x1 - x0 + 4, 2, color('wood-light'));
}

// 얇은 커튼. side -1 은 창 왼쪽(edge = 창틀 왼쪽 끝), 1 은 창 오른쪽(edge = 창틀 오른쪽 끝).
function drawCurtain(g, edge, top, bottom, side) {
  for (let y = top; y < bottom; y++) {
    const inner = 3 + Math.round(Math.sin(y * 0.4) * 0.7 + (y - top > (bottom - top) / 2 ? 1 : 0));
    for (let k = -4; k < inner; k++) {
      const x = side < 0 ? edge + k : edge - 1 - k;
      g.set(x, y, color((x + 1) % 3 === 0 ? 'curtain-dark' : 'curtain'));
    }
  }
}

// 책상: 윗면은 불빛 가까울수록 밝다.
function drawDesk(g, left, right, top, bottom, litX) {
  for (let x = left; x < right; x++) g.set(x, top, blend(color('desk-lit'), color('wood-light'), Math.abs(x - litX) / ((right - left) * 0.5), x, top));
  g.rect(left, top + 1, right - left, bottom - top - 1, color('wood'));
}

function drawFloor(g, top, W, H) {
  g.rect(0, top, W, 1, color('wood-light'));
  g.rect(0, top + 1, W, H - top - 1, color('wood'));
  for (let y = top + 2; y < H; y += 2) for (let x = (y * 5) % 11; x < W; x += 11) g.set(x, y, color('wood-dark'));
}

// 크리스마스 방 안 모양: 스탠드 대신 트리. 아래로 넓어지는 세 층이고, 층 아래 끝과 왼쪽은 그늘이다.
function drawTree(g, cx, bottom, height = 40) {
  const top = bottom - height, rows = height - 3, tierRows = Math.round(rows / 3);
  const halfAt = r => {
    const tier = Math.min(2, Math.floor(r / tierRows));
    return Math.round(1 + tier * 2 + (r - tier * tierRows) * 0.45);
  };
  for (let r = 0; r < rows; r++) {
    const half = halfAt(r), tierEnd = r % tierRows === tierRows - 1 || r === rows - 1;
    for (let x = cx - half; x <= cx + half; x++) g.set(x, top + r, color(tierEnd || x < cx - half / 3 ? 'tree-dark' : 'tree'));
  }
  const lights = new Rand(23), palette = ['bulb-1', 'bulb-2', 'bulb-3', 'bulb-4', 'lamp-light'];
  for (let i = 0; i < Math.round(18 * rows / 37); i++) {
    const r = lights.int(3, rows - 2), half = halfAt(r);
    g.set(cx + Math.round(lights.range(-0.8, 0.8) * half), top + r, color(palette[lights.int(0, palette.length - 1)]));
  }
  g.rect(cx, top - 2, 1, 3, color('lamp-light'));
  g.rect(cx - 1, top - 1, 3, 1, color('lamp-light'));
  g.rect(cx - 3, top + rows, 7, bottom - top - rows, color('pot'));
}

function drawGifts(g, cx, bottom) {
  g.sprite(cx - 7, bottom, ['RRgRR', 'RRgRR', 'ggggg', 'RRgRR'], { R: 'santa', g: 'pouch-gold' });
  g.sprite(cx + 6, bottom, ['GGrG', 'rrrr', 'GGrG'], { G: 'summer-1', r: 'santa-trim' });
}

function drawShelf(g, x0, x1, y) {
  g.rect(x0, y, x1 - x0, 1, color('wood-light'));
  g.rect(x0 + 1, y + 1, x1 - x0 - 2, 1, color('wood-dark'));
  const books = new Rand(19);
  for (let i = 0, x = x0 + 2; i < 6; i++, x += 2) {
    const h = books.int(5, 8);
    g.rect(x, y - h, 2, h, color(`book-${i % 3 + 1}`));
  }
  const px = x1 - 5;
  g.sprite(px, y, SPRITES.plant, SPRITE_COLORS);
  for (const [dx, len] of [[-2, 9], [0, 15], [2, 6]]) {
    for (let j = 0; j < len; j++) g.set(px + dx + (j % 4 === 3 ? 1 : 0), y + 2 + j, color(j % 2 ? 'plant-dark' : 'plant'));
  }
}

// 지름 13칸 벽시계와 크리스마스 모양(위쪽 호랑가시)
function drawClock(g, cx, cy, s) {
  disc(g, cx + 0.5, cy + 0.5, 6.5, color('clock-rim'));
  disc(g, cx + 0.5, cy + 0.5, 5.5, color('clock-face'));
  for (const [dx, dy] of [[0, -5], [5, 0], [0, 5], [-5, 0]]) g.set(cx + dx, cy + dy, color('clock-rim'));
  const hand = (turns, length, width) => {
    const a = turns * 2 * Math.PI, [dx, dy] = [Math.sin(a), -Math.cos(a)];
    for (let t = 0; t <= length; t += 0.5) {
      for (let k = 0; k < width; k++) g.set(cx + Math.round(dx * t - dy * k * 0.7), cy + Math.round(dy * t + dx * k * 0.7), color('clock-hand'));
    }
  };
  hand(s.minute / 60, 5, 1);
  hand((s.hour % 12 + s.minute / 60) / 12, 3, 2);
  g.sprite(cx, cy - 5, ['LL.LL', '.LrL.'], { L: 'summer-2', r: 'santa' });
}

// ---- 구도 ----
// 크기마다 자리를 따로 정한다. wide: medium, big: large.

// A. 책상 앞에 앉은 뒷모습, 창은 뒤쪽 배경 (06-lofi 와 같다)
function composeBack(g, W, H, s) {
  const wide = W > H, deskTop = H - 7, sill = deskTop - 2;
  const x0 = Math.round(W * (wide ? 0.06 : 0.04)), x1 = x0 + Math.round(W * (wide ? 0.5 : 0.6));
  const y0 = Math.round(H * 0.1), treeX = W - 9, personX = Math.round(W * (wide ? 0.72 : 0.6));
  drawWall(g, W, H, s, [treeX, H - 20]);
  drawClock(g, x1 + 7, y0 + 4, s);
  drawWindow(g, x0, y0, x1, sill, s);
  drawCurtain(g, x0, y0 - 2, deskTop, -1);
  drawCat(g, 'back', x0 + 9, sill);
  g.sprite(x1 - 6, sill, SPRITES.plant, SPRITE_COLORS);
  if (H > 80) drawShelf(g, x1 + 6, W - 6, Math.round(H * 0.38));
  drawDesk(g, 0, treeX - 11, deskTop, H, treeX);
  g.sprite(personX - pt(42), deskTop + 1, SPRITES.books, SPRITE_COLORS);
  g.sprite(personX - pt(24), deskTop + 1, SPRITES.mug, SPRITE_COLORS);
  drawTree(g, treeX, H);
  drawGifts(g, treeX, H);
  drawPerson(g, 'back', personX, H);
}

// B. 창 아래 책상에서 창 쪽(왼쪽)을 보고 앉은 옆모습. 책상·의자·바닥이 보인다.
function composeDesk(g, W, H, s) {
  const wide = W > H, big = H > 80, rows = PEOPLE.desk.rows;
  const floor = H - (big ? 8 : 5), top = floor - rows.length, deskTop = top + 18;
  const personX = Math.round(W * (wide ? 0.62 : big ? 0.56 : 0.58)), left = personX - rows[0].length / 2;
  const x0 = Math.round(W * 0.05), x1 = left - (wide || big ? 4 : 2), y0 = Math.round(H * 0.1);
  const treeX = W - (W > 80 ? 10 : 7), treeHeight = W > 80 ? 40 : 30;
  drawWall(g, W, H, s, [treeX, floor - 20]);
  drawFloor(g, floor, W, H);
  drawClock(g, Math.round((x1 + treeX - 10) / 2), y0 + 5, s);
  drawWindow(g, x0, y0, x1, deskTop - 3, s);
  drawCurtain(g, x0, y0 - 2, deskTop, -1);
  if (big) drawShelf(g, x1 + 6, W - 6, Math.round(H * 0.38));
  drawTree(g, treeX, floor + 1, treeHeight);
  drawGifts(g, treeX, floor + 1);
  // 책상은 창 아래 벽에 붙은 판과 다리 둘이다. 판 오른쪽 끝에 사람 손이 닿는다.
  const deskRight = left + 4;
  drawDesk(g, 0, deskRight, deskTop, deskTop + 2, treeX);
  for (const x of [2, deskRight - 2]) g.rect(x, deskTop + 2, 1, floor - deskTop - 2, color('wood-dark'));
  drawCat(g, 'back', x0 + 9, deskTop);
  g.sprite(Math.round((x0 + 9 + left) / 2) + 2, deskTop + 1, SPRITES.books, SPRITE_COLORS);
  g.sprite(left - 3, deskTop + 1, SPRITES.mug, SPRITE_COLORS);
  // 의자: 등받이, 앉는 판, 다리 둘
  const chair = color('wood-dark');
  g.rect(left + 13, top + 12, 2, 12, chair);
  g.rect(left + 3, top + 23, 12, 1, chair);
  for (const x of [left + 4, left + 13]) g.rect(x, top + 24, 1, floor - top - 24, chair);
  drawPerson(g, 'desk', personX, floor);
}

// C. 큰 창 아래 벤치에 무릎을 세우고 앉은 옆모습. 사람은 창을 등지지 않고 창밖을 본다.
function composeSeat(g, W, H, s) {
  const big = H > 80, seat = H - (big ? 20 : 13);
  const x0 = Math.round(W * 0.04), x1 = Math.round(W * (W > 80 ? 0.74 : 0.69)), y0 = Math.round(H * (big ? 0.3 : 0.08));
  const treeX = W - (W > 80 ? 11 : 7), treeHeight = W > 80 ? 40 : 30, personX = x1 - 10;
  drawWall(g, W, H, s, [treeX, H - 20]);
  drawClock(g, Math.round((x1 + 4 + W) / 2), big ? y0 + 6 : 8, s);
  if (big) drawShelf(g, x0 + 6, x1 - 6, y0 - 10);
  drawWindow(g, x0, y0, x1, seat, s);
  drawCurtain(g, x0, y0 - 2, seat, -1);
  drawCurtain(g, x1, y0 - 2, seat, 1);
  // 벤치: 방석과 앞판
  g.rect(x0 - 4, seat, x1 - x0 + 8, 2, color('beanie'));
  g.rect(x0 - 4, seat + 2, x1 - x0 + 8, 1, color('beanie-dark'));
  g.rect(x0 - 4, seat + 3, x1 - x0 + 8, 1, color('wood-light'));
  g.rect(x0 - 4, seat + 4, x1 - x0 + 8, H - seat - 4, color('wood'));
  drawTree(g, treeX, H, treeHeight);
  drawGifts(g, treeX, H);
  drawCat(g, 'curled', personX - 13, seat + 1);
  drawPerson(g, 'seat', personX, seat + 1);
}

// D. 집 밖에서 불 켜진 창 안을 본다. 창밖 풍경 그리기를 집 바깥에 쓰고, 방 안은 창 안에 그린다.
function composeOutside(g, W, H, s) {
  const big = H > 80;
  const { ground, hx0, hy0, wx0, wx1, wy0, wy1, treeHeight } = W > 80
    ? (big ? { ground: 116, hx0: 16, hy0: 54, wx0: 30, wx1: 106, wy0: 66, wy1: 106, treeHeight: 34 }
           : { ground: 50, hx0: 46, hy0: 9, wx0: 58, wx1: 114, wy0: 15, wy1: 46, treeHeight: 26 })
    : { ground: 50, hx0: 10, hy0: 7, wx0: 15, wx1: 54, wy0: 12, wy1: 46, treeHeight: 20 };
  g.within(0, 0, W, ground, () => drawView(g, W, ground, s));
  g.rect(0, ground, W, H - ground, pc(s, 'snow'));
  // 집 벽(가로 판자)과 처마
  for (let y = hy0; y < ground; y++) g.rect(hx0, y, W - hx0, 1, color((y - hy0) % 3 === 2 ? 'wood-dark' : 'wood'));
  g.rect(hx0 - 3, hy0 - 3, W - hx0 + 3, 3, color('lamp-body'));
  if (s.snowCovered) g.rect(hx0 - 3, hy0 - 4, W - hx0 + 3, 2, pc(s, 'snow'));
  // 창 안: 방 벽, 시계, 트리, 사람, 고양이. 사람 허리 아래는 창 아래 끝에서 잘린다.
  const gx = wx0 + 2, gy = wy0 + 2, gw = wx1 - wx0 - 4, gh = wy1 - gy;
  g.within(gx, gy, gw, gh, () => {
    const treeX = gw - Math.round(treeHeight / 3);
    drawWall(g, gw, gh, s, [treeX, gh - 10]);
    drawClock(g, big ? 10 : 8, big ? 10 : 8, s);
    drawTree(g, treeX, gh + 1, treeHeight);
    drawPerson(g, 'front', Math.round(gw * 0.5), gh + 4);
    drawCat(g, 'front', big ? 14 : 6 + (W > 80 ? 5 : 0), gh);
    drawFrost(g, gw, gh);
  });
  for (let y = wy0; y < wy1; y++) {
    for (let x = wx0; x < wx1; x++) if (x < gx || x >= gx + gw || y < gy) g.set(x, y, color(y === wy0 ? 'wood-light' : 'wood'));
  }
  g.rect(wx0 - 2, wy1, wx1 - wx0 + 4, 2, color('wood-light'));
  if (s.snowCovered) g.rect(wx0 - 2, wy1 - 1, wx1 - wx0 + 4, 1, pc(s, 'snow'));
  if (s.snowing) drawSnow(g, W, H, s);
}

// E. 책상 너머 사람이 이쪽을 본다. 창은 사람 뒤에 있다.
function composeFront(g, W, H, s) {
  const big = H > 80, deskTop = H - 7, sill = deskTop - 4;
  const x0 = Math.round(W * (W > 80 ? 0.28 : 0.3)), x1 = Math.round(W * (W > 80 ? 0.78 : 0.9)), y0 = Math.round(H * (big ? 0.3 : 0.1));
  const personX = Math.round((x0 + x1) / 2), treeX = W - (W > 80 ? 10 : 6), treeHeight = W > 80 ? 40 : 30;
  drawWall(g, W, H, s, [treeX, H - 20]);
  drawClock(g, Math.round(x0 / 2), y0 + 6, s);
  if (big) drawShelf(g, x0 + 4, x1 - 4, y0 - 10);
  drawWindow(g, x0, y0, x1, sill, s);
  drawCurtain(g, x0, y0 - 2, deskTop, -1);
  drawCurtain(g, x1, y0 - 2, deskTop, 1);
  drawTree(g, treeX, H, treeHeight);
  drawPerson(g, 'front', personX, deskTop + 3);
  drawDesk(g, 0, W, deskTop, H, treeX);
  drawGifts(g, treeX, deskTop + 1);
  drawCat(g, 'front', x0 - 9, deskTop + 1);
  g.sprite(personX + 10, deskTop + 1, SPRITES.mug, SPRITE_COLORS);
}

const COMPOSITIONS = { back: composeBack, desk: composeDesk, seat: composeSeat, outside: composeOutside, front: composeFront };

// ---- 페이지 ----

function widget(scene, sizeKey) {
  const [w, h] = SIZES[sizeKey];
  const s = sceneContext(scene);
  const g = new Grid(Math.ceil(w / DOT), Math.ceil(h / DOT));
  COMPOSITIONS[COMPOSITION](g, g.cols, g.rows, s);
  const canvas = g.canvas();
  const offset = [Math.floor((g.cols * DOT - w) / 2), Math.floor((g.rows * DOT - h) / 2)];
  const box = document.createElement('div');
  box.className = `widget ${sizeKey}`;
  box.style.width = `${w}px`;
  box.style.height = `${h}px`;
  box.setAttribute('role', 'img');
  box.setAttribute('aria-label', [s.region, s.time, s.weather.condition, ...s.occasions.map(id => OCCASION_NAMES[id])].join(', '));
  canvas.className = 'dots';
  Object.assign(canvas.style, { width: `${g.cols * DOT}px`, height: `${g.rows * DOT}px`, left: `${-offset[0]}px`, top: `${-offset[1]}px` });
  box.append(canvas);
  return { box, colors: new Set(g.cells.filter(Boolean)).size };
}

document.getElementById('scenes').append(...SCENES.map(scene => {
  const widgets = Object.keys(SIZES).map(size => widget(scene, size));
  const section = document.createElement('section');
  section.className = 'scene';
  section.innerHTML = `<h2>${scene.title}</h2><p class="meta">${scene.region} ${scene.date} ${scene.time} · ${scene.weather[0]} · 색 ${widgets.map(w => w.colors).join('/')}</p><div class="sizes"></div>`;
  section.querySelector('.sizes').append(...widgets.map(w => w.box));
  return section;
}));
