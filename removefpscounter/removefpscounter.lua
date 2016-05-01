function FPS_ON_INIT_HOOKED(addon, frame)
	_G["FPS_ON_INIT_OLD"](addon, frame);
	ui.CloseFrame("fps");
end

SETUP_HOOK(FPS_ON_INIT_HOOKED, "FPS_ON_INIT");

ui.CloseFrame("fps");

ui.SysMsg("FPS Counter Disabled");
