local nowPlaying = _G["ADDONS"]["NOWPLAYING"];
local settings = {
	showFrame = 1; 			-- Default enable or disable onscreen text. This will also disable notifications.
	onlyNotification = 1;	-- Do you want to only show text as a temporary notification after bgm changes?
	notifyDuration = 15;	-- Duration of the notification text
	chatMessage = 0;		-- Chat message for each new bgm?
}
function NOWPLAYING_UPDATE_FRAME()
	if nowPlaying.musicInst ~= imcSound.GetPlayingMusicInst() then
		nowPlaying.musicInst = imcSound.GetPlayingMusicInst();
		local musicFileName = nowPlaying.musicInst:GetFileName();
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
			
			nowPlaying.currentTrack = string.format('Now playing: %s - %s', musicArtist, musicTitle);
			nowPlaying.frame:ShowWindow(nowPlaying.settings.showFrame);
			if nowPlaying.settings.onlyNotification == 1 then
				nowPlaying.frame:SetDuration(nowPlaying.settings.notifyDuration);
			end
			
			if nowPlaying.settings.chatMessage == 1 then
				CHAT_SYSTEM(nowPlaying.currentTrack);  
			end
			
			nowPlaying.frame:SetPos(nowPlaying.chatFrame:GetX()+2, nowPlaying.chatFrame:GetY()-nowPlaying.frame:GetHeight());
			nowPlaying.textBox:SetTextByKey("text", nowPlaying.currentTrack);
		end
	end
end

function processNowPlayingCommand(words)
	local cmd = table.remove(words,1);
	if cmd == 'hide' then
		nowPlaying.showFrame= 0;
		nowPlaying.frame:ShowWindow(0);
		return;
	elseif cmd == 'show' then
		nowPlaying.showFrame = 1;
		nowPlaying.frame:ShowWindow(1);
		return;
	elseif cmd == 'chat' then
		cmd = table.remove(words,1);
		if cmd == 'show' then
			nowPlaying.settings.chatMessage = 1;
		elseif cmd == 'hide' then
			nowPlaying.settings.chatMessage = 0;
		end
		return;
	elseif cmd == 'help' then
		local msg = 'removePetInfo{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. '/music{nl}'
		msg = msg .. 'Show the current track name.{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. '/music [show/hide]{nl}';
		msg = msg .. 'Show/hide the yellow text above chat.{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. '/music chat [show/hide]{nl}';
		msg = msg .. 'Show/hide chat messages on new track.{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. '/music help{nl}';
		msg = msg .. 'Shows this window.{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. '/music can also be used as /np or /nowplaying';

		return ui.MsgBox(msg,"","Nope");
	end
	local msg = '';
	msg = nowPlaying.currentTrack;
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

nowPlaying.chatFrame = ui.GetFrame("chatframe");
nowPlaying.frame = ui.GetFrame("nowplaying");
nowPlaying.textBox = GET_CHILD(nowPlaying.frame, "textbox");

if not nowPlaying.loaded then
	nowPlaying.settings = settings;
	nowPlaying.frame:ShowWindow(settings.showFrame);
	
	if settings.onlyNotification == 1 then
		nowPlaying.frame:SetDuration(settings.notifyDuration);
	end
	
	nowPlaying["addon"]:RegisterMsg('FPS_UPDATE', 'NOWPLAYING_UPDATE_FRAME');
	nowPlaying.loaded = true;
end
