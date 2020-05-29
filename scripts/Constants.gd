extends Node

enum ResourceType {
	# Asteroid Content
	IronOre,
	NickelOre,
	CobaltOre,
	Ice,
	
	# Composites or intermediate resources
	Hydrogen,
	Oxygen,
	Fuel
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

enum BuildingType {
	Vacant,
	ElectrolysisPlant,
	FuelRefinery
}

export(Dictionary) var BUILDING_TYPE = {
	BuildingType.Vacant: "Vacant",
	BuildingType.ElectrolysisPlant: "Electrolysis Plant",
	BuildingType.FuelRefinery: "Fuel Refinery"
}

export(Dictionary) var BUILDING_COST = {
	BuildingType.Vacant: 0,
	BuildingType.ElectrolysisPlant: 700,
	BuildingType.FuelRefinery: 1000
}

export(Dictionary) var BUILDING_CONSUMES = {
	BuildingType.Vacant: {},
	BuildingType.ElectrolysisPlant: {
		ResourceType.Ice: 1
	},
	BuildingType.FuelRefinery: {
		ResourceType.Hydrogen: 1,
		ResourceType.Oxygen: 1
	}
}

export(Dictionary) var BUILDING_PRODUCES = {
	BuildingType.Vacant: {},
	BuildingType.ElectrolysisPlant: {
		ResourceType.Hydrogen: 2,
		ResourceType.Oxygen: 1
	},
	BuildingType.FuelRefinery: {
		ResourceType.Fuel: 1
	}
}
