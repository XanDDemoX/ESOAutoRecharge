
local Bag = {}

local function GetBagItems(bagId,func)
	
	local cache = SHARED_INVENTORY:GenerateFullSlotData(nil, bagId)
	local tbl = {}
	for slotId,data in pairs(cache) do 
		v = func(data.slotIndex) 
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

local function GetItemsByType(bagId,types)
	
	local tbl = GetBagItems(bagId,function(i)
		
		local itemType = GetItemType(bagId,i)
		
		for i,t in ipairs(types) do
			if itemType == t then
				return {
					bag = bagId,
					index = i,
					itemType=itemType
				}
			end
		end
	
	end)
	
	return tbl
end

local b = Bag 

b.GetBagItems = GetBagItems
b.GetSoulGems = GetSoulGems
b.GetRepairKits = GetRepairKits
b.GetItemsByType = GetItemsByType

Recharge.Bag = b 