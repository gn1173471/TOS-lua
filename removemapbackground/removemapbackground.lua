function MAP_OPEN_HOOKED(frame)
	_G["MAP_OPEN_OLD"](frame);
	GET_CHILD(ui.GetFrame("map"), "bg"):ShowWindow(0);
end

GET_CHILD(ui.GetFrame("map"), "bg"):ShowWindow(0);

SETUP_HOOK(MAP_OPEN_HOOKED, "MAP_OPEN");
