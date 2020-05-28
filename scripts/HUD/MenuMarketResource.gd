extends HBoxContainer

var resource: MarketResource
var price: float

func set_resource(res: MarketResource, max_quantity: int, price_: float):
	resource = res
	price = price_
	
	$Name.text = Constants.RESOURCE_NAME[resource.resource_type]
	$MaxQuantity.text = str(max_quantity)
	$Price.text = str(price)
	$SellCount.max_value = max_quantity

func _on_All_pressed():
	$SellCount.value = $SellCount.max_value

func get_quantity():
	return $SellCount.value
