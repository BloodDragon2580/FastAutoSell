local L = LibStub("AceLocale-3.0"):GetLocale("FastAutoSell", false)

local function OnEvent(self, event)
	totalPrice = 0	
	for myBags = 0,4 do
		for bagSlots = 1, C_Container.GetContainerNumSlots(myBags) do
			CurrentItemLink = C_Container.GetContainerItemLink(myBags, bagSlots)
			if CurrentItemLink then
				_, _, itemRarity, _, _, _, _, _, _, _, itemSellPrice = GetItemInfo(CurrentItemLink)
				itemInfo = C_Container.GetContainerItemInfo(myBags, bagSlots)
				if itemRarity == 0 and itemSellPrice ~= 0 then
					totalPrice = totalPrice + (itemSellPrice * itemInfo.stackCount)
					C_Container.UseContainerItem(myBags, bagSlots)
					PickupMerchantItem()
				end
			end
		end
	end
	if totalPrice ~= 0 then
		DEFAULT_CHAT_FRAME:AddMessage(L["FastAutoSell"]..GetCoinTextureString(totalPrice), 255, 255, 255)
	end
end


local f = CreateFrame("Frame")
f:SetScript("OnEvent", OnEvent);
f:RegisterEvent("MERCHANT_SHOW");
