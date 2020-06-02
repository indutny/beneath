extends Node

enum ResourceType {
	# Asteroid Content
	Silicon = 0,
	Ice = 1,
	Carbon = 2,
	IronOre = 3,
	NickelOre = 4,
	CobaltOre = 5,
	MagnesiumOre = 6,
	PlatinumOre = 7,
	UraniumOre = 8,
	
	# Composites or intermediate resources
	Electricity = 100,
	Hydrogen = 101,
	Oxygen = 102,
	Fuel = 103,
	Microchip = 104
}

export(Dictionary) var RESOURCE_NAME = {
	ResourceType.Silicon: "Silicon",
	ResourceType.Ice: "Ice",
	ResourceType.Carbon: "Carbon",
	ResourceType.IronOre: "Iron Ore",
	ResourceType.NickelOre: "Nickel Ore",
	ResourceType.CobaltOre: "Cobalt Ore",
	ResourceType.MagnesiumOre: "Magnesium Ore",
	ResourceType.PlatinumOre: "Platinum Ore",
	ResourceType.UraniumOre: "Uranium Ore",
	
	ResourceType.Electricity: "Electricity",
	ResourceType.Hydrogen: "Hydrogen",
	ResourceType.Oxygen: "Oxygen",
	ResourceType.Fuel: "Fuel",
	ResourceType.Microchip: "Microchip"
}

export(Dictionary) var RESOURCE_WEIGHT = {
	ResourceType.Ice: 1,
	ResourceType.Silicon: 2,
	ResourceType.Carbon: 2,
	ResourceType.IronOre: 8,
	ResourceType.NickelOre: 9,
	ResourceType.CobaltOre: 9,
	ResourceType.MagnesiumOre: 2,
	ResourceType.PlatinumOre: 21,
	ResourceType.UraniumOre: 19,
	
	ResourceType.Electricity: -1,
	ResourceType.Hydrogen: 1,
	ResourceType.Oxygen: 1,
	ResourceType.Microchip: 1,
	
	# NOTE: Isn't placed in cargo anyway
	ResourceType.Fuel: 0
}

export(Dictionary) var RESOURCE_STATION_CAPACITY = {
	ResourceType.Ice: 10000,
	ResourceType.Silicon: 10000,
	ResourceType.Carbon: 10000,
	ResourceType.IronOre: 10000,
	ResourceType.NickelOre: 10000,
	ResourceType.CobaltOre: 10000,
	ResourceType.MagnesiumOre: 10000,
	ResourceType.PlatinumOre: 10000,
	ResourceType.UraniumOre: 10000,
	
	ResourceType.Electricity: 100,
	ResourceType.Hydrogen: 2000,
	ResourceType.Oxygen: 1000,
	ResourceType.Fuel: 250,
	ResourceType.Microchip: 1000
}

# Take in account: price of base resources and production rate at level 0
export(Dictionary) var RESOURCE_BASE_PRICE = {
	ResourceType.IronOre: 300,
	ResourceType.NickelOre: 4000,
	ResourceType.CobaltOre: 1000,
	ResourceType.Ice: 50,
	ResourceType.Silicon: 100,
	ResourceType.Carbon: 100,
	ResourceType.IronOre: 300,
	ResourceType.NickelOre: 2000,
	ResourceType.CobaltOre: 1000,
	ResourceType.MagnesiumOre: 4000,
	ResourceType.PlatinumOre: 7000,
	ResourceType.UraniumOre: 10000,
	
	# Can't be sold
	ResourceType.Electricity: 0,
	
	ResourceType.Hydrogen: 25,
	ResourceType.Oxygen: 50,
	ResourceType.Fuel: 300,
	ResourceType.Microchip: 500
}

# Price difference between buy/sell
export(float) var MARK_UP = 1.05

enum BuildingType {
	Vacant = 0,
	SolarPanel = 1,
	ElectrolysisPlant = 2,
	FuelRefinery = 3,
	IceMine = 4,
	MicrochipFactory = 5
}

export(Dictionary) var BUILDING_NAME = {
	BuildingType.Vacant: "Vacant",
	BuildingType.SolarPanel: "Solar Panel",
	BuildingType.ElectrolysisPlant: "Electrolysis Plant",
	BuildingType.FuelRefinery: "Fuel Refinery",
	BuildingType.IceMine: "Ice Mine",
	BuildingType.MicrochipFactory: "Microchip Factory"
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
	],
	BuildingType.MicrochipFactory: [
		100000,
		{
			ResourceType.Silicon: 5
		}
	]
}

export(Dictionary) var BUILDING_CONSUMES = {
	BuildingType.Vacant: {},
	BuildingType.SolarPanel: {},
	BuildingType.ElectrolysisPlant: {
		ResourceType.Electricity: 5,
		ResourceType.Ice: 2
	},
	BuildingType.FuelRefinery: {
		ResourceType.Electricity: 3,
		ResourceType.Hydrogen: 2,
		ResourceType.Oxygen: 2
	},
	BuildingType.IceMine: {
		ResourceType.Electricity: 5
	},
	BuildingType.MicrochipFactory: {
		ResourceType.Microchip: 1
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
	ResourceType.Ice: 0.5,
	ResourceType.Silicon: 1.0,
	ResourceType.Carbon: 1.0,
	ResourceType.IronOre: 3.0,
	ResourceType.NickelOre: 5.0,
	ResourceType.CobaltOre: 7.0,
	ResourceType.MagnesiumOre: 7.0,
	ResourceType.PlatinumOre: 10.0,
	ResourceType.UraniumOre: 30.0,
}

# Generation of fuel on stations
export(int) var STATION_REFUEL_INTERVAL = 15

# How much credits are taken on empty fuel tank
export(int) var FUEL_LOAN_PRICE = 1000

# Per one universe scale
export(int) var FUEL_PER_UNIVERSE_UNIT = 10
