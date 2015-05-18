
local _slots = {EQUIP_SLOT_MAIN_HAND,EQUIP_SLOT_OFF_HAND,EQUIP_SLOT_BACKUP_MAIN,EQUIP_SLOT_BACKUP_OFF}
local _prefix = "[AutoRecharge]: "
local _settings = { rechargeEnabled = true, minChargePercent=0 }

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

local function IsItemAboveThreshold(bagId,slotIndex,minPercent)

	local charge,maxcharge = GetChargeInfoForItem(bagId,slotIndex)
	local isAbove = charge >= maxcharge or (minPercent ~= nil and (charge/maxcharge) > minPercent)
	
	return isAbove,charge,maxcharge
end

local function RechargeItem(bagId,slotIndex,gems,minPercent)
	
	local gem
	
	local recharged = false
	local total = 0
	
	local isAbove,charge,maxcharge = IsItemAboveThreshold(bagId,slotIndex,minPercent)
	
	if isAbove == true then return 0 end

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

local function GetEquipSlotText(slot)
	if slot == EQUIP_SLOT_MAIN_HAND then return "Main Hand"
	elseif slot == EQUIP_SLOT_OFF_HAND then return "Off Hand"
	elseif slot == EQUIP_SLOT_BACKUP_MAIN then return "Backup Main Hand"
	elseif slot == EQUIP_SLOT_BACKUP_OFF then return "Backup Off Hand" 
	end
end

local function RechargeEquipped(silentNothing)

	silentNothing = silentNothing or false 

	local gems = GetSoulGems(BAG_BACKPACK)
	if #gems == 0 then return end
	

	local total = 0 
	
	local str
	
	for i,v in ipairs(_slots) do
		total = RechargeItem(BAG_WORN,v,gems,_settings.minChargePercent)
		if total > 0 then
			str = (str or "Recharged: ")..((str and ", ") or "")..GetEquipSlotText(v).." ("..tostring(round(total,2)).." % filled)"
		end
	end
	
	if str == nil then
		
		local charge,maxcharge,remain
		
		for i,v in ipairs(_slots) do
			
			charge,maxcharge = GetChargeInfoForItem(BAG_WORN,v)
			
			if maxcharge > 0 then 

				remain = (charge / maxcharge) * 100
				
				if silentNothing == false then 
					str = (str or "Recharged nothing: ")..((str and ", ") or "")..GetEquipSlotText(v).." ("..tostring(round(remain,2)).." % remaining)"
				end
				
			end 
		end
		
	end
	
	if str ~= nil then
		d(_prefix..str)
	elseif silentNothing == false then
		d("No rechargeable weapons equipped.")
	end
end

local function Recharge_CombatStateChanged(eventCode, inCombat)
	if _settings.rechargeEnabled == true then
		RechargeEquipped(true)
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

local function Initialise()

	EVENT_MANAGER:RegisterForEvent("Recharge_CombatStateChanged",EVENT_PLAYER_COMBAT_STATE,Recharge_CombatStateChanged)

	SLASH_COMMANDS["/rc"] = function(arg)
		if arg == nil or arg == "" then
			RechargeEquipped()
		else
			local percent = tonumber(arg)
			
			if percent ~= nil and percent >= 0 and percent <= 99 then
				_settings.minChargePercent = (percent == 0 and 0) or (percent / 100)
				d(table.concat({_prefix,"Minimum charge: ",tostring(percent),"%"}))
			elseif percent ~= nil then 
				d(table.concat({_prefix,"Invalid percentage: ",tostring(percent)," range: 0-99."}))
			elseif isOnString(arg) then
				_settings.rechargeEnabled = true
				d(_prefix.."Enabled")
			elseif isOffString(arg) then
				_settings.rechargeEnabled = false
				d(_prefix.."Disabled")
			end
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