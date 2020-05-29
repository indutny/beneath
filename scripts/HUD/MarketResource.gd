extends HBoxContainer

var resource_type
var price: float

func set_resource_type(resource_type_):
	resource_type = resource_type_
	$Name.text = Constants.RESOURCE_NAME[resource_type]

func reset():
	$SellCount.value = 0

func configure(max_quantity: int, price_: float):
	price = price_
	
	$MaxQuantity.text = str(max_quantity)
	$Price.text = str(price)
	$SellCount.max_value = max_quantity

func _on_All_pressed():
	$SellCount.value = $SellCount.max_value

func get_quantity():
	return $SellCount.value

func get_price():
	return price
