local settings = {
	showFrame = 1; 			-- Default enable or disable onscreen text. This will also disable notifications.
	onlyNotification = 1;	-- Do you want to only show text as a temporary notification after bgm changes?
	notifyDuration = 15;		-- Duration of the notification text
}

local addon = _G["ADDONS"]["NOWPLAYING"]["addon"];
addon:RegisterMsg('FPS_UPDATE', 'NOWPLAYING_UPDATE_FRAME');

local chatFrame = ui.GetFrame("chatframe");
local frame = ui.GetFrame("nowplaying");
local textBox = GET_CHILD(frame, "textbox");

frame:ShowWindow(_G["ADDONS"]["NOWPLAYING"]["showFrame"] or settings.showFrame);


local currentTrack = '';
function NOWPLAYING_UPDATE_FRAME()
	if settings.onlyNotification == 1 and currentTrack ~= NOWPLAYING_GET_INFO() and settings.showFrame == 1 then
		currentTrack = NOWPLAYING_GET_INFO();
		frame:SetDuration(settings.notifyDuration);
	end
	frame:SetPos(chatFrame:GetX()+2, chatFrame:GetY()-frame:GetHeight());
	textBox:SetTextByKey("text", NOWPLAYING_GET_INFO());
end

function NOWPLAYING_GET_INFO()
	local musicInst = imcSound.GetPlayingMusicInst();
	local musicFileName = musicInst:GetFileName();
	for word in string.gmatch(musicFileName, "bgm\(.-)mp3") do
		local musicArtist = string.match(musicFileName, "tos_(.-)_");
		local musicTitle = string.match(musicFileName, "tos_.-_(.-)%.mp3");
		musicTitle = string.gsub(musicTitle, '_', ' ');
		
		if musicArtist == "Tree" then
			musicTitle = "Tree of Savior";
			musicArtist = "Cinenote; Sevin";
		end
		if musicArtist == "SFA" then
			musicArtist = "S.F.A"
		end
		
		return string.format('Now playing: %s - %s', musicArtist, musicTitle);
	end
	return "";
end

function processNowPlayingCommand(words)
	local cmd = table.remove(words,1);
	if cmd == 'hide' then
		_G["ADDONS"]["NOWPLAYING"]["showFrame"] = 0;
		ui.CloseFrame('nowplaying');
		return;
	elseif cmd == 'show' then
		_G["ADDONS"]["NOWPLAYING"]["showFrame"] = 1;
		ui.OpenFrame('nowplaying');
		return;
	end
	local msg = '';
	msg = NOWPLAYING_GET_INFO();
	if msg == '' then
		msg = 'Now Playing: None';
	end
	cwAPI.util.log(msg);
end

if (not cwAPI) then
	return false;
else
	_G['ADDON_LOADER']['nowplaying'] = function() 
		cwAPI.commands.register('/nowplaying',processNowPlayingCommand);
		cwAPI.commands.register('/np',processNowPlayingCommand);
		cwAPI.commands.register('/music',processNowPlayingCommand);
		cwAPI.util.log('[nowPlaying:help] /music [show/hide]');
		return true;
	end
end 
