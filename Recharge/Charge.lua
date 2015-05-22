
local Bag = Recharge.Bag
local ItemsData = Recharge.ItemsData
local Charge = {}

local function IsItemAboveThreshold(bagId,slotIndex,minPercent)

	local charge,maxcharge = GetChargeInfoForItem(bagId,slotIndex)
	local isAbove = charge >= maxcharge or (minPercent ~= nil and (charge/maxcharge) > minPercent)
	
	return isAbove,charge,maxcharge
end

local function IsItemChargable(bagId,slotIndex)
	return not ItemsData.IsMasterWeapon(bagId,slotIndex)
end 

local function ChargeItem(bagId,slotIndex,gems,minPercent)
	
	local gem
	
	local recharged = false
	local total = 0
	
	local isAbove,charge,maxcharge = IsItemAboveThreshold(bagId,slotIndex,minPercent)
	
	if isAbove == true or IsItemChargable(bagId,slotIndex) == false then return 0 end
	
	local oldcharge = charge
		
	if gem == nil then
		gem = gems[#gems]
	end

	if gem ~= nil then

		local amount = GetAmountSoulGemWouldChargeItem(bagId,slotIndex,gem.bag,gem.index)
		
		ChargeItemWithSoulGem(bagId,slotIndex,gem.bag,gem.index)
		
		gem.size = gem.size - 1 
		
		if gem.size < 1 then
			table.remove(gems)
		end
		
		if (charge + amount) < maxcharge then
			charge = charge + amount
		else
			charge = maxcharge
		end
		
	end
	
	return ((charge - oldcharge) / maxcharge) * 100
end

local c = Charge

c.ChargeItem = ChargeItem

Recharge.Charge = c