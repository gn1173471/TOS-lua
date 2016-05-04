# TOS-lua
These addons are intended to be used with [this](https://github.com/Excrulon/Tree-of-Savior-Lua-Mods) or [this](https://github.com/fiote/treeofsavior-addons) addon loader format. [utility.lua](https://github.com/Excrulon/Tree-of-Savior-Lua-Mods/blob/master/addons/utility.lua) is a dependency.

[![Addon Safe](https://cdn.rawgit.com/lubien/awesome-tos/master/badges/addon-safe.svg)](https://github.com/lubien/awesome-tos#addons-badges)  [![Addon Status Unknown](https://cdn.rawgit.com/lubien/awesome-tos/master/badges/addon-unknown.svg)](https://github.com/lubien/awesome-tos#addons-badges) 

These addons have not been officially approved but are not intrusive and can almost certainly be considered safe. See [here](https://forum.treeofsavior.com/t/stance-on-addons/141262/3) and [here](https://forum.treeofsavior.com/t/stance-on-addons/141262/24) about IMC's stance on addons.

#### cabinetCommas
Format the silver values for the item listings in the market "sell" and "retrieve" tabs with thousands separators (commas) for readability. [preview](https://i.imgur.com/0jnNGxx.png)

#### fixChatContextMenu
Add the option to report a bot and view character information to the chat's context menu. As bonuses, this addon will automatically block someone when you report them and fix the bug that will sometimes automatically like someone when you open their character information. [preview](https://i.imgur.com/qqIGBuw.png)

#### removeFPSCounter
Hide the FPS counter.

#### removeMapBackground
Remove the grey dimming background when the full map is opened. [preview](https://i.imgur.com/IfcOlo9.jpg)

#### removePetInfo
Hide pet names and/or HP bars. If you have [cwAPI](https://github.com/fiote/treeofsavior-addons) installed, in-game slash commands will be available, however this is not a dependency for the core functionality of the addon.

Available slash commands:

- /pet -- Information about the addon.
- /pet name [on/off] - Show/hide your pet name. (Default: on)
- /pet hp [on/off] - Show/hide your pet HP. (Default: off)
- /pet other [on/off] - Show/hide other pet names. (Default: off)

You can edit the default settings at the top of the file.

#### toggleDuels
Allows you to toggle whether or not you will receive duel requests. If you have [cwAPI](https://github.com/fiote/treeofsavior-addons) installed, in-game slash commands will be available, however this is not a dependency for the core functionality of the addon.

Available slash commands:

- /duels -- Quick toggle duels on/off.
- /duels [on/off] -- Set duel requests on/off. "On" means that you will be able to receive duel requests. (Default: on)
- /duels notify -- Toggle whether you will be notified in chat when a duel request is blocked, e.g. "Blocked duel request from Mie" (Default: on)
- /duels help -- Information about the addon.

By default, duels are set to "on", meaning you will recieve duel requests. If you would like to edit the default settings, you can do so at the top of the file. It is set this way to prevent inconvenience in the case that somebody unwittingly installs the addon.
