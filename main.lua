require("scripts.embeddablecallbackhack")

local Ancient = RegisterMod("The Ancient",1)
local game = Game()
local ModRNG = RNG()
local playerType = Isaac.GetPlayerTypeByName("The Ancient")


local TheAncientInitPool = {
    	[1] = {				--GOLD
		DAMAGE = 4.5,
		SPEED = 0,
		TEARS = -3,
		SHOTSPEED = 5,
    		TEARHEIGHT = 1,
    		TEARFALLINGSPEED = 0,
		LUCK = 0,
		TEARFLAG = 0,
		ItemPool= { 429,  	
				109 , 	
				18, 		
				380},		
		TrinketPool= { 83}	
    	},
    	[2] = {				--MultiTears 
		DAMAGE = -0.7,
		SPEED = 0.3,
		TEARS = 2,
		SHOTSPEED = -0.2,
    		TEARHEIGHT = 0,
    		TEARFALLINGSPEED = 0,
		LUCK = 0,
		TEARFLAG = 0,
		ItemPool= { 153,  	
				245 , 	
				424, 		
				2},		
		TrinketPool= { 77}	
	},
	[3] = {				--Bartolomé 
		DAMAGE = -1,
		SPEED = 1,
		TEARS = 4,
		SHOTSPEED = 3,
    		TEARHEIGHT = 2,
    		TEARFALLINGSPEED = -3,
		LUCK = 3.5,
		TEARFLAG = 1,
		ItemPool= { 528,  	
				512 , 	
				529, 		
				173},		
		TrinketPool= { 77}	
    },
    [4] = {				--Bartolomé 
		DAMAGE = 2.2,
		SPEED = -0.2,
		TEARS = -12,
		SHOTSPEED = -0.1,
    		TEARHEIGHT = 0,
    		TEARFALLINGSPEED = 0,
		LUCK = 7,
		TEARFLAG = 1,
		ItemPool= { 247,  	
				8 , 	
				67, 		
				293},		
		TrinketPool= { 6}	
    },
}

--[[ Ancient:AddCallback(ModCallbacksMC_POST_CURSE_EVAL,function()
	game:GetLevel():AddCurse(2,true)
end) ]]

Ancient:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, fromSave)
	ModRNG:SetSeed(game:GetSeeds():GetStartSeed(), 35) -- Seed the rng for the run. 

		local player = Isaac.GetPlayer(0)
		local data = player:GetData()
		data.QtyRoomCleared = 0
		data.TakenHit = 0
end)

Ancient:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function(_, player)
	player:GetData().RandomStarterPack = ModRNG:RandomInt(#TheAncientInitPool) + 1
end)

Ancient:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cacheFlag)
	if player:GetName() == "The Ancient" then
		if not player:GetPlayerType() == playerType then return end
		    
   			if cacheFlag == CacheFlag.CACHE_DAMAGE then
		  	player.Damage = player.Damage + TheAncientInitPool[player:GetData().RandomStarterPack].DAMAGE
	
		elseif cacheFlag == CacheFlag.CACHE_MOVESPEED then
			player.MoveSpeed = player.MoveSpeed - TheAncientInitPool[player:GetData().RandomStarterPack].SPEED
	
   			elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
			  player.MaxFireDelay = player.MaxFireDelay - TheAncientInitPool[player:GetData().RandomStarterPack].TEARS
	
		elseif cacheFlag == CacheFlag.CACHE_SHOTSPEED then
			player.ShotSpeed = player.ShotSpeed - TheAncientInitPool[player:GetData().RandomStarterPack].SHOTSPEED
	
		elseif cacheFlag == CacheFlag.CACHE_TEARHEIGHT then
			player.TearHeight = player.TearHeight - TheAncientInitPool[player:GetData().RandomStarterPack].TEARHEIGHT
	
		elseif cacheFlag == CacheFlag.CACHE_TEARFALLINGSPEED then
			player.TearFallingSpeed	= player.TearFallingSpeed - TheAncientInitPool[player:GetData().RandomStarterPack].TEARFALLINGSPEED
	
		elseif cacheFlag == CacheFlag.CACHE_LUCK then
			player.Luck = player.Luck + TheAncientInitPool[player:GetData().RandomStarterPack].LUCK
		
		elseif cacheFlag == CacheFlag.CACHE_TEARFLAG then
			player.TearFlags = player.TearFlags + TheAncientInitPool[player:GetData().RandomStarterPack].TEARFLAG
			  
   		end
   	end
end)


local function TakeHit(_, player)
	local data = player:GetData()
	if not data.TakenHit then data.TakenHit = 0 end
   
	if not data.NewRoom then
	    data.TakenHit = data.TakenHit + 1
	else
	    data.TakenHit = 0
	end
  end
Ancient:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, TakeHit, EntityType.ENTITY_PLAYER)

Ancient:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function()
	local player = Isaac.GetPlayer(0)
	local data = player:GetData()
	if player:GetName() == "The Ancient" then
	    	local room = game:GetRoom()
		
	    	player:GetData().QtyItemInList = 4
	    	player:GetData().QtyTrinketInList = 1
		
		if room:IsFirstVisit() then
			-- Game():GetRoom():SetFloorColor(Color(1,1,1,1,25,0,0)) --turn the ground into red color
	    		if room:IsClear() and data.TakenHit < 1 then
				player:GetData().QtyRoomCleared = player:GetData().QtyRoomCleared + 1
				-- print(player:GetData().QtyRoomCleared)

				if player:GetData().QtyRoomCleared % 4 == 0 and player:GetData().QtyItemInList ~= 0 then
				  	local StartItemPos = room:FindFreePickupSpawnPosition(player.Position + Vector(0,-100), 0.0, true)
				  	local ItemPoolTemp = TheAncientInitPool[player:GetData().RandomStarterPack].ItemPool
				  	local itemIndex = math.random(#TheAncientInitPool)
				  	local randomItem = ItemPoolTemp[itemIndex ]
				  	Isaac.Spawn(5, 100, randomItem, StartItemPos, Vector(0,0), nil)

					data.QtyItemInList = data.QtyItemInList - 1
--[[ 				elseif data.QtyTrinketInListketQty ~= 0 then
					local StartTrinketPos = room:FindFreePickupSpawnPosition(player.Position + Vector(0,-100), 0.0, true)
					local TrinketPoolTemp = TheAncientInitPool[data.RandomStarterPack].TrinketPool
					local TrinketIndex = math.random(#TheAncientInitPool)
					local randomTrinket = TrinketPoolTemp[TrinketIndex ]
					Isaac.Spawn(5, 100, randomTrinket, StartTrinketPos, Vector(0,0), nil)

					data.QtyTrinketInList = data.QtyTrinketInList - 1 ]]
				end
			end
		end
	end
end)

