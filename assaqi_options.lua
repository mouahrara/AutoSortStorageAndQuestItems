-- Add the two sorting options and their section title to Options > Gameplay.
--
-- Lua 5.0.2: no "#" operator (use table.getn), no getglobal (use _G).

----------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------

local I18N_LIBRARY = "assaqi_i18n"

local MOD_PREFIX = AutoSortStorageAndQuestItems.PREFIX
local MOD_DISPLAY_NAME = "Auto-Sort Storage And Quest Items"
local SETTINGS_CATEGORY = "Gameplay"
local SORT_STORAGE_KEY = AutoSortStorageAndQuestItems.SORT_STORAGE_KEY
local SORT_STORAGE_TOOLTIP_KEY = SORT_STORAGE_KEY .. "Tooltip"
local SORT_QUEST_ITEMS_KEY = AutoSortStorageAndQuestItems.SORT_QUEST_ITEMS_KEY
local SORT_QUEST_ITEMS_TOOLTIP_KEY = SORT_QUEST_ITEMS_KEY .. "Tooltip"

-- Setting labels sit at X = 3.825, controls at X = 4.705.
local SECTION_LABEL_X = 4
local SECTION_LABEL_FONT = "gui_huge"
local SECTION_LABEL_COLOR = {0.78, 0.67, 0.42}
local SECTION_SPACE_ABOVE = 0.44
local SECTION_SPACE_BELOW = 0.04
local SECTION_LABEL_HEIGHT = 0.32
local SECTION_TOTAL_HEIGHT = SECTION_SPACE_ABOVE + SECTION_LABEL_HEIGHT + SECTION_SPACE_BELOW

----------------------------------------------------------------------
-- Settings
----------------------------------------------------------------------

local SortStorageSetting
local SortQuestItemsSetting

local function DeclareSortStorageSetting()
	SortStorageSetting = makeClass(CCheckBoxSetting)

	function SortStorageSetting:new()
		return SortStorageSetting:create()
	end

	function SortStorageSetting:GetClassName()
		return SORT_STORAGE_KEY
	end

	function SortStorageSetting:GetCategory()
		return SETTINGS_CATEGORY
	end

	function SortStorageSetting:GetDefaultValue()
		return 1
	end

	function SortStorageSetting:GetSettingName()
		return AutoSortStorageAndQuestItems.Translate("SortStorage")
	end

	function SortStorageSetting:GetSettingTooltip()
		return SORT_STORAGE_TOOLTIP_KEY
	end

	function SortStorageSetting:ApplyChanges()
		self:ApplyChangesInternal()
	end
end

local function DeclareSortQuestItemsSetting()
	SortQuestItemsSetting = makeClass(CCheckBoxSetting)

	function SortQuestItemsSetting:new()
		return SortQuestItemsSetting:create()
	end

	function SortQuestItemsSetting:GetClassName()
		return SORT_QUEST_ITEMS_KEY
	end

	function SortQuestItemsSetting:GetCategory()
		return SETTINGS_CATEGORY
	end

	function SortQuestItemsSetting:GetDefaultValue()
		return 1
	end

	function SortQuestItemsSetting:GetSettingName()
		return AutoSortStorageAndQuestItems.Translate("SortQuestItems")
	end

	function SortQuestItemsSetting:GetSettingTooltip()
		return SORT_QUEST_ITEMS_TOOLTIP_KEY
	end

	function SortQuestItemsSetting:ApplyChanges()
		self:ApplyChangesInternal()
	end
end

local function RegisterSettings()
	DeclareSortStorageSetting()
	DeclareSortQuestItemsSetting()

	local settings = {SortStorageSetting:new(), SortQuestItemsSetting:new()}
	local index = 1

	while index <= table.getn(settings) do
		RegisterLuaSetting(settings[index])
		settings[index]:Read()
		index = index + 1
	end
end

----------------------------------------------------------------------
-- Tooltips
----------------------------------------------------------------------

local function RegisterTooltips()
	if type(g_tSettingsDescriptions) ~= "table" then
		g_tSettingsDescriptions = {}
	end
	g_tSettingsDescriptions[SORT_STORAGE_TOOLTIP_KEY] = function()
		return AutoSortStorageAndQuestItems.Translate("SortStorageTooltip")
	end
	g_tSettingsDescriptions[SORT_QUEST_ITEMS_TOOLTIP_KEY] = function()
		return AutoSortStorageAndQuestItems.Translate("SortQuestItemsTooltip")
	end
end

----------------------------------------------------------------------
-- Section title
----------------------------------------------------------------------

local function BuildSectionLabelDefinition(y)
	return {
		Type = "String",
		Position = {Aurora = {X = SECTION_LABEL_X, Y = y, Z = 1}},
		String = MOD_DISPLAY_NAME,
		Font = SECTION_LABEL_FONT,
		Alignment = "Centered",
		WordWrap = false,
		Color = {
			R = SECTION_LABEL_COLOR[1],
			G = SECTION_LABEL_COLOR[2],
			B = SECTION_LABEL_COLOR[3]
		}
	}
end

local function DrawSectionLabel(settingsPanel, contentPanel)
	pcall(function()
		settingsPanel.lm_nPosY = settingsPanel.lm_nPosY - SECTION_SPACE_ABOVE
		CDefineGUIPanel:DefineControl(contentPanel, MOD_PREFIX .. "SectionLabel", BuildSectionLabelDefinition(settingsPanel.lm_nPosY), g_aGuiDefinitions.EmptyContentPanel, {})
		settingsPanel.lm_nPosY = settingsPanel.lm_nPosY - SECTION_LABEL_HEIGHT - SECTION_SPACE_BELOW
	end)
end

local function HookSectionLabel()
	local liftPending = false
	local createSettingList = CGuiNewSystemSettingsPanel.CreateSettingList

	CGuiNewSystemSettingsPanel.CreateSettingList = function(self, contentPanel, items, categoryName)
		liftPending = categoryName == SETTINGS_CATEGORY

		local height = createSettingList(self, contentPanel, items, categoryName)

		liftPending = false
		if categoryName == SETTINGS_CATEGORY then
			return height + SECTION_TOTAL_HEIGHT
		end
		return height
	end

	local addSetting = CGuiNewSystemSettingsPanel.AddSetting

	CGuiNewSystemSettingsPanel.AddSetting = function(self, contentPanel, items, setting, count)
		local isFirstModSetting = false

		RegisterTooltips()
		if liftPending then
			liftPending = false
			self.lm_nPosY = self.lm_nPosY + SECTION_TOTAL_HEIGHT
		end
		pcall(function()
			isFirstModSetting = setting:GetSettingTooltip() == SORT_STORAGE_TOOLTIP_KEY
		end)
		if isFirstModSetting then
			DrawSectionLabel(self, contentPanel)
		end

		local added, result = pcall(function()
			return addSetting(self, contentPanel, items, setting, count)
		end)

		if not added then
			return
		end
		return result
	end
end

----------------------------------------------------------------------
-- Installation
----------------------------------------------------------------------

g_Lua:PlayFile(I18N_LIBRARY)
if type(AutoSortStorageAndQuestItems.Translate) ~= "function" then
	return
end

pcall(RegisterSettings)
HookSectionLabel()
