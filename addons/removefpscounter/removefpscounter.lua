local addon = _G["ADDONS"]["REMOVEFPSCOUNTER"]["addon"];
local frame = _G["ADDONS"]["REMOVEFPSCOUNTER"]["frame"];

function ADDON_REMOVE_FPS_COUNTER()
	ui.CloseFrame("fps");
end

addon:RegisterMsg('GAME_START_3SEC', 'ADDON_REMOVE_FPS_COUNTER');
