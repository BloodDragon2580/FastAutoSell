local StartMsg = CreateFrame("FRAME", nil, MerchantFrame)
    StartMsg:ClearAllPoints()
    StartMsg:SetPoint("BOTTOMLEFT", 4, 4)
    StartMsg:SetSize(160, 22)
    StartMsg:SetToplevel(true)
    StartMsg:Hide()
    
    StartMsg.s = StartMsg:CreateTexture(nil, "BACKGROUND")
    StartMsg.s:SetAllPoints()
    StartMsg.s:SetColorTexture(0.1, 0.1, 0.1, 1.0)
    
    StartMsg.f = StartMsg:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge") 
    StartMsg.f:SetAllPoints();
    StartMsg.f:SetText("SELLING JUNK")
    
    local IterationCount, totalPrice = 500, 0
    local SellJunkTicker, mBagID, mBagSlot
    
    local SellJunkFrame = SellJunkFrame or CreateFrame("Frame", "SellJunkFrame", UIParent)
    
    local function StopSelling()
        if SellJunkTicker then SellJunkTicker:Cancel() end
        StartMsg:Hide()
        SellJunkFrame:UnregisterEvent("ITEM_LOCKED")
        SellJunkFrame:UnregisterEvent("ITEM_UNLOCKED")
    end
    
    local function SellJunkFunc()
        
        local SoldCount, Rarity, ItemPrice = 0, 0, 0
        local CurrentItemLink, void
        
        for BagID = 0, 5 do
            for BagSlot = 1, C_Container.GetContainerNumSlots(BagID) do
                CurrentItemLink = C_Container.GetContainerItemLink(BagID, BagSlot)
                if CurrentItemLink then
                    void, void, Rarity, void, void, void, void, void, void, void, ItemPrice = GetItemInfo(CurrentItemLink)
                    local void, itemCount = C_Container.GetContainerItemInfo(BagID, BagSlot)
                    if Rarity == 0 and ItemPrice ~= 0 then
                        SoldCount = SoldCount + 1
                        if MerchantFrame:IsShown() then
                            C_Container.UseContainerItem(BagID, BagSlot)
                            if SellJunkTicker._remainingIterations == IterationCount then
                                totalPrice = totalPrice + (ItemPrice * itemCount)
                                if SoldCount == 1 then
                                    mBagID, mBagSlot = BagID, BagSlot
                                end
                            end
                        else
                            StopSelling()
                            return
                        end
                    end
                end
            end
        end
        
        if SoldCount == 0 or SellJunkTicker and SellJunkTicker._remainingIterations == 1 then 
            StopSelling()
        end
    end
    
    local function SetupEvents()
        SellJunkFrame:RegisterEvent("MERCHANT_SHOW");
        SellJunkFrame:RegisterEvent("MERCHANT_CLOSED");
    end
    
    SetupEvents()
    
    SellJunkFrame:SetScript("OnEvent", function(self, event)
            if event == "MERCHANT_SHOW" then
                totalPrice, mBagID, mBagSlot = 0, -1, -1
                if IsShiftKeyDown() then return end
                if SellJunkTicker then SellJunkTicker:Cancel() end
                SellJunkTicker = C_Timer.NewTicker(0.2, SellJunkFunc, IterationCount)
                SellJunkFrame:RegisterEvent("ITEM_LOCKED")
                SellJunkFrame:RegisterEvent("ITEM_UNLOCKED")
            elseif event == "ITEM_LOCKED" then
                StartMsg:Show()
                SellJunkFrame:UnregisterEvent("ITEM_LOCKED")
            elseif event == "ITEM_UNLOCKED" then
                SellJunkFrame:UnregisterEvent("ITEM_UNLOCKED")
                if mBagID and mBagSlot and mBagID ~= -1 and mBagSlot ~= -1 then
                    local texture, count, locked = GetContainerItemInfo(mBagID, mBagSlot)
                    if count and not locked then
                        StopSelling()
                    end
                end
            elseif event == "MERCHANT_CLOSED" then
                StopSelling()
            end
    end)