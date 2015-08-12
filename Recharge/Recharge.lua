
Recharge = {}

local _repairSlots = {EQUIP_SLOT_OFF_HAND,EQUIP_SLOT_BACKUP_OFF, EQUIP_SLOT_HEAD, EQUIP_SLOT_SHOULDERS, EQUIP_SLOT_CHEST,EQUIP_SLOT_WAIST, EQUIP_SLOT_LEGS,EQUIP_SLOT_HAND, EQUIP_SLOT_FEET}
local _rechargeSlots = {EQUIP_SLOT_MAIN_HAND,EQUIP_SLOT_OFF_HAND,EQUIP_SLOT_BACKUP_MAIN,EQUIP_SLOT_BACKUP_OFF}

local _slotText = { 
	[EQUIP_SLOT_MAIN_HAND] = "Main Hand",
	[EQUIP_SLOT_OFF_HAND] = "Off Hand",
	[EQUIP_SLOT_BACKUP_MAIN] = "Backup Main Hand",
	[EQUIP_SLOT_BACKUP_OFF] = "Backup Off Hand" ,
	[EQUIP_SLOT_HEAD] = "Head",
	[EQUIP_SLOT_SHOULDERS] = "Shoulders",
	[EQUIP_SLOT_CHEST] = "Chest",
	[EQUIP_SLOT_WAIST] = "Waist",
	[EQUIP_SLOT_LEGS] = "Legs",
	[EQUIP_SLOT_HAND] = "Hands",
	[EQUIP_SLOT_FEET] = "Feet"
 }

local _prefix = "[AutoRecharge]: "
local _settings = { chargeEnabled = true, repairEnabled = true, minChargePercent=0, minConditionPercent=0 }

local function round(value,places)
	local s =  10 ^ places
	return math.floor(value * s + 0.5) / s
end

local function trim(str)
	if str == nil or str == "" then return str end 
	return (str:gsub("^%s*(.-)%s*$", "%1"))
end 

local function GetEquipSlotText(slot)
	return _slotText[slot]
end

local function println(...)
	local args = {...}
	for i,v in ipairs(args) do 
		args[i] = tostring(v)
	end 
	table.insert(args,1,_prefix)
	d(table.concat(args))
end

local function ChargeEquipped(silentNothing)

	silentNothing = silentNothing or false 

	local gems = Recharge.Bag.GetSoulGems(BAG_BACKPACK)

	if #gems == 0 then 
		if silentNothing == false then println("Soul gems empty.") end 
		return 
	end
	

	local total = 0 
	
	local str
	
	for i,slot in ipairs(_rechargeSlots) do

		total = Recharge.Charge.ChargeItem(BAG_WORN,slot,gems,_settings.minChargePercent)
		
		if total > 0 then
			str = (str or "Charged: ")..((str and ", ") or "")..GetEquipSlotText(slot).." ("..tostring(round(total,2)).." %)"
		end

	end
	
	if str == nil and silentNothing == false then
		
		local charge,maxcharge
		
		for i,slot in ipairs(_rechargeSlots) do
			
			charge,maxcharge = GetChargeInfoForItem(BAG_WORN,slot)
			
			if maxcharge > 0 then 
				str = (str or "Charged nothing: ")..((str and ", ") or "")..GetEquipSlotText(slot).." ("..tostring(round((charge / maxcharge) * 100,2)).." %)"
			end 
		end
		
	end
	
	if str ~= nil then
		println(str)
	elseif silentNothing == false then
		println("No chargeable weapons equipped.")
	end
end


local function RepairEquipped(silentNothing)
	silentNothing = silentNothing or false 
	
	local kits = Recharge.Bag.GetRepairKits(BAG_BACKPACK)
	if #kits == 0 then
		if silentNothing == false then println("Repair kits empty.") end 
		return
	end 
	
	local total = 0 
	
	local str
	
	for i,slot in ipairs(_repairSlots) do

		total = Recharge.Repair.RepairItem(BAG_WORN,slot,kits, _settings.minConditionPercent)
		
		if total > 0 then
			str = (str or "Repaired: ")..((str and ", ") or "")..GetEquipSlotText(slot).." ("..tostring(round(total,2)).." %)"
		end
		
	end
	
	if str == nil and silentNothing == false then
		
		local condition 
	
		for i,slot in ipairs(_repairSlots) do
			condition = GetItemCondition(BAG_WORN,slot) 
			str = (str or "Repaired nothing: ")..((str and ", ") or "")..GetEquipSlotText(slot).." ("..tostring(round(condition,2)).." %)"
		end 
	end 
	
	if str ~= nil then
		println(str)
	end
end

local function IsPlayerDead()
	return IsUnitDead("player")
end

local function Recharge_CombatStateChanged(eventCode, inCombat)
	if IsPlayerDead() == true then return end
	
	if _settings.chargeEnabled == true then
		ChargeEquipped(true)
	end
	
	if _settings.repairEnabled == true then
		RepairEquipped(true)
	end
	
end

local function TryParseOnOff(str)
	local on = (str == "+" or str == "on")
	local off = (str == "-" or str == "off")
	if on == false and off == false then return nil end
	return on
end

local function TryParsePercent(str)
	local percent = tonumber(str)
	if percent ~= nil and percent >= 0 and percent <= 100 then return (percent / 100) end
	return nil
end

-- >> Baertram
--Build the addon's LAM 2.0 settings menu
--Create the settings panel object of libAddonMenu 2.0
local LAM 		 = LibStub('LibAddonMenu-2.0')
local function BuildAddonMenu()

	local panelData = {
		type 				= 'panel',
		name 				= 'Auto Recharge',
		displayName 		= 'Auto Recharge',
		author 				= 'XanDDemoX',
		version 			= '2.0.4',
		registerForRefresh 	= true,
		registerForDefaults = true,
		slashCommand = "/rcs",
	}
	LAM:RegisterAddonPanel("Auto Recharge", panelData)

	local optionsTable =
    {	-- BEGIN OF OPTIONS TABLE

		--Description of the addon
		{
			type = "description",
			text = "Recharges and repairs your equipped weapons and amour automatically upon entering and leaving combat",
		},
		--Automatic recharging
		{
        	type = "header",
        	name = "Automatic charging",
        },
		{
			type = "checkbox",
			name = "Automatic weapon recharge",
			tooltip = "Automatically recharge your weapons upon entering/leaving combat. Consumes 1 soul gem per weapon charged.",
			getFunc = function() return _settings.chargeEnabled end,
			setFunc = function(value) _settings.chargeEnabled = value end,
            default = _settings.chargeEnabled,
            width="half",
		},
 		{
			type = "slider",
			name = "Minimum charge percentage",
			tooltip = "Set a value between 0% and 99%. Weapons will be recharged when the current charge percentage is equal to or lower than this value.",
			min = 0,
			max = 99,
			getFunc = function() return (_settings.minChargePercent*100) end,
			setFunc = function(percent)
					local percentage = TryParsePercent(percent)
					if percentage ~= nil and percentage >= 0 and percentage < 1 then
						_settings.minChargePercent = percentage
	                    println("Minimum charge: ",tostring(percent),"%")
                    end
 				end,
            width="half",
			default = (_settings.minChargePercent*100),
            disabled = function() return not _settings.chargeEnabled end,
		},
		--Automatic repairing
		{
        	type = "header",
        	name = "Automatic repairing",
        },
		{
			type = "checkbox",
			name = "Automatic armour repair",
			tooltip = "Automatically repair your armour upon entering/leaving combat. Consumes 1 repair kit per item repaired.",
			getFunc = function() return _settings.repairEnabled end,
			setFunc = function(value) _settings.repairEnabled = value end,
            default = _settings.repairEnabled,
            width="half",
		},
 		{
			type = "slider",
			name = "Minimum condition percentage",
			tooltip = "Set a value between 0% and 99%. Armour will be repaired when the current condition percentage is equal to or lower than this value.",
			min = 0,
			max = 99,
			getFunc = function() return (_settings.minConditionPercent*100) end,
			setFunc = function(percent)
					local percentage = TryParsePercent(percent)
					if percentage ~= nil and percentage >= 0 and percentage < 1 then
						_settings.minConditionPercent = percentage
						println("Minimum condition: ",tostring(percent),"%")
                    end
 				end,
            width="half",
			default = (_settings.minConditionPercent*100),
            disabled = function() return not _settings.repairEnabled end,
		},

    } -- END OF OPTIONS TABLE
	LAM:RegisterOptionControls("Auto Recharge", optionsTable)

end
-- << Baertram

local function Initialise()

	EVENT_MANAGER:RegisterForEvent("Recharge_CombatStateChanged",EVENT_PLAYER_COMBAT_STATE,Recharge_CombatStateChanged)

	SLASH_COMMANDS["/rc"] = function(arg)
		arg = trim(arg)
		if arg == nil or arg == "" then
			if IsPlayerDead() == true then return end
			ChargeEquipped()
		else
			local percent = TryParsePercent(arg)

			if percent ~= nil and percent >= 0 and percent < 1 then
				_settings.minChargePercent = percent
				println("Minimum charge: ",tostring(percent * 100),"%")
			elseif percent ~= nil then
				println("Invalid percentage: ",tostring(percent * 100)," range: 0-99.")
			else
				 local enabled = TryParseOnOff(arg)
				 if enabled ~= nil then 
					_settings.chargeEnabled = enabled
					println("Charge ", ((_settings.chargeEnabled and "Enabled") or "Disabled"))
				 end
			end
		end 

	end

	SLASH_COMMANDS["/rp"] = function(arg)
		arg = trim(arg)
		if arg == nil or arg == "" then
			if IsPlayerDead() == true then return end
			RepairEquipped()
		else
			local percent = TryParsePercent(arg)
			
			if percent ~= nil and percent >= 0 and percent < 1 then
				_settings.minConditionPercent = percent
				println("Minimum condition: ",tostring(percent * 100),"%")
			elseif percent ~= nil then
				println("Invalid percentage: ",tostring(percent * 100)," range: 0-99.")
			else
				local enabled = TryParseOnOff(arg)
				if enabled ~= nil then 
					_settings.repairEnabled = enabled
					println("Repair ",((_settings.repairEnabled and "Enabled") or "Disabled"))
				end
			end
		
		end 
	end 

end

local function Recharge_Loaded(eventCode, addOnName)

	if(addOnName ~= "Recharge") then
        return
    end

	BuildAddonMenu()

	_settings = ZO_SavedVars:New("AutoRecharge_SavedVariables", "3", "", _settings, nil)

	Initialise()
	
end

EVENT_MANAGER:RegisterForEvent("Recharge_Loaded", EVENT_ADD_ON_LOADED, Recharge_Loaded)
