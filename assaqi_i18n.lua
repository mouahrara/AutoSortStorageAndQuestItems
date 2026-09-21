-- Translate the mod strings into the game's text language, English by default.
--
-- Lua 5.0.2: no "#" operator (use table.getn), no getglobal (use _G).

local FALLBACK_LANGUAGE = "en"

-- GetClientTextLanguage() identifiers, mapped to language codes.
local LANGUAGE_CODES = {
	[3] = "en",
	[5] = "pl",
	[10] = "de",
	[11] = "fr",
	[12] = "es",
	[13] = "it",
	[14] = "ru",
	[15] = "cs",
	[16] = "hu",
	[21] = "zh"
}

local TRANSLATIONS = {
	SortStorage = {
		en = "Sort Storage",
		fr = "Trier le coffre"
	},
	SortStorageTooltip = {
		en = "Toggle storage sorting",
		fr = "Activer / désactiver le tri du coffre"
	},
	SortQuestItems = {
		en = "Sort Quest Items",
		fr = "Trier les objets de quête"
	},
	SortQuestItemsTooltip = {
		en = "Toggle quest item sorting",
		fr = "Activer / désactiver le tri des objets de quête"
	}
}

local function GetLanguageCode()
	local read, identifier = pcall(function()
		return getClientExoApp():GetClientTextLanguage()
	end)

	if not read then
		return FALLBACK_LANGUAGE
	end
	return LANGUAGE_CODES[identifier] or FALLBACK_LANGUAGE
end

function AutoSortStorageAndQuestItems.Translate(key)
	local entry = TRANSLATIONS[key]

	if entry == nil then
		return key
	end
	return entry[GetLanguageCode()] or entry[FALLBACK_LANGUAGE] or key
end
