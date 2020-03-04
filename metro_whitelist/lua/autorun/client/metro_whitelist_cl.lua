--[[ include ]]
include("metro_config/metro_config_whitelist.lua")
AddCSLuaFile("metro_config/metro_config_whitelist.lua")



--[[ defining custom functions to make them global in the file ]]
local function openMainMenu() end -- Open Main Menu
local function openPlayerMenu() end -- Open player menu
local function openRemoveJobMenu() end -- Open player menu


--[[ custom function ]]

function openPlayerMenu(whitelistTable)
	local mainPanel = vgui.Create( "GNFrame" )
	mainPanel:SetSize( ScrW()/2, ScrH()/2 )
	mainPanel:Center()
	mainPanel:SetTitle( "WHITELIST PANEL - ADMIN" )
	mainPanel:SetDraggable( false )
	mainPanel:MakePopup()

	local playerList = vgui.Create( "GNComboBox", mainPanel )
	playerList:SetSize( ScrW()/9.6, ScrH()/27 )
	playerList:CenterVertical(0.4)
	playerList:CenterHorizontal(0.13)
	playerList:SetValue( "Player" )
	for _, v in pairs(player.GetAll()) do
    	playerList:AddChoice( v:Name() )
	end

	local whitelistedTeams = vgui.Create( "GNComboBox", mainPanel )
	whitelistedTeams:SetSize( ScrW()/12.8, ScrH()/27 )
	whitelistedTeams:CenterVertical(0.4)
	whitelistedTeams:CenterHorizontal(0.4)
	whitelistedTeams:SetValue( "Jobs to add" )
	for _, v in pairs(whitelistTable) do
	    whitelistedTeams:AddChoice( v["JobName"] )
	end

	local checkboxChar1 = vgui.Create( "DCheckBoxLabel", mainPanel )
	checkboxChar1:CenterVertical(0.6)
	checkboxChar1:CenterHorizontal(0.2)
	checkboxChar1:SetText( "Add Character 1" )
	checkboxChar1:SetValue( false )
	checkboxChar1:SizeToContents()

	local checkboxChar2 = vgui.Create( "DCheckBoxLabel", mainPanel )
	checkboxChar2:CenterVertical(0.65)
	checkboxChar2:CenterHorizontal(0.2)
	checkboxChar2:SetText( "Add Character 2" )
	checkboxChar2:SetValue( false )
	checkboxChar2:SizeToContents()

	local checkboxChar3 = vgui.Create( "DCheckBoxLabel", mainPanel )
	checkboxChar3:CenterVertical(0.7)
	checkboxChar3:CenterHorizontal(0.2)
	checkboxChar3:SetText( "Add Character 3" )
	checkboxChar3:SetValue( false )
	checkboxChar3:SizeToContents()

	local addWhitelist = vgui.Create( "GNButton", mainPanel )
	addWhitelist:SetSize( ScrW()/9.6, ScrH()/27 )
	addWhitelist:CenterVertical(0.4)
	addWhitelist:CenterHorizontal(0.6)
	addWhitelist:SetText( "Add current character to whitelist" )
	function addWhitelist:OnMousePressed()
		if whitelistedTeams:GetSelected()["text"] ~= "Jobs to add" and playerList:GetSelected()["text"] ~= "Player" then
			mainPanel:Remove()

			net.Start("Metro::WhitelistOrderToServer")
				net.WriteString("addWhitelistPlayer")
				net.WriteString(playerList:GetSelected()["text"])
				net.WriteString(whitelistedTeams:GetSelected()["text"])
			net.SendToServer()
		else
			--notification.AddLegacy( "You have to select a team and a player before add it !", NOTIFY_ERROR , 4 )
			GNLib.AutoTranslate( MConf.LanguageType, "You have to select a team and a player before add it !", function(callback) notification.AddLegacy( callback, NOTIFY_ERROR , 4 ) end )
			surface.PlaySound( "buttons/button15.wav" )
		end
	end

	local addMultipleWhitelist = vgui.Create( "GNButton", mainPanel )
	addMultipleWhitelist:SetSize( ScrW()/9.6, ScrH()/27 )
	addMultipleWhitelist:CenterVertical(0.65)
	addMultipleWhitelist:CenterHorizontal(0.6)
	addMultipleWhitelist:SetText( "Add multiple characters to whitelist" )
	function addMultipleWhitelist:OnMousePressed()
		if whitelistedTeams:GetSelected()["text"] ~= "Jobs to add" and playerList:GetSelected()["text"] ~= "Player" then
			mainPanel:Remove()

			local charactersToAdd = {}
			if checkboxChar1:GetChecked() then
				table.insert( charactersToAdd, "1" )
			end
			if checkboxChar2:GetChecked() then
				table.insert( charactersToAdd, "2" )
			end
			if checkboxChar3:GetChecked() then
				table.insert( charactersToAdd, "3" )
			end

			net.Start("Metro::WhitelistOrderToServer")
				net.WriteString("addMultipleWhitelistPlayer")
				net.WriteString(playerList:GetSelected()["text"])
				net.WriteString(whitelistedTeams:GetSelected()["text"])
				net.WriteTable(charactersToAdd)
			net.SendToServer(charactersToAdd)
		else
			--notification.AddLegacy( "You have to select a team before add it !", NOTIFY_ERROR , 4 )
			GNLib.AutoTranslate( MConf.LanguageType, "You have to select a team before add it !", function(callback) notification.AddLegacy( callback, NOTIFY_ERROR , 4 ) end )
			surface.PlaySound( "buttons/button15.wav" )
		end
	end

	local returnButton = vgui.Create( "GNButton", mainPanel )
	returnButton:SetSize( ScrW()/19.2, ScrH()/27 )
	returnButton:CenterVertical(0.9)
	returnButton:CenterHorizontal(0.9)
	returnButton:SetText( "Return" )
	function returnButton:OnMousePressed()
		mainPanel:Remove()

		openMainMenu()
	end
end




function openMainMenu()

	local mainPanel = vgui.Create( "GNFrame" )
	mainPanel:SetSize( ScrW()/2, ScrH()/2 )
	mainPanel:Center()
	mainPanel:SetTitle( "WHITELIST PANEL - ADMIN" )
	mainPanel:SetDraggable( false )
	mainPanel:MakePopup()

	local jobList = vgui.Create( "GNComboBox", mainPanel )
	jobList:SetSize( ScrW()/12.8, ScrH()/27 )
	jobList:CenterVertical(0.5)
	jobList:CenterHorizontal(0.4)
	jobList:SetValue( "Jobs to add" )
	for _, v in pairs(RPExtraTeams) do
    	jobList:AddChoice( v.name )	
	end

	local addTeamButton = vgui.Create( "GNButton", mainPanel )
	addTeamButton:SetSize( ScrW()/16, ScrH()/27 )
	addTeamButton:CenterVertical(0.5)
	addTeamButton:CenterHorizontal(0.7)
	addTeamButton:SetText( "Add job" )
	function addTeamButton:OnMousePressed()
		if jobList:GetSelected()["text"]~= "Jobs" then
			net.Start("Metro::WhitelistOrderToServer")
				net.WriteString("addWhitelistTeam")
				net.WriteString(jobList:GetSelected()["text"])
			net.SendToServer()
		else
			GNLib.AutoTranslate( MConf.LanguageType, "The job has been removed from the database !", function(callback) notification.AddLegacy( callback, NOTIFY_ERROR , 4 ) end )
			surface.PlaySound( "buttons/button15.wav" )
		end
	end

	local playerButton = vgui.Create( "GNButton", mainPanel )
	playerButton:SetSize( ScrW()/19.2, ScrH()/27 )
	playerButton:CenterVertical(0.9)
	playerButton:CenterHorizontal(0.1)
	playerButton:SetText( "Switch to player" )
	function playerButton:OnMousePressed()
		net.Start("Metro::WhitelistOrderToServer")
			net.WriteString("getWhitelistedTeams")
		net.SendToServer()

		timer.Simple(0.01, function() -- disable the litle tick wich make the screen disapear
			mainPanel:Remove()
		end)
	end

	local removeButton = vgui.Create( "GNButton", mainPanel )
	removeButton:SetSize( ScrW()/12, ScrH()/27 )
	removeButton:CenterVertical(0.9)
	removeButton:CenterHorizontal(0.83)
	removeButton:SetText( "Remove job from whitelist" )
	function removeButton:OnMousePressed()
		net.Start("Metro::WhitelistOrderToServer")
			net.WriteString("openRemoveJobMenu")
		net.SendToServer()

		timer.Simple(0.01, function() -- disable the litle tick wich make the screen disapear
			mainPanel:Remove()
		end)
	end
end


function openRemoveJobMenu(tableWhitelist)
	local mainPanel = vgui.Create( "GNFrame" )
	mainPanel:SetSize( ScrW()/2, ScrH()/2 )
	mainPanel:Center()
	mainPanel:SetTitle( "WHITELIST PANEL - ADMIN" )
	mainPanel:SetDraggable( false )
	mainPanel:MakePopup()

	local removeList = vgui.Create( "GNComboBox", mainPanel )
	removeList:SetSize( ScrW()/12.8, ScrH()/27 )
	removeList:CenterVertical(0.5)
	removeList:CenterHorizontal(0.4)
	removeList:SetValue( "Job to remove" )
	for _, v in pairs(tableWhitelist) do
    	removeList:AddChoice( v["JobName"] )
	end

	local removeWhitelist = vgui.Create( "GNButton", mainPanel )
	removeWhitelist:SetSize( ScrW()/19.2, ScrH()/27 )
	removeWhitelist:CenterVertical(0.5)
	removeWhitelist:CenterHorizontal(0.7)
	removeWhitelist:SetText( "Remove job" )
	function removeWhitelist:OnMousePressed()
		if removeList:GetSelected()["text"] ~= "Job to remove" then
			mainPanel:Remove()

			net.Start("Metro::WhitelistOrderToServer")
				net.WriteString("removeJobFromWhitelist")
				net.WriteString(removeList:GetSelected()["text"])
			net.SendToServer()
		else
			--notification.AddLegacy( "You have to select a team before remove it !", NOTIFY_ERROR , 4 )
			GNLib.AutoTranslate( MConf.LanguageType, "You have to select a team before remove it !", function(callback) notification.AddLegacy( callback, NOTIFY_ERROR , 4 ) end )
			surface.PlaySound( "buttons/button15.wav" )
		end
	end

	local returnButton = vgui.Create( "GNButton", mainPanel )
	returnButton:SetSize( ScrW()/19.2, ScrH()/27 )
	returnButton:CenterVertical(0.9)
	returnButton:CenterHorizontal(0.1)
	returnButton:SetText( "Return" )
	function returnButton:OnMousePressed()
		mainPanel:Remove()

		openMainMenu()
	end
end


--[[ net receive ]]
net.Receive("Metro::WhitelistOrderToPlayer", function()
	local order = net.ReadString()

	if order == "openMenu" then
		openMainMenu()
	elseif order == "notification" then
		notification.AddLegacy( net.ReadString(), net.ReadInt(4), net.ReadInt(4) )
		surface.PlaySound( "buttons/button15.wav" )
	elseif order == "openPlayerMenu" then
		openPlayerMenu(net.ReadTable())
	elseif order == "openRemoveJobMenu" then
		openRemoveJobMenu(net.ReadTable())
	end
end)