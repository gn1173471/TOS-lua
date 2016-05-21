local settings = {
	boldSender = true;				-- put the text before a message in bold, e.g [AM 00:00] [Chat][Sender]:
	channelTag = false;				-- show or hide the channel tag in each message, e.g. [Party], or [Shout]
	hideSystemName = true;			-- hide the sender name for system messages
	urlClickWarning = true;			-- warning before opening a web url
	timeStamp = true;				-- show timestamps
	urlMatching = true;				-- do you want to enable URL links in chat?
};

settings.whisperSound = {
	enabled = true;					-- enable or disable sound upon receiving a whisper

	cooldown = 0; 					-- cooldown in seconds, 0 is off, useful to avoid notification spam.
	sound = 'sys_jam_slot_equip';	-- notification sound (need better sound, check sound.ipf/SE.lst)
	onSendingMessage = false;		-- do you want to hear this sound when you send a whisper too?
	requireNewCluster = true;		-- require a new chat cluster (new "bubble"), useful to avoid notification spam
}

settings.formatting = {				-- brackets to use for each tag
	channelTagBrackets = "<>";
	nameTagBrackets = "<>";
	timeStampBrackets = "[]";
	indentation = " ";				-- indentation at the start of each new message cluster
}

settings.chatColors = {				-- hex color codes
	Whisper = 'FF0000';
	Normal = 'FFFFFF';
	Shout = 'FFFF00';
	Party = '008000';
	Guild = '00FFFF';
	System = '808080';
	Link = "800080"; 				-- default color for party and map links
};

settings.tagStringColors = {		-- do you want the tag string to be a different colour to the actual message?
	enabled = false;				-- this part --> [AM 00:00] [Chat][Sender]:
	Whisper = 'ff40ff';				-- you will need to set your own colours, these defaults are the same as the above colours.
	Normal = 'f4e65c';
	Shout = 'ff2223';
	Party = '2da6ff';
	Guild = '40fb40';
	System = 'ff9696';
};

settings.itemColors = setmetatable({
	"e1e1e1", 	-- white item
	"108CFF", 	-- blue item
	"9F30FF", 	-- purple item
	"FF4F00", 	-- orange item
}, {__index = function() return "e1e1e1" end }); -- default, white


local classicChat = _G["ADDONS"]["CLASSICCHAT"];
local myFamilyName = GETMYFAMILYNAME();

function CLASSICCHAT_DRAW_CHAT_MSG(groupBoxName, size, startIndex, frameName)

	if startIndex < 0 then
		return;
	end

	if frameName == nil then

		frameName = "chatframe";

		local popupFrameName = "chatpopup_" ..groupBoxName:sub(10, groupBoxName:len())
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

		local roomInfo = session.chat.GetByStringID(roomID);
		local memberString = GET_GROUP_TITLE(roomInfo);

		local nameTag = '';
		local channelTag = '';
		local timeStamp = '';

		local chatColor = settings.chatColors[messageType];

		local styleString = string.format("{ol}{#%s}", chatColor);

		local tagStyleString = '';

		if settings.tagStringColors.enabled == true then
			tagStyleString = string.format("{ol}{#%s}", settings.tagStringColors[messageType]);
		else
			tagStyleString = string.format("{ol}{#%s}", chatColor);
		end

		if settings.boldSender == true then
			tagStyleString = tagStyleString .. "{ds}";
		end

		-- channel tag
		if settings.channelTag == true then
			local channelTagFormat = string.format("%s%%s%s ", settings.formatting.channelTagBrackets:sub(1,1),  settings.formatting.channelTagBrackets:sub(2,2));
			channelTag = channelTagFormat:format(messageType);
		end

		-- name tag
		local nameTagFormat = string.format("%s%%s%s", settings.formatting.nameTagBrackets:sub(1,1),  settings.formatting.nameTagBrackets:sub(2,2));
		nameTag = nameTagFormat:format(messageSender);

		-- timestamp
		if settings.timeStamp == true then
			local timeStampFormat = string.format("%s%%s%s ", settings.formatting.timeStampBrackets:sub(1,1),  settings.formatting.timeStampBrackets:sub(2,2));
			timeStamp = timeStampFormat:format(clusterInfo:GetTimeStr());
		end


		-- structuring for different scenarios
		-- [AM 00:00] [System]: msg
		if messageType == 'System' then
			if settings.hideSystemName == true then
				messageText =  string.format("%s%s", styleString, messageText);
			else
				messageText =  string.format("%s%s%s%s:{/}%s %s", tagStyleString, settings.formatting.indentation, timeStamp, nameTag, styleString, messageText);
			end

		-- [AM 00:00] [Player] whispers: msg
		elseif messageType == 'Whisper' and messageSender ~= myFamilyName then
			messageText =  string.format("%s%s%s%s whispers:{/}%s %s", tagStyleString, settings.formatting.indentation, timeStamp, nameTag, styleString, messageText);

		-- [AM 00:00] To [Player]: msg
		elseif messageType == 'Whisper' and roomInfo ~= nil then
			messageText =  string.format("%s%s%sTo %s:{/}%s %s", tagStyleString, settings.formatting.indentation, timeStamp, memberString, styleString, messageText);

		-- [AM 00:00] [Chat][Player]: msg
		else
			messageText =  string.format("%s%s%s%s%s:{/}%s %s", tagStyleString, settings.formatting.indentation, timeStamp, channelTag, nameTag, styleString, messageText);
		end

		if settings.urlMatching == true then
			messageText = classicChat.processUrls(messageText);
		end

		messageText = classicChat.escape(messageText);

		-- refresh style after {/} but not {/}{
		messageText = classicChat.instertText(messageText, "{/}[^{]", "{/}", styleString);


		-- refresh style after {/} before {a for consecutive chat links
		messageText = classicChat.instertText(messageText, "{/}[{][a]", "{/}", styleString);

		-- refresh style after {/} before {nl} for newlines directly after chat link
		messageText = classicChat.instertText(messageText, "{/}[{][n][l][}]", "{/}", styleString);

		-- item link colours
		for word in messageText:gmatch("{a SLI.-}{#0000FF}{img.-{/}{/}{/}") do
			local itemID, itemIcon = word:match("{a SLI .- (.-)}{#0000FF}{img (.-) .-{/}{/}{/}");

			local messageTextSubstring = itemID .. "}{#0000FF}";
			local itemObj = CreateIESByID("Item", tonumber(itemID));
			local itemColor = settings.itemColors[itemObj.ItemGrade];

			if tostring(itemObj.ItemGrade) == "None" then 			--recipes do not hold an itemgrade
				local recipeGrade = itemIcon:match("misc(%d)"); 	-- e.g icon_item_gloves_misc[1-5]
				if recipeGrade ~= nil then
					itemColor = settings.itemColors[tonumber(recipeGrade)-1];
				end
			end

			local messageTextReplace = messageTextSubstring:gsub("0000FF", itemColor);
			messageText = messageText:gsub(messageTextSubstring, messageTextReplace);
		end

		--never display black text (had some issues with system msgs coming up black)
		messageText = messageText:gsub("{#000000}", string.format("{#%s}", chatColor));

		--change default color for other links (party, map)
		messageText = messageText:gsub("{#0000FF}", string.format("{#%s}", settings.chatColors.Link));


		messageText = classicChat.unescape(messageText);

		repeat
		if settings.whisperSound.enabled == true and messageType == "Whisper" and startIndex ~= 0 then
			if settings.whisperSound.onSendingMessage ~= true and messageSender == myFamilyName then break end
			if classicChat.isWhisperCooldown == true then break end
			if settings.whisperSound.requireNewCluster == true and cluster ~= nil then break end

			imcSound.PlaySoundEvent(settings.whisperSound.sound);
			classicChat.isWhisperCooldown = true;
			ReserveScript("classicChat.isWhisperCooldown = false", settings.whisperSound.cooldown);
		end
		until true

		if cluster ~= nil then -- overwrite existing cluster

			local label = cluster:GetChild('bg');
			local txt = GET_CHILD(label, "text");
			txt:SetTextByKey("text", messageText);

			local timeBox = GET_CHILD(cluster, "timebox");

			local slflag = messageText:find('a SL')
			if slflag == nil then
				label:EnableHitTest(0)
			else
				label:EnableHitTest(1)
			end

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

			nameText:SetText('{@st61}'..messageSender..'{/}');
			nameText:ShowWindow(0);

			if messageType ~= "System" then
				chatCtrl:SetEventScript(ui.RBUTTONUP, 'CHAT_RBTN_POPUP');
				chatCtrl:SetUserValue("TARGET_NAME", clusterInfo:GetCommanderName());
				chatCtrl:EnableHitTest(1);
			end

			local slflag = messageText:find('a SL')
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

	if parentframe:GetName():find("chatpopup_") == nil then
		if roomID ~= "Default" and groupBox:IsVisible() == 1 then
			chat.UpdateReadFlag(roomID);
		end
	else

		if roomID ~= "Default" and parentframe:IsVisible() == 1 then
			chat.UpdateReadFlag(roomID);
		end
	end

end

function SLL(text, warned)
	if settings.urlClickWarning == true and warned ~= true then
		local msgBoxString = "Do you want to open the URL?{nl}"
		local length = 35;
		if #text > length then
			msgBoxString = msgBoxString .. text:sub(1, length) .. "...";
		else
			msgBoxString = msgBoxString .. text;
		end
		local msgBoxScp = string.format("SLL('%s', true)", text);
		ui.MsgBox(msgBoxString, msgBoxScp, "None");
	else
		login.OpenURL(text);
	end
end

local domains = [[.ac.ad.ae.aero.af.ag.ai.al.am.an.ao.aq.ar.arpa.as.asia.at.au
	.aw.ax.az.ba.bb.bd.be.bf.bg.bh.bi.biz.bj.bm.bn.bo.br.bs.bt.bv.bw.by.bz.ca
	.cat.cc.cd.cf.cg.ch.ci.ck.cl.cm.cn.co.com.coop.cr.cs.cu.cv.cx.cy.cz.dd.de
	.dj.dk.dm.do.dz.ec.edu.ee.eg.eh.er.es.et.eu.fi.firm.fj.fk.fm.fo.fr.fx.ga
	.gb.gd.ge.gf.gh.gi.gl.gm.gn.gov.gp.gq.gr.gs.gt.gu.gw.gy.hk.hm.hn.hr.ht.hu
	.id.ie.il.im.in.info.int.io.iq.ir.is.it.je.jm.jo.jobs.jp.ke.kg.kh.ki.km.kn
	.kp.kr.kw.ky.kz.la.lb.lc.li.lk.lr.ls.lt.lu.lv.ly.ma.mc.md.me.mg.mh.mil.mk
	.ml.mm.mn.mo.mobi.mp.mq.mr.ms.mt.mu.museum.mv.mw.mx.my.mz.na.name.nato.nc
	.ne.net.nf.ng.ni.nl.no.nom.np.nr.nt.nu.nz.om.org.pa.pe.pf.pg.ph.pk.pl.pm
	.pn.post.pr.pro.ps.pt.pw.py.qa.re.ro.ru.rw.sa.sb.sc.sd.se.sg.sh.si.sj.sk
	.sl.sm.sn.so.sr.ss.st.store.su.sv.sy.sz.tc.td.tel.tf.tg.th.tj.tk.tl.tm.tn
	.to.tp.tr.travel.tt.tv.tw.tz.ua.ug.uk.um.us.uy.va.vc.ve.vg.vi.vn.vu.web.wf
	.ws.xxx.ye.yt.yu.za.zm.zr.zw]]

function classicChat.processUrls(text)
	local minLength = 8;
	local tlds = {}
	for tld in domains:gmatch'%w+' do
		tlds[tld] = true
	end
	local function max4(a,b,c,d) return math.max(a+0, b+0, c+0, d+0) end
	local protocols = {[''] = 0, ['http://'] = 0, ['https://'] = 0, ['ftp://'] = 0}
	local finished = {}
	local textNew = text;
	for pos_start, url, prot, subd, tld, colon, port, slash, path in
		text:gmatch'()(([%w_.~!*:@&+$/?%%#-]-)(%w[-.%w]*%.)(%w+)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%%#=-]*))'
	do
		if protocols[prot:lower()] == (1 - #slash) * #path and not subd:find'%W%W'
			and (colon == '' or port ~= '' and port + 0 < 65536)
			and (tlds[tld:lower()] or tld:find'^%d+$' and subd:find'^%d+%.%d+%.%d+%.$'
			and max4(tld, subd:match'^(%d+)%.(%d+)%.(%d+)%.$') < 256)
		then
			finished[pos_start] = true
			if #url >= minLength then
				textNew = classicChat.insertlink(textNew, url);
			end
		end
	end

	for pos_start, url, prot, dom, colon, port, slash, path in
		text:gmatch'()((%f[%w]%a+://)(%w[-.%w]*)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%%#=-]*))'
	do
		if not finished[pos_start] and not (dom..'.'):find'%W%W'
			and protocols[prot:lower()] == (1 - #slash) * #path
			and (colon == '' or port ~= '' and port + 0 < 65536)
		then
			if #url >= minLength then
				textNew = classicChat.insertlink(textNew, url);
			end
		end
	end
	return textNew;
end

function classicChat.insertlink(text, url, urlDisplay)
	local maxLength = 28;

	text = classicChat.escape(text);
	url = classicChat.escape(url);
	urlDisplay = urlDisplay or url;

	local urlHttp = url;
	if urlHttp:match("https?://") == nil then
		urlHttp = "http://" .. urlHttp;
	end

	if urlDisplay == classicChat.escape("https://classich.at") then
		urlDisplay = "Classic Chat";
		urlHttp = classicChat.escape("https://github.com/Miei/TOS-lua/");
	end

	if urlDisplay ~= url then
		maxLength = 100;
	end

	local linkFormat = "{a SLL %s}{#%s}%s{/}{/}{/}";

	if #classicChat.unescape(urlDisplay) >= maxLength then
		linkFormat = "{a SLL %s}{#%s}%s!@#DOT#@!!@#DOT#@!!@#DOT#@!{/}{/}{/}";
		urlDisplay = classicChat.escape(classicChat.unescape(urlDisplay):sub(1, maxLength-3));
	end

	text = text:gsub(url, linkFormat:format(urlHttp, settings.chatColors.Link, urlDisplay));

	return classicChat.unescape(text);
end

function classicChat.escape(text)
	text = text:gsub('[%%]','!@#PERCENT#@!');
	text = text:gsub('[%+]','!@#PLUS#@!');
	text = text:gsub('[%-]','!@#MINUS#@!');
	text = text:gsub('[%*]','!@#ASTERISK#@!');
	text = text:gsub('[%?]','!@#QMARK#@!');
	text = text:gsub('[%[]','!@#LBRACKET#@!');
	text = text:gsub('[%]]','!@#RBRACKET#@!');
	text = text:gsub('[%^]','!@#CARET#@!');
	text = text:gsub('[%$]','!@#DOLLAR#@!');
	return text:gsub('[%.]','!@#DOT#@!');
end

function classicChat.unescape(text)
	text = text:gsub('!@#PERCENT#@!', '%%');
	text = text:gsub('!@#PLUS#@!', '%+');
	text = text:gsub('!@#MINUS#@!', '%-');
	text = text:gsub('!@#ASTERISK#@!', '%*');
	text = text:gsub('!@#QMARK#@!', '%?');
	text = text:gsub('!@#LBRACKET#@!', '%[');
	text = text:gsub('!@#RBRACKET#@!', '%]');
	text = text:gsub('!@#CARET#@!', '%^');
	text = text:gsub('!@#DOLLAR#@!', '%$');
	return text:gsub('!@#DOT#@!', '%.');
end


function classicChat.instertText(messageText, pattern, instertAfter, insertString)
	for word in messageText:gmatch(pattern) do

		local messageTextSubstring = messageText:match(pattern);
		if messageTextSubstring == nil then
			break;
		end

		local messageTextReplace = messageTextSubstring:gsub(instertAfter, "%1" .. insertString);
		messageText = messageText:gsub(messageTextSubstring, messageTextReplace);
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

function CLASSICCHAT_CHAT_SET_OPACITY(num)
	local chatFrame = ui.GetFrame("chatframe");
	if chatFrame == nil then
		return;
	end

	local count = chatFrame:GetChildCount();
	for  i = 0, count-1 do
		local child = chatFrame:GetChildByIndex(i);
		local childName = child:GetName();
		if childName:sub(1, 9) == "chatgbox_" then
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
function classicChat.chatlog(text)
	if lastMessage == text then
		return;
	end
	local file, error = io.open('../chatlog.txt', "a");
	if (error) then
		return false;
	else
		lastMessage = text;
		file:write(text.."\n");
		 io.close(file);
		 return true;
	end
end

classicChat.isWhisperCooldown = false;

local addon = classicChat["addon"];
local frame = classicChat["frame"];

_G["DRAW_CHAT_MSG"] = CLASSICCHAT_DRAW_CHAT_MSG;

if classicChat.loaded ~= true then
	_G["RESIZE_CHAT_CTRL"] = CLASSICCHAT_RESIZE_CHAT_CTRL;
	_G["CHAT_SET_OPACITY"] = CLASSICCHAT_CHAT_SET_OPACITY;

	if settings.urlMatching == true then
		CHAT_SYSTEM("https://classich.at loaded!");
	else
		CHAT_SYSTEM("Classic Chat loaded!");
	end

	classicChat.loaded = true;
end

CLASSICCHAT_CHAT_SET_OPACITY(-1);
