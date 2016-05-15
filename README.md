# TOS-lua
These addons are intended to be used with [this](https://github.com/Excrulon/Tree-of-Savior-Lua-Mods) or [this](https://github.com/fiote/treeofsavior-addons) addon loader format. [utility.lua](https://github.com/Excrulon/Tree-of-Savior-Lua-Mods/blob/master/addons/utility.lua) is a dependency.

[![Addon Safe](https://cdn.rawgit.com/lubien/awesome-tos/master/badges/addon-safe.svg)](https://github.com/lubien/awesome-tos#addons-badges)  [![Addon Status Unknown](https://cdn.rawgit.com/lubien/awesome-tos/master/badges/addon-unknown.svg)](https://github.com/lubien/awesome-tos#addons-badges) 

These addons have not been officially approved but are not intrusive and can almost certainly be considered safe. See [here](https://forum.treeofsavior.com/t/stance-on-addons/141262/3) and [here](https://forum.treeofsavior.com/t/stance-on-addons/141262/24) about IMC's stance on addons.

When installing, make sure that the .ipf files in /data have a unicode character in them, or they will not work. For example: ⚗classicchat.ipf

#### cabinetCommas
Format the silver values for the item listings in the market "sell" and "retrieve" tabs with thousands separators (commas) for readability. [preview](https://i.imgur.com/0jnNGxx.png)

#### classicChat
Changes the chat to be more similar to a classic MMO chat frame. [preview](https://i.imgur.com/Z3GgKT7.png)

Features:

- Different text colors for each chat channel.
- Colored item and recipe links based on rarity.
- Whisper notification sounds. (Disabled by default)
- Optional time stamps.
- Open links from chat in your browser.
- More

These settings can and should be customized at the top of the lua file. Hex color codes are used.

Upon installing this addon, I would recommend that you readjust your [chat's transparency setting](https://i.imgur.com/WCevi1v.png) as the default background skin for the text frame will be replaced with a darker one to allow a greater range of transparency.

This addon will conflict with LKChat, they cannot be used together.

#### fixFontSizeSlider
Fix the font size slider in the chat options to dynamically update the font size in the chat frame.

#### nowPlaying
Add text above the chat window to show the currently playing BGM. [preview](https://i.imgur.com/tJGwNUr.png)

You can optionally enable this all of the time, enable it as a notification for a set duration once the BGM changes, or disable it altogether. See the top of the file to change these settings. The default setting is notification style with a 15 second duration.

If you have [cwAPI](https://github.com/fiote/treeofsavior-addons) installed, in-game slash commands will be available, however this is not a dependency for the core functionality of the addon.

Available slash commands:

- /np - Shows a chat message with the current bgm.
- /np [on/off] - Allows you to show or hide the text above the chat window
- /np chat [show/hide] - Enable/disable chat messages upon track change
- /np notify [on/off] - Enable/disable notification mode. Notification mode will show the text above the chat frame for a set duration when a new BGM plays, instead of showing this text constantly.
- /np help - Displays a help dialogue
 
/np can also be used as /music or /nowplaying.

#### removeFPSCounter
Hide the FPS counter.

(updated to use event-based ipf format)

#### removeMapBackground
Remove the grey dimming background when the full map is opened. [preview](https://i.imgur.com/IfcOlo9.jpg)

(updated to use event-based ipf format)

#### removePetInfo
Hide pet names and/or HP bars. If you have [cwAPI](https://github.com/fiote/treeofsavior-addons) installed, in-game slash commands will be available, however this is not a dependency for the core functionality of the addon.

Available slash commands, accessed with /companion or /comp:

- /comp -- Information about the addon.
- /comp name [on/off] - Show/hide your pet name. (Default: on)
- /comp hp [on/off] - Show/hide your pet HP. (Default: off)
- /comp other [on/off] - Show/hide other pet names. (Default: off)

You can edit the default settings at the top of the file.

#### toggleDuels
Allows you to toggle whether or not you will receive duel requests. If you have [cwAPI](https://github.com/fiote/treeofsavior-addons) installed, in-game slash commands will be available, however this is not a dependency for the core functionality of the addon.

Available slash commands:

- /duels -- Quick toggle duels on/off.
- /duels [on/off] -- Set duel requests on/off. "On" means that you will be able to receive duel requests. (Default: on)
- /duels notify -- Toggle whether you will be notified in chat when a duel request is blocked, e.g. "Blocked duel request from Mie" (Default: on)
- /duels help -- Information about the addon.

By default, duels are set to "on", meaning you will recieve duel requests. If you would like to edit the default settings, you can do so at the top of the file. It is set this way to prevent inconvenience in the case that somebody unwittingly installs the addon.
