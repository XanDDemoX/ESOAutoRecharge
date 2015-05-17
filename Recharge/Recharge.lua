-----------------------------------
--  Auto Recharge Version 0.0.3  --
-----------------------------------
local _repairSlots = {EQUIP_SLOT_HEAD,EQUIP_SLOT_SHOULDERS, EQUIP_SLOT_CHEST,EQUIP_SLOT_WAIST, EQUIP_SLOT_LEGS,EQUIP_SLOT_HAND, EQUIP_SLOT_FEET}
local _rechargeSlots = {EQUIP_SLOT_MAIN_HAND,EQUIP_SLOT_OFF_HAND,EQUIP_SLOT_BACKUP_MAIN,EQUIP_SLOT_BACKUP_OFF}
local _prefix = "[AutoRecharge]: "
local _settings = { rechargeEnabled = true, rechargeMinPercent = 0, repairEnabled = true, repairMinPercent = 0}

local function round(value,places)
	local s =  10 ^ places
	return math.floor(value * s + 0.5) / s
end

local function GetBagItems(bagId,func)
	local size = GetNumBagUsedSlots(bagId)
	
	local tbl = {}
	
	local v
	
	for i =1, size do
	
		v = func(i)
		
		if v ~= nil then 
			table.insert(tbl,v)
		end
	
	end
	
	return tbl
end

local function GetSoulGems(bagId)
	
	local tbl = GetBagItems(bagId,function(i)
	
		if IsItemSoulGem(SOUL_GEM_TYPE_FILLED,bagId,i) == true then
			return {
				bag=bagId,
				index =i, 
				tier=GetSoulGemItemInfo(bagId,i),
				size=GetItemTotalCount(bagId,i)
			}
		end
		
	end)
	
	table.sort(tbl,function(x,y)
		return x.tier > y.tier
	end)
	
	return tbl
end

local function GetRepairKits(bagId)
	local tbl = GetBagItems(bagId,function(i)
		if IsItemRepairKit(bagId,i) == true then 
			return {
				bag = bagId,
				index = i,
				tier = GetRepairKitTier(bagId,i),
				size = GetItemTotalCount(bagId,i)
			}
		end 
	end)
	
	table.sort(tbl,function(x,y)
		return x.tier > y.tier
	end)
	
	return tbl
end 

local function IsItemAboveConditionThreshold(bagId,slotIndex,minPercent)
	local condition = GetItemCondition(bagId,slotIndex) 
	return condition > minPercent,(condition > 0 and (condition/100)) or 0 
end

local function RepairItem(bagId,slotIndex,kits,minPercent)
--
	local isAbove,condition = IsItemAboveConditionThreshold(bagId,slotIndex,minPercent)
	
	if isAbove == true then return 0 end
	
	local oldcondition = condition
	
	local kit = kits[#kits]
	
	if kit ~= nil then 
		
		local link = GetItemLink(bagId,slotIndex,LINK_STYLE_DEFAULT)

		local rating = GetItemLinkArmorRating(link,false)
	
		local amount = GetAmountRepairKitWouldRepairItem(bagId,slotIndex,kit.bag,kit.index)
		
		RepairItemWithRepairKit(bagId,slotIndex,kit.bag,kit.index)
		
		kit.size = kit.size - 10
		
		if kit.size < 1 then 
			table.remove(kits)
		end 
		
		if ((condition*rating) + amount) < rating then 
			condition = condition + (amount/rating)	
		else
			condition = 1
		end
		
	end 
	
	return (condition-oldcondition) * 100
end 

local function IsItemAboveChargeThreshold(bagId,slotIndex,minPercent)

	local charge,maxcharge = GetChargeInfoForItem(bagId,slotIndex)
	local isAbove = charge >= maxcharge or (minPercent ~= nil and (charge/maxcharge) > minPercent)
	
	return isAbove,charge,maxcharge
end

local function RechargeItem(bagId,slotIndex,gems,minPercent)
		
	local isAbove,charge,maxcharge = IsItemAboveChargeThreshold(bagId,slotIndex,minPercent)

	if isAbove == true then return 0 end

	local oldcharge = charge
	
	local gem = gems[#gems]

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

local function GetEquipSlotText(slot)
	if slot == EQUIP_SLOT_MAIN_HAND then return "Main Hand"
	elseif slot == EQUIP_SLOT_OFF_HAND then return "Off Hand"
	elseif slot == EQUIP_SLOT_BACKUP_MAIN then return "Backup Main Hand"
	elseif slot == EQUIP_SLOT_BACKUP_OFF then return "Backup Off Hand" 
	end
end


local function RepairRechargeEquipped(sltos,getItems,repairRecharge,text)

	local items = getItems()
	if #items == 0 then return end 
	
	local total = 0 
	local str 
	
	for i,v in ipairs(slots) do 
	
		total = repairRecharge(v,kits)
		
		if total > 0 then 
			str = (str or text..": ")..((str and ", ") or "")..GetEquipSlotText(v).." ("..tostring(round(total,2)).." %)"
		end 
	
	end 
	
	if str ~= nil then
		d(_prefix..str)
	end
end 

local function RepairEquipped()
	RepairRechargeEquipped(_repairSlots,
							function() return GetRepairKits(BAG_BACKPACK) end,
							function(v,kits) return RepairItem(BAG_WORN,v,kits,_settings.repairMinPercent) end,
							"Repaired")
end 

local function RechargeEquipped()
	RepairRechargeEquipped(_rechargeSlots,
							function() return GetSoulGems(BAG_BACKPACK) end,
							function(v,gems) return RechargeItem(BAG_WORN,v,gems,_settings.rechargeMinPercent) end,
							"Recharged")

end 

local function Recharge_CombatStateChanged(eventCode, inCombat)
	if _settings.repairEnabled == true then 
		RepairEquipped()
	end 
	if _settings.rechargeEnabled == true then
		RechargeEquipped()
	end
end

local function isOnString(str)
	str = string.lower(str)
	return str == "+" or str == "on"
end

local function isOffString(str)
	str = string.lower(str)
	return str == "-" or str == "off"
end

local function GetBoolValue(arg)
	if arg == nil or arg == "" then return nil end 
	if isOnString(arg) then return true end 
	if isOffString(arg) then return false end
	return nil
end 

local function Initialise()

	EVENT_MANAGER:RegisterForEvent("Recharge_CombatStateChanged",EVENT_PLAYER_COMBAT_STATE,Recharge_CombatStateChanged)

	SLASH_COMMANDS["/rc"] = function(arg)
		local value = GetBoolValue(arg)
		if value ~= nil then 
			_settings.rechargeEnabled = value
			d(_prefix, (value == true and "Charging Enabled") or "Charging Disabled")
		end 
	end
	
	SLASH_COMMANDS["/rp"] = function(arg)
		local value = GetBoolValue(arg)
		if value ~= nil then 
			_settings.repairEnabled = value
			d(_prefix, (value == true and "Repairing Enabled") or "Repairing Disabled")
		else
			d(IsItemAboveConditionThreshold(BAG_WORN,EQUIP_SLOT_HEAD,0))
		end 
	end 

end

local function Recharge_Loaded(eventCode, addOnName)

	if(addOnName ~= "Recharge") then
        return
    end
	
	_settings = ZO_SavedVars:New("AutoRecharge_SavedVariables", "1", "", _settings, nil)
	
	Initialise()
	
end

EVENT_MANAGER:RegisterForEvent("Recharge_Loaded", EVENT_ADD_ON_LOADED, Recharge_Loaded)