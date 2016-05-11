local addon = _G["ADDONS"]["REMOVEMAPBACKGROUND"]["addon"];
local frame = _G["ADDONS"]["REMOVEMAPBACKGROUND"]["frame"];

function ADDON_REMOVE_MAP_BACKGROUND()
	GET_CHILD(ui.GetFrame("map"), "bg"):ShowWindow(0);
end

addon:RegisterMsg('GAME_START_3SEC', 'ADDON_REMOVE_MAP_BACKGROUND');
