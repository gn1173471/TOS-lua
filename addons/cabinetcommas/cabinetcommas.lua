function ON_CABINET_ITEM_LIST_HOOKED(frame)
	_G["ON_CABINET_ITEM_LIST_OLD"](frame);
	
	local itemGbox = GET_CHILD(frame, "itemGbox");
	local itemlist = GET_CHILD(itemGbox, "itemlist", "ui::CDetailListBox");
	local cnt = itemlist:GetChildCount();
	
	for i = 0 , cnt - 1 do
		local cabinetItem = session.market.GetCabinetItemByIndex(i);
		local ctrlSet = itemlist:GetChild("DETAIL_ITEM_" .. i .. "_0");
		local totalPrice = ctrlSet:GetChild("totalPrice");
		totalPrice:SetTextByKey("value", GetCommaedText(cabinetItem.count));
	end

end


function ON_MARKET_SELL_LIST_HOOKED(frame, msg, argStr, argNum)
	_G["ON_MARKET_SELL_LIST_OLD"](frame, msg, argStr, argNum);
	
	local itemlist = GET_CHILD(frame, "itemlist", "ui::CDetailListBox");
	local cnt = itemlist:GetChildCount();

	for i = 0 , cnt - 1 do
		local marketItem = session.market.GetItemByIndex(i);
		local ctrlSet = itemlist:GetChild("DETAIL_ITEM_" .. i .. "_0");
		local priceStr = string.format("{img icon_item_silver %d %d}%s", 20, 20, GetCommaedText(marketItem.sellPrice * marketItem.count)) 
		local totalPrice = ctrlSet:GetChild("totalPrice");
		totalPrice:SetTextByKey("value", priceStr);

		local cashValue = GetCashValue(marketItem.premuimState, "marketSellCom") * 0.01;
		local stralue = GetCashValue(marketItem.premuimState, "marketSellCom");
		priceStr = string.format("{img icon_item_silver %d %d}%s [%d%%]", 20, 20, GetCommaedText(marketItem.sellPrice * marketItem.count * cashValue), stralue) 
		local silverFee = ctrlSet:GetChild("silverFee");
		silverFee:SetTextByKey("value", priceStr);
	end
end

SETUP_HOOK(ON_MARKET_SELL_LIST_HOOKED, "ON_MARKET_SELL_LIST");
SETUP_HOOK(ON_CABINET_ITEM_LIST_HOOKED, "ON_CABINET_ITEM_LIST");
