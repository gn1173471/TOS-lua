function REPORT_AUTOBOT_MSGBOX_HOOKED(teamName)

	local msgBoxString = 'Do you want to report and block ' .. teamName;
	msgBoxString = msgBoxString .. '?';
	local yesScp = string.format("REPORT_BLOCK_AUTOBOT( \"%s\" )", teamName);
	
	ui.MsgBox(msgBoxString, yesScp, "None");	
end

function REPORT_BLOCK_AUTOBOT(teamName)
	friends.RequestBlock(teamName);
	packet.ReportAutoBot(teamName);
	local msgStr = teamName .. ' has been blocked and reported.';
	ui.SysMsg(msgStr);
end

function CHAT_RBTN_POPUP_HOOKED(frame, chatCtrl)

	if session.world.IsIntegrateServer() == true then
		ui.SysMsg(ScpArgMsg("CantUseThisInIntegrateServer"));
		return;
	end

	local targetName = chatCtrl:GetUserValue("TARGET_NAME");
	local myName = GETMYFAMILYNAME();
	if myName == targetName then
		return;
	end

	local context = ui.CreateContextMenu("CONTEXT_CHAT_RBTN", targetName, 0, 0, 170, 100);
	ui.AddContextMenuItem(context, ScpArgMsg("WHISPER"), string.format("ui.WhisperTo('%s')", targetName));	
	local strRequestAddFriendScp = string.format("friends.RequestRegister('%s')", targetName);
	ui.AddContextMenuItem(context, ScpArgMsg("ReqAddFriend"), strRequestAddFriendScp);
	local partyinviteScp = string.format("PARTY_INVITE(\"%s\")", targetName);
	ui.AddContextMenuItem(context, ScpArgMsg("PARTY_INVITE"), partyinviteScp);
	
	local reportAutoBotScp = string.format("REPORT_AUTOBOT_MSGBOX(\"%s\")", targetName);
	ui.AddContextMenuItem(context, ScpArgMsg("Report_AutoBot"),	reportAutoBotScp);

	local blockScp = string.format("CHAT_BLOCK_MSG('%s')", targetName );
	ui.AddContextMenuItem(context, ScpArgMsg("FriendBlock"), blockScp);
	
	ui.AddContextMenuItem(context, ScpArgMsg("Cancel"), "None");
	ui.OpenContextMenu(context);

end

SETUP_HOOK(REPORT_AUTOBOT_MSGBOX_HOOKED, "REPORT_AUTOBOT_MSGBOX");
SETUP_HOOK(CHAT_RBTN_POPUP_HOOKED, "CHAT_RBTN_POPUP");
