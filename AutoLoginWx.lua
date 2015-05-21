

--////////////////////////////////////////////////////////////////////
--注意在mi2s要将软件的图形模式设置为兼容
--定义文件路径
DEBUG_LOG=false;
LOG_FILE="/mnt/sdcard/glog.txt"
WX_ACCOUNT_FILE_PATH = "/sdcard/wxacc/wx.txt"
WX_APP_NAME ="com.tencent.mm"
VERSION_STRING="AutoLoginWX v0.4a"
DEVICE_TYPE=""


function rMain()
	--判断设备类型
	screen_width,screen_height=getScreenResolution();
	Log("screen_width,screen_height="..tostring(screen_width)..","..tostring(screen_height));
	if screen_width==720 and screen_height==1280 then
		DEVICE_TYPE="MI";
	elseif screen_width==480 and screen_height==800 then
		DEVICE_TYPE="SS";
	else
		DEVICE_TYPE="";
	end
	if DEVICE_TYPE=="" then
		Log("DEVICE_TYPE not matched.");
		notifyMessage("DEVICE_TYPE not matched.");
		return;
	end
	Log("DEVICE_TYPE is "..DEVICE_TYPE);
	notifyMessage("DEVICE_TYPE is "..DEVICE_TYPE);
	local accTab=GetAllAccount();
	local wxUsn;
	local wxPwd;
	
	Log('Type continue');
	local id=tonumber(Split(uid,' ')[1]);
	Log("Do login to id #"..tostring(id));
	wxUsn=GetUsernameFromTableById(accTab,id);
	wxPwd=GetPasswordFromTableById(accTab,id);
	Log("Account ok.");
	
	Log("utype="..tostring(utype));
	if wxUsn~='coder_lin' then
		if utype~='type 7' then
			Log('Type done.');
			notifyMessage("Done!");
			return;
		end
	end

	if wxUsn==nil or wxPwd==nil then
		Log("GetAccount error!");
		notifyMessage("Account err!");
		return;
	end
	Log(string.format("account:%s %s",wxUsn,wxPwd));
	--检查在哪个页面
	notifyMessage("准备登陆"..wxUsn..",等待微信界面");
	appRun(WX_APP_NAME);
	while true
	do
		if IsInProtectd() then --保护界面，输入手势密码等一会再continue
			inputProtectPwd();
			mSleep(400);
		end
		if IsInQieHuanZhangHao() then
			WXLogin(wxUsn,wxPwd);
			break;
		end
		if IsInMainPage() then
			WXLogout();
			WXLogin(wxUsn,wxPwd);
			break;
		end

		mSleep(200);
	end
	notifyMessage("Done!");



	
end
-----------------------------------------------------------------
--登录账号
function WXLogin(username,password)
	Log("loging "..username);
	if not appRunning(WX_APP_NAME) then
	    appRun(WX_APP_NAME) 
	end
	--等待切换用户界面
	if not IsInQieHuanZhangHao() then
		--notifyMessage('等待切换用户页面');
			repeat 
				mSleep(100);
			until IsInQieHuanZhangHao()
	end
	--notifyMessage('在切换页面,正在登陆。。。');
	--点击切换账号
	touchAlies(0,"ALIES_WXLOGIN_TOUCH_QIEHUAN"   );
	mSleep(400);
	--选择微信号/邮箱/QQ号
	touchAlies(0, "ALIES_WXLOGIN_TOUCH_MAIL"   );
	mSleep(400);
	--输入账号
	inputText(username);
	--换到密码输入
	touchAlies(0, "ALIES_WXLOGIN_TOUCH_PASSWORD" );
	mSleep(200)
	--输入密码
	inputText(password)	
	--点登陆
	touchAlies(0,  "ALIES_WXLOGIN_TOUCH_LOGIN"  );
	return true;

end

--登录账号
function WXLogout()

	Log("logout...");
	if not IsInMainPage() then
		--等待主界面
		--notifyMessage('等待主页。。');
		repeat 
			mSleep(500);
			Log("waiting main page...");
		until IsInMainPage()
		Log("main page...");
	end
	--notifyMessage('在主页,正在注销。。');
	mSleep(400);
	--点我
	Log("touch me...");
	touchAlies(0,"ALIES_WXLOGOUT_TOUCH_ME");
	mSleep(400);
	--点设置
	Log("touch setting...");
	touchAlies(0, "ALIES_WXLOGOUT_TOUCH_SETTING" );
	mSleep(400);
	--点退出
	Log("touch exit...");
	touchAlies(0,   "ALIES_WXLOGOUT_TOUCH_EXIT"  );
	mSleep(400);
	---[[点退出当前账号 //安装了twitter后没有这一项了
	Log("touch quit cur...");
	touchAlies(0,  "ALIES_WXLOGOUT_TOUCH_CUR"  );
	mSleep(400);
	--]]
	--点退出
	Log("touch quit...");
	touchAlies( 0,"ALIES_WXLOGOUT_TOUCH_QUIT"  );
	mSleep(400);
	return true;
end
--别名点击，不同设备不同坐标
function touchAlies(id,aliesName)
	local x=0;
	local y=0;

	if DEVICE_TYPE=="MI" then
		if aliesName=="ALIES_WXLOGOUT_TOUCH_ME" then
			x=633;
			y=1228;
		elseif aliesName=="ALIES_WXLOGOUT_TOUCH_SETTING" then
			x=165;
			y=805;
		elseif aliesName=="ALIES_WXLOGOUT_TOUCH_EXIT" then
			x=91;
			y=947;
		elseif aliesName=="ALIES_WXLOGOUT_TOUCH_CUR" then
			x=304;
			y=601;
		elseif aliesName=="ALIES_WXLOGOUT_TOUCH_QUIT" then
			x=501;
			y=759;


		elseif aliesName=="ALIES_WXLOGIN_TOUCH_QIEHUAN" then
			x=634;
			y=96;
		elseif aliesName=="ALIES_WXLOGIN_TOUCH_MAIL" then
			x=273;
			y=714;
		elseif aliesName=="ALIES_WXLOGIN_TOUCH_PASSWORD" then
			x=254;
			y=324;
		elseif aliesName=="ALIES_WXLOGIN_TOUCH_LOGIN" then
			x=354;
			y=485;
		else
			Log("aliesName don't exists:"..aliesName);
			x=0;
			y=0;
		end
	elseif DEVICE_TYPE=="SS" then
		if aliesName=="ALIES_WXLOGOUT_TOUCH_ME" then
			x=420;
			y=764;
		elseif aliesName=="ALIES_WXLOGOUT_TOUCH_SETTING" then
			x=110;
			y=603;
		elseif aliesName=="ALIES_WXLOGOUT_TOUCH_EXIT" then
			x=63;
			y=911;
		elseif aliesName=="ALIES_WXLOGOUT_TOUCH_CUR" then
			x=225;
			y=372;
		elseif aliesName=="ALIES_WXLOGOUT_TOUCH_QUIT" then
			x=329;
			y=489;


		elseif aliesName=="ALIES_WXLOGIN_TOUCH_QIEHUAN" then
			x=409;
			y=75;
		elseif aliesName=="ALIES_WXLOGIN_TOUCH_MAIL" then
			x=219;
			y=456;
		elseif aliesName=="ALIES_WXLOGIN_TOUCH_PASSWORD" then
			x=185;
			y=237;
		elseif aliesName=="ALIES_WXLOGIN_TOUCH_LOGIN" then
			x=239;
			y=347;
		else
			Log("aliesName don't exists:"..aliesName);
			x=0;
			y=0;
		end
	else
		Log("DEVICE_TYPE don't exists:"..DEVICE_TYPE);
		x=0;
		y=0;
	end
	
	touch(id,x,y);

end
--------------------------------------------------------------------
function touch(id,x,y)
	touchDown(id,x,y);
	mSleep(100);
	touchUp(id);
	mSleep(200);
end
function IsInProtectd()
	if DEVICE_TYPE=="MI" then
		--[[

		Log("IsInQieHuanZhangHao");
		Log("getColor()="..tostring(getColor( 134,417)));
		Log("getColor()="..tostring(getColor( 137,417)));
		Log("getColor()="..tostring(getColor( 144,418)));
		Log("getColor()="..tostring(getColor( 124,480)));
		Log("getColor()="..tostring(getColor( 125,480)));
		--]]
		if getColor( 134,417)~=0xF8F8F8 then return false;end;
		if getColor( 137,417)~=0xECECEC then return false;end;
		if getColor( 144,418)~=0xE0E0E0 then return false;end;
		if getColor( 124,480)~=0xD1D1D1 then return false;end;
		if getColor( 125,480)~=0xB7B7B7 then return false;end;
		return true;
	elseif DEVICE_TYPE=="SS" then
		
		return false;
	else
		Log("DEVICE_TYPE don't exists:"..DEVICE_TYPE);
	end
	return false;
end
function inputProtectPwd()
        mSleep(92);
        touchDown(0, 592, 739);
        mSleep(113);
        touchMove(0, 586, 729);
        mSleep(9);
        touchMove(0, 583, 724);
        mSleep(10);
        touchMove(0, 581, 719);
        mSleep(10);
        touchMove(0, 578, 715);
        mSleep(9);
        touchMove(0, 572, 709);
        mSleep(13);
        touchMove(0, 568, 704);
        mSleep(7);
        touchMove(0, 563, 698);
        mSleep(9);
        touchMove(0, 557, 692);
        mSleep(10);
        touchMove(0, 551, 685);
        mSleep(10);
        touchMove(0, 544, 676);
        mSleep(9);
        touchMove(0, 536, 667);
        mSleep(10);
        touchMove(0, 531, 660);
        mSleep(9);
        touchMove(0, 525, 652);
        mSleep(10);
        touchMove(0, 517, 643);
        mSleep(9);
        touchMove(0, 510, 634);
        mSleep(10);
        touchMove(0, 502, 626);
        mSleep(9);
        touchMove(0, 494, 616);
        mSleep(10);
        touchMove(0, 485, 607);
        mSleep(10);
        touchMove(0, 477, 598);
        mSleep(10);
        touchMove(0, 469, 589);
        mSleep(10);
        touchMove(0, 462, 580);
        mSleep(9);
        touchMove(0, 455, 573);
        mSleep(8);
        touchMove(0, 447, 564);
        mSleep(9);
        touchMove(0, 440, 556);
        mSleep(10);
        touchMove(0, 432, 547);
        mSleep(8);
        touchMove(0, 425, 540);
        mSleep(10);
        touchMove(0, 416, 531);
        mSleep(8);
        touchMove(0, 408, 523);
        mSleep(10);
        touchMove(0, 401, 515);
        mSleep(9);
        touchMove(0, 395, 508);
        mSleep(10);
        touchMove(0, 390, 502);
        mSleep(10);
        touchMove(0, 385, 498);
        mSleep(10);
        touchMove(0, 381, 494);
        mSleep(10);
        touchMove(0, 378, 490);
        mSleep(9);
        touchMove(0, 376, 488);
        mSleep(10);
        touchMove(0, 373, 485);
        mSleep(9);
        touchMove(0, 370, 483);
        mSleep(10);
        touchMove(0, 368, 481);
        mSleep(9);
        touchMove(0, 366, 480);
        mSleep(10);
        touchMove(0, 365, 479);
        mSleep(9);
        touchMove(0, 364, 478);
        mSleep(10);
        touchMove(0, 363, 478);
        mSleep(41);
        touchMove(0, 362, 478);
        mSleep(10);
        touchMove(0, 362, 479);
        mSleep(40);
        touchMove(0, 362, 490);
        mSleep(20);
        touchMove(0, 364, 514);
        mSleep(10);
        touchMove(0, 366, 532);
        mSleep(10);
        touchMove(0, 370, 548);
        mSleep(9);
        touchMove(0, 372, 566);
        mSleep(10);
        touchMove(0, 376, 586);
        mSleep(9);
        touchMove(0, 379, 608);
        mSleep(9);
        touchMove(0, 381, 627);
        mSleep(10);
        touchMove(0, 385, 645);
        mSleep(9);
        touchMove(0, 389, 667);
        mSleep(10);
        touchMove(0, 391, 678);
        mSleep(9);
        touchMove(0, 393, 690);
        mSleep(8);
        touchMove(0, 394, 700);
        mSleep(9);
        touchMove(0, 396, 707);
        mSleep(10);
        touchMove(0, 397, 713);
        mSleep(9);
        touchMove(0, 398, 718);
        mSleep(10);
        touchMove(0, 399, 721);
        mSleep(10);
        touchMove(0, 400, 724);
        mSleep(10);
        touchMove(0, 400, 726);
        mSleep(72);
        touchMove(0, 399, 728);
        mSleep(9);
        touchMove(0, 397, 727);
        mSleep(10);
        touchMove(0, 393, 723);
        mSleep(10);
        touchMove(0, 387, 719);
        mSleep(10);
        touchMove(0, 378, 711);
        mSleep(9);
        touchMove(0, 368, 702);
        mSleep(9);
        touchMove(0, 357, 692);
        mSleep(10);
        touchMove(0, 345, 682);
        mSleep(9);
        touchMove(0, 334, 669);
        mSleep(8);
        touchMove(0, 323, 659);
        mSleep(9);
        touchMove(0, 313, 647);
        mSleep(10);
        touchMove(0, 296, 633);
        mSleep(10);
        touchMove(0, 284, 622);
        mSleep(10);
        touchMove(0, 272, 610);
        mSleep(8);
        touchMove(0, 258, 598);
        mSleep(10);
        touchMove(0, 246, 587);
        mSleep(9);
        touchMove(0, 232, 576);
        mSleep(10);
        touchMove(0, 219, 566);
        mSleep(10);
        touchMove(0, 209, 557);
        mSleep(9);
        touchMove(0, 196, 546);
        mSleep(11);
        touchMove(0, 188, 536);
        mSleep(8);
        touchMove(0, 178, 527);
        mSleep(10);
        touchMove(0, 164, 515);
        mSleep(10);
        touchMove(0, 153, 505);
        mSleep(10);
        touchMove(0, 141, 497);
        mSleep(10);
        touchMove(0, 131, 490);
        mSleep(10);
        touchMove(0, 124, 484);
        mSleep(10);
        touchMove(0, 117, 478);
        mSleep(11);
        touchMove(0, 111, 472);
        mSleep(10);
        touchMove(0, 106, 468);
        mSleep(11);
        touchMove(0, 103, 465);
        mSleep(10);
        touchMove(0, 100, 462);
        mSleep(10);
        touchMove(0, 98, 460);
        mSleep(10);
        touchMove(0, 96, 459);
        mSleep(10);
        touchMove(0, 96, 458);
        mSleep(10);
        touchMove(0, 95, 457);
        mSleep(41);
        touchUp(0);
end
function IsInQieHuanZhangHao()
	if DEVICE_TYPE=="MI" then
		--[[

		Log("IsInQieHuanZhangHao");
		Log("getColor()="..tostring(getColor( 579,93 )));
		Log("getColor()="..tostring(getColor( 583,92 )));
		Log("getColor()="..tostring(getColor( 580,96 )));
		Log("getColor()="..tostring(getColor( 583,96 )));
		Log("getColor()="..tostring(getColor( 581,94 )));
		--]]
		if getColor( 579,93 )~=2238764  then return false;end;
		if getColor( 583,92 )~=2370350  then return false;end;
		if getColor( 580,96 )~=13422287 then return false;end;
		if getColor( 583,96 )~=2370350  then return false;end;
		if getColor( 581,94 )~=16777215 then return false;end;
		return true;
	elseif DEVICE_TYPE=="SS" then
		--[[

		Log("IsInQieHuanZhangHao");
		Log("getColor()="..tostring(getColor( 373,70 )));
		Log("getColor()="..tostring(getColor( 378,73 )));
		Log("getColor()="..tostring(getColor( 374,73 )));
		Log("getColor()="..tostring(getColor( 377,70 )));
		Log("getColor()="..tostring(getColor( 376,71 )));
		--]]
		if getColor( 373,70 )~=0x22292C then return false;end;
		if getColor( 378,73 )~=0x22292C then return false;end;
		if getColor( 374,73 )~=0x242B2E then return false;end;
		if getColor( 377,70 )~=0x727779 then return false;end;
		if getColor( 376,71 )~=0xFFFFFF then return false;end;
		return true;
	else
		Log("DEVICE_TYPE don't exists:"..DEVICE_TYPE);
	end
	return false;
end
function IsInMainPage()
	if DEVICE_TYPE=="MI" then
		if getColor( 550,82  )~= 0xFFFFFF then return false;end;
		if getColor( 548,91  )~= 0x22292C then return false;end;
		if getColor( 536,92  )~= 0xFFFFFF then return false;end;
		if getColor( 560,105 )~= 0xFFFFFF then return false;end;
		if getColor( 566,111 )~= 0xFFFFFF then return false;end;
		if getColor( 571,111 )~= 0x22292C then return false;end;
		return true;
	elseif DEVICE_TYPE=="SS" then
		--[[

		Log("IsInMainPage");
		Log("getColor()="..tostring(getColor( 373,70 )));
		Log("getColor()="..tostring(getColor( 378,73 )));
		Log("getColor()="..tostring(getColor( 374,73 )));
		Log("getColor()="..tostring(getColor( 377,70 )));
		Log("getColor()="..tostring(getColor( 376,71 )));
		Log("getColor()="..tostring(getColor( 376,71 )));
		--]]
		if getColor( 351,61  )~= 0xFDFDFD then return false;end;
		if getColor( 352,64  )~= 0x252B2E then return false;end;
		if getColor( 343,72  )~= 0x8E9293 then return false;end;
		if getColor( 356,77 )~= 0x22292C then return false;end;
		if getColor( 359,79 )~= 0xFFFFFF then return false;end;
		if getColor( 367,87 )~= 0x8F9294 then return false;end;
		return true;
	else
		Log("DEVICE_TYPE don't exists:"..DEVICE_TYPE);
	end
	return false;
end

--///////

function readFile(filename)
	--打开文件
	local file=io.open(filename)
    assert(file,"file open failed")
    Log("readFile "..filename.."...");
    local fileTab = {}
    local line = file:read()
    while line do
        Log("get line:"..line)
        table.insert(fileTab,line)
        line = file:read()
    end
    Log(table.concat(fileTab, ":"))
     --关闭文件
     file:close();
    return fileTab
end
 
function writeFile(filename,fileTab)
	local file=io.open(filename)
    assert(file,"file open failed")
    for i,line in ipairs(fileTab) do
        Log("write "..line)
        file:write(line)
        file:write("\n")
    end
     --关闭文件
     file:close();
end

--读取账号
function GetAccount(id)
   	 --读取文件到tab数组
     local tab = readFile(WX_ACCOUNT_FILE_PATH)
     --文件行数
     Log(string.format("tab size=%d,id=%d,tab[%d]=%s",#tab,id,id,tab[id]));
     --以,分割

     local arr=Split(tab[id],",");
     Log(string.format("arr size=%d",#arr));
     if #arr~=2 then 
     	return nil,nil;
     end

	return arr[1],arr[2];
	
end
--读取所有的账号
function GetAllAccount()
   	 --读取文件到tab数组
     local tab = readFile(WX_ACCOUNT_FILE_PATH)
     --文件行数
     Log(string.format("acc tab size=%d",#tab));
	return tab;
	
end
function GetUsernameFromTableById(tab,id)
	 local arr=Split(tab[id],",");
     if #arr~=2 then 
     	Log("acc tab error:arr size not equ 2.")
     	return nil,nil;
     end
	return arr[1];
end
function GetPasswordFromTableById(tab,id)
	 local arr=Split(tab[id],",");
     if #arr~=2 then 
     	Log("acc tab error:arr size not equ 2.")
     	return nil,nil;
     end
	return arr[2];
end
--数组分割函数
function Split(szFullString, szSeparator)
	Log(string.format("Split string=%s with separator=%s",szFullString,szSeparator));
	local nSplitArray = {}
	local nFindStartIndex = 1
	local nSplitIndex = 1

	        while true do
	           local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
	           if not nFindLastIndex then
	                nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
	                break
	           end
	           nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
	           nFindStartIndex = nFindLastIndex + string.len(szSeparator)
	           nSplitIndex = nSplitIndex + 1
	        end
	return nSplitArray
end

--////////////////////////////////////////////////////////////////////
function Log(str)
	--可以用 busybox tail -f log.txt查看
	--str=str or "_"
	if not DEBUG_LOG then return;end;;
	local cmd=string.format("echo \"[%s]%s\">>%s",os.date("%c"),str,LOG_FILE);
	--logDebug(cmd);
	os.execute(cmd);
	--logDebug(str);
	--notifyMessage(str);
end
function main()
	Log(string.format("=========main==Start with current lua version:%s",_VERSION))
	local exitStatu=xpcall(rMain,errorHandle);
	Log(string.format("---------End with statu:[%s]",tostring(exitStatu)))
end

function errorHandle(err)
	Log(string.format("Error:%s",err));
end
--//////////////////////////////////////////////////////////////////////////////////
Log("\n\n=========global init=======")
gAccTab=GetAllAccount();
Log("gAccTab size:"..tostring(#gAccTab));

listString="";

for i=1 , #gAccTab do
	tmpUsn=GetUsernameFromTableById(gAccTab,i);
	Log("id #"..tostring(i).."usn:"..tmpUsn);
	listString=listString..tostring(i).." "..tmpUsn.."|";
end
listString=string.sub(listString,0,string.len(listString)-1);
Log("listString="..listString);
UI = {
        {'TextView{                    '..VERSION_STRING..'}'},  
        {'TextView{ }'},
        {'DropList{'..listString..'}',    'uid','Select account to login'},
        {'DropList{type 1|type 2|type 3|type 4|type 5|type 6|type 7|type 8|type 9|type 0}',    'utype','Select type'},
        {'TextView{ }'},
        {'TextView{\n                                              (c) by coderlin}'},
};
Log("Init done!");
--////////////////////////////////////////////////////////////////////////////////////

--[[
_VERSION="vv";
function Log(str)
	print(str);
end
main();
--]]
