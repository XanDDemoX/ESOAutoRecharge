
local ItemsData = {}

local _masterWeaponIds = {

--The Master's Restoration Staff
55939, --Powered
55969, --Charged
55975, --Precise
55981, --Infused
55987, --Defending
55993, --Sharpened
55999, --Weighted

--The Master's Lightning Staff
57454, --Charged
57455, --Precise
57456, --Infused
57457, --Defending
57458, --Sharpened
57459, --Weighted

--The Master's Greatsword
55934, --Powered
55964, --Charged
55970, --Precise
55976, --Infused
55982, --Defending
55988, --Sharpened
55994, --Weighted

--The Master's Sword
55935, --Powered
55965, --Charged
55971, --Precise
55977, --Infused
55983, --Defending
55989, --Sharpened
55995  --Weighted
}

local _linkIdCache = {}

local function GetItemId(bagId,slotId)
	local link = GetItemLink(bagId,slotId) 
	local itemId = _linkIdCache[link]
	if itemId == nil then 
		itemId = select(4, ZO_LinkHandler_ParseLink(link))
		_linkIdCache[link] = itemId
	end 
	return itemId
end 

local function IsMasterWeapon(bagId,slotId)
	local id = GetItemId(bagId,slotId)
	
	for i,v in ipairs(_masterWeaponIds) do
		if id == v then return true end 
	end 
	
	return false
end

local d = ItemsData

d.GetItemId = GetItemId
d.IsMasterWeapon = IsMasterWeapon

Recharge.ItemsData = ItemsData