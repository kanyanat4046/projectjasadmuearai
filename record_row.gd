extends HBoxContainer
func set_data(date, desc, price, vatshow, total):
	$DateLabel.text = date
	$DescriptionLabel.text = desc
	$PriceLabel.text = str(price)
	$VATLabel.text = str(vatshow)
	$TotalLabel.text = str(total)
