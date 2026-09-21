-- Sort the Storage panel and the quest items strip when their items change,
-- if the matching option is enabled.
--
-- Lua 5.0.2: no "#" operator (use table.getn), no getglobal (use _G).

----------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------

local SORTING_LIBRARY = "assaqi_sorting"

local SORT_STORAGE_KEY = AutoSortStorageAndQuestItems.SORT_STORAGE_KEY
local SORT_QUEST_ITEMS_KEY = AutoSortStorageAndQuestItems.SORT_QUEST_ITEMS_KEY

local DEFAULT_COLUMN_COUNT = 10
local DEFAULT_ROW_COUNT = 16

----------------------------------------------------------------------
-- Reading the options
----------------------------------------------------------------------

local function IsSettingEnabled(key)
	local status, result = pcall(function()
		return CHardwareDependantSettingsManager:Instance():GetSetting("C" .. key .. "Setting"):GetValue()
	end)

	if status and result ~= nil then
		return result ~= 0
	end
	return true
end

local function IsStorageSortingEnabled()
	return IsSettingEnabled(SORT_STORAGE_KEY)
end

local function IsQuestItemsSortingEnabled()
	return IsSettingEnabled(SORT_QUEST_ITEMS_KEY)
end

----------------------------------------------------------------------
-- Shared
----------------------------------------------------------------------

local function IsFilling()
	local filling = false

	pcall(function()
		filling = g_GuiInGame.lm_pNewInventoryPanel.lm_bWaitForAllItemsBeforeOpening == true
	end)
	return filling
end

----------------------------------------------------------------------
-- Storage
----------------------------------------------------------------------

local storageApplying = false

local function IsStorageOpen()
	local open = false

	pcall(function()
		open = g_GuiInGame.lm_pNewInventoryPanel:IsStorageOpen() == true
	end)
	return open
end

local function GetColumnCount(panel)
	local count = 0

	pcall(function()
		local row = panel.lm_tRepository[1]

		while row[count + 1] ~= nil do
			count = count + 1
		end
	end)
	if count < 1 then
		return DEFAULT_COLUMN_COUNT
	end
	return count
end

local function GetVisibleRowCount(panel)
	local rows = nil

	pcall(function()
		rows = panel.lm_pPanel.lm_pSkinData.MaxRows
	end)
	if type(rows) ~= "number" or rows < 1 then
		return DEFAULT_ROW_COUNT
	end
	return rows
end

local function GetStorageEntries(panel)
	local entries = {}

	pcall(function()
		for objectId in pairs(panel.lm_tItems) do
			entries[table.getn(entries) + 1] = {
				objectId = objectId,
				key = AutoSortStorageAndQuestItems.BuildSortKey(objectId)
			}
		end
	end)
	return entries
end

local function ApplyStorageLayout(panel, entries)
	local itemCount = panel.lm_nItemCount
	local index = 1

	while index <= table.getn(entries) do
		local entry = entries[index]
		local slot = panel.lm_tItems[entry.objectId]

		if slot ~= nil then
			slot.X = entry.x
			slot.Y = entry.y
		end
		index = index + 1
	end

	panel.lm_nMaxY = GetVisibleRowCount(panel)
	panel.lm_nYOffset = 0
	panel:MoveItemsInPanel()
	panel.lm_nItemCount = itemCount
	panel:UpdateScrollBar()
end

local function SortStorage(panel)
	if not IsStorageSortingEnabled() then
		return
	end
	if panel == nil or storageApplying or not IsStorageOpen() then
		return
	end
	if not AutoSortStorageAndQuestItems.LoadReferenceTables() then
		return
	end

	local entries = GetStorageEntries(panel)

	if table.getn(entries) < 2 then
		return
	end

	local columnCount = GetColumnCount(panel)
	local ordered = pcall(function()
		table.sort(entries, AutoSortStorageAndQuestItems.MakeComparer())
		AutoSortStorageAndQuestItems.LayOutItems(entries, columnCount)
	end)

	if not ordered then
		return
	end

	storageApplying = true

	pcall(function()
		ApplyStorageLayout(panel, entries)
	end)

	storageApplying = false
end

local pendingStorage = nil

local function SortPendingStorage()
	local panel = pendingStorage

	pendingStorage = nil
	if panel ~= nil then
		pcall(function()
			SortStorage(panel)
		end)
	end
end

local function RequestStorageSort(panel)
	pendingStorage = panel

	local scheduled = pcall(function()
		g_Module:RemoveTimerByFunction(SortPendingStorage)
		g_Module:AddTimer(SortPendingStorage, {}, 0, "SortStorage", true)
	end)

	if not scheduled then
		SortPendingStorage()
	end
end

local function InstallStorageSort()
	if type(CGuiNewTransferPanel) ~= "table" then
		return
	end

	local addItem = CGuiNewTransferPanel.AddItem

	if type(addItem) ~= "function" then
		return
	end

	CGuiNewTransferPanel.AddItem = function(self, x, y, objectId, skinned)
		local known = true

		pcall(function()
			known = self.lm_tItems[objectId] ~= nil
		end)

		local result = addItem(self, x, y, objectId, skinned)

		if not known and not storageApplying and not IsFilling() then
			pcall(function()
				RequestStorageSort(self)
			end)
		end
		return result
	end

	local removeItem = CGuiNewTransferPanel.RemoveItem

	if type(removeItem) == "function" then
		CGuiNewTransferPanel.RemoveItem = function(self, objectId)
			local result = removeItem(self, objectId)

			if not storageApplying then
				pcall(function()
					RequestStorageSort(self)
				end)
			end
			return result
		end
	end
end

----------------------------------------------------------------------
-- Quest items
----------------------------------------------------------------------

local questItemsApplying = false

local function SortQuestItems(panel)
	if not IsQuestItemsSortingEnabled() then
		return
	end
	if panel == nil or questItemsApplying or panel.lm_bAlchemyVersion or panel.lm_bActive ~= true then
		return
	end
	if not AutoSortStorageAndQuestItems.LoadReferenceTables() then
		return
	end

	local slots = panel.lm_tQuestItems

	if table.getn(slots) < 2 then
		return
	end

	local entries = {}
	local index = 1

	while index <= table.getn(slots) do
		entries[index] = {
			slot = slots[index],
			key = AutoSortStorageAndQuestItems.BuildSortKey(slots[index].Item)
		}
		index = index + 1
	end

	local sorted = pcall(function()
		table.sort(entries, AutoSortStorageAndQuestItems.MakeComparer())
	end)

	if not sorted then
		return
	end

	questItemsApplying = true

	pcall(function()
		local i = 1

		while i <= table.getn(entries) do
			slots[i] = entries[i].slot
			i = i + 1
		end
		panel:CheckQuestItemStart()
		panel:RefreshQuestItems()
	end)

	questItemsApplying = false
end

local pendingQuestItems = nil

local function SortPendingQuestItems()
	local panel = pendingQuestItems

	pendingQuestItems = nil
	if panel ~= nil then
		pcall(function()
			SortQuestItems(panel)
		end)
	end
end

local function RequestQuestItemsSort(panel)
	pendingQuestItems = panel

	local scheduled = pcall(function()
		g_Module:RemoveTimerByFunction(SortPendingQuestItems)
		g_Module:AddTimer(SortPendingQuestItems, {}, 0, "SortQuestItems", true)
	end)

	if not scheduled then
		SortPendingQuestItems()
	end
end

local function InstallQuestItemsSort()
	if type(CGuiNewRepositoryPanel) ~= "table" then
		return
	end

	local addQuestItem = CGuiNewRepositoryPanel.AddItem

	if type(addQuestItem) ~= "function" then
		return
	end

	CGuiNewRepositoryPanel.AddItem = function(self, x, y, objectId, addAction)
		local before = 0

		pcall(function()
			before = self.lm_nQuestItems
		end)

		local result = addQuestItem(self, x, y, objectId, addAction)

		if not questItemsApplying and not IsFilling() then
			pcall(function()
				if self.lm_nQuestItems > before then
					RequestQuestItemsSort(self)
				end
			end)
		end
		return result
	end
end

----------------------------------------------------------------------
-- Installation
----------------------------------------------------------------------

local function InstallSorting()
	pcall(function()
		g_Lua:PlayFile(SORTING_LIBRARY)
	end)
	if type(AutoSortStorageAndQuestItems.BuildSortKey) ~= "function" then
		return
	end
	if type(CGuiNewInventoryPanel) ~= "table" then
		return
	end

	local endOfItems = CGuiNewInventoryPanel.EndOfItems

	if type(endOfItems) ~= "function" then
		return
	end

	pcall(InstallStorageSort)
	pcall(InstallQuestItemsSort)

	CGuiNewInventoryPanel.EndOfItems = function(self)
		local result = endOfItems(self)

		pcall(function()
			SortStorage(self.lm_pTransferPanel)
		end)
		pcall(function()
			SortQuestItems(self.lm_pRepositoryPanel)
		end)
		return result
	end
end

pcall(InstallSorting)
