extends Node

enum ResourceType {
	Metal
}

export(Dictionary) var RESOURCE_NAME = {
	ResourceType.Metal: "Metal"
}

export(Dictionary) var RESOURCE_WEIGHT = {
	ResourceType.Metal: 1
}
