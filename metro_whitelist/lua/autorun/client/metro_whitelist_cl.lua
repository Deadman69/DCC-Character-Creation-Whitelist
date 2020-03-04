--[[ include ]]
include("metro_config/metro_config_whitelist.lua")
AddCSLuaFile("metro_config/metro_config_whitelist.lua")



--[[ defining custom functions to make them global in the file ]]
local function openMainMenu() end -- Open Main Menu
local function openPlayerMenu() end -- Open player menu
local function openRemoveJobMenu() end -- Open player menu


--[[ custom function ]]

function openPlayerMenu(whitelistTable)
	local mainPanel = vgui.Create( "DFrame" )
	mainPanel:SetPos( 0, 0 )
	mainPanel:SetSize( ScrW()/2, ScrH()/2 )
	mainPanel:Center()
	mainPanel:SetTitle( "Whitelist panel players" )
	mainPanel:SetDraggable( false )
	mainPanel:MakePopup()

	local playerList = vgui.Create( "DComboBox", mainPanel )
	playerList:SetPos( 0, 0 )
	playerList:SetSize( 100, 40 )
	playerList:CenterVertical(0.5)
	playerList:CenterHorizontal(0.2)
	playerList:SetValue( "Player" )
	for _, v in pairs(player.GetAll()) do
    	playerList:AddChoice( v:Name() )
	end

	local whitelistedTeams = vgui.Create( "DComboBox", mainPanel )
	whitelistedTeams:SetPos( 0, 0 )
	whitelistedTeams:SetSize( 100, 40 )
	whitelistedTeams:CenterVertical(0.5)
	whitelistedTeams:CenterHorizontal(0.35)
	whitelistedTeams:SetValue( "Jobs to add" )
	for _, v in pairs(whitelistTable) do
	    whitelistedTeams:AddChoice( v["JobName"] )
	end

	local checkboxChar1 = vgui.Create( "DCheckBoxLabel", mainPanel )
	checkboxChar1:SetPos( 0, 0 )						-- Set the position
	checkboxChar1:CenterVertical(0.4)
	checkboxChar1:CenterHorizontal(0.8)
	checkboxChar1:SetText( "Add Character 1" )					-- Set the text next to the box
	checkboxChar1:SetValue( false )						-- Initial value
	checkboxChar1:SizeToContents()

	local checkboxChar2 = vgui.Create( "DCheckBoxLabel", mainPanel )
	checkboxChar2:SetPos( 0, 0 )						-- Set the position
	checkboxChar2:CenterVertical(0.45)
	checkboxChar2:CenterHorizontal(0.8)
	checkboxChar2:SetText( "Add Character 2" )					-- Set the text next to the box
	checkboxChar2:SetValue( false )						-- Initial value
	checkboxChar2:SizeToContents()

	local checkboxChar3 = vgui.Create( "DCheckBoxLabel", mainPanel )
	checkboxChar3:SetPos( 0, 0 )						-- Set the position
	checkboxChar3:CenterVertical(0.5)
	checkboxChar3:CenterHorizontal(0.8)
	checkboxChar3:SetText( "Add Character 3" )					-- Set the text next to the box
	checkboxChar3:SetValue( false )						-- Initial value
	checkboxChar3:SizeToContents()

	local addWhitelist = vgui.Create( "Button", mainPanel )
	addWhitelist:SetSize( 200, 40 )
	addWhitelist:CenterVertical(0.5)
	addWhitelist:CenterHorizontal(0.6)
	addWhitelist:SetText( "Add ONLY current character to whitelist" )
	function addWhitelist:OnMousePressed()
		if whitelistedTeams:GetValue() ~= "Jobs to add" and playerList:GetValue() ~= "Player" then
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
				net.WriteString("addWhitelistPlayer")
				net.WriteString(playerList:GetValue())
				net.WriteString(whitelistedTeams:GetValue())
			net.SendToServer()
		else
			notification.AddLegacy( "You have to select a team before add it !", NOTIFY_ERROR , 4 )
			surface.PlaySound( "buttons/button15.wav" )
		end
	end

	local addMultipleWhitelist = vgui.Create( "Button", mainPanel )
	addMultipleWhitelist:SetSize( 200, 40 )
	addMultipleWhitelist:CenterVertical(0.6)
	addMultipleWhitelist:CenterHorizontal(0.8)
	addMultipleWhitelist:SetText( "Add MULTIPLE characters to whitelist" )
	function addMultipleWhitelist:OnMousePressed()
		if whitelistedTeams:GetValue() ~= "Jobs to add" and playerList:GetValue() ~= "Player" then
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
				net.WriteString(playerList:GetValue())
				net.WriteString(whitelistedTeams:GetValue())
				net.WriteTable(charactersToAdd)
			net.SendToServer(charactersToAdd)
		else
			notification.AddLegacy( "You have to select a team before add it !", NOTIFY_ERROR , 4 )
			surface.PlaySound( "buttons/button15.wav" )
		end
	end
end




function openMainMenu()

	local mainPanel = vgui.Create( "DFrame" )
	mainPanel:SetPos( 0, 0 )
	mainPanel:SetSize( ScrW()/2, ScrH()/2 )
	mainPanel:Center()
	mainPanel:SetTitle( "Whitelist panel" )
	mainPanel:SetDraggable( false )
	mainPanel:MakePopup()

	local jobList = vgui.Create( "DComboBox", mainPanel )
	jobList:SetPos( 0, 0 )
	jobList:SetSize( 100, 40 )
	jobList:CenterVertical(0.5)
	jobList:CenterHorizontal(0.5)
	jobList:SetValue( "Jobs" )
	for _, v in pairs(RPExtraTeams) do
    	jobList:AddChoice( v.name )	
	end

	local addTeamButton = vgui.Create( "Button", mainPanel )
	addTeamButton:SetSize( 100, 40 )
	addTeamButton:CenterVertical(0.5)
	addTeamButton:CenterHorizontal(0.7)
	addTeamButton:SetText( "add job" )
	function addTeamButton:OnMousePressed()
		if jobList:GetValue() ~= "Jobs" then
			net.Start("Metro::WhitelistOrderToServer")
				net.WriteString("addWhitelistTeam")
				net.WriteString(jobList:GetValue())
			net.SendToServer()
		else
			notification.AddLegacy( "You have to select a team before add it !", NOTIFY_ERROR , 4 )
			surface.PlaySound( "buttons/button15.wav" )
		end
	end

	local playerButton = vgui.Create( "Button", mainPanel )
	playerButton:SetSize( 100, 40 )
	playerButton:CenterVertical(0.9)
	playerButton:CenterHorizontal(0.1)
	playerButton:SetText( "Switch to player" )
	function playerButton:OnMousePressed()
		mainPanel:Remove()

		net.Start("Metro::WhitelistOrderToServer")
			net.WriteString("getWhitelistedTeams")
		net.SendToServer()
	end

	local removeButton = vgui.Create( "Button", mainPanel )
	removeButton:SetSize( 160, 40 )
	removeButton:CenterVertical(0.9)
	removeButton:CenterHorizontal(0.7)
	removeButton:SetText( "Remove job from whitelist" )
	function removeButton:OnMousePressed()
		mainPanel:Remove()

		net.Start("Metro::WhitelistOrderToServer")
			net.WriteString("openRemoveJobMenu")
		net.SendToServer()
	end
end


function openRemoveJobMenu(tableWhitelist)
	local mainPanel = vgui.Create( "DFrame" )
	mainPanel:SetPos( 0, 0 )
	mainPanel:SetSize( ScrW()/2, ScrH()/2 )
	mainPanel:Center()
	mainPanel:SetTitle( "Whitelist panel players" )
	mainPanel:SetDraggable( false )
	mainPanel:MakePopup()

	local removeList = vgui.Create( "DComboBox", mainPanel )
	removeList:SetPos( 0, 0 )
	removeList:SetSize( 100, 40 )
	removeList:CenterVertical(0.5)
	removeList:CenterHorizontal(0.4)
	removeList:SetValue( "Job to remove" )
	for _, v in pairs(tableWhitelist) do
    	removeList:AddChoice( v["JobName"] )
	end

	local removeWhitelist = vgui.Create( "Button", mainPanel )
	removeWhitelist:SetSize( 100, 40 )
	removeWhitelist:CenterVertical(0.5)
	removeWhitelist:CenterHorizontal(0.7)
	removeWhitelist:SetText( "Remove job" )
	function removeWhitelist:OnMousePressed()
		if removeList:GetValue() ~= "Job to remove" then
			mainPanel:Remove()

			net.Start("Metro::WhitelistOrderToServer")
				net.WriteString("removeJobFromWhitelist")
				net.WriteString(removeList:GetValue())
			net.SendToServer()
		else
			notification.AddLegacy( "You have to select a team before remove it !", NOTIFY_ERROR , 4 )
			surface.PlaySound( "buttons/button15.wav" )
		end
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