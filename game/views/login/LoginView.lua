--
-- Author: wx
--

local LoginView = class("LoginView", base.BaseView)

function LoginView:ctor()
    self.super.ctor(self)
    self.uiClear = UICacheType.cacheDisabled
    self.tabRoleLevel = {}
end

function LoginView:initView()
    --健康公告
    local jkgg = self.view:GetChild("n39")
    if jkgg then
        if tonumber(g_var.packId) == 1001 or tonumber(g_var.packId) == 1002 then
            jkgg.visible = false
        end
    end
    local loginUrl = ""
    local logoUrl = ""
    local _panel = self.view:GetChild("n8")
    if g_var.gameFrameworkVersion >= 18 then
        loginUrl = "@res/images/login.png"
        logoUrl = "@res/images/logo.png"
    else
        if tonumber(g_var.packId) == 1001 or tonumber(g_var.packId) == 3001 then
            loginUrl = "res/bgs/login/login2_"..g_var.packId
        else
            loginUrl = "res/bgs/login/login_"..g_var.packId
        end
        logoUrl = "res/bgs/login/logo_"..g_var.packId
    end
    self.view:GetChild("n9").url = loginUrl
    self.view:GetChild("n38").url = logoUrl
    ---当前服务器
    self._btn_cur = self.view:GetChild("n12")
    self._btn_cur.onClick:Add(self.onOpenServerListPanel, self)
    --服务器列表
    self.serverListPanel = self.view:GetChild("n7")
    self.serverListPanel.visible = false

    --公告面板
    self.noticeView = self.view:GetChild("n40")
    self.noticeView.onClick:Add(self.onClickNotice,self)
    self.noticeView.visible = false

    --调试使用的，使用是需要特别注意，不要滥用
    local dInput = UPlayerPrefs.GetString("debug_input_flag")
    if dInput~=nil and dInput=="true" then
        g_var.debugInput = 1
    end

    if g_var.debugInput == 1 then
        local account = UPlayerPrefs.GetString("account")
        self.inputText = _panel:GetChild("n1")
        self.inputText.onChanged:Add(self.onChangeInput,self)
        self.inputText.text = account
        g_var.accountId = account
        self:setPopupView()
    else
        _panel.visible = false
        self._btn_cur.visible = false
    end

    self.rightlist = self.serverListPanel:GetChild("n5")
    self.rightlist:SetVirtual()
    self.rightlist.itemRenderer = function(index,obj)
        self:cellseverdata(index, obj)
    end
    self.rightlist.numItems = 0
    self.rightlist.onClickItem:Add(self.onBtnServerCallBack,self)

    local btn_close_ListPanel = self.serverListPanel:GetChild("n13"):GetChild("n2")
    btn_close_ListPanel.onClick:Add(self.onCloseSeverListPanel,self)
    --进入游戏
    local btn_intogame = self.view:GetChild("n11")
    btn_intogame.onClick:Add(self.onStartClick, self)
    
    --显示版本号
    local textVersion = self.view:GetChild("n35")
    local vLabel = "App v"..g_var.pack_version.."."..g_var.version.."."..g_msg_version
    vLabel = vLabel.." Res v"..g_var.res_version.." Code v"..g_var.gameFrameworkVersion.." Build r"..g_var.build_time
    textVersion.text = vLabel
    local str = ""
    if tonumber(g_var.packId) == 3001 then
        str = language.login06
    end
    self.view:GetChild("n41").text = str
end

function LoginView:onSdkLoginSuc()
    self._btn_cur.visible = true
    self:onHTTPRequest()

    --SDK登录成功显示公告
    if not g_ios_test then
        self:setPopupView()
    end
end

function LoginView:onChangeInput(context)
    g_var.accountId = self.inputText.text
    --服务器列表请求
    if g_var.accountId ~= "" then
        self:onHTTPRequest()
    end
end

function LoginView:initData()
    --EVE 游戏登录界面特效
    if tonumber(g_var.packId) == 1001 or tonumber(g_var.packId) == 3001 then
        local gameNameEfc = self.view:GetChild("n33")
        self:addEffect(4020116,gameNameEfc)
        local gameBGEfc = self.view:GetChild("n32")
        local effectBG = self:addEffect(4030109,gameBGEfc)
        effectBG.Scale = Vector3.New(90,90,90)        --背景特效缩放  --添加时间 2017/5/15
        effectBG.LocalPosition = Vector3.New(0,90,0)   --背景特效位置

        local bgEfc = self.view:GetChild("n37")   --2017/7/25 背景特效
        local effectBG02 = self:addEffect(4030115,bgEfc)
        effectBG02.Scale = Vector3.New(65, 65, 65)
        effectBG02.LocalPosition = Vector3.New(0,0,500)   --特效位置
    end

    local btnEnterEfc = self.view:GetChild("n34")
    local effect = self:addEffect(4020117,btnEnterEfc)
    effect.Scale = Vector3.New(80,80,80)            --特效缩放
    effect.LocalPosition = Vector3.New(19.2,-6,0)   --特效位置

    --服务器列表请求
    if g_var.accountId ~= "" then
        self:onHTTPRequest()
    end

    --登录sdk
    mgr.TimerMgr:addTimer(0.5, 1, function()
        --mgr.SDKMgr:login()
        mgr.SDKMgr:cpLogin()
    end, "LoginSDK")
end 

--公告弹窗 logic
function LoginView:onClickNotice()
    mgr.HttpMgr:http(g_var.gonggao_url, 10, 10, function(state, data)
        mgr.ViewMgr:openView2(ViewName.NoticeView,data)
    end) 
end

--本地保存弹窗信息
function LoginView:setPopupView()
    mgr.HttpMgr:http(g_var.gonggao_url, 10, 10, function(state, data)
        local ispop = false
        local isBtn = false
        local open = tonumber(data.open)
        if open == 0 then  -- 每天第一次登陆弹出，或者更新后弹出
            isBtn = true
            local noticeVersion = UPlayerPrefs.GetInt("NoticeVersion")
            if noticeVersion ~= tonumber(data.version) then
                ispop = true
            else
                local curTime = os.time()
                local saveTime = UPlayerPrefs.GetInt("NoticeTime")
                local cur = GTotimeString6(curTime)
                local save = GTotimeString6(saveTime)
                if cur["year"] ~= save["year"] or cur["day"] ~= save["day"] or cur["month"] ~= save["month"] then
                    ispop = true
                end
            end
        elseif open == 1 then  -- 每次登陆都弹出
            ispop = true
            isBtn = true
        elseif open == 2 then  -- 登陆不弹出
            isBtn = true
        elseif open == 3 then  -- 不弹出并隐藏图标
            isBtn = false
        end
        if self.noticeView then
            self.noticeView.visible = isBtn
            if ispop then
                mgr.ViewMgr:openView2(ViewName.NoticeView,data)
                UPlayerPrefs.SetInt("NoticeVersion", tonumber(data.version))
                UPlayerPrefs.SetInt("NoticeTime", os.time())
            end
        end
    end)
end

function LoginView:onOpenServerListPanel()
    if  g_ios_test then  --EVE 屏蔽区服列表
        return
    end

    if not self.serverList then
        return
    end
    --如果是第一次登录
    if g_var.firstLogin == 1 then
        self:login()
    else
        self.serverListPanel.visible = true
        self:initSeverList()
    end
end
function LoginView:onCloseSeverListPanel()
    self.serverListPanel.visible = false
end

function LoginView:onStartClick()
    self:login()
end

---连接http,获取服务器列表 param page 请求第几页的信息
function LoginView:onHTTPRequest(page)
    if self.request then return  end
    self.request = true
    self.page = page or 1

    --当debugInput=1时，为debug模式
    if g_var.debugInput == 1 then
         if self.inputText.text ~= "" then --测试模式是， 直接读输入框的
            g_var.accountId = self.inputText.text
        end
    end

    mgr.HttpMgr:requestServerList("",page,function(data)
        self.request = false --消息已经返回
        if data.ret == 1 then
            if data.msg.my_list then
                self.serverList = data.msg  
                for k , v in pairs(self.serverList.my_list) do 
                    self.tabRoleLevel[v.name] = v.level                               
                end
            end
            if not page then 
                self:setSaveServer() --设置默认服务器信息
                self:initRightList(1)
            end
            --第几页的信息
            if not self.server_namelist then 
                self.server_namelist = {}
            elseif self.server_namelist[self.page] then 
                self.server_namelist[self.page] = {}
            end
            self.server_namelist[self.page] = data.msg.list
            if self.serverListPanel.visible and page then 
                if g_is_banshu then
                    self:initRightList(self.page)
                else
                    self:initRightList(self.totalCount- self.page)
                end                            
            end
        else
            plog("服务器列表没有返回")
        end
    end)
end

function LoginView:initSeverList()
    self:onHTTPRequest()
    -- return
    if not self.serverList then
        self:onHTTPRequest()
        return
    end
    --区选择
    --一共多少页
    if g_is_banshu then
        self.totalCount = self.serverList.pageTotal + 1
    else
        self.totalCount = self.serverList.pageTotal + 2 
    end
    --plog(self.totalCount,"self.totalCount")
    if not self.listLeft then
        self.listLeft = self.serverListPanel:GetChild("n4")--.asList
        self.listLeft:SetVirtual()
        self.listLeft.itemRenderer = function(index,obj)
            self:cellData(index, obj)
        end
        self.listLeft.numItems = self.totalCount
        self.listLeft.scrollPane.onScroll:Add(self.doSpecialEffect, self)
        self.listLeft.onClickItem:Add(self.onUIClickCall,self)
    else
        self.listLeft.numItems = self.totalCount
    end

    if self.qulistindex == 0 then
        self.listLeft:AddSelection(0,false)
        self:setLeftIndex(0)
    else
        self.listLeft:AddSelection(1,false)
        self:setLeftIndex(1)
    end
end
function LoginView:doSpecialEffect()
end

-- stype=1:最新的
-- stype=2:所以的服务器S,A,C,
-- stype=3:10000段以后A,C
--设置服务器区信息
function LoginView:cellData(index, cell)
    cell.data = index
    if g_is_banshu then
        if index == 0 then
            cell.title = language.login02
        else
            local max = (self.serverList.pageTotal - index + 1 )*10
            cell.title = self:toServerPre(max-9).."-"..self:toServerPre(max)..language.login03
            -- cell.title = string.format(language.login03,max-9,max)
        end
        return
    end

    if index == 0 then
        cell.title = language.login01
    elseif index == 1 then
        cell.title = language.login02
    else
        --古剑服务器列表
        self:gjxyCellData(index, cell)
    end
end

--武炼的服务器列表区号显示
function LoginView:wldfCellData(index, cell)
    local max  = (self.serverList.pageTotal - index + 2 ) * 10
    cell.title = self:toServerListTitle(max, 0)
end

--古剑的服务器列表区号显示
function LoginView:gjxyCellData(index, cell)
  --通过stype区分段
    local max = (self.serverList.pageTotal - index + 2 ) * 10

    if self.serverList.stype == 0 then
        cell.title = self:toServerListTitle(max, 30000)
    elseif self.serverList.stype == 2 then
        if max <=20 then 
            --此处为特殊处理区服问题（1-20为老服显示为S区
            cell.title = self:toServerListTitle(max, 0)
        elseif max <=40 then
            --此处为特殊处理区服问题（10001-19999）显示为A区
            cell.title = self:toServerListTitle(max-20, 10000)
        elseif max <=60 then 
            --此处为特殊处理区服问题（20001-29999）显示为C区
            cell.title = self:toServerListTitle(max-40, 20000)
        else
            --此处为特殊处理区服问题（30001-39999）显示为D区
            cell.title = self:toServerListTitle(max-60, 30000)
        end
    elseif self.serverList.stype == 3 then
        if max <=20 then 
            cell.title = self:toServerListTitle(max, 10000)
        elseif max <=40 then
            cell.title = self:toServerListTitle(max-20, 20000)
        else
            cell.title = self:toServerListTitle(max-40, 30000)
        end
    elseif self.serverList.stype == 4 then
        if max <=20 then
            cell.title = self:toServerListTitle(max, 20000)
        else
            cell.title = self:toServerListTitle(max-20, 30000)
        end
    elseif self.serverList.stype == 5 then
        cell.title = self:toServerListTitle(max, 30000)
    else --stype=1的，暂时先这样用
        cell.title = self:toServerListTitle(max, 20000)
    end
end

-- function LoginView:toServerListTitle(max,startMax)
function LoginView:toServerListTitle(max, startMax)
    max = (startMax or 0) + max
    return self:toServerPre(max-9).."-"..self:toServerPre(max)..language.login03
end

function LoginView:setLeftIndex(index)
    local num = 1
    if g_is_banshu then
        num = 0
    end
    if index > num then
        if not self.server_namelist or not self.server_namelist[self.totalCount-index] then --请求过的页面信息不再请求
            self:onHTTPRequest(self.totalCount-index) --按照当前选择的页数请求服务器列表
        else
            self:initRightList(index)
        end
    else
        self:initRightList(index)
    end
end

--某一个区 区间选择
function LoginView:onUIClickCall(context)
    local cell = context.data
    local index = cell.data
    self:setLeftIndex(index)
end
--服务器列表 选择
function LoginView:onBtnServerCallBack( context )
    local cell = context.data
    local info = cell.data
    if not info or not next(info) then
        return 
    end 
    if self:checkTypeInfo(info) then
        self:setCurinfo(info)
        self:onCloseSeverListPanel()
    end
end

function LoginView:checkTypeInfo(info)
    -- body
    local data = {}
    data.sure = function( ... )
        --plog("data.sure callback")
    end
    data.cancel = function( ... )
        --plog("data.cancel callback")
    end

    if info.type == 3 or info.type == 4 or info.type == 2 then     
        data.type = 5
        data.richtext = info.tip_str
        data.sure = function ()
            self:onCloseSeverListPanel()
        end
        GComAlter(data)
        return false
    end
    return true
end

--设置服务器列表信息
function LoginView:cellseverdata(index, cell)
    local info = self.rightdata[index+1]  
    cell.data = info
    -- printt("服务器信息",info)

    --EVE 优化 服务器选择界面，显示角色等级
    local  c1 = cell:GetController("ctrl_Level")
    c1.selectedIndex = 1 

    local textLevel = cell:GetChild("n8")

    local param = self.tabRoleLevel[info.name]
    if param then
        c1.selectedIndex = 0
        
        textLevel.text = "Lv.".. param  
    else
        c1.selectedIndex = 1

        textLevel.text = ""
    end
    cell.title = self:toServerPreName(info)
    cell.icon = UIItemRes.denlufuwuqi_statue_img[info.type+1] or UIItemRes.denlufuwuqi_statue_img[3] 
    local n2 = cell:GetChild("n2")
    if info.type == 1 or info.type == 2 then   --EVE 服务器爆满和维护，其上面的标志logo设为空
        n2.url = nil
    else
        n2.url = UIItemRes.denlufuwuqi_statue_font[info.type+1]     --EVE 服务器为新建，则加新建logo
    end
end



--计算服序号1021001(1001初始Id,需要减1000)
--获取服务器名字， 带前缀Sxx-xxx
--直接使用area_id作为区Id
function LoginView:toServerPreName(info)
        return info.name
end

--获取前缀
function LoginView:toServerPre(areaId)
    --前缀对应
    return areaId%1000
end

--服务器列表信息
function LoginView:initRightList(index)
    local data = {}
    if g_is_banshu then
        if index == 0 then --我的服务器
            data = self.serverList.recom_list or {}   
        else
            data = self.server_namelist[index] or {}
        end
    else
        if index == 0 then --我的服务器
            data = self.serverList.my_list or {}
        elseif index == 1 then --推荐服务器
            data = self.serverList.recom_list or {}
        else
            local page = self.totalCount - index
            data = self.server_namelist[page] or {}
        end
    end

    self.rightdata = data

    self.rightlist.numItems = #self.rightdata
end
--设置选择服务器信息
function LoginView:setCurinfo(info)
    --设置当前服务器信息
    if not info  then
        return 
    end 
    self.selectinfo = info
    local serverName = self:toServerPreName(info)
    g_var.serverName = serverName
    self._btn_cur.title = serverName
    self._btn_cur.icon = UIItemRes.denlufuwuqi_statue_img[info.type+1] or UIItemRes.denlufuwuqi_statue_img[3]
    if info.type == 0  then
        self._btn_cur:GetChild("icon1").url = "ui://login/denlufuwuqi_024"
    else
        self._btn_cur:GetChild("icon1").url = nil 
    end

end

function LoginView:setSaveServer()
    plog("setSaveServer")
    --服务器列表信息
    local info = {}
    --本地保存 上次登录信息
    local saveList = UPlayerPrefs.GetString("save_server_list_item")
    local cache_server
    if saveList and saveList ~= "" then
        cache_server = json.decode(saveList)
    end
    local n3 = self.serverListPanel:GetChild("n3")
    if cache_server and cache_server.name then
        n3.text = string.format(language.login04,cache_server.name)
    else
        n3.text = ""
    end
    -- 默认选择
    local data = nil
    --
    local teststr = ""
    if g_cache_server and not g_is_banshu and cache_server and cache_server.name then  --本地登录方便 直接选择上次登录界面
        teststr = teststr .. "本地缓存"
        data = cache_server
        if g_is_banshu then
            self.qulistindex = 0
        else
            self.qulistindex = 1 --当前选择是我的服务器列表
        end
    else
        --我的服务器（且不是客户端强制要求链接上传缓存服务器 主要给本地登录方便）
        if self.serverList.my_list and #self.serverList.my_list > 0 then 
            teststr = teststr .. "查找我的列表"

            if cache_server and #cache_server>0  then  --本地有
                for k , v in pairs(self.serverList.my_list) do 
                    if v.server_id == cache_server.server_id then
                        data = v                      
                        break
                    end
                end
            end
            if not data then
                for k , v in pairs(self.serverList.my_list) do 
                    if v.type == 0 or v.type == 1 then
                        data = v 
                        break
                    end
                end
            end

            if not data then --服务都在不0,1状态，而且 上次登录和php 缓存不一致（异常情况）
                data = self.serverList.my_list[1]
            end

            self.qulistindex = 0 --当前选择是我的服务器列表
        else --推荐服务器
            teststr = teststr .. "推荐服务器"
            for k ,v in pairs(self.serverList.recom_list) do --推荐服务器
                if v.type == 0 or v.type == 1 then
                    data =v 
                    break
                end
            end
            if not data then
                data = self.serverList.recom_list[1]
            end
            if g_is_banshu then
                self.qulistindex = 0
            else
                self.qulistindex = 1  --当前选择是推荐服务器
            end
        end
    end
    
    self:setCurinfo(data)
end

function LoginView:login()
    if g_var.accountId == "" then
        mgr.SDKMgr:cpLogin()
        return
    end
    if not self.selectinfo then
        return
    end
    if not self:checkTypeInfo(self.selectinfo) then
        return
    end

    local server = string.split(self.selectinfo["server"],":")
    g_var.socketAddress = server[1]
    g_var.socketPort = server[2]
    --设置服务器Id
    g_var.serverId = self.selectinfo.server_id
    --缓存信息
    UPlayerPrefs.SetString("save_server_list_item",json.encode(self.selectinfo))
    
    
    --win版本/没有SDK/游戏状态为内部测试(5)
    if g_var.debugInput == 1 then
        if self.inputText.text ~= "" then --测试模式是， 直接读输入框的
            g_var.accountId = self.inputText.text
        end
        UPlayerPrefs.SetString("account", g_var.accountId)
        if g_var.accountId == "" then
            GComAlter(language.login05)
            return
        end
    end

    self:loginGame()
end

function LoginView:loginGame()
    --CP登录成功，获取账号，可以进入游戏了
    if g_var.accountId ~= "" then
        if g_var.chargeBack == 0 then
            mgr.SDKMgr:enterGame()
        else
            local param = {}
            param.type = 14
            param.richtext = string.format(language.fengcefanhuan,g_var.chargeBack)
            param.sure = function()
                mgr.SDKMgr:enterGame()
            end
            param.cancel = function ()
                
            end
            GComAlter(param)
        end
    else
        mgr.SDKMgr:cpLogin()
    end
end

--[override]
function LoginView:doClearView(clear)

    -- 清理登录页
    if g_var.gameFrameworkVersion >= 2 then
        UnityResMgr:ForceDelAssetBundle("res/bgs/login/login_"..g_var.packId)
        UnityResMgr:ForceDelAssetBundle("res/bgs/login/login2_"..g_var.packId)
        UnityResMgr:ForceDelAssetBundle("res/bgs/login/logo_"..g_var.packId)
    end
end

return LoginView