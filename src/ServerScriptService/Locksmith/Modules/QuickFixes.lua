-- Copyright (©) 2024 Metatable Games
-- Written by vq9o
-- License: The Unlicense
-- GitHub: https://github.com/RAMPAGELLC/Locksmith

local function generic_pattern_removal(pattern, scriptContainer: Script?)
	local instances = scriptContainer and {scriptContainer} or {}

	if #instances == 0 then
		for _, descendant in ipairs(game.StarterGui:GetDescendants()) do
			table.insert(instances, descendant)
		end
		for _, descendant in ipairs(game.ServerScriptService:GetDescendants()) do
			table.insert(instances, descendant)
		end
		for _, descendant in ipairs(game.Workspace:GetDescendants()) do
			table.insert(instances, descendant)
		end
	end

	for _, instance in ipairs(instances) do
		if instance:IsA("Script") or instance:IsA("ModuleScript") or instance:IsA("LocalScript") then
			local source = instance.Source
			source = source:gsub(pattern, "")
			instance.Source = source

			warn("Locksmith Quick-Removal™ has removed a virus pattern from " .. instance.Name)
		end
	end
end

return {
	-- [flagName] = { stringPattern, fixFunction }

	["RoSync"] = {
		"--%[%[ Last [sS]ynced(.*)",
		generic_pattern_removal,	
	};	
	["Suspicious Chat Spoofing"] = {
		"DefaultChatSystemChatEvents%.SayMessageRequest:FireServer",
		generic_pattern_removal,	
	};
	["Name Spoofing"] = {
		"script%.Name = ",
		generic_pattern_removal,	
	};
	["Hidden String Encoder"] = {
		"string%.char%(%)",
		generic_pattern_removal,	
	};
	["Bytecode Loader"] = {
		"string%.byte%(%)",
		generic_pattern_removal,	
	};
	["getfenv"] = {
		"getfenv%(.+%)%[.+%]",
		generic_pattern_removal,	
	};
	["Environment Manipulation"] = {
		"setfenv%(.+%, getfenv%()",
		generic_pattern_removal,	
	};
	["Loadstring"] = {
		"loadstring%(.+%)",
		generic_pattern_removal,	
	};
	["Server Crasher"] = {
		"while true do wait%(0%.1%)",
		generic_pattern_removal,	
	};
}