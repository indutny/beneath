extends Node

enum ResourceType {
	# Asteroid Content
	IronOre = 0,
	NickelOre = 1,
	CobaltOre = 2,
	Ice = 3,
	Silicon = 4,
	
	# Composites or intermediate resources
	Electricity = 100,
	Hydrogen = 101,
	Oxygen = 102,
	Fuel = 103
}

export(Dictionary) var RESOURCE_NAME = {
	ResourceType.IronOre: "Iron Ore",
	ResourceType.NickelOre: "Nickel Ore",
	ResourceType.CobaltOre: "Cobalt Ore",
	ResourceType.Ice: "Ice",
	ResourceType.Silicon: "Silicon",
	
	ResourceType.Electricity: "Electricity",
	ResourceType.Hydrogen: "Hydrogen",
	ResourceType.Oxygen: "Oxygen",
	ResourceType.Fuel: "Fuel"
}

export(Dictionary) var RESOURCE_WEIGHT = {
	ResourceType.IronOre: 8,
	ResourceType.NickelOre: 9,
	ResourceType.CobaltOre: 9,
	ResourceType.Ice: 1,
	ResourceType.Silicon: 2,
	
	ResourceType.Electricity: -1,
	ResourceType.Hydrogen: 1,
	ResourceType.Oxygen: 1,
	
	# NOTE: Isn't placed in cargo anyway
	ResourceType.Fuel: 0
}

export(Dictionary) var RESOURCE_STATION_CAPACITY = {
	ResourceType.IronOre: 1000,
	ResourceType.NickelOre: 1000,
	ResourceType.CobaltOre: 1000,
	ResourceType.Ice: 1000,
	ResourceType.Silicon: 1000,
	
	ResourceType.Electricity: 1000,
	ResourceType.Hydrogen: 2000,
	ResourceType.Oxygen: 1000,
	ResourceType.Fuel: 250,
}

# Take in account: price of base resources and production rate at level 0
export(Dictionary) var RESOURCE_BASE_PRICE = {
	ResourceType.IronOre: 300,
	ResourceType.NickelOre: 4000,
	ResourceType.CobaltOre: 1000,
	ResourceType.Ice: 50,
	ResourceType.Silicon: 100,
	
	# Can't be sold
	ResourceType.Electricity: 0,
	
	ResourceType.Hydrogen: 50,
	ResourceType.Oxygen: 100,
	ResourceType.Fuel: 750
}

# Price difference between buy/sell
export(float) var MARK_UP = 1.05

enum BuildingType {
	Vacant = 0,
	SolarPanel = 1,
	ElectrolysisPlant = 2,
	FuelRefinery = 3,
	IceMine = 4
}

export(Dictionary) var BUILDING_NAME = {
	BuildingType.Vacant: "Vacant",
	BuildingType.SolarPanel: "Solar Panel",
	BuildingType.ElectrolysisPlant: "Electrolysis Plant",
	BuildingType.FuelRefinery: "Fuel Refinery",
	BuildingType.IceMine: "Ice Mine"
}

export(Dictionary) var BUILDING_COST = {
	BuildingType.Vacant: [ 0, {} ],
	BuildingType.SolarPanel: [ 20000, { ResourceType.Silicon: 250 } ],
	BuildingType.ElectrolysisPlant: [ 50000, { ResourceType.IronOre: 200 } ],
	BuildingType.FuelRefinery: [
		75000,
		{
			ResourceType.IronOre: 50,
			ResourceType.NickelOre: 100
		}
	],
	BuildingType.IceMine: [
		200000,
		{
			ResourceType.IronOre: 100,
			ResourceType.CobaltOre: 10
		}
	]
}

export(Dictionary) var BUILDING_CONSUMES = {
	BuildingType.Vacant: {},
	BuildingType.SolarPanel: {},
	BuildingType.ElectrolysisPlant: {
		ResourceType.Electricity: 5,
		ResourceType.Ice: 4
	},
	BuildingType.FuelRefinery: {
		ResourceType.Electricity: 3,
		ResourceType.Hydrogen: 2,
		ResourceType.Oxygen: 2
	},
	BuildingType.IceMine: {
		ResourceType.Electricity: 5
	}
}

export(Dictionary) var BUILDING_PRODUCES = {
	BuildingType.Vacant: {},
	BuildingType.SolarPanel: {
		ResourceType.Electricity: 1
	},
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
	BuildingType.SolarPanel: [ 2.0 ],
	BuildingType.ElectrolysisPlant: [ 10.0 ],
	BuildingType.FuelRefinery: [ 15.0 ],
	BuildingType.IceMine: [ 3.0 ]
}

#
# Mining
#

export(Dictionary) var MINING_INTERVAL = {
	ResourceType.IronOre: 3.0,
	ResourceType.NickelOre: 4.0,
	ResourceType.CobaltOre: 5.0,
	ResourceType.Ice: 0.5,
	ResourceType.Silicon: 1.0,
}
