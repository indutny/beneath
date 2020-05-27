extends HBoxContainer

var resource_type
var resource_price
var quantity = 0
var max_quantity = 0
var digits = RegEx.new()

func _ready():
	digits.compile("[^0-9]+")

func set_resource(type, count, price):
	resource_type = type
	resource_price = price
	
	$Name.text = Constants.RESOURCE_NAME[resource_type]
	$Count.text = str(count)
	$Price.text = str(resource_price)
	max_quantity = count


func change_quantity(delta):
	set_quantity(quantity + delta)

func set_quantity(new_value):
	quantity = clamp(new_value, 0, max_quantity)
	$SellCount.text = str(quantity)


func _on_All_pressed():
	set_quantity(max_quantity)

func _on_SellCount_text_changed(new_text):
	var sanitized = digits.sub(new_text, "", true)
	set_quantity(sanitized.to_int())
