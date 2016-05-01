local settings = {};
settings.showMyPetName = 1;
settings.showMyPetHP = 0;
settings.showOtherPetNames = 0;

	
function UPDATE_COMPANION_TITLE_HOOKED(frame, handle)
	_G["UPDATE_COMPANION_TITLE_OLD"](frame, handle)
	frame = tolua.cast(frame, "ui::CObject");

	local mycompinfoBox = GET_CHILD_RECURSIVELY(frame, "mycompinfo");
	if mycompinfoBox == nil then
		return;
	end
	local otherscompinfo = GET_CHILD_RECURSIVELY(frame, "otherscompinfo");
	
	local mynameRtext = GET_CHILD_RECURSIVELY(frame, "myname");
	local gauge_stamina = GET_CHILD_RECURSIVELY(frame, "StGauge");
	local hp_stamina = GET_CHILD_RECURSIVELY(frame, "HpGauge");
	local pcinfo_bg_L = GET_CHILD_RECURSIVELY(frame, "pcinfo_bg_L");
	local pcinfo_bg_R = GET_CHILD_RECURSIVELY(frame, "pcinfo_bg_R");
	
	local othernameTxt = GET_CHILD_RECURSIVELY(frame, "othername");
	
	gauge_stamina:ShowWindow(settings.showMyPetHP)
	hp_stamina:ShowWindow(settings.showMyPetHP)
	pcinfo_bg_L:ShowWindow(settings.showMyPetHP)
	pcinfo_bg_R:ShowWindow(settings.showMyPetHP)
	mynameRtext:ShowWindow(settings.showMyPetName)
	
	othernameTxt:ShowWindow(settings.showOtherPetNames)

	frame:Invalidate()
end




function processPetInfoCommand(words)
	local cmd = table.remove(words,1);

	if not cmd then
		local msg = 'removePetInfo{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. '/pet name [on/off]{nl}'
		msg = msg .. 'Show/hide your pet name.{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. '/pet hp [on/off]{nl}';
		msg = msg .. 'Show/hide your pet HP.{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. '/pet other [on/off]{nl}';
		msg = msg .. 'Show/hide other pet names.{nl}';

		return ui.MsgBox(msg,"","Nope");
	
	elseif cmd == 'name' then
		cmd = table.remove(words,1);
		if cmd == 'on' then
			settings.showMyPetName = 1;
		elseif cmd == 'off' then
			settings.showMyPetName = 0;
		end
	
	elseif cmd == 'hp' then
		cmd = table.remove(words,1);
		if cmd == 'on' then
			settings.showMyPetHP = 1;
		elseif cmd == 'off' then
			settings.showMyPetHP = 0;
		end
	
	elseif cmd == 'other' then
		cmd = table.remove(words,1);
		if cmd == 'on' then
			settings.showOtherPetNames =  1;
		elseif cmd == 'off' then
			settings.showOtherPetNames = 0;
		end
		
	else 
		cwAPI.util.log('[removePetInfo] Invalid input. Type "/pet" for help.');
	end

end

SETUP_HOOK(UPDATE_COMPANION_TITLE_HOOKED, "UPDATE_COMPANION_TITLE");

if (not cwAPI) then
	ui.SysMsg('[removePetInfo] could not find cwAPI, you will not be able to change settings in-game.{nl}');
	return false;
else
	_G['ADDON_LOADER']['removepetinfo'] = function() 
		cwAPI.commands.register('/pet',processPetInfoCommand);
		cwAPI.util.log('[removePetInfo:help] /pet{nl}');
		return true;
	end
end 
