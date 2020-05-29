'use strict';

const ICE = 'ice';
const HYDROGEN = 'hydrogen';
const OXYGEN = 'oxygen';
const FUEL = 'fuel';

const GOODS = [ ICE, HYDROGEN, OXYGEN, FUEL ];
const CAPACITY = 1000;
const STATION_CREDITS = 1000;
const CARRIER_CAPACITY = 100;

const STEP_COUNT = 10;

class ElectrolysisPlant {
  constructor() {
    this.interval = 1;
  }

  run(station) {
    if (!station.has(ICE, 4)) {
      return;
    }

    station.take(ICE, 4);
    station.put(HYDROGEN, 2);
    station.put(OXYGEN, 1);
  }
}

class FuelRefinery {
  constructor() {
    this.interval = 2;
  }

  run(station) {
    if (!station.has(HYDROGEN, 2) || !station.has(OXYGEN, 2)) {
      return;
    }

    station.take(HYDROGEN, 2);
    station.take(OXYGEN, 2);
    station.put(FUEL, 1);
  }
}

class Station {
  constructor(name, position) {
    this.name = name;
    this.position = position;
    this.buildings = [];
    this.goods = new Map();

    this.credits = STATION_CREDITS;

    for (const good in GOODS) {
      this.goods.set(good, { quantity: 0, capacity: CAPACITY });
    }
  }

  has(good, quantity) {
    return this.goods.get(good).quantity >= quantity;
  }

  take(good, quantity) {
    this.goods.get(good).quantity -= quantity;
  }

  put(good, quantity) {
    const entry = this.goods.get(good);
    entry.quantity = Math.min(entry.capacity, entry.quantity + quantity);
  }

  addBuilding(building) {
    this.buildings.push(building);
  }
}

//
// Simulation
//

const alpha = new Station('alpha', [ 0, 0, 0 ]);
alpha.addBuilding(new ElectrolysisPlant());
const beta = new Station('beta', [ 1, 0, 0 ]);
beta.addBuilding(new FuelRefinery());

const STATIONS = [ alpha, beta ];
for (let step = 0; step < STEP_COUNT; step++) {
}
