local settings = {
	TimeStamp = true;		-- show timestamps
	BoldSender = true;		-- put the text before a message in bold, e.g [AM 00:00] [Chat][Sender]:
};

settings.whisperSound = {
	enabled = false;				-- enable or disable sound upon receiving a whisper
	sound = 'sys_jam_slot_equip';	-- notification sound (need better sound, check sound.ipf/SE.lst)
	requireNewCluster = true;		-- require a new chat cluster (new "bubble"), useful to avoid notification spam
	cooldown = 2; 					-- cooldown in seconds, 0 is off, useful to avoid notification spam
}

settings.chatColors = {		-- hex color codes
	Whisper = 'ff40ff';
	Normal = 'f4e65c';
	Shout = 'ff2223';
	Party = '2da6ff';
	Guild = '40fb40';
	System = 'ff9696';
	Link = "2a58ff"; 		-- default color for party and map links
};

settings.itemColors = setmetatable({
	"e1e1e1", 	-- white item
	"108CFF", 	-- blue item
	"9F30FF", 	-- purple item
	"FF4F00", 	-- orange item
}, {__index = function() return "e1e1e1" end }); -- default, white

local myFamilyName = GETMYFAMILYNAME();

function DRAW_CHAT_MSG_HOOKED(groupBoxName, size, startIndex, frameName)

	if startIndex < 0 then
		return;
	end

	if frameName == nil then

		frameName = "chatframe";

		local popupFrameName = "chatpopup_" ..string.sub(groupBoxName, 10, string.len(groupBoxName))
		DRAW_CHAT_MSG(groupBoxName, size, startIndex, popupFrameName);
	end

	local chatFrame = ui.GetFrame(frameName)
	if chatFrame == nil then
		return
	end

	local groupBox = GET_CHILD(chatFrame,groupBoxName);

	if groupBox == nil then

		local groupBoxLeftMargin = chatFrame:GetUserConfig("GBOX_LEFT_MARGIN")
		local groupBoxRightMargin = chatFrame:GetUserConfig("GBOX_RIGHT_MARGIN")
		local groupBoxTopMargin = chatFrame:GetUserConfig("GBOX_TOP_MARGIN")
		local groupBoxBottomMargin = chatFrame:GetUserConfig("GBOX_BOTTOM_MARGIN")
		
		groupBox = chatFrame:CreateControl("groupbox", groupBoxName, chatFrame:GetWidth() - (groupBoxLeftMargin + groupBoxRightMargin), chatFrame:GetHeight() - (groupBoxTopMargin + groupBoxBottomMargin), ui.RIGHT, ui.BOTTOM, 0, 0, groupBoxRightMargin, groupBoxBottomMargin);

		_ADD_GBOX_OPTION_FOR_CHATFRAME(groupBox)
		groupBox:SetSkinName("bg");
	end

	if startIndex == 0 then
		DESTROY_CHILD_BYNAME(groupBox, "cluster_");
	end

	local roomID = "Default"


	local marginLeft = 0;
	local marginRight = 25;
	
	local ypos = 0

	for i = startIndex , size - 1 do

		if i ~= 0 then
			local clusterInfo = session.ui.GetChatMsgClusterInfo(groupBoxName, i-1)
			if clusterInfo ~= nil then
				local beforeChildName = "cluster_"..clusterInfo:GetClusterID()
				local beforeChild = GET_CHILD(groupBox, beforeChildName);
				if beforeChild ~= nil then
					ypos = beforeChild:GetY() + beforeChild:GetHeight();
					
				end
			end
			if ypos == 0 then
				DRAW_CHAT_MSG(groupBoxName, size, 0, frameName);
				return;
			end
		end

		local clusterInfo = session.ui.GetChatMsgClusterInfo(groupBoxName, i);
		if clusterInfo == nil then
			return;
		end
		roomID = clusterInfo:GetRoomID();

		local clusterName = "cluster_"..clusterInfo:GetClusterID()
		local cluster = GET_CHILD(groupBox, clusterName);

		local messageType = clusterInfo:GetMsgType();
		if type(tonumber(messageType)) == "number" then
			messageType = "Whisper";
		end
		local messageSender = clusterInfo:GetCommanderName();		
		local messageText = clusterInfo:GetMsg();
		local timeString = '';
		local roomInfo = session.chat.GetByStringID(roomID);
		local memberString = GET_GROUP_TITLE(roomInfo);

		local chatColor = settings.chatColors[messageType];
		
		local styleString = string.format("{ol}{#%s}", chatColor);
		local styleStringFormat = string.format("{ol}{#%s}{ds}", chatColor);
		
		if settings.BoldSender ~= true then
			styleStringFormat = styleString;
		end
		
		--timestamp
		if settings.TimeStamp == true then
			timeString = string.format("[%s] ", clusterInfo:GetTimeStr());
		end
		
		--formatting for different scenarios
		--[AM 00:00] [System]: msg
		if messageType == 'System' then		
			messageText =  string.format("%s%s[%s]:{/}%s %s", styleStringFormat, timeString, messageSender, styleString, messageText);
		
		--[AM 00:00] [Player] whispers: msg
		elseif messageType == 'Whisper' and messageSender ~= myFamilyName then
			messageText =  string.format("%s%s[%s] whispers:{/}%s %s", styleStringFormat, timeString, messageSender, styleString, messageText);
		
		--[AM 00:00] To [Player]: msg
		elseif messageType == 'Whisper' and roomInfo ~= nil then
			messageText =  string.format("%s%sTo [%s]:{/}%s %s", styleStringFormat, timeString, memberString, styleString, messageText);
		
		--[AM 00:00] [Chat][Player]: msg
		else
			messageText =  string.format("%s%s[%s][%s]:{/}%s %s", styleStringFormat, timeString, messageType, messageSender, styleString, messageText);
		end

		--refresh style after {/} but not {/}{
		messageText = CLASSICCHAT_INSTERT_TEXT(messageText, "{/}[^{]", "{/}", styleString)
		
		--refresh style after {/} before {a for consecutive chat links
		messageText = CLASSICCHAT_INSTERT_TEXT(messageText, "{/}[{][a]", "{/}", styleString)
		
		--refresh style after {/} before {nl} for newlines directly after chat link
		messageText = CLASSICCHAT_INSTERT_TEXT(messageText, "{/}[{][n][l][}]", "{/}", styleString)
		
		--item link colours	
		for word in messageText:gmatch("{a SLI.-}{#0000FF}{img.-{/}{/}{/}") do 
			local itemID, itemIcon = string.match(word, "{a SLI .- (.-)}{#0000FF}{img (.-) .-{/}{/}{/}");
			
			local messageTextSubstring = itemID .. "}{#0000FF}";
			local itemObj = CreateIESByID("Item", tonumber(itemID));
			local itemColor = settings.itemColors[itemObj.ItemGrade];
			
			if tostring(itemObj.ItemGrade) == "None" then 		--recipes do not hold an itemgrade
				local recipeGrade = string.match(itemIcon, "misc(%d)"); 	-- e.g icon_item_gloves_misc[1-5]
				if recipeGrade ~= nil then
					itemColor = settings.itemColors[tonumber(recipeGrade)-1];
				end
			end
			
			local messageTextReplace = string.gsub(messageTextSubstring, "0000FF", itemColor);
			messageText = string.gsub(messageText, messageTextSubstring, messageTextReplace);
		end

		--never display black text (had some issues with system msgs coming up black)
		messageText = string.gsub(messageText, "{#000000}", string.format("{#%s}", chatColor));
		
		--change default color for other links (party, map)
		messageText = string.gsub(messageText, "{#0000FF}", string.format("{#%s}", settings.chatColors.Link));
		
		repeat
		if settings.whisperSound.enabled == true and messageType == "Whisper" and messageSender ~= myFamilyName and startIndex ~= 0 then
			if whisperSoundIsOnCooldown == true then break end
			if settings.whisperSound.requireNewCluster == true and cluster ~= nil then break end
			imcSound.PlaySoundEvent(settings.whisperSound.sound);
			whisperSoundIsOnCooldown = true;
			ReserveScript("whisperSoundIsOnCooldown = false", settings.whisperSound.cooldown);
		end
		until true
		
		if cluster ~= nil then -- overwrite existing cluster
			
			local label = cluster:GetChild('bg');
			local txt = GET_CHILD(label, "text");
			txt:SetTextByKey("text", messageText);

			local timeBox = GET_CHILD(cluster, "timebox");
			RESIZE_CHAT_CTRL(cluster, label, txt, timeBox)

			if cluster:GetHorzGravity() == ui.RIGHT then
				cluster:SetOffset( marginRight , ypos); 
			else
				cluster:SetOffset( marginLeft , ypos); 
			end

		else
			--text always on the left
			local chatCtrlName = 'chatu';
			local horzGravity = ui.LEFT;

			local fontSize = GET_CHAT_FONT_SIZE();	
			local chatCtrl = groupBox:CreateOrGetControlSet(chatCtrlName, clusterName, horzGravity, ui.TOP, marginLeft, ypos, marginRight, 0);
			local label = chatCtrl:GetChild('bg');
			local txt = GET_CHILD(label, "text", "ui::CRichText");
			local notread = GET_CHILD(label, "notread", "ui::CRichText");
			local timeBox = GET_CHILD(chatCtrl, "timebox", "ui::CGroupBox");
			local timeCtrl = GET_CHILD(timeBox, "time", "ui::CRichText");
			local nameText = GET_CHILD(chatCtrl, "name", "ui::CRichText");
			local iconPicture = GET_CHILD(chatCtrl, "iconPicture", "ui::CPicture");
			
			chatCtrl:EnableHitTest(1);
			
			notread:ShowWindow(0);
			iconPicture:ShowWindow(0);
			
			label:SetOffset(25, 0);
			label:SetAlpha(0);
			
			--resize text box to (almost) fill chat window
			txt:SetMaxWidth(groupBox:GetWidth()-40);
			txt:Resize(groupBox:GetWidth()-40, txt:GetHeight());
			
			txt:SetTextByKey("size", fontSize);
			txt:SetTextByKey("text", messageText);
			txt:SetGravity(ui.LEFT, ui.TOP);
			
			timeCtrl:SetTextByKey("time", clusterInfo:GetTimeStr());
			
			timeBox:ShowWindow(0);
			nameText:ShowWindow(0);
			
			if clusterInfo:GetMsgType() ~= "System" then
				chatCtrl:SetEventScript(ui.RBUTTONUP, 'CHAT_RBTN_POPUP');
				chatCtrl:SetUserValue("TARGET_NAME", clusterInfo:GetCommanderName());
				chatCtrl:EnableHitTest(1);
			end

			local slflag = string.find(clusterInfo:GetMsg(),'a SL')
			label:EnableHitTest(0);
			if slflag == nil then
				label:EnableHitTest(0)
			else
				label:EnableHitTest(1)
			end
		
			RESIZE_CHAT_CTRL(chatCtrl, label, txt, timeBox);
		end
	end

	local scrollend = false
	if groupBox:GetLineCount() == groupBox:GetCurLine() + groupBox:GetVisibleLineCount() then
		scrollend = true;
	end

	local beforeLineCount = groupBox:GetLineCount();	
	groupBox:UpdateData();
	
	local afterLineCount = groupBox:GetLineCount();
	local changedLineCount = afterLineCount - beforeLineCount;
	local curLine = groupBox:GetCurLine();
	if scrollend == false then
		groupBox:SetScrollPos(curLine + changedLineCount);
	else
		groupBox:SetScrollPos(99999);
	end

	if groupBox:GetName() == "chatgbox_TOTAL" and groupBox:IsVisible() == 1 then
		chat.UpdateAllReadFlag();
	end

	local parentframe = groupBox:GetParent()
	
	if string.find(parentframe:GetName(),"chatpopup_") == nil then
		if roomID ~= "Default" and groupBox:IsVisible() == 1 then
			chat.UpdateReadFlag(roomID);
		end
	else
	
		if roomID ~= "Default" and parentframe:IsVisible() == 1 then
			chat.UpdateReadFlag(roomID);
		end
	end

end

function CLASSICCHAT_INSTERT_TEXT(messageText, pattern, instertAfter, insertString)
	for word in messageText:gmatch(pattern) do 
	
		local messageTextSubstring = string.match(messageText, pattern);
		if messageTextSubstring == nil then
			break;
		end
		
		local messageTextReplace = string.gsub(messageTextSubstring, instertAfter, "%1" .. insertString);
		messageText = string.gsub(messageText, messageTextSubstring, messageTextReplace);
	end
	
	return messageText;
end

function CLASSICCHAT_RESIZE_CHAT_CTRL(chatCtrl, label, txt, timeBox)
	local groupBox = chatCtrl:GetParent();
	local labelWidth = txt:GetWidth();
	local chatWidth = groupBox:GetWidth();
	
	label:Resize(labelWidth, txt:GetHeight());
	chatCtrl:Resize(chatWidth, label:GetY() + label:GetHeight());
end

function CHAT_SET_OPACITY_HOOKED(num)
	local chatFrame = ui.GetFrame("chatframe");
	if chatFrame == nil then
		return;
	end

	local count = chatFrame:GetChildCount();
	for  i = 0, count-1 do 
		local child = chatFrame:GetChildByIndex(i);
		local childName = child:GetName();
		if string.sub(childName, 1, 9) == "chatgbox_" then
			if child:GetClassName() == "groupbox" then
			
				child = tolua.cast(child, "ui::CGroupBox");
				
				if child:GetSkinName() ~= 'bg' then
					child:SetSkinName("bg");
				end
				
				if num == -1 then
					return;
				elseif num == 0 then
					num = 1;
				end
				
				local colorToneStr = string.format("%02X", num);				
				colorToneStr = colorToneStr .. "000000";
				child:SetColorTone(colorToneStr);
			end
		end
	end

end

-- for debugging purposes
local lastMessage = '';
function chatlog(text)
	if lastMessage == text then
		return;
	end
	local file, error = io.open('../chatlog.txt', "a");
	if (error) then
		return false;
	else 
		lastMessage = text;
		file:write(text.."\nl");
	    io.close(file);
	    return true;
	end
end

whisperSoundIsOnCooldown = false;

local addon = _G["ADDONS"]["CLASSICCHAT"]["addon"];
local frame = _G["ADDONS"]["CLASSICCHAT"]["frame"];

if _G["ADDONS"]["CLASSICCHAT"]["loaded"] ~= true then
	_G["RESIZE_CHAT_CTRL"] = CLASSICCHAT_RESIZE_CHAT_CTRL;
	_G["CHAT_SET_OPACITY"] = CHAT_SET_OPACITY_HOOKED;
	_G["CHAT_SET_FONTSIZE"] = CHAT_SET_FONTSIZE_HOOKED;
	_G["ADDONS"]["CLASSICCHAT"]["loaded"] = true;
end
_G["DRAW_CHAT_MSG"] = DRAW_CHAT_MSG_HOOKED;
CHAT_SET_OPACITY_HOOKED(-1);
