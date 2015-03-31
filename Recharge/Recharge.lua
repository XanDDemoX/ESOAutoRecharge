-----------------------------------
--  Auto Recharge Version 0.0.1  --
-----------------------------------

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

local function RechargeItem(bagId,slotIndex,gems,minPercent)
	
	local gem
	
	local recharged = false
	local total = 0
	
	local charge,maxcharge = GetChargeInfoForItem(bagId,slotIndex)

	if charge >= maxcharge or (minPercent ~= nil and (charge/maxcharge) >= minPercent) then return 0 end

	local oldcharge = charge
	
	repeat 
	
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
				break
			end
			
		end

	until gem == nil or charge >= maxcharge
	
	return ((charge - oldcharge) / maxcharge) * 100
end

local function GetEquipSlotText(slot)
	if slot == EQUIP_SLOT_MAIN_HAND then return "Main Hand"
	elseif slot == EQUIP_SLOT_OFF_HAND then return "Off Hand"
	elseif slot == EQUIP_SLOT_BACKUP_MAIN then return "Main Hand - Backup"
	elseif slot == EQUIP_SLOT_BACKUP_OFF then return "Off Hand - Backup" 
	end
end

local function RechargeEquipped()

	local gems = GetSoulGems(BAG_BACKPACK)
	if #gems == 0 then return end
	
	local slots = {EQUIP_SLOT_MAIN_HAND,EQUIP_SLOT_OFF_HAND,EQUIP_SLOT_BACKUP_MAIN,EQUIP_SLOT_BACKUP_OFF}
	
	local total = 0 
	
	local str
	
	for i,v in ipairs(slots) do
		total = RechargeItem(BAG_WORN,v,gems,0)
		if total > 0 then
			str = (str or "Recharged: ")..((str and ", ") or "")..GetEquipSlotText(v).." ("..tostring(round(total,2)).." % filled)"
		end
	end
	
	if str == nil then
		
		local charge,maxcharge,remain
		
		for i,v in ipairs(slots) do
			
			charge,maxcharge = GetChargeInfoForItem(BAG_WORN,v)
			
			if maxcharge > 0 then 

				remain = (charge / maxcharge) * 100
				
				str = (str or "Recharged nothing: ")..((str and ", ") or "")..GetEquipSlotText(v).." ("..tostring(round(remain,2)).." % remaining)"
				
			end 
		end
		
	end
	
	if str ~= nil then
		d(str)
	else
		d("No rechargeable weapons equipped.")
	end
end


local function Initialise()

	SLASH_COMMANDS["/rc"] = function()
		RechargeEquipped()
	end

end

local function Recharge_Loaded(eventCode, addOnName)

	if(addOnName ~= "Recharge") then
        return
    end
	
	Initialise()
	
end

EVENT_MANAGER:RegisterForEvent("Recharge_Loaded", EVENT_ADD_ON_LOADED, Recharge_Loaded)