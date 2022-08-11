# Factions Mod for Minetest
A mod that allows players to team together, mostly for the purposes of cooperation

## Usage:
Grant yourself the faction_add and set_faction privilege
Then, create a faction with the `/add_faction` commmand and use the `/set_faction` command to set the faction one user, the leader of the faction, to the newly added faction. Grant them the faction_leader privilege. They can invite people with the `/invite_to_faction` command, and others can join the faction (if they're invited) with the `/join_faction` command

## Caveats
- Displaying factions in usernames can clash with other mods that mess with the username displaying UI
- Displaying factions in chat can clash with chat altering mods
- In order to use faction protection, you must change the optional dependencies of the `protector` mod. 
