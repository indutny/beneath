extends Node
class_name MarketResource

export(Constants.ResourceType) var resource_type = Constants.ResourceType.Metal
export(float,0,1000) var buy_price = 1
export(float,0,1000) var sell_price = 1
export(int,0,1000) var quantity = 0
export(int,0,10000) var capacity = 1000
