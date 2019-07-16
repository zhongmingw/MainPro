--[[
  更新管理
]]
local UpdateMgr = class("UpdateMgr")

function UpdateMgr:ctor()
    -- 版本更新
    self.updateList = {}
    self.curBytes = 0
    self.loadBytes = 0
    self.totalBytes = 0

    --后台资源下载
    self.resLoadList = {}
end
--更新回调  1-下载中 2-解压完成
function UpdateMgr:onUpdateCallBack(state, loadBytes)
    if state == 1 or state == 2 then
        local b = tonumber(loadBytes) + self.loadBytes
        local view = mgr.ViewMgr:get(ViewName.UpdateView)
        if view then
            view:updateBar(b, self.totalBytes*1024)
        end
        local str = string.format("%.2fM/%.2fM", (b/1024/1024), (self.totalBytes/1024)) 
        self:setText("更新版本大小("..str..")....")
    elseif state == 3 then
        self.loadBytes = self.loadBytes + loadBytes
        table.remove(self.updateList, 1)
        self:startLoad()
    end
end

--开始检查更新
function UpdateMgr:startCheckUpdate()
    local ver = self:getLocalVersion()
    if tonumber(g_var.version) == tonumber(ver) then--版本一致
        --TODO 没有更新
        self:updateComplete()
    else
        --注册回调事件
        UnityUpdateMgr:RegisterLuaFunc(function(state, loadBytes)
            self:onUpdateCallBack(state, loadBytes)
        end)
        --TODO 获取更新信息
        mgr.ViewMgr:openView(ViewName.UpdateView, function()
            self:requestVersionInfo(g_var.version)
        end)
    end
end
--获取远程服务器最新版本
function UpdateMgr:requestNewestInfo()
    self:setText("检查服务器版本信息....")
    local url = g_var.server_url.."?pname="..self:getPlatform().."&version=".."1.0.1"
    mgr.HttpMgr:http(url, 10, 10, function(state, data)
        if state == "success" then
            --请求完成服务端的最新版本信息
            g_var.version = data.version
            g_var.res_version = data.res_version
            g_var.server_list_url = data.server_list_url
            g_var.cdn_url = data.cdn_url
            g_var.record_account_url = data.record_account_url
            --printt(data)
            --开始更新本地
            self:startCheckUpdate()
        elseif state == "fail" then
            --TODO 弹出对话框请求失败->获取服务端版本信息失败
            self:setText("获取服务端版本信息失败....")
        end
    end)
end

--请求服务器，获取版本数据
function UpdateMgr:requestVersionInfo(version)
    self:setText("收集更新版本....")
    self.markTime = os.time()
    local url = self:getServerName()..self:getPlatform().."/v"..version.."/version.txt?t="..self.markTime
    mgr.HttpMgr:http(url, 10, 10, function(state, data)
        if state == "success" then
            self:calculateUpdateList(data)
        elseif state == "fail" then
            --TODO 弹出对话框请求失败->更新版本version失败
            plog("弹出对话框请求失败->更新版本version失败")
        end
    end)
end

--计算那些更新 可能有几个版本 
function UpdateMgr:calculateUpdateList(data)
    table.insert(self.updateList, 1, data)
    local lastVer = tonumber(data.pkg_version) - 1
    if tonumber(self:getLocalVersion()) == lastVer then --添加完成 计算所有包的大小
        self.totalBytes = 0
        for i,v in ipairs(self.updateList) do 
            self.totalBytes = self.totalBytes + v.pkgtotal
        end
        self:setText("更新版本大小(0/"..math.floor(self.totalBytes/1024).."M)....")
        if self.totalBytes <= 10240 then  --更新包大于10M
            self:startLoad()
        else
            self:startLoad()
        end 
    else
        self:requestVersionInfo(lastVer)
    end
end

--开始下载更新内容
function UpdateMgr:startLoad()
    local len = #self.updateList
    if len == 0 then
        self:updateComplete()
    else
        local data = self.updateList[1]
        local updateUrl = self:getUpdateUrl(data.pkg_version)
        UnityUpdateMgr:OnDownloadFile(updateUrl)
    end
end

--进入游戏
function UpdateMgr:updateComplete()
    self:setText("初始化游戏资源")
    --游戏的初始化
    require("game.init")
    --加载公共资源
    --进入登录界面
    local view = mgr.ViewMgr:get(ViewName.UpdateView)
    if view then
        view:updateBar(100, 100)
    end
    local count = #UICommonRes
    for k, v in pairs(UICommonRes) do
        local resStr = "res/ui/"..v
        unity.loadUIPackage(resStr, function()
            count = count - 1
            if count <= 0 then
                mgr.ViewMgr:closeView(ViewName.UpdateView)
                mgr.ViewMgr:openView(ViewName.LoginView)
            end
        end)
    end
end

function UpdateMgr:getUpdateUrl(version)
    local url = self:getServerName()..self:getPlatform().."/v"..version.."/update.zip?t="..os.time()
    return url
end

function UpdateMgr:getLocalVersion()
    return require("version").pkg_version
end

function UpdateMgr:getPlatform()
    return require("version").platform
end

function UpdateMgr:getServerName()
    return g_var.cdn_url.."/"
end

-----------------后台资源下载----------------------
function UpdateMgr:startCheckBackUpdate()
    --注册回调事件
    UnityUpdateMgr:RegisterLuaFunc(function(state, loadBytes)
        self:onResUpdate(state, loadBytes)
    end)
    local resVer = g_var.res_version
    self.markTime = os.time()
    local url = self:getServerName()..self:getPlatform().."/e"..resVer.."/version.txt?t="..self.markTime
    mgr.HttpMgr:http(url, 10, 10, function(state, data)
        if state == "success" then
            self:compareMd5(data)
        elseif state == "fail" then
            plog("获取资源版本号失败")
        end
    end)
end

function UpdateMgr:onResUpdate(state, loadBytes)
    if state == 3 then  --一个包下载完成
        table.remove(self.resLoadList, 1)
        self:startLoadRes()
    end
end

function UpdateMgr:compareMd5(data)
    for k, v in pairs(data) do
        local md5 = UnityUpdateMgr:GetLocalMd5(k)
        if md5 ~= tostring(v) then
            table.insert(self.resLoadList, k)
            plog("需要下载的资源包体", k)
        end
    end

    self:startLoadRes()
end

function UpdateMgr:startLoadRes()
    local len = #self.resLoadList
    if len > 0 then
        local name = self.resLoadList[1]
        local updateUrl = self:getResUrl(name)
        UnityUpdateMgr:OnDownloadFile(updateUrl)
    else
        plog("所有后台下载包体完毕")
    end
end

function UpdateMgr:getResUrl(name)
    local url = self:getServerName()..self:getPlatform().."/e"..g_var.res_version.."/"..name..".zip?t="..os.time()
    return url
end

------------------view显示操作-----------------------
function UpdateMgr:setText(str)
    local view = mgr.ViewMgr:get(ViewName.UpdateView)
    if view then
        view:updateLabel(str)
    end
end

------------------弹窗提示---------------------------
function UpdateMgr:setAlert(str)
    
end

return UpdateMgr