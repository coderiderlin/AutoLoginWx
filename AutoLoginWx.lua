

--////////////////////////////////////////////////////////////////////
--注意在mi2s要将软件的图形模式设置为兼容
--定义文件路径
DEBUG_LOG=false;
LOG_FILE="/mnt/sdcard/glog.txt"
WX_ACCOUNT_FILE_PATH = "/sdcard/wxacc/wx.txt"
WX_APP_NAME ="com.tencent.mm"
VERSION_STRING="AutoLoginWX v0.3a"
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
		notifyMessage('等待切换用户页面');
			repeat 
				mSleep(100);
			until IsInQieHuanZhangHao()
	end
	--notifyMessage('在切换页面,正在登陆。。。');
	--点击切换账号
	touchAlies(0,"ALIES_WXLOGIN_TOUCH_QIEHUAN"   );
	mSleep(500);
	--选择微信号/邮箱/QQ号
	touchAlies(0, "ALIES_WXLOGIN_TOUCH_MAIL"   );
	mSleep(1000);
	--输入账号
	inputText(username);
	--换到密码输入
	touchAlies(0, "ALIES_WXLOGIN_TOUCH_PASSWORD" );
	mSleep(300)
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
		notifyMessage('等待主页。。');
		repeat 
			mSleep(500);
			Log("waiting main page...");
		until IsInMainPage()
		Log("main page...");
	end
	--notifyMessage('在主页,正在注销。。');
	mSleep(1000);
	--点我
	Log("touch me...");
	touchAlies(0,"ALIES_WXLOGOUT_TOUCH_ME");
	mSleep(500);
	--点设置
	Log("touch setting...");
	touchAlies(0, "ALIES_WXLOGOUT_TOUCH_SETTING" );
	mSleep(500);
	--点退出
	Log("touch exit...");
	touchAlies(0,   "ALIES_WXLOGOUT_TOUCH_EXIT"  );
	mSleep(500);
	--点退出当前账号
	Log("touch quit cur...");
	touchAlies(0,  "ALIES_WXLOGOUT_TOUCH_CUR"  );
	mSleep(500);
	--点退出
	Log("touch quit...");
	touchAlies( 0,"ALIES_WXLOGOUT_TOUCH_QUIT"  );
	mSleep(500);
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
			y=711;
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

function IsInQieHuanZhangHao()
	if DEVICE_TYPE=="MI" then
		if getColor( 579,93 )~=0x22292C then return false;end;
		if getColor( 583,92 )~=0x22292C then return false;end;
		if getColor( 580,96 )~=0x4C5255 then return false;end;
		if getColor( 583,96 )~=0x252C2F then return false;end;
		if getColor( 581,94 )~=0xFFFFFF then return false;end;
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
