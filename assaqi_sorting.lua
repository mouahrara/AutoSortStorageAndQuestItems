-- Sort items and lay them out on a grid. The order is shared by the Storage panel
-- and the quest items strip.
--
-- Order: quest item rank (see QUEST_ORDER), item type, market category,
-- alchemy substance, main tag, full tag, stack size (largest first).
--
-- Lua 5.0.2: no "#" operator (use table.getn), no getglobal (use _G).

----------------------------------------------------------------------
-- Orders
----------------------------------------------------------------------

local QUEST_ORDER = {
	-- Major artifacts and main quest gear
	"it_quest_163",		-- Witcher's medallion
	"bere_medall",		-- Berengar's Medallion
	"it_quest_117",		-- Split salamander brooch
	"it_quest_214",		-- Teleporting crystal
	"q3043_cm",			-- Magic sensor
	"seeing_stone",		-- Seeing Stone
	"it_quest_177",		-- Dimeritium amulet
	"it_quest_203",		-- Piece of armor
	"it_quest_204",		-- Remains of Raven's armor
	"it_quest_190",		-- Secrets stolen from Kaer Morhen
	-- Sefirot
	"seph_maalkad",		-- Maal'kad Sephirah
	"seph_veenah",		-- Veen'ah Sephirah
	"seph_ghevrath",	-- Ghe'vrath Sephirah
	"seph_oth",			-- Oth Sephirah
	"seph_kethaar",		-- Keth'aar Sephirah
	"seph_choccmah",	-- Chocc'mah Sephirah
	"seph_kezath",		-- Kezath Sephirah
	"seph_tipperath",	-- Tipperath Sephirah
	"seph_yesath",		-- Y'esath Sephirah
	"seph_nehtza",		-- Neh'tza Sephirah
	-- Alina and the vodyanoi
	"it_quest_185",		-- Alina's garland
	"it_quest_175",		-- Shard of Alina's mirror
	"it_quest_176",		-- Alina's broken mirror
	"it_quest_192",		-- Wreath of immortelles
	"amulet_vodianoi",	-- Vodyanoi amulet
	"it_quest_181",		-- Alabaster figurine
	"it_quest_186",		-- Priest's staff
	"it_quest_179",		-- Vodyanoi ring
	-- Ingredients, potions and consumables
	"it_potion_015",	-- Potion for Triss
	"it_potion_015/227",-- Potion for Triss (alchemy stages)
	"it_quest_162",		-- Coating
	"q1005_vial",		-- Glass vial
	"philter_ill",		-- Anti-illusion philter
	"lycan_cure",		-- Lycanthropy cure
	"ingn_potion",		-- Combustible mixture
	"grandma_grease",	-- Grandma's pickles and lard
	"grandma_tincture",	-- Grandma's cordial
	"it_quest_197",		-- Yellow milk
	"it_quest_210",		-- Catoblepas meat
	"psilocyb",			-- Psilocybe
	"it_quest_135",		-- Glean Enid
	-- Jewelry, gems and valuables
	"family_ring",		-- Family ring
	"it_quest_149",		-- Isa's beads
	"it_quest_193",		-- Turquoise necklace
	"it_quest_212",		-- Brooch
	"skarb_q3023",		-- Dwarf's treasure
	"item_q3011",		-- Sapphire
	"it_quest_180",		-- Gramps' diamond
	"it_quest_182",		-- Gold bracelet
	"it_quest_183",		-- The Lady of the Lake's ruby
	"it_quest_184",		-- Golden calf
	-- Miscellaneous quest objects
	"it_quest_194",		-- Human remains
	"pack_bandit_q1010",-- Bandit's package
	"eternal_fire",		-- Holy Flame
	"card_tower",		-- Tower Tarot card
	"jaskier_lute",		-- Dandelion's lute
	"it_quest_196",		-- Cat harness
	"it_quest_195",		-- Four-leaf clover
	"it_quest_200",		-- Bifunctional fiber and alloy recirculator
	"mg_dices_box",		-- Dice box
	"lightning_rod",	-- Lightning rod
	"it_quest_206",		-- Famous fist fighter's tooth
	-- Documents, books, letters and warrants
	"q3021_key",		-- Key to Salamandra code
	"warrant_q1014",	-- Arrest warrant
	"it_quest_169",		-- Letter of safe conduct
	"safe_conduct",		-- Royal letter of safe conduct
	"it_quest_208",		-- Letter of safe conduct issued by the City Militia
	"it_quest_209",		-- Letter of safe conduct issued by the City Militia
	"it_quest_152",		-- Letter of recommendation
	"it_quest_156",		-- Letter from Gellert Bleinheim
	"it_quest_157",		-- Salamandra documents
	"q3021_encrypt",	-- Encrypted document
	"q3021_decrypt",	-- Decrypted document
	"letter_leuv",		-- Blood-stained letter
	"letter_yaevin",	-- Yaevinn's letter
	"letter_vivaldi",	-- Vivaldi's Letter
	"it_quest_211",		-- Vizima cemetery pass
	"it_quest_171",		-- Mysterious note
	"it_quest_187",		-- Berengar's letter
	"it_quest_188",		-- The Professor's Report
	"it_quest_198",		-- Receipt
	"it_quest_202",		-- Magic formula
	"it_quest_205",		-- Royal edicts
	"it_quest_207",		-- Notes of an elven minstrel
	"it_quest_213",		-- List of suspects
	"it_quest_229",		-- Kalkstein's notes
	"Letter_q1014",		-- Bandit's letter
	"it_quest_188/114",	-- Letter from the Professor
	"it_quest_215",		-- Letter from Triss
	"it_quest_218",		-- Letter to Triss
	"it_quest_219",		-- Letter to Triss
	"it_quest_220",		-- Letter to Triss
	"it_quest_221",		-- Letter to Triss
	"it_quest_216",		-- Letter from Shani
	"it_quest_222",		-- Letter to Shani
	"it_quest_223",		-- Letter to Shani
	"it_quest_224",		-- Letter to Shani
	"it_quest_225",		-- Letter to Shani
	"it_quest_201",		-- St. Gregory's Litany
	"it_quest_230",		-- The Legend of Saint Gregory
	"it_quest_164",		-- Berengar's notes on the Beast
	"it_quest_189",		-- Ostrit's journal
	"grandma_diary",	-- Grandma's diary
	"it_scroll_008",	-- The Secret Gates
	"it_scroll_009",	-- Ain Soph Aur
	"it_quest_142",		-- Tower mage's book
	-- Keys
	"q3013_base",		-- Power Stone
	"L09_G28_01",		-- Leuvaarden's key
	"L09_G29_01",		-- Scheffer's key
	"L09_G29_02",		-- Grabek's key
	"L09_G28_09",		-- Pograbek's key
	"L09_G15_01",		-- Reverand's key
	"L09_G11_01",		-- Teterer's key
	"key_l04_g35_03",	-- Old key
	"it_key_018",		-- Key
	"key_crypt",		-- Key
	"key_l04_g35_01",	-- Key
	"king_key",			-- Key
	"L09_G06_01",		-- Haren's key
	"L09_G28_04",		-- Ferner's key
	"leuv_door",		-- Horold's key
	"q3016_kosa",		-- Angus' key
	"q3016_door",		-- Bandit's key
	"it_key_019",		-- Key
	"key_cementery",	-- Key
	"key_l04_g35_02",	-- Key
	"q2127",			-- Key
	"q3042_cityhall",	-- Key
	"q3051_army",		-- Key
	"sewers_key/231",	-- Key to the sewers
	"q6001_key_zeugl",	-- Key
	"q6001_key_order",	-- Key
	"it_key_021",		-- Key
	"q1001_inn",		-- Large brass key
	"key_sewers",		-- Key
	"q3042_storage",	-- Key
	"it_key_026",		-- Key
	"sewers_key",		-- Key
	"it_key_020",		-- Key
	"q6001_key",		-- Key
	"q2019",			-- Key
	"it_key_028",		-- Key
}

local TYPE_ORDER = {
	"steelsword",
	"silversword",
	"dagger",
	"long_axe",
	"long_club",
	"long_flail",
	"short_axe",
	"short_club",
	"short_flail",
	"pole_halberd",
	"pole_spear",
	"staff",
	"crossbow",
	"bow",
	"echin_bow",
	"sling",
	"thrown_arms",
	"ammunition_arrow",
	"ammunition_bolt",
	"witcher_armor",
	"shield",
	"upgrade_component",
	"grease",
	"ring",
	"magical_ring",
	"necklace",
	"magical_necklace",
	"medalion",
	"gem",
	"gold",
	"trophy",
	"ingredient",
	"alch_base",
	"potion",
	"potion_poison",
	"potion_unfinished",
	"bomb",
	"drink",
	"food",
	"quest",
	"scroll",
	"key",
	"torch",
	"dice",
	"mg_dice",
	"other",
	"fists",
	"natural",
	"natural_ranged",
	"improvised",
	"thorn",
	"gabriel",
	"spell",
	"spellranged",
	"sp_rngd_amm",
	"npcwork",
	"it_work",
	"NULL_ITEM",
}

local CATEGORY_ORDER = {
	"Weapon",
	"SilverSword",
	"WeaponUp",
	"Armor",
	"torch",
	"Value",
	"Trophy",
	"cloth",
	"Ingredient",
	"MonsterIngredient",
	"herb",
	"flower",
	"grease",
	"powder",
	"WitherAlchemy",
	"Alchemy",
	"Food",
	"Candy",
	"Alcohol",
	"AlcoholStrong",
	"Book",
	"Dice",
	"Illegal",
}

local SUBSTANCE_ORDER = {
	"Vitriol",
	"Rebis",
	"Aether",
	"Quebrith",
	"Hydragenum",
	"Vermilion",
}

local questRankByKey = {}
do
	local index = 1

	while index <= table.getn(QUEST_ORDER) do
		questRankByKey[QUEST_ORDER[index]] = index
		index = index + 1
	end
end

----------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------

local UNRANKED = 9999
local NO_SUBSTANCE = 99
local UNIQUE_SUBSTANCE = 6

----------------------------------------------------------------------
-- Cache
----------------------------------------------------------------------

local typeRankByBaseItem = nil
local categoryRankByMarketCat = nil
local substanceByIngredient = nil

----------------------------------------------------------------------
-- Reference tables
--
-- Ranks the game's 2da rows against the orders above, by label. Read
-- lazily on the first attempt to sort, then cached.
----------------------------------------------------------------------

local function Trim(text)
	local _, _, trimmed = string.find(text, "^%s*(.-)%s*$")

	return trimmed or text
end

local function BuildRankTable(fileName, order)
	local rankByLabel = {}
	local index = 1

	while index <= table.getn(order) do
		rankByLabel[string.lower(order[index])] = index
		index = index + 1
	end

	local ranks = {}
	local file = C2DA:new(fileName, false)

	file:Load2DArray()

	local rowCount = file:GetNumRows()
	local row = 0

	while row <= rowCount - 1 do
		local _, _, label = file:GetCExoStringEntry(row, "Label", "")

		if label ~= nil then
			local rank = rankByLabel[string.lower(Trim(label))]

			if rank ~= nil then
				ranks[row] = rank
			end
		end
		row = row + 1
	end
	file:Unload2DArray()
	file:delete()
	return ranks
end

function AutoSortStorageAndQuestItems.LoadReferenceTables()
	if typeRankByBaseItem ~= nil then
		return true
	end

	local loaded = pcall(function()
		typeRankByBaseItem = BuildRankTable("baseitems", TYPE_ORDER)
		categoryRankByMarketCat = BuildRankTable("marketcat", CATEGORY_ORDER)

		substanceByIngredient = {}

		local ingredients = C2DA:new("alchemy_ingre", false)

		ingredients:Load2DArray()

		local rowCount = ingredients:GetNumRows()

		for row = 0, rowCount - 1 do
			local _, _, unique = ingredients:GetCExoStringEntry(row, "Unique", "")

			if unique ~= nil and unique ~= "" and unique ~= " " then
				substanceByIngredient[row] = UNIQUE_SUBSTANCE
			else
				local substance = nil
				local column = 1

				while column <= table.getn(SUBSTANCE_ORDER) do
					local _, _, rawValue = ingredients:GetCExoStringEntry(row, SUBSTANCE_ORDER[column], "")
					local value = tonumber(rawValue)

					if value ~= nil and value ~= 0 then
						substance = column - 1
					end
					column = column + 1
				end
				substanceByIngredient[row] = substance or (UNIQUE_SUBSTANCE + 1)
			end
		end
		ingredients:Unload2DArray()
		ingredients:delete()
	end)

	if not loaded then
		typeRankByBaseItem = nil
		categoryRankByMarketCat = nil
		substanceByIngredient = nil
	end
	return loaded
end

----------------------------------------------------------------------
-- Main tag
----------------------------------------------------------------------

function AutoSortStorageAndQuestItems.GetMainTag(tag)
	if tag == nil or tag == "" then
		return ""
	end

	local parts = {}
	local remainder = tag

	while true do
		local separator = string.find(remainder, ";", 1, true)

		if separator == nil then
			parts[table.getn(parts) + 1] = Trim(remainder)
			break
		end
		parts[table.getn(parts) + 1] = Trim(string.sub(remainder, 1, separator - 1))
		remainder = string.sub(remainder, separator + 1)
	end

	local index = 1

	while index <= table.getn(parts) do
		if string.find(parts[index], "^it_") then
			return parts[index]
		end
		index = index + 1
	end
	index = 1
	while index <= table.getn(parts) do
		if string.find(parts[index], "_%d+$") then
			return parts[index]
		end
		index = index + 1
	end
	return parts[1] or tag
end

----------------------------------------------------------------------
-- Natural comparison
----------------------------------------------------------------------

function AutoSortStorageAndQuestItems.CompareNatural(left, right)
	if left == right then
		return false
	end

	local leftIndex, rightIndex = 1, 1
	local leftLength, rightLength = string.len(left), string.len(right)

	while leftIndex <= leftLength and rightIndex <= rightLength do
		local leftIsDigit = string.find(left, "^%d", leftIndex)
		local rightIsDigit = string.find(right, "^%d", rightIndex)

		if leftIsDigit and rightIsDigit then
			local _, leftEnd, leftDigits = string.find(left, "^(%d+)", leftIndex)
			local _, rightEnd, rightDigits = string.find(right, "^(%d+)", rightIndex)
			local leftNumber, rightNumber = tonumber(leftDigits), tonumber(rightDigits)

			if leftNumber ~= rightNumber then
				return leftNumber < rightNumber
			end
			leftIndex, rightIndex = leftEnd + 1, rightEnd + 1
		else
			local leftChar = string.sub(left, leftIndex, leftIndex)
			local rightChar = string.sub(right, rightIndex, rightIndex)

			if leftChar ~= rightChar then
				return leftChar < rightChar
			end
			leftIndex, rightIndex = leftIndex + 1, rightIndex + 1
		end
	end
	if leftLength ~= rightLength then
		return leftLength < rightLength
	end
	return left < right
end

----------------------------------------------------------------------
-- Sort keys
----------------------------------------------------------------------

function AutoSortStorageAndQuestItems.BuildSortKey(objectId)
	local key = {
		questRank = UNRANKED,
		typeRank = UNRANKED,
		categoryRank = UNRANKED,
		substance = NO_SUBSTANCE,
		mainTag = "",
		tag = "",
		stack = 1,
		width = 1,
		height = 1
	}

	pcall(function()
		local item = g_pClientExoApp:GetItemByGameObjectID(objectId)

		if item == nil then
			return
		end

		local model = item:GetModelPart(0) or 0

		key.typeRank = typeRankByBaseItem[item:GetBaseItemID()] or UNRANKED
		key.categoryRank = categoryRankByMarketCat[item:GetMarketCategory()] or UNRANKED
		key.tag = item:GetObjectTag() or ""
		key.mainTag = AutoSortStorageAndQuestItems.GetMainTag(key.tag)
		key.questRank = questRankByKey[key.mainTag .. "/" .. model] or questRankByKey[key.mainTag] or UNRANKED
		key.stack = item:GetStackSize() or 1
		key.width = item:GetInvSlotWidth() or 1
		key.height = item:GetInvSlotHeight() or 1

		if item:GetAlchemyIngredient() ~= nil then
			local ingredient = item:GetAlchemyIngredientIndex()

			if ingredient ~= nil and substanceByIngredient[ingredient] ~= nil then
				key.substance = substanceByIngredient[ingredient]
			end
		end

	end)
	return key
end

function AutoSortStorageAndQuestItems.MakeComparer()
	return function(left, right)
		local first, second = left.key, right.key

		if first.questRank ~= second.questRank then
			return first.questRank < second.questRank
		end
		if first.typeRank ~= second.typeRank then
			return first.typeRank < second.typeRank
		end
		if first.categoryRank ~= second.categoryRank then
			return first.categoryRank < second.categoryRank
		end
		if first.substance ~= second.substance then
			return first.substance < second.substance
		end
		if first.mainTag ~= second.mainTag then
			return AutoSortStorageAndQuestItems.CompareNatural(first.mainTag, second.mainTag)
		end
		if first.tag ~= second.tag then
			return AutoSortStorageAndQuestItems.CompareNatural(first.tag, second.tag)
		end
		if first.stack ~= second.stack then
			return first.stack > second.stack
		end
		return false
	end
end

----------------------------------------------------------------------
-- Layout
----------------------------------------------------------------------

function AutoSortStorageAndQuestItems.LayOutItems(entries, columnCount)
	local occupied = {}

	local function IsFree(x, y, width, height)
		local offsetY = 0

		while offsetY <= height - 1 do
			local offsetX = 0

			while offsetX <= width - 1 do
				if x + offsetX > columnCount - 1 then
					return false
				end
				if occupied[(y + offsetY) * columnCount + (x + offsetX)] then
					return false
				end
				offsetX = offsetX + 1
			end
			offsetY = offsetY + 1
		end
		return true
	end

	local function Occupy(x, y, width, height)
		local offsetY = 0

		while offsetY <= height - 1 do
			local offsetX = 0

			while offsetX <= width - 1 do
				occupied[(y + offsetY) * columnCount + (x + offsetX)] = true
				offsetX = offsetX + 1
			end
			offsetY = offsetY + 1
		end
	end

	local usedRows = 0
	local index = 1

	while index <= table.getn(entries) do
		local entry = entries[index]
		local width = entry.key.width
		local height = entry.key.height
		local placed = false
		local y = 0

		if width < 1 then
			width = 1
		end
		if width > columnCount then
			width = columnCount
		end
		if height < 1 then
			height = 1
		end
		while not placed do
			local x = 0

			while x <= columnCount - 1 do
				if IsFree(x, y, width, height) then
					Occupy(x, y, width, height)
					entry.x, entry.y = x, y
					if y + height > usedRows then
						usedRows = y + height
					end
					placed = true
					break
				end
				x = x + 1
			end
			if not placed then
				y = y + 1
			end
		end
		index = index + 1
	end
	return usedRows
end
