-- #textdomain wesnoth-Gui_Debug_Tools
local _ = wesnoth.textdomain "wesnoth-Gui_Debug_Tools"

-- to make code shorter
local wml_actions = wesnoth.wml_actions

function wesnoth.wml_conditionals.debug_status ( cfg )
	return wesnoth.game_config.debug
end

function wml_actions.lua_console ( cfg )
	return wesnoth.show_lua_console()
end

wml_actions.set_menu_item { id = "_1_gamestate_inspector" ,
	description = _ "Gamestate Inspector" ,
	image = "magical.png",
	{ "show_if" , {
		{ "debug_status" }
	}},
	{ "command" , { 
		{ "inspect" }
	}}
}

wml_actions.set_menu_item { id = "_2_lua_console" ,
	description = _ "Lua Console" ,
	image = "magical.png",
	{ "show_if" , {
		{ "debug_status" }
	}},
	{ "command" , { 
		{ "lua_console" }
	}}
}

wml_actions.set_menu_item { id = "_3_unit_debug" ,
	description = _ "Unit Debug" ,
	image = "magical.png",
	{ "show_if" , {
		{ "debug_status" },
		{ "have_unit", { x = "$x1", y = "$y1" } }
	}},
	{ "command" , { 
		{ "gui_unit_debug" }
	}}
}

wml_actions.set_menu_item { id = "_4_side_debug" ,
	description = _ "Side Debug" ,
	image = "magical.png",
	{ "show_if" , {
		{ "debug_status" },
		{ "have_unit", { x = "$x1", y = "$y1" } }
	}},
	{ "command" , { 
		{ "gui_side_debug" }
	}}
}
