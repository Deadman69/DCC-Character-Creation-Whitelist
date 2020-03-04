MConf = MConf or {}
MConf.WhitelistVersion = 1.3

MConf.WhitelistCommand = "!whitelist" -- command to open the menu
MConf.WhitelistCommandDeleteAll = "!whitelistDeleteAll" -- WARNING: Will delete all the data from the whitelist, only superadmin allowed
MConf.WhitelistAllowedCommand = { -- groups allowed to open the whitelist menu
	["superadmin"] = true,
	["admin"] = true,
	["mod"] = true,
}

MConf.WhitelistAllowedSteamID = { -- allowed SteamID to open the whitelist menu
	["STEAM:0:1_055161131"] = true,
	["STEAM:0:1_055161131"] = true,
	["STEAM:0:1_055161131"] = true,
	["STEAM:0:1_055161131"] = true,
	["STEAM:0:1_055161131"] = true,
	["STEAM:0:1_055161131"] = true,
}

MConf.WhitelistBypassRanks = { -- groups allowed to bypass the whitelist
	["mod"] = true,
	["head-admin"] = true,
}