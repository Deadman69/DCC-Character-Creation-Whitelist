
--[[ include ]]
include("metro_config/metro_config_whitelist.lua")
AddCSLuaFile("metro_config/metro_config_whitelist.lua")


--[[ defining net messages ]]
util.AddNetworkString("Metro::WhitelistOrderToPlayer")
util.AddNetworkString("Metro::WhitelistOrderToServer")


--[[ creating database ]]
if not sql.TableExists( "MetroWhitelistJob" ) then
	sql.Query([[
		CREATE TABLE MetroWhitelistJob(
			JobUID    			INTEGER 		PRIMARY KEY AUTOINCREMENT, 	-- UID for the job
		  	JobName  			VARCHAR(255)	NOT NULL,								-- Job name like "Super Staff"
		  	JobActive 			BOOLEAN			NOT NULL								-- If true: whitelist active, elseif false: inactive
		)
	]])
end

if not sql.TableExists( "MetroWhitelistCharacters" ) then
	sql.Query([[
		CREATE TABLE MetroWhitelistCharacters(
		  	WhitelistUID    	INTEGER 		PRIMARY KEY AUTOINCREMENT, 			-- UID for the whitelist
		  	WhitelistSteamID  	VARCHAR(20)		NOT NULL,							-- CharacterOwner SteamID64
		  	WhitelistCharID   	INTEGER 		NOT NULL,							-- Character ID
		  	WhitelistJobUID		INTEGER			NOT NULL,							-- FK to MetroWhitelistJob.JobUID

		  	FOREIGN KEY(WhitelistJobUID) REFERENCES MetroWhitelistJob(JobUID),
		  	FOREIGN KEY(WhitelistSteamID, WhitelistCharID) REFERENCES MetroCharacters(CharacterOwner, CharacterID)
		)
	]])
end



--[[ Custom functions ]]
-- Use the DarkRPFunction: playerCanChangeTeam, 2 returns arguments expected (allowed, reason)
function allowedToGetJob(ply, numberTeam, isForced) 
	if isForced then 
		return true, "Metro Whitelist - Job change forced " 
	end

	if MConf.WhitelistBypassRanks[ply:GetUserGroup()] then
		return true, "Metro Whitelist - Job bypass due to rank"
	end

	local query = sql.Query("SELECT JobName, JobUID FROM MetroWhitelistJob WHERE JobName = '"..team.GetName(numberTeam).."' AND JobActive = 1")
	if query == nil then -- No whitelist for this job
		return true, "Metro Whitelist - Job not whitelisted"
	else -- if there is a whitelist on the job
		local checkQuery = sql.Query("SELECT * FROM MetroWhitelistCharacters WHERE WhitelistSteamID = '"..ply:SteamID64().."' AND WhitelistCharID = '"..ply:GetNWInt("Metro::CharacterID").."' AND WhitelistJobUID = '"..query[1]["JobUID"].."'")
		if checkQuery == nil then -- if character is not already whitelisted
			MMNotification(ply, "You are not whitelisted !", 1, 3)
			return false, "Metro Whitelist - Character not whitelisted"
		else -- if character is whitelisted
			return true, "Metro Whitelist - Character whitelisted"
		end
	end
end

local function addJobToWhitelist(plyAsker, jobToAdd)
	local query = sql.Query("SELECT JobName, JobActive FROM MetroWhitelistJob")
	if istable(query) then -- if there is 1 whitelisted job or more

		-- check if job is already in database
		local canAdd, switchActive = true, false
		for _, job in pairs(query) do
			if job["JobName"] == jobToAdd then
				if job["JobActive"] == 1 then
					canAdd = false
				else
					canAdd = false
					switchActive = true
				end
			end
		end

		if canAdd then -- If it has never been in the database
			sql.Query("INSERT INTO MetroWhitelistJob(JobName, JobActive) VALUES('"..jobToAdd.."', 1)")
			MMNotification(plyAsker, "The job '"..jobToAdd.."' has been added in the database !", 0, 3)
		elseif not canAdd and switchActive then -- if it was inactive
			sql.Query("UPDATE MetroWhitelistJob SET JobActive = 1 WHERE JobName = '"..jobToAdd.."'")
			MMNotification(plyAsker, "The job '"..jobToAdd.."' has been edited in the database (it has been activated) !", 2, 3)
		else -- if it's already active
			MMNotification(plyAsker, "This job '"..jobToAdd.."' is already in the database !", 1, 3)
		end

	else -- if there is no jobs, no need to check
		sql.Query("INSERT INTO MetroWhitelistJob(JobName, JobActive) VALUES('"..jobToAdd.."', 1)")
		MMNotification(plyAsker, "The job ('"..jobToAdd.."') has been added in the database !", 0, 3)
	end
end

local function allowedPanel(ply)
	if not MConf.WhitelistAllowedCommand[ply:GetUserGroup()] and not MConf.WhitelistAllowedSteamID[ply:SteamID()] then 
		return false -- ply can't access
	else
		return true -- ply can access
	end
end

--[[ Hooks ]]
hook.Add( "PlayerSay", "Metro::WhitelistHook::PlayerSay", function( ply, text )
	local playerInput = string.Explode( " ", text )
	if playerInput[1] == MConf.WhitelistCommand and allowedPanel(ply) then
		net.Start("Metro::WhitelistOrderToPlayer")
			net.WriteString("openMenu")
		net.Send(ply)

		return ""
	elseif playerInput[1] == MConf.WhitelistCommandDeleteAll then
		if ply:IsSuperAdmin() then
			MMNotification(ply, "Everything from the whitelist will be deleted in 3 seconds, and will be followed with a server restart", 2, 3)

			if sql.TableExists( "MetroWhitelistJob" ) then
				sql.Query([[
					PRAGMA foreign_keys = OFF; 				-- Disable foreign keys constraint
					DROP TABLE MetroWhitelistJob;			-- Drop table
					PRAGMA foreign_keys = ON;				-- Enable foreign keys
				]])
			end

			if sql.TableExists( "MetroWhitelistCharacters" ) then
				sql.Query([[
					PRAGMA foreign_keys = OFF; 				-- Disable foreign keys constraint
					DROP TABLE MetroWhitelistCharacters;	-- Drop table
					PRAGMA foreign_keys = ON;				-- Enable foreign keys
				]])
			end

			timer.Simple(3, function()
				game.ConsoleCommand("changelevel "..game.GetMap().."\n")
			end)

		else
			MMNotification(ply, "You don't have access to this command !", 1, 3)
		end
	end
end)

hook.Add("playerCanChangeTeam", "Metro::WhitelistCheckAllowed", function(ply, numberTeam, force)
	if allowedToGetJob(ply, numberTeam, force) then
		return true
	else
		return false
	end
end)


--[[ net receive ]]
net.Receive("Metro::WhitelistOrderToServer", function(len, ply)
	local order = net.ReadString()

	if order == "addWhitelistTeam" then -- trigger when we add a team to the whitelist
		if not allowedPanel(ply) then return end

		addJobToWhitelist(ply, net.ReadString())
	elseif order == "getWhitelistedTeams" then -- trigger when we click  to "Switch to player"
		if not allowedPanel(ply) then return end

		local whitelistTable = sql.Query("SELECT JobName FROM MetroWhitelistJob WHERE JobActive = 1")
		if istable(whitelistTable) then
			net.Start("Metro::WhitelistOrderToPlayer")
				net.WriteString("openPlayerMenu")
				net.WriteTable(whitelistTable)
			net.Send(ply)
		else
			MMNotification(ply, "There is no job in the whitelist !", 1, 3)
		end
	elseif order == "addWhitelistPlayer" then -- trigger when we add a player to the whitelist
		if not allowedPanel(ply) then return end

		local playerName = net.ReadString()
		local teamName = net.ReadString()
		local playerEnt -- defined just below

		for _, v in pairs(player.GetAll()) do
			if v:Name() == playerName then
				playerEnt = v
				break
			end
		end
		

		-- Add curent character to whitelist

		local jobUID = sql.Query("SELECT JobUID FROM MetroWhitelistJob WHERE JobName = '"..teamName.."'")
		local query = sql.Query("SELECT * FROM MetroWhitelistCharacters WHERE WhitelistSteamID = '"..playerEnt:SteamID64().."' AND WhitelistCharID = '"..tonumber(playerEnt:GetNWString("Metro::CharacterID")).."' AND WhitelistJobUID = '"..jobUID[1]["JobUID"].."'")
		if query == nil then -- if character is not already whitelisted
			sql.Query("INSERT INTO MetroWhitelistCharacters(WhitelistSteamID, WhitelistCharID, WhitelistJobUID) VALUES('"..playerEnt:SteamID64().."', "..tonumber(playerEnt:GetNWString("Metro::CharacterID"))..", "..tonumber(jobUID[1]["JobUID"])..")")
		end
	elseif order == "addMultipleWhitelistPlayer" then -- trigger when we add MULTIPLE characters to whitelist
		local playerName = net.ReadString()
		local teamName = net.ReadString()
		local charactersToAdd = net.ReadTable()
		local playerEnt -- defined just below

		for _, v in pairs(player.GetAll()) do
			if v:Name() == playerName then
				playerEnt = v
				break
			end
		end
		

		-- Add multiple characters to whitelist
		local jobUID = sql.Query("SELECT JobUID FROM MetroWhitelistJob WHERE JobName = '"..teamName.."'")
		for _, id in pairs(charactersToAdd) do
			local query = sql.Query("SELECT * FROM MetroWhitelistCharacters WHERE WhitelistSteamID = '"..playerEnt:SteamID64().."' AND WhitelistCharID = '"..id.."' AND WhitelistJobUID = '"..jobUID[1]["JobUID"].."'")
			if query == nil then -- if character is not already whitelisted
				sql.Query("INSERT INTO MetroWhitelistCharacters(WhitelistSteamID, WhitelistCharID, WhitelistJobUID) VALUES('"..playerEnt:SteamID64().."', "..id..", "..tonumber(jobUID[1]["JobUID"])..")")
				-- if the characters doesn't exist, it create a SQL error because FOREIGN KEY FAILED, obvisouly, there is no characters to link !
			end
		end


	elseif order == "openRemoveJobMenu" then -- when we try to open to remove job menu
		if not allowedPanel(ply) then return end

		local whitelistTable = sql.Query("SELECT JobName FROM MetroWhitelistJob WHERE JobActive = 1")
		if istable(whitelistTable) then
			net.Start("Metro::WhitelistOrderToPlayer")
				net.WriteString("openRemoveJobMenu")
				net.WriteTable(sql.Query("SELECT JobName FROM MetroWhitelistJob WHERE JobActive = 1"))
			net.Send(ply)
		else
			MMNotification(ply, "There is no job to delete !", 1, 3)
		end
	elseif order == "removeJobFromWhitelist" then -- trigger when we remove job from whitelist
		if not allowedPanel(ply) then return end

		local teamName = net.ReadString()
		sql.Query("UPDATE MetroWhitelistJob SET JobActive = 0 WHERE JobName = '"..teamName.."'")
		MMNotification(ply, "The job ('"..teamName.."') has been removed from the database !", 0, 3)

		-- If there is still jobs in the list, reopening menu to let user delete other jobs
		local whitelistTable = sql.Query("SELECT JobName FROM MetroWhitelistJob WHERE JobActive = 1")
		if istable(whitelistTable) then
			net.Start("Metro::WhitelistOrderToPlayer")
				net.WriteString("openRemoveJobMenu")
				net.WriteTable(whitelistTable)
			net.Send(ply)
		end
	end
end)