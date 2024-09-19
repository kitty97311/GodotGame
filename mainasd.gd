extends Control

@onready var itemList = [
	{"name":"demon","sku":"idlesuccessmanager_superoffer1","btnNode":$fl_demon},
	{"name":"cerberus","sku":"idlesuccessmanager_newmanager","btnNode":$fl_cerberus},
	{"name":"GOLD","sku":"idlesuccessmanager_newgems6","btnNode":$Label}
]

var purchasedItemList = []
signal skuOK
var test
var payment
var playerTotalGold = 0

func _ready():
	if Engine.has_singleton("GodotGooglePlayBilling"):
		payment = Engine.get_singleton("GodotGooglePlayBilling")
		payment.connected.connect(_on_connected)
		payment.sku_details_query_completed.connect(_on_detailQueryCompleted) 
		payment.purchases_updated.connect(_onPurchaseUpdate) # Purchases (Dictionary[])
		payment.query_purchases_response.connect(_purchasedItems) 
		payment.startConnection()
		$ColorRect.visible = true

func _process(delta):
	$Label.text = str(playerTotalGold)

func _on_connected():
	$ColorRect.visible = false
	payment.queryPurchases("inapp")

func _on_detailQueryCompleted(product_details):
	test = product_details
	skuOK.emit()

func _onPurchaseUpdate(purchase):
	payment.queryPurchases("inapp")

func _purchasedItems(query_result):
	if query_result.status == OK:
		for purchaseItem in query_result.purchases:
			var sku = purchaseItem.skus[0]
			var quantity = purchaseItem.quantity
			if sku == "idlesuccessmanager_superoffer1":
				playerTotalGold += 500 * quantity
				payment.consumePurchase(purchaseItem.purchase_token)
			elif sku == "idlesuccessmanager_newmanager":
				playerTotalGold += 1500 * quantity
				payment.consumePurchase(purchaseItem.purchase_token)
			elif sku == "idlesuccessmanager_newgems6":
				playerTotalGold += 15500 * quantity
				payment.consumePurchase(purchaseItem.purchase_token)
			else:
				if !purchasedItemList.has(sku):
					purchasedItemList.append(sku)
				payment.acknowledgePurchase(purchaseItem.purchase_token)

func _on_PurchaseButton(itemIndex):
	var mySKU = "idlesuccessmanager_superoffer1" #itemList[int(itemIndex)].sku
	payment.querySkuDetails([mySKU], "inapp")
	await skuOK
	payment.purchase(mySKU)

func _on_fl_cerberus_pressed():
	var mySKU = "idlesuccessmanager_newmanager" #itemList[int(itemIndex)].sku
	payment.querySkuDetails([mySKU], "inapp")
	await skuOK
	payment.purchase(mySKU)

func _on_fl_cerberus_2_pressed():
	var mySKU = "idlesuccessmanager_newgems6" #itemList[int(itemIndex)].sku
	payment.querySkuDetails([mySKU], "inapp")
	await skuOK
	payment.purchase(mySKU)
