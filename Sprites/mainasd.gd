extends Control

@onready var itemList = [
	{"name":"demon","sku":"fl_demon","btnNode":$fl_demon},
	{"name":"cerberus","sku":"wtfbro","btnNode":$fl_cerberus},
	{"name":"GOLD","sku":"golditem","btnNode":$Label}
]

var purchasedItemList = []

signal skuOK

var test

var payment

var playerTotalGold = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.has_singleton("GodotGooglePlayBilling"):
		payment = Engine.get_singleton("GodotGooglePlayBilling")
		payment.connected.connect(_on_connected)
		payment.disconnected.connect(_on_disconnected)
		
		payment.sku_details_query_completed.connect(_on_detailQueryCompleted) 
		payment.sku_details_query_error.connect(_on_detailQueryFailed) 
		
		payment.purchases_updated.connect(_onPurchaseUpdate) # Purchases (Dictionary[])
		payment.purchase_error.connect(_onPurchaseError)
		
		payment.query_purchases_response.connect(_purchasedItems) 
		
		payment.startConnection()
		$ColorRect.visible = true
	pass # Replace with function body.


func _on_connected():
	$ColorRect.visible = false
	#payment.querySkuDetails([], "inapp")
	#payment.querySkuDetails(["flcerberus"], "inapp")
	#payment.querySkuDetails(["fl_cerberusx"], "inapp")
	#payment.querySkuDetails(["anotherrandomitem"], "inapp")
	#payment.querySkuDetails(["fl_dog"], "inapp")
	#payment.querySkuDetails(["flcerberus"], "inapp")
	#SKU DETAIL NEEDS TO BE QUERY-ED BEFORE CAN BE USED
	
	payment.queryPurchases("inapp")
	#Check all purchased Items Result = query_purchases_response


func _on_disconnected():
	print("PAYMENT DISCONNECTED")
	

func _on_detailQueryCompleted(product_details):
	test = product_details
	print(product_details," IS THE SKU DETAIL")
	print("skuDetailOK")
	skuOK.emit()
	
	pass

func _on_detailQueryFailed(response_id, error_message, products_queried):
	var newStr= "on_product_details_query_error id:"+str(response_id)+" message: "+str(error_message)+ " products: "+str(products_queried)
	print(newStr)

func _onPurchaseUpdate(purchase):
	print("------BUYING--------")
	payment.queryPurchases("inapp")
	
func _onPurchaseError(response_id, error_message):
	print("FAILED")


func _purchasedItems(query_result):
	#print(query_result)
	test = query_result
	print("------BOUGHT ITEMS--------")
	if query_result.status == OK:
		print("------ OK --------")
		for purchaseItem in query_result.purchases:
			print("----- ",purchaseItem.skus[0])
			print(purchaseItem)
			if purchaseItem.skus[0] == "golditem":
				playerTotalGold += 500*purchaseItem.quantity
				payment.consumePurchase(purchaseItem.purchase_token)
				
			elif !purchasedItemList.has(purchaseItem.skus[0]):
				purchasedItemList.append(purchaseItem.skus[0])
				payment.acknowledgePurchase(purchaseItem.purchase_token)
		
	else:
		print("------ ERROR --------")
		var newstr = str("queryPurchases failed, response code: ",
				query_result.response_code,
				" debug message: ", query_result.debug_message)
		print(str(newstr))
	_updateButtons()


func _updateButtons():
	for i in get_tree().get_nodes_in_group("InAppItem"):
		i.disabled = false
	
	for i in itemList:
		if purchasedItemList.has(i.sku):
			#i.btnNode.disabled = true
			pass
	$Label.text = "Gold : "+str(playerTotalGold)
	
	


func _on_PurchaseButton(itemIndex):
	var mySKU = itemList[int(itemIndex)]
	mySKU = mySKU.sku
	payment.querySkuDetails([mySKU], "inapp")
	await skuOK
	print("skuDetail Received")
	payment.purchase(mySKU)
	print("BUYING : ",mySKU)
	pass # Replace with function body.
