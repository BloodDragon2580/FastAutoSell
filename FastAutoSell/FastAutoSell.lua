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
    
    -- Declarations
    local IterationCount, totalPrice = 500, 0
    local SellJunkTicker, mBagID, mBagSlot
    
    -- Create configuration panel
    local SellJunkFrame = SellJunkFrame or CreateFrame("Frame", "SellJunkFrame", UIParent)
    
    -- Function to stop selling
    local function StopSelling()
        if SellJunkTicker then SellJunkTicker:Cancel() end
        StartMsg:Hide()
        SellJunkFrame:UnregisterEvent("ITEM_LOCKED")
        SellJunkFrame:UnregisterEvent("ITEM_UNLOCKED")
    end
    
    -- Vendor function
    local function SellJunkFunc()
        
        -- Variables
        local SoldCount, Rarity, ItemPrice = 0, 0, 0
        local CurrentItemLink, void
        
        -- Traverse bags and sell grey items
        for BagID = 0, 4 do
            for BagSlot = 1, GetContainerNumSlots(BagID) do
                CurrentItemLink = GetContainerItemLink(BagID, BagSlot)
                if CurrentItemLink then
                    void, void, Rarity, void, void, void, void, void, void, void, ItemPrice = GetItemInfo(CurrentItemLink)
                    local void, itemCount = GetContainerItemInfo(BagID, BagSlot)
                    if Rarity == 0 and ItemPrice ~= 0 then
                        SoldCount = SoldCount + 1
                        if MerchantFrame:IsShown() then
                            -- If merchant frame is open, vendor the item
                            UseContainerItem(BagID, BagSlot)
                            -- Perform actions on first iteration
                            if SellJunkTicker._remainingIterations == IterationCount then
                                -- Calculate total price
                                totalPrice = totalPrice + (ItemPrice * itemCount)
                                -- Store first sold bag slot for analysis
                                if SoldCount == 1 then
                                    mBagID, mBagSlot = BagID, BagSlot
                                end
                            end
                        else
                            -- If merchant frame is not open, stop selling
                            StopSelling()
                            return
                        end
                    end
                end
            end
        end
        
        -- Stop selling if no items were sold for this iteration or iteration limit was reached
        if SoldCount == 0 or SellJunkTicker and SellJunkTicker._remainingIterations == 1 then 
            StopSelling()
        end
    end
    
    -- Function to setup events
    local function SetupEvents()
        SellJunkFrame:RegisterEvent("MERCHANT_SHOW");
        SellJunkFrame:RegisterEvent("MERCHANT_CLOSED");
    end
    
    SetupEvents()
    
    -- Event handler
    SellJunkFrame:SetScript("OnEvent", function(self, event)
            if event == "MERCHANT_SHOW" then
                -- Reset variables
                totalPrice, mBagID, mBagSlot = 0, -1, -1
                -- Do nothing if shift key is held down
                if IsShiftKeyDown() then return end
                -- Cancel existing ticker if present
                if SellJunkTicker then SellJunkTicker:Cancel() end
                -- Sell grey items using ticker (ends when all grey items are sold or iteration count reached)
                SellJunkTicker = C_Timer.NewTicker(0.2, SellJunkFunc, IterationCount)
                SellJunkFrame:RegisterEvent("ITEM_LOCKED")
                SellJunkFrame:RegisterEvent("ITEM_UNLOCKED")
            elseif event == "ITEM_LOCKED" then
                StartMsg:Show()
                SellJunkFrame:UnregisterEvent("ITEM_LOCKED")
            elseif event == "ITEM_UNLOCKED" then
                SellJunkFrame:UnregisterEvent("ITEM_UNLOCKED")
                -- Check whether vendor refuses to buy items
                if mBagID and mBagSlot and mBagID ~= -1 and mBagSlot ~= -1 then
                    local texture, count, locked = GetContainerItemInfo(mBagID, mBagSlot)
                    if count and not locked then
                        -- Item has been unlocked but still not sold so stop selling
                        StopSelling()
                    end
                end
            elseif event == "MERCHANT_CLOSED" then
                -- If merchant frame is closed, stop selling
                StopSelling()
            end
    end)
    
end