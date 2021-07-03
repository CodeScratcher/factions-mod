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

        if has_value(minetest.deserialize(user:get_attribute("factions")), param) then
              user:set_attribute("faction", param)
        else
            return false, "You aren't allowed to join that faction."
        end

        local nick = user:get_attribute("faction")

        if nick then
            user:set_nametag_attributes({text = "(" .. nick .. ")" .. " " .. user:get_player_name()})
        end
    end
})

minetest.register_chatcommand("set_faction_color", {
   params = "<red> <green> <blue>",
   privs = {
     interact = true,
     set_faction = true
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

       -- TODO: Colors
       
       local nick = user:get_attribute("faction")

       if nick then
           user:set_nametag_attributes({text = "(" .. nick .. ")" .. " " .. player:get_player_name() })
       end
   end
})

minetest.register_chatcommand("set_faction", {
   params = "<player>, <faction name>",
   privs = {
     interact = true,
     set_faction = true
   },
   description = "Set the faction of a player",
   func = function(username, param)
       local user = minetest.get_player_by_name(username)
       local params = string.split(param, ", ")
       local to = params[1]
       local faction = params[2]

       if to == nil or faction == nil then
           print(to)
           print(faction)
           return false, "Params: <user, faction>"
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

       if nick then
           player:set_nametag_attributes({text = "(" .. nick .. ")" .. " " .. player:get_player_name() })
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

    if nick then
        player:set_nametag_attributes({text = "(" .. nick .. ")" .. " " .. player:get_player_name()})
    end
end)

minetest.register_node("factions:chest", {
  description = "Factions Chest",
  tiles = {
    "factions_chest_top.png",
    "factions_chest_bottom.png",
    "factions_chest_right.png",
    "factions_chest_left.png",
    "factions_chest_back.png",
    "factions_chest_front.png",
  },
  drop = "factions:chest",
  groups = {choppy = 1, oddly_breakable_by_hand = 1},
  --sounds = (what here?),
})
