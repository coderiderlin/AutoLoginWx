

--////////////////////////////////////////////////////////////////////

--定义文件路径
DEBUG_LOG=false;
LOG_FILE="/mnt/sdcard/glog.txt"
WX_ACCOUNT_FILE_PATH = "/sdcard/wxacc/wx.txt"
WX_APP_NAME ="com.tencent.mm"
VERSION_STRING="AutoLoginWX v0.1a"


function rMain()
	local accTab=GetAllAccount();
	local wxUsn;
	local wxPwd;
	local id=tonumber(Split(uid,' ')[1]);
	Log("Do login to id #"..tostring(id));
	wxUsn=GetUsernameFromTableById(accTab,id);
	wxPwd=GetPasswordFromTableById(accTab,id);
	
	
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
	touch(0,634,96   );
	mSleep(500);
	--选择微信号/邮箱/QQ号
	touch(0, 273,714   );
	mSleep(1000);
	--输入账号
	inputText(username);
	--换到密码输入
	touch(0, 254,324 );
	mSleep(300)
	--输入密码
	inputText(password)	
	--点登陆
	touch(0,  354,458  );
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
	touch(0,633,1228);
	mSleep(500);
	--点设置
	Log("touch setting...");
	touch(0, 165,805 );
	mSleep(500);
	--点退出
	Log("touch exit...");
	touch(0,   91,947  );
	mSleep(500);
	--点退出当前账号
	Log("touch quit cur...");
	touch(0,  304,601  );
	mSleep(500);
	--点退出
	Log("touch quit...");
	touch( 0, 501,759  );
	mSleep(500);
	return true;
end
--------------------------------------------------------------------
function touch(id,x,y)
	touchDown(id,x,y);
	mSleep(100);
	touchUp(id);
	mSleep(200);
end

function IsInQieHuanZhangHao()
	if getColor( 579,93 )~=0x22292C then return false;end;
	if getColor( 583,92 )~=0x22292C then return false;end;
	if getColor( 580,96 )~=0x4C5255 then return false;end;
	if getColor( 583,96 )~=0x252C2F then return false;end;
	if getColor( 581,94 )~=0xFFFFFF then return false;end;
	return true;
end
function IsInMainPage()
	if getColor( 550,82  )~= 0xFFFFFF then return false;end;
	if getColor( 548,91  )~= 0x22292C then return false;end;
	if getColor( 536,92  )~= 0xFFFFFF then return false;end;
	if getColor( 560,105 )~= 0xFFFFFF then return false;end;
	if getColor( 566,111 )~= 0xFFFFFF then return false;end;
	if getColor( 571,111 )~= 0x22292C then return false;end;
	return true;
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
