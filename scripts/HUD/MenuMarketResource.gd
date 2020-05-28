extends HBoxContainer

var resource: MarketResource
var price: float
var quantity: int = 0
var max_quantity: int = 0
var digits = RegEx.new()

func _ready():
	digits.compile("[^0-9]+")

func set_resource(res: MarketResource, max_quantity_: int, price_: float):
	resource = res
	price = price_
	max_quantity = max_quantity_
	
	$Name.text = Constants.RESOURCE_NAME[resource.resource_type]
	$MaxQuantity.text = str(max_quantity)
	$Price.text = str(price)

func change_quantity(delta: int):
	set_quantity(quantity + delta)

func set_quantity(new_value: int):
	quantity = convert(clamp(new_value, 0, max_quantity), TYPE_INT)
	$SellCount.text = str(quantity)

func _on_All_pressed():
	set_quantity(max_quantity)

func _on_SellCount_text_changed(new_text):
	var sanitized = digits.sub(new_text, "", true)
	set_quantity(sanitized.to_int())
