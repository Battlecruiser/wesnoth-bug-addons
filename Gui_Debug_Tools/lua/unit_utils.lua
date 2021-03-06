-- #textdomain wesnoth-Gui_Debug_Tools
local _ = wesnoth.textdomain "wesnoth-Gui_Debug_Tools"

local gdt_unit = {}

local helper = wesnoth.require "lua/helper.lua"
local utils = wesnoth.require "~add-ons/Gui_Debug_Tools/lua/utils.lua"

-- to make code shorter
local wml_actions = wesnoth.wml_actions

function gdt_unit.abilities ( unit, abilities )
	-- abilities change - adds or removes new abilities via objects, does not affect abilities that come with the unit type
	if abilities ~= "" then
		-- remove existing ability objects
		local u = unit.__cfg -- traits need to be removed by editing a __cfg table
		for tag = #u, 1, -1 do
			if u[tag][1] == "modifications" then
				for subtag = #u[tag][2], 1, -1 do
					if u[tag][2][subtag][1] == "object" and u[tag][2][subtag][2].gdt_id ~= nil then
						table.remove( u[tag][2], subtag )
					end
				end
			end
		end
		wesnoth.put_unit ( u ) -- overwrites original that's still there, preserves underlying_id & proxy access
		wesnoth.transform_unit ( unit, unit.type ) -- the above gets the [object], this gets the [abilities] imparted by the object
		if abilities ~= " " then -- a shortcut if user just wants to clear added objects
			-- chop user entered value
			local ability_sources = { }
			for value in utils.split( abilities ) do
				table.insert ( ability_sources, utils.chop( value ) )
			end
			-- add new abilities, copy from unit_types that have desired abilities
			for i = 1, #ability_sources do
				local new_ability = helper.get_child(wesnoth.unit_types[ability_sources[i]].__cfg, "abilities")
				if new_ability then
					local new_object = { gdt_id = i, delayed_variable_substitution = true, { "effect", { apply_to = "new_ability", { "abilities", new_ability } } } }
					wesnoth.add_modification ( unit, "object", new_object )
				end
			end
		end
	end
end

function gdt_unit.attack ( unit, attack )
	-- attacks - adds or removes new attacks via objects, does not affect attacks that come with the unit type
	if attack ~= "" then
		if attack == " " then -- user just wants to clear added object(s)
			-- remove existing attack objects
			local u = unit.__cfg -- traits need to be removed by editing a __cfg table
			for tag = #u, 1, -1 do
				if u[tag][1] == "modifications" then
					for subtag = #u[tag][2], 1, -1 do
						if u[tag][2][subtag][1] == "object" and u[tag][2][subtag][2].gdt_id == "attack" then
							table.remove( u[tag][2], subtag )
						end
					end
				end
			end
			wesnoth.put_unit ( u ) -- overwrites original that's still there, preserves underlying_id & proxy access
			wesnoth.transform_unit ( unit, unit.type ) -- the above gets the [object], this gets the [attack] imparted by the object
		else
			-- chop user entered value
			local attack_sources = { }
			for value in utils.split( attack ) do
				table.insert ( attack_sources, utils.chop( value ) )
			end
			-- add new attack, copy from unit_type & attack index that has the desired attack
			local new_attack = helper.get_nth_child(wesnoth.unit_types[attack_sources[1]].__cfg, "attack", attack_sources[2])
			if new_attack then
				new_attack.apply_to = "new_attack"
				local new_object = { gdt_id = "attack", delayed_variable_substitution = true, { "effect", new_attack } }
				wesnoth.add_modification ( unit, "object", new_object )
			end
		end
	end
end

function gdt_unit.canrecruit ( unit, value )
	wml_actions.modify_unit { { "filter", { id = unit.id } }, canrecruit = value }
end

function gdt_unit.copy_unit ( unit, bool )
		-- do it this way instead of using wesnoth.copy_unit as
		-- it doesn't handle specified ids (ie, 'Konrad') in
		-- the way that we want it to
	if bool then
		local copy = unit.__cfg
		copy.id, copy.underlying_id = nil, nil
		if copy.x == "recall" and copy.y == "recall" then
			wesnoth.put_recall_unit ( copy )
		else
			local x, y = wesnoth.find_vacant_tile ( copy.x, copy.y, copy )
			wesnoth.put_unit ( x, y, copy )
		end
	end
end

function gdt_unit.gender ( unit, gender )
		if gender ~= unit.__cfg.gender then -- if there are custom portraits, they are lost.
			wml_actions.modify_unit { { "filter", { id = unit.id } }, profile = "", small_profile = "", gender = gender }
			wesnoth.transform_unit ( unit, unit.type ) -- transform refills the profile keys
		end
end

function gdt_unit.generate_name ( unit, bool )
	if bool then
		wml_actions.modify_unit { { "filter", { id = unit.id } }, name = "", generate_name = true }
	end
end

function gdt_unit.get_traits_string ( unit )
	local unit_modifications = helper.get_child ( unit.__cfg, "modifications" ) or {}
	local trait_ids = { }
	for trait in helper.child_range ( unit_modifications, "trait" ) do
			if trait.id ~= nil then
				table.insert ( trait_ids, trait.id )
			end
	end
	return table.concat( trait_ids, "," )
end

function gdt_unit.goto_xy ( unit, str )
		local goto_xy = { }
		for value in utils.split ( str ) do
			table.insert ( goto_xy, utils.chop( value ) )
		end
		wml_actions.modify_unit { { "filter", { id = unit.id } }, goto_x = goto_xy[1], goto_y = goto_xy[2]}
end

function gdt_unit.heal_unit ( unit, bool )
	if bool then
		wml_actions.heal_unit { { "filter", { id = unit.id } }, moves = "full" }
	end
end

function gdt_unit.id ( unit, value )
	wml_actions.modify_unit { { "filter", { id = unit.id } }, id = value }
end

function gdt_unit.location ( unit, str )
	local location = { }
	for value in utils.split ( str ) do
		table.insert ( location, utils.chop( value ) )
	end
	if location[1] == "0" and location[2] == "0" then
		-- do it this way as wml_action.put_to_recall doesn't cover petrified or unhealable
		wml_actions.heal_unit { { "filter", { id = unit.id } }, moves = "full", restore_attacks = true }
		wml_actions.modify_unit { { "filter", { id = unit.id } }, goto_x = 0, goto_y = 0 }
		wesnoth.put_recall_unit ( unit )
	else
		wesnoth.put_unit ( location[1], location[2], unit )
	end
end

function gdt_unit.name ( unit, value )
	wml_actions.modify_unit { { "filter", { id = unit.id } }, name = value }
end

function gdt_unit.overlays ( unit, value )
	wml_actions.modify_unit { { "filter", { id = unit.id } }, overlays = value }
end

function gdt_unit.traits ( unit, trait_str )
	if trait_str ~= gdt_unit.get_traits_string ( unit ) then
		-- returns a list of all mainline traits plus bonus traits
		-- start with making a table and adding the global traits
		-- quick, resilient, strong, intelligent
		local trait_array = {}
		local trait_t = wesnoth.get_traits()
		local i = 1
		for k,v in pairs(trait_t) do
			trait_array[i] = v
			i = i + 1
		end

		-- traverse through specified races and units to add more mainline traits
		-- healthy, dextrous, weak, slow, dim, mechanical, fearless, undead
		local race_array = { "dwarf", "elf", "goblin", "mechanical", "troll", "undead" }
		-- feral, elemental
		local unit_array = { "Vampire Bat", "Mudcrawler" }
		for i,v in ipairs(race_array) do
			for temp_trait in helper.child_range(wesnoth.races[v].__cfg, "trait") do
				local trait_is_present = false
				for j = 1, #trait_array do
					if temp_trait.id == trait_array[j].id then
						trait_is_present = true; break
					end
				end
				if trait_is_present == false then
					table.insert(trait_array, temp_trait)
				end
			end
		end
		for i,v  in ipairs(unit_array) do
			for temp_trait in helper.child_range(wesnoth.unit_types[v].__cfg, "trait") do
				local trait_is_present = false
				for j = 1, #trait_array do
					if temp_trait.id == trait_array[j].id then
						trait_is_present = true; break
					end
				end
				if trait_is_present == false then
					table.insert(trait_array, temp_trait)
				end
			end
		end

		-- add aged, & loyal as none of the races or units in mainline cover them
		-- #textdomain wesnoth-help
		local _ = wesnoth.textdomain "wesnoth-help"
		local trait_aged = { id="aged", male_name=_"aged", female_name=_"female^aged",
			{ "effect", { apply_to="hitpoints", increase_total=-8 } },
			{ "effect", { apply_to="movement", increase=-1 } },
			{ "effect", { apply_to="attack", range="melee", increase_damage=-1 } } }
		local trait_loyal = { id="loyal", male_name=_"loyal", female_name=_"female^loyal",
			description=_"Zero upkeep", { "effect", { apply_to="loyal" } } }
		table.insert(trait_array, trait_aged)
		table.insert(trait_array, trait_loyal)

		-- add bonus traits expert, heroic, & powerful
		-- #textdomain wesnoth-Gui_Debug_Tools
		local _ = wesnoth.textdomain "wesnoth-Gui_Debug_Tools"
		-- expert trait - from The Great Quest
		local trait_expert = { id="expert", male_name=_"expert", female_name=_"female^expert",
			{ "effect", { apply_to="attack", increase_attacks=1 } },
			{ "effect", { apply_to="attack", increase_damage=-1 } } }
		-- heroic trait (Props to the World Conquest add-on for the idea.)
		-- This is The Great Quest version that has strong, resilient, quick & dextrous.
		local trait_heroic = { id="heroic", male_name=_"heroic", female_name=_"female^heroic",
			{ "effect", { apply_to="attack", increase_damage=1 } },
			{ "effect", { apply_to="hitpoints", increase_total=5 } },
			{ "effect", { apply_to="hitpoints", times="per level", increase_total=1 } },
			{ "effect", { apply_to="movement", increase=1 } } }
		-- powerful trait - from Random Campaign
		local trait_powerful = { id="powerful", male_name=_"powerful", female_name=_"female^powerful",
			{ "effect", { apply_to="attack", increase_damage="20%" } } }
		table.insert(trait_array, trait_expert)
		table.insert(trait_array, trait_heroic)
		table.insert(trait_array, trait_powerful)
		_ = nil

		-- add the unit's race, unit_type, and current traits to the array
		-- overwriting any with same id that are already in the array
		-- race traits
		for temp_trait in helper.child_range(wesnoth.races[unit.race].__cfg, "trait") do
			local trait_is_present = false
			for j = 1, #trait_array do
				if temp_trait.id == trait_array[j].id then
					trait_is_present = true
					trait_array[j] = temp_trait
					break
				end
			end
			if trait_is_present == false then
				table.insert(trait_array, temp_trait)
			end
		end
		-- unit_type traits
		for temp_trait in helper.child_range(wesnoth.unit_types[unit.type].__cfg, "trait") do
			local trait_is_present = false
			for j = 1, #trait_array do
				if temp_trait.id == trait_array[j].id then
					trait_is_present = true
					trait_array[j] = temp_trait
					break
				end
			end
			if trait_is_present == false then
				table.insert(trait_array, temp_trait)
			end
		end
		-- unit's current traits
		local u_mods = helper.get_child(unit.__cfg, "modifications") or {}
		for temp_trait in helper.child_range(u_mods, "trait") do
			local trait_is_present = false
			for j = 1, #trait_array do
				if temp_trait.id == trait_array[j].id then
					trait_is_present = true
					trait_array[j] = temp_trait
					break
				end
			end
			if trait_is_present == false then
				table.insert(trait_array, temp_trait)
			end
		end

		-- now that all the traits to pick from have been assembled
		-- take user entered values and use to set the unit's traits
		-- chop user entered value
		local temp_new_traits = { }
		for value in utils.split( trait_str ) do
			table.insert ( temp_new_traits, utils.chop( value ) )
		end
		-- remove undead status keys, in case undead trait is being removed
		-- it is easier to remove these keys from proxy than a __cfg
		-- TODO: may not be best handling, find better handling for this and removal of loyal?
		unit.status.not_living = nil
		unit.status.undrainable = nil
		unit.status.unplaugeable = nil
		unit.status.unpoisonable = nil
		-- remove existing traits
		local u = unit.__cfg -- traits need to be removed by editing a __cfg table
		for tag = #u, 1, -1 do
			if u[tag][1] == "modifications" then
				for subtag = #u[tag][2], 1, -1 do
					if u[tag][2][subtag][1] == "trait" then
						table.remove( u[tag][2], subtag )
					end
				end
			end
		end
		if u.upkeep == "loyal" then -- in case loyal was present
			u.upkeep = "full"
		end
		-- add new traits
		for i = 1, #temp_new_traits do
			for j = 1, #trait_array do
				if temp_new_traits[i] == trait_array[j].id then
					if helper.get_child( u, "modifications" ) == nil then
						utils.add_child( u, "modifications" )
					end
					local m = helper.get_child( u, "modifications" )
					table.insert ( m, { [1] = "trait", [2] = trait_array[j] } )
					break
				end
			end
		end
		wesnoth.put_unit ( u ) -- overwrites original that's still there, preserves underlying_id & proxy access
		wesnoth.transform_unit ( unit, unit.type ) -- refresh the unit with the new changes
	end
end

function gdt_unit.type_advances_to ( unit, unit_type, advances_to )
	-- only when type is changing do we want to disregard what is entered for advances_to
	if unit.type ~= unit_type then
		wesnoth.transform_unit ( unit, unit_type )
	else
		unit.advances_to = utils.string_split ( advances_to, "," )
	end
end

function gdt_unit.unrenamable ( unit, value )
	wml_actions.modify_unit { { "filter", { id = unit.id } }, unrenamable = value }
end

function gdt_unit.variables ( unit, variables )
	if variables ~= "" then
		local vstr = {}
		for value in utils.split( variables, "=" ) do
			table.insert ( vstr, utils.chop( value ) )
		end
		if vstr[2] == nil then
			vstr[2] = ""
		end
		unit.variables[vstr[1]] = vstr[2]
	end
end

function gdt_unit.variation ( unit, variation )
	-- can this simply be a modify unit without all the rest of the code if this occurs
	-- before the unit_type transformation?
	if variation ~= unit.__cfg.variation then
		wml_actions.modify_unit { { "filter", { id = unit.id } }, variation = variation }
		wesnoth.transform_unit ( unit, unit.type ) -- so the variation change will take
	end
end

return gdt_unit
