local settings = {};
settings.duels = true; --Default setting allows duel requests. Change to false if you want to ignore duel requests by default.
settings.notify = true; --Do you want to receive a chat message each time a duel request is blocked?

function ASKED_FRIENDLY_FIGHT_HOOKED(handle, familyName)
	if settings.duels == true then
		local msgBoxString = ScpArgMsg("DoYouAcceptFriendlyFightingWith{Name}?", "Name", familyName);
		ui.MsgBox(msgBoxString, string.format("ACK_FRIENDLY_FIGHT(%d)", handle) ,"None");
	elseif settings.notify == true then
		CHAT_SYSTEM('[toggleDuels] Declined duel from ' .. familyName);
	end
end

function processDuelsCommand(words)
	local cmd = table.remove(words,1);

	if not cmd then
		if settings.duels == true then
			settings.duels = false;
			msg = '[toggleDuels] Duels toggled off.{nl}'
			
		else
			settings.duels = true;
			msg = '[toggleDuels] Duels toggled on.{nl}'
		end
	
	elseif cmd == 'off' then
		settings.duels = false;
		msg = duelStatusString();
	
	elseif cmd == 'on' then
		settings.duels = true;
		msg = duelStatusString();
	
	elseif cmd == 'help' then
		local msg = 'toggleDuels{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. 'Usage: /duels [on/off/notify/help]{nl}'
		msg = msg .. 'Typing "/duels" without an argument will toggle duels on/off quickly.{nl}';
		msg = msg .. 'e.g. On means that duels are "on" and you will recieve duel requests.{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. '/duels notify{nl}';
		msg = msg .. 'Toggles the chat message that is sent when a duel request is automatically declined.';

		return ui.MsgBox(msg,"","Nope");
		
	elseif cmd == 'notify' then
		if settings.notify == true then
			settings.notify = false;
			msg = '[toggleDuels] Notify setting toggled off.'
		else
			settings.notify = true;
			msg = '[toggleDuels] Notify setting toggled on.'
		end
		
	else 
		msg = '[toggleDuels] Invalid input. Valid inputs are: on, off, notify, help.';
	end

	cwAPI.util.log(msg);
end

function duelStatusString()
	local statusString = '';
	if settings.duels == false then
		statusString = '[toggleDuels] Declining duels.';
	else
		statusString = '[toggleDuels] Allowing duel requests.';
	end
	return statusString;
end

if _G["ASKED_FRIENDLY_FIGHT_OLD"] == nil then
	_G["ASKED_FRIENDLY_FIGHT_OLD"] = _G["ASKED_FRIENDLY_FIGHT"];
	_G["ASKED_FRIENDLY_FIGHT"] = ASKED_FRIENDLY_FIGHT_HOOKED;
else
	_G["ASKED_FRIENDLY_FIGHT"] = ASKED_FRIENDLY_FIGHT_HOOKED;
end

if (not cwAPI) then
	ui.SysMsg('[toggleDuels] could not find cwAPI, you will not be able to change settings in-game.{nl}' .. duelStatusString());
	return false;
else
	_G['ADDON_LOADER']['toggleduels'] = function() 
		cwAPI.commands.register('/duels',processDuelsCommand);
		cwAPI.util.log('[toggleDuels:help] /duels help{nl}' .. duelStatusString());
		return true;
	end
end 

