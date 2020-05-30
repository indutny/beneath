extends Node

enum ResourceType {
	# Asteroid Content
	IronOre = 0,
	NickelOre = 1,
	CobaltOre = 2,
	Ice = 3,
	
	# Composites or intermediate resources
	Hydrogen = 4,
	Oxygen = 5,
	Fuel = 6
}

export(Dictionary) var RESOURCE_NAME = {
	ResourceType.IronOre: "Iron Ore",
	ResourceType.NickelOre: "Nickel Ore",
	ResourceType.CobaltOre: "Cobalt Ore",
	ResourceType.Ice: "Ice",
	
	ResourceType.Hydrogen: "Hydrogen",
	ResourceType.Oxygen: "Oxygen",
	ResourceType.Fuel: "Fuel"
}

export(Dictionary) var RESOURCE_WEIGHT = {
	ResourceType.IronOre: 8,
	ResourceType.NickelOre: 9,
	ResourceType.CobaltOre: 9,
	ResourceType.Ice: 1,
	
	ResourceType.Hydrogen: 1,
	ResourceType.Oxygen: 1,
	ResourceType.Fuel: 1
}

# Take in account: price of base resources and production rate at level 0
export(Dictionary) var RESOURCE_BASE_PRICE = {
	ResourceType.IronOre: 30,
	ResourceType.NickelOre: 400,
	ResourceType.CobaltOre: 100,
	ResourceType.Ice: 5,
	
	ResourceType.Hydrogen: 5,
	ResourceType.Oxygen: 10,
	ResourceType.Fuel: 75
}

# Price difference between buy/sell
export(float) var MARK_UP = 1.2

enum BuildingType {
	Vacant = 0,
	ElectrolysisPlant = 1,
	FuelRefinery = 2,
	IceMine = 3
}

export(Dictionary) var BUILDING_NAME = {
	BuildingType.Vacant: "Vacant",
	BuildingType.ElectrolysisPlant: "Electrolysis Plant",
	BuildingType.FuelRefinery: "Fuel Refinery",
	BuildingType.IceMine: "Ice Mine"
}

export(Dictionary) var BUILDING_COST = {
	BuildingType.Vacant: 0,
	BuildingType.ElectrolysisPlant: 700,
	BuildingType.FuelRefinery: 1000,
	BuildingType.IceMine: 500
}

export(Dictionary) var BUILDING_CONSUMES = {
	BuildingType.Vacant: {},
	BuildingType.ElectrolysisPlant: {
		ResourceType.Ice: 4
	},
	BuildingType.FuelRefinery: {
		ResourceType.Hydrogen: 2,
		ResourceType.Oxygen: 2
	},
	BuildingType.IceMine: {}
}

export(Dictionary) var BUILDING_PRODUCES = {
	BuildingType.Vacant: {},
	BuildingType.ElectrolysisPlant: {
		ResourceType.Hydrogen: 2,
		ResourceType.Oxygen: 1
	},
	BuildingType.FuelRefinery: {
		ResourceType.Fuel: 1
	},
	BuildingType.IceMine: {
		ResourceType.Ice: 1
	}
}

export(Dictionary) var BUILDING_PRODUCE_INTERVAL = {
	BuildingType.Vacant: [ INF ],
	BuildingType.ElectrolysisPlant: [ 10.0 ],
	BuildingType.FuelRefinery: [ 15.0 ],
	BuildingType.IceMine: [ 3.0 ]
}
