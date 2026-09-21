-- Load assaqi_options once the game has loaded its settings panel script, and
-- assaqi_panels once it has loaded its inventory panel script.
--
-- Lua 5.0.2: no "#" operator (use table.getn), no getglobal (use _G).

if AutoSortStorageAndQuestItems ~= nil then
	return
end

AutoSortStorageAndQuestItems = {}

----------------------------------------------------------------------
-- Shared names
----------------------------------------------------------------------

AutoSortStorageAndQuestItems.PREFIX = "AutoSortStorageAndQuestItems"
AutoSortStorageAndQuestItems.SORT_STORAGE_KEY = AutoSortStorageAndQuestItems.PREFIX .. "SortStorage"
AutoSortStorageAndQuestItems.SORT_QUEST_ITEMS_KEY = AutoSortStorageAndQuestItems.PREFIX .. "SortQuestItems"

----------------------------------------------------------------------
-- Entry point
----------------------------------------------------------------------

local LIBRARY_BY_SCRIPT = {
	gui_new_system_settingspanel = "assaqi_options",
	gui_new_inventory = "assaqi_panels"
}

local loaded = {}
local luaMetatable = getmetatable(g_Lua)
local playFile = luaMetatable.PlayFile

luaMetatable.PlayFile = function(self, name, optional)
	local result = playFile(self, name, optional)
	local library = LIBRARY_BY_SCRIPT[name]

	if library ~= nil and not loaded[library] then
		loaded[library] = true
		pcall(function()
			g_Lua:PlayFile(library)
		end)
	end
	return result
end
