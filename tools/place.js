'use strict';

const STATION_NAMES = require('./station-names.json');
const ZERO = { x: 0, y: 0, z: 0 };

const RADIUS = 14;
const STAR_RADIUS = 2;
const STARTING_RADIUS = 1;

const STATION_MIN_DISTANCE = 3.3;
const STATION_MAX_DISTANCE = 9;
const STATION_MIN_BUILDINGS = 2;
const STATION_MAX_BUILDINGS = 8;

const ASTEROID_MIN_STATION_DISTANCE = 0.5;
const ASTEROID_MAX_STATION_DISTANCE = 3;
const ASTEROID_MIN_DISTANCE = 3;

const RESOURCE_POSTFIX = new Map([
  [ 'silicon', 'S' ],
  [ 'ice', 'I' ],
  [ 'carbon', 'C' ],
  [ 'iron', 'MI' ],
  [ 'nickel', 'MN' ],
  [ 'cobalt', 'MC' ],
  [ 'magnesium', 'MM' ],
  [ 'platinum', 'MP' ],
  [ 'uranium', 'U' ],
]);

const RESOURCE_RANGE = new Map([
  [ 'silicon', [ 0.8, 1.2 ] ],
  [ 'ice', [ 0.8, 1.2 ] ],
  [ 'carbon', [ 0, 1.2 ] ],
  [ 'iron', [ 0, 0.5 ] ],
  [ 'nickel', [ 0, 0.5 ] ],
  [ 'cobalt', [ 0, 0.35 ] ],
  [ 'magnesium', [ 0, 0.25 ] ],
  [ 'platinum', [ 0, 0.2 ] ],
  [ 'uranium', [ 0, 0.15 ] ],
]);

const RESOURCE_COUNT = [
  [ 'silicon', 1, true ],
  [ 'silicon', 30 ],
  [ 'ice', 30 ],
  [ 'carbon', 20 ],
  [ 'iron', 10 ],
  [ 'nickel', 7 ],
  [ 'cobalt', 5 ],
  [ 'magnesium', 3 ],
  [ 'platinum', 2 ],
  [ 'uranium', 1 ],
];

const RESOURCE_ID = new Map([
  [ 'silicon', 0 ],
  [ 'ice', 1 ],
  [ 'carbon', 2 ],
  [ 'iron', 3 ],
  [ 'nickel', 4 ],
  [ 'cobalt', 5 ],
  [ 'magnesium', 6 ],
  [ 'platinum', 7 ],
  [ 'uranium', 8 ],
]);

const stations = [];
const asteroids = [];
const asteroidNames = new Set();

function getWorldPoint(maxRadius = RADIUS, minRadius = STAR_RADIUS) {
  for (;;) {
    const x = Math.round((Math.random() * 2 - 1) * 100) / 100;
    const y = Math.round((Math.random() * 2 - 1) * 100) / 100;
    const z = Math.round((Math.random() * 2 - 1) * 100) / 100;

    const r = Math.sqrt(x ** 2 + y ** 2 + z **2) * maxRadius;
    if (r > maxRadius) {
      continue;
    }
    if (r <= minRadius) {
      continue;
    }
    return { x: x * maxRadius, y: y * maxRadius, z: z * maxRadius };
  }
}

function distance(a, b) {
  return Math.sqrt((a.x - b.x) ** 2 + (a.y - b.y) ** 2 + (a.z - b.z) ** 2);
}

function groupDistance(point, group) {
  let min = Infinity;
  let max = 0;

  for (const elem of group) {
    const d = distance(point, elem.center);
    min = Math.min(d, min);
    max = Math.max(d, max);
  }

  return { min, max };
}

function placeStation(name) {
  let created = false;
  while (!created) {
    let center;
    if (stations.length === 0) {
      const range = RESOURCE_RANGE.get('silicon');
      center = getWorldPoint(RADIUS, range[0] * RADIUS + STAR_RADIUS);
    } else {
      center = getWorldPoint();
    }

    const group = groupDistance(center, stations);

    // The station is too far from others
    if (stations.length !== 0 && group.min > STATION_MAX_DISTANCE) {
      continue;
    }

    // Station is too close to others
    if (group.min < STATION_MIN_DISTANCE) {
      continue;
    }

    const buildings = STATION_MIN_BUILDINGS +
      (Math.random() * (STATION_MAX_BUILDINGS - STATION_MIN_BUILDINGS)) | 0;

    created = { name, center, buildings };
  }
  stations.push(created);
}

function generateAsteroidName(type) {
  const postfix = RESOURCE_POSTFIX.get(type);
  if (!postfix) {
    throw new Error('Unknown type: ' + type);
  }

  let letters = '';
  const ALPHABET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');

  while (letters.length < 3) {
    letters += ALPHABET[(ALPHABET.length * Math.random()) | 0];
  }

  let digits = '';
  while (digits.length < 2) {
    digits += (Math.random() * 10) | 0;
  }

  return `${letters}-${digits}-${postfix}`;
}

function generateUniqueAsteroidName(type) {
  let name;
  do {
    name = generateAsteroidName(type);
  } while (asteroidNames.has(name));
  asteroidNames.add(name);
  return name;
}

function placeAsteroid() {
  const first = RESOURCE_COUNT[0];
  const type = first[0];
  first[1]--;
  if (first[1] === 0) {
    RESOURCE_COUNT.shift();
  }
  const isStarting = !!first[2];

  const range = RESOURCE_RANGE.get(type);

  let created;
  while (!created) {
    let center;
    if (isStarting) {
      center = getWorldPoint(STARTING_RADIUS, 0);
      center.x += stations[0].center.x;
      center.y += stations[0].center.y;
      center.z += stations[0].center.z;
    } else {
      center = getWorldPoint();
    }

    const centerDistance = distance(center, ZERO) - STAR_RADIUS;
    if (centerDistance < range[0] * (RADIUS - STAR_RADIUS)) {
      continue;
    }
    if (centerDistance > range[1] * (RADIUS - STAR_RADIUS)) {
      continue;
    }

    const stationsGroup = groupDistance(center, stations);

    // Too close to the station
    if (stationsGroup.min < ASTEROID_MIN_STATION_DISTANCE) {
      continue;
    }

    // Too far from the station
    if (stationsGroup.min > ASTEROID_MAX_STATION_DISTANCE) {
      continue;
    }

    const group = groupDistance(center, asteroids);

    // Too close to other asteroids
    if (group.min < ASTEROID_MIN_DISTANCE) {
      continue;
    }

    const name = generateUniqueAsteroidName(type);

    created = {
      name,
      center,
      type,
    };
  }
  asteroids.push(created);
}

function generateTransform(center) {
  function matmul(a, b) {
    const out = [
      [ 0, 0, 0 ],
      [ 0, 0, 0 ],
      [ 0, 0, 0 ],
    ];

    for (let i = 0; i < 3; i++) {
      for (let j = 0; j < 3; j++) {
        for (let k = 0; k < 3; k++) {
          out[i][j] += a[i][k] * b[k][j];
        }
      }
    }

    return out;
  }

  function normalize(a) {
    const det = a[0][0] * (a[1][1] * a[2][2] - a[1][2] * a[2][1]) -
      a[0][1] * (a[1][0] * a[2][2] - a[1][2] * a[2][0]) +
      a[0][2] * (a[1][0] * a[2][1] - a[1][1] * a[2][0]);

    return a.map((row) => row.map((elem) => elem / det));
  }

  let m = [
    [ 1, 0, 0 ],
    [ 0, 1, 0 ],
    [ 0, 0, 1 ],
  ];

  const xa = Math.random() * 2 * Math.PI;
  const ya = Math.random() * 2 * Math.PI;
  const za = Math.random() * 2 * Math.PI;

  const x = [
    [ 1, 0, 0 ],
    [ 0, Math.cos(xa), Math.sin(xa) ],
    [ 0, -Math.sin(xa), Math.cos(xa) ],
  ];
  const y = [
    [ Math.cos(ya), 0, Math.sin(ya) ],
    [ 0, 1, 0 ],
    [ -Math.sin(ya), 0, Math.cos(ya) ],
  ];
  const z = [
    [ Math.cos(za), Math.sin(za), 0 ],
    [ -Math.sin(za), Math.cos(za), 0 ],
    [ 0, 0, 1 ],
  ];

  m = matmul(m, x);
  m = matmul(m, y);
  m = matmul(m, z);
  m = normalize(m, z);

  const linear = m.map((row) => row.join(', ')).join(', ');
  return `transform=` +
    `Transform(${linear}, ${center.x}, ${center.y}, ${center.z})`;
}

for (const name of STATION_NAMES) {
  placeStation(name);
}

while (RESOURCE_COUNT.length !== 0) {
  placeAsteroid();
}

const start = stations[0];
const startResources = new Map();;
for (const asteroid of asteroids) {
  const d = distance(start.center, asteroid.center);
  if (startResources.has(asteroid.type)) {
    startResources.set(asteroid.type,
      Math.min(startResources.get(asteroid.type), d));
  } else {
    startResources.set(asteroid.type, d);
  }
}
console.error(startResources);

console.log('[node name="Stations" type="Spatial" parent="."]');
console.log('');

for (const station of stations) {
  console.log(
    `[node name="${station.name}" ` +
    `parent="Stations" instance=ExtResource( 2 )]`);
  console.log(generateTransform(station.center));
  console.log('');

  for (let i = 0; i < station.buildings; i++) {
    console.log(
      `[node name="Vacant${i}" parent="Stations/${station.name}" ` +
      `instance=ExtResource( 3 )]`);
    console.log('');
  }
}

console.log('[node name="AsteroidFeilds" type="Spatial" parent="."]');
console.log('');
for (const asteroid of asteroids) {
  console.log(
    `[node name="${asteroid.name}" parent="AsteroidFeilds" ` +
    `instance=ExtResource( 5 )]`);
  console.log(`resource_type = ${RESOURCE_ID.get(asteroid.type)}`);
  console.log(generateTransform(asteroid.center));
  console.log('');
}
