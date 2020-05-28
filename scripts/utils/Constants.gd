extends Node

enum ResourceType {
	Metal
}

# TODO(indutny): generate this automatically
export(Dictionary) var RESOURCE_NAME = {
	ResourceType.Metal: "Metal"
}

export(Dictionary) var RESOURCE_WEIGHT = {
	0: 1
}
