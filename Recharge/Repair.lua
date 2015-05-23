
local Repair = {}

local function IsItemAboveConditionThreshold(bagId,slotIndex,minPercent)
	local condition = GetItemCondition(bagId,slotIndex)
	return (condition / 100) > minPercent,condition
end

local function RepairItem(bagId,slotIndex,kits,minPercent)

	local count = #kits 
	
	if count < 1 then return 0 end 
	
	local kit = kits[#kits]
	
	if kit ~= nil then 
	

		local amount = GetAmountRepairKitWouldRepairItem(bagId,slotIndex,kit.bag,kit.index)
		
		local isAbove,condition = IsItemAboveConditionThreshold(bagId,slotIndex,minPercent)
		local oldcondition = condition
		
		if isAbove == true then return 0 end
			
		local link = GetItemLink(bagId,slotIndex,LINK_STYLE_DEFAULT)
	
		RepairItemWithRepairKit(bagId,slotIndex,kit.bag,kit.index)
		
		kit.size = kit.size - 1
		
		if kit.size < 1 then 
			table.remove(kits)
		end 
		
		condition = condition + amount
		
		if condition > 100 then 
			condition = 100
		end
		
		return (condition-oldcondition)
	end 
	
	return 0
end 

local r = Repair

r.RepairItem = RepairItem

Recharge.Repair = r