local gen_def = dofile(minetest.get_modpath("more_chests") .. "/utils/base.lua")
local actions = dofile(minetest.get_modpath("more_chests") .. "/utils/actions.lua")

local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

local function print_all_of (tab)
    for index, value in ipairs(tab) do
        print(value)
    end
end

storage = minetest.get_mod_storage()

minetest.register_chatcommand("add_faction", {
    params = "<faction name>",
    privs = {
        faction_add = true,
        interact = true,
    },
    description = "Allows admins/moderators to add factions",
    func = function(username, params)
          if minetest.deserialize(storage:get_string("factions")) then
              local facs = minetest.deserialize(storage:get_string("factions"))
              facs[#facs+1] = params
              print_all_of(facs)

              print(minetest.serialize(facs))

              storage:set_string("factions", minetest.serialize(facs))

              local x = minetest.deserialize(storage:get_string("faction_color"))
              if not x then
                  x = {}
              end
              x[params] = {
                  r = 255,
                  b = 255,
                  g = 255
              }
              storage:set_string("faction_color", minetest.serialize(x))
        else
            storage:set_string("factions", minetest.serialize({params}))
          end
    end
})

minetest.register_chatcommand("invite_to_faction", {
    params = "<faction name>",
    privs = {
          interact = true,
          faction_leader = true
    },
    description = "Invite a player into a faction",
    func = function(username, param)
          local user = minetest.get_player_by_name(username)
          local player = minetest.get_player_by_name(param)

          if not player then
                minetest.chat_send_player(user:get_player_name(), "That player does not exist or is not online")
          else
                if player:get_attribute("factions") then
                      local facs = minetest.deserialize(player:get_attribute("factions"))

                      facs[#facs+1] = user:get_attribute("faction")
                      print_all_of(facs)
                      player:set_attribute("factions", minetest.serialize(facs))
                else
                      player:set_attribute("factions", minetest.serialize({user:get_attribute("faction")}))
                end
          end
    end
})

minetest.register_chatcommand("join_faction", {
    params = "<faction name>",
    privs = {
          interact = true,
          faction_leader = false
    },
    description = "Join a faction you are allowed into",
    func = function(username, param)
        local user = minetest.get_player_by_name(username)

        if not minetest.deserialize(user:get_attribute("factions")) then
            user:set_attribute("factions", minetest.serialize({"neutral"}))
        end

        if has_value(minetest.deserialize(user:get_attribute("factions")), param) then
              user:set_attribute("faction", param)
        else
            return false, "You aren't allowed to join that faction."
        end

        local nick = user:get_attribute("faction")

        if not x then
            x = {}
            x[user:get_attribute("faction")] = {
                r = 255,
                b = 255,
                g = 255
            }
            storage:set_string("faction_color", minetest.serialize(x))
        end

        local colors = x[user:get_attribute("faction")]

        if nick then
            user:set_nametag_attributes({text = "(" .. nick .. ")" .. " " .. user:get_player_name(), color = colors})
        end
    end
})

minetest.register_chatcommand("set_faction_color", {
    params = "<red> <green> <blue>",
    privs = {
      interact = true,
      faction_leader = true
    },
    description = "Set the color of a faction",
    func = function(username, param)
        local user = minetest.get_player_by_name(username)
        local params = string.split(param, " ")
        local red = params[1]
        local green = params[2]
        local blue = params[3]

        if red == nil or green == nil or blue == nil then
            return false, "<red> <green> <blue>"
        end

        local x = minetest.deserialize(storage:get_string("faction_color"))

        x[user:get_attribute("faction")] = {
            r = red,
            g = green,
            b = blue,
        }

        storage:set_string("faction_color", minetest.serialize(x))
        -- TODO: Colors

        local nick = user:get_attribute("faction")
        local faction_color = x[user:get_attribute("faction")]
        if nick then
            user:set_nametag_attributes({
                text = "(" .. nick .. ")" .. " " .. user:get_player_name(),
                color = faction_color
            })
        end
    end
})

minetest.register_chatcommand("set_faction", {
    params = "<player> <faction name>",

    description = "Set the faction of a player",
    func = function(username, param)
        local user = minetest.get_player_by_name(username)

        local i = 0
        local to = ""
        local tab = {}

        for word in string.gmatch(param, "([^%s]+)") do
            if i == 0 then
                to = word
            else
                table.insert(tab, word)
            end

            i = i + 1
        end

        local faction = table.concat(tab, " ")

        if to == nil or faction == nil then
            print(to)
            print(faction)
            return false, "Usage: /set_faction <user> <faction>"
        end

        local player = minetest.get_player_by_name(to)

        if has_value(minetest.deserialize(storage:get_string("factions")), faction) then
            if player then
                player:set_attribute("faction", faction)
            else
                return false, "That player does not exist or is not online"
            end
        else
            return false, "That faction does not exist."
        end

        local nick = player:get_attribute("faction")
        local x = minetest.deserialize(storage:get_string("faction_color"))

        if not x then
            x = {}
            x[player:get_attribute("faction")] = {
                r = 255,
                g = 255,
                b = 255,
            }

            storage:set_string("faction_color", minetest.serialize(x))
        end

        local colors = x[player:get_attribute("faction")]

        if nick then
            player:set_nametag_attributes({text = "(" .. nick .. ")" .. " " .. player:get_player_name(), color = colors })
        end
    end
})

minetest.register_chatcommand("faction", {
    params = "",
    description = "Print your faction",
    func = function(username, param)
        local user = minetest.get_player_by_name(username)
        if not user:get_attribute("faction") then
            return true, ""
        else
            return true, user:get_attribute("faction")
        end
    end
})

minetest.register_privilege("faction_add", {
    description = "Add faction",
    give_to_singleplayer = false
})

minetest.register_privilege("faction_leader", {
    description = "Lead a faction",
    give_to_singleplayer = false
})

minetest.register_privilege("set_faction", {
    description = "Set a player's faction",
    give_to_singleplayer = false
})

minetest.register_on_joinplayer(function(player)
    if not player:get_attribute("faction") then
        player:set_attribute("faction", "neutral")
    end

    if type(minetest.deserialize(player:get_attribute("faction"))) == "table" then
       player:set_attribute("faction", "neutral")
    end

    local nick = player:get_attribute("faction")
    local x = minetest.deserialize(storage:get_string("faction_color"))
    if not x then
        x = {}
        x[player:get_attribute("faction")] = {
            r = 255,
            b = 255,
            g = 255
        }
        storage:set_string("faction_color", minetest.serialize(x))

    end
    local colors = x[player:get_attribute("faction")]
    if nick then
        player:set_nametag_attributes({text = "(" .. nick .. ")" .. " " .. player:get_player_name(), color = colors})
    end
end)

local chest = gen_def({
	description = "Factions chest",
	type = "chest",
	size = "small",
	tiles = {
        "factions_chest_top.png",
        "factions_chest_bottom.png",
        "factions_chest_right.png",
        "factions_chest_left.png",
        "factions_chest_back.png",
        "factions_chest_front.png",
    },
	pipeworks_enabled = true,
	allow_metadata_inventory_move = false,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		if actions.has_locked_chest_privilege(meta, player) then
			return stack:get_count()
		end
		local target = meta:get_inventory():get_list(listname)[index]
		local target_name = target:get_name()
		local stack_count = stack:get_count()
		if target_name == stack:get_name()
		and target:get_count() < stack_count then
			return stack_count
		end
		if target_name ~= "" then
			return 0
		end
		return stack_count
	end,
	allow_metadata_inventory_take = actions.get_allow_metadata_inventory_take({
		"dropbox", check_privs = actions.has_locked_chest_privilege
	}),
})

minetest.register_node("factions:chest", chest)

minetest.register_craft({
    output = "factions:chest",
    recipe = {
        {"group:tree", "group:tree", "group:tree"},
        {"group:tree", "default:mese_crystal", "group:tree"},
        {"group:tree", "group:tree", "group:tree"},
    },
})

minetest.register_craft({
    output = "factions:chest",
    recipe = {
        {"",              "default:chest",        ""},
        {"default:chest", "default:mese_crystal", "default:chest"},
        {"",              "default:chest",        ""},
    },
})

minetest.register_craft({
    type = "fuel",
    recipe = "factions:chest",
    burntime = 30,
})
