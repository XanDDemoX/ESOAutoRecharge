
local Repair = {}

local function IsItemAboveConditionThreshold(bagId,slotIndex,minPercent)
	local condition = GetItemCondition(bagId,slotIndex) 
	return condition > minPercent,(condition > 0 and (condition/100)) or 0 
end

local function RepairItem(bagId,slotIndex,kits)

	local count = #kits 
	
	if count < 1 then return 0 end 
	
	local kit = kits[#kits]
	
	if kit ~= nil then 
	
		local oldcondition = condition
		
		local amount = GetAmountRepairKitWouldRepairItem(bagId,slotIndex,kit.bag,kit.index)
				
		local minPercent = 1-amount
		
		local isAbove,condition = IsItemAboveConditionThreshold(bagId,slotIndex,minPercent)
		
		if isAbove == true then return 0 end
			
		local link = GetItemLink(bagId,slotIndex,LINK_STYLE_DEFAULT)

		local rating = GetItemLinkArmorRating(link,false)
	
		RepairItemWithRepairKit(bagId,slotIndex,kit.bag,kit.index)
		
		kit.size = kit.size - 1
		
		if kit.size < 1 then 
			table.remove(kits)
		end 
		
		if ((condition*rating) + amount) < rating then 
			condition = condition + (amount/rating)	
		else
			condition = 1
		end
		
		return (condition-oldcondition) * 100
	end 
	
	return 0
end 

local r = Repair

r.RepairItem = RepairItem

Recharge.Repair = r