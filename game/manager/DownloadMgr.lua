--
-- Author: yr
-- Date: 2017-06-08 16:13:19
--

local DownloadMgr = class("DownloadMgr")

function DownloadMgr:ctor()
    self.isComplete = false
    self.totalSize = 0
    self.receiveSize = 0
    self.thingIds = nil
    self.allow4g = false
    self.first = true
end

function DownloadMgr:init()
    self:startLoad()
    if self.isComplete then
        -- print("@分包资源已下载")
        -- TODO 下载完了
        self:finish()
    else
        -- TODO 没有下载完。添加客户端图标
        self.isArleayDownload = false

        UnityUpdateMgr:RegisterLuaFunc(function(name)
            print("@资源下载解压完毕："..name)

            --icon加载完毕就load进来
            if name == "ui1004" then
                self:loadIcon()
            end
        end)
    end
end
--下载完了
function DownloadMgr:finish()
    self.isArleayDownload = true
    local view = mgr.ViewMgr:get(ViewName.MainView)
    if view then
        view.TopActive:checkRedGift()
    end
end

--wifi环境或者force=true
function DownloadMgr:startLoad(force)
    if force and not self:isWifi() then self.allow4g = n4g end   --是否允许4G下载
    if self:isDownload() and self.first == false then
        -- print("已经下载中/第一次不返回")
        return
    end
    if self:isWifi() or force then
        -- print("@开启后台下载程序")
        self.isComplete = true
        self.thingIds = {}
        local cdnResUrl = g_var.cdn_url.."/"..g_var.ptName.."/"..g_var.platform.."/e"..g_var.res_version.."/"
        print("DownloadMgr-Url:"..cdnResUrl)
        local info = conf.DownloadConf:getDownloadInfo()
        for i=1, #info do
            local v = info[i]
            local list = v["list"]
            if g_var.gameFrameworkVersion < 19 and #list <= 0 then
                -- C#版本在19以前，如果#list==0则continue
            else
                local resName = v["name"]
                local url = cdnResUrl..resName..".zip"
                local exit = UnityUpdateMgr:BackDownloadFile(url)
                if exit then  --已经下载
                    if self.first then
                        self.receiveSize = self.receiveSize + (v["size"] or 0) 
                    end
                else  --未下载
                    -- print("未下载："..url)
                    for j=1, #list do
                        self.thingIds[tostring(list[j])] = 1
                    end
                    self.isComplete = false
                end
                if self.first then
                    self.totalSize = self.totalSize + (v["size"] or 0)
                end
            end
        end
        self.first = false
    else
        self.isComplete = self:checkDownComplete2()
    end

    --定时器检查
    if not self.downTimer and not self.isComplete then
        self.downTimer = mgr.TimerMgr:addTimer(2, -1, function()
            --如果是wifi则开始下载
            if self:isWifi() then
                if not self:isDownload() then
                    -- print("@切换Wifi，可以下载")
                    self:startLoad()
                end
            else --如果是非wifi并且没有允许4g下载在下载中 则停止下载
                if self:isDownload() and self.allow4g==false then
                    -- print("@切换4G，停止下载")
                    self:stopDownload()
                end
            end

            --检查是否下载完毕
            if self:checkDownComplete() then
                -- print("@分包资源下载完毕")
                self.thingIds = {}
                if self.downTimer then
                    mgr.TimerMgr:removeTimer(self.downTimer)
                    self.downTimer = nil
                end
                self:finish()
            end
        end,"downTimer")
    end
end

function DownloadMgr:downProgress()
    --print("@分包资源进度")
    if self:isDownload() then  --如果在下载
        return self.receiveSize + self:getReceiveSize(), self.totalSize
    else  --如果没有下载
        if self.first then
            local info = conf.DownloadConf:getDownloadInfo()
            for i=1, #info do
                local v = info[i]
                local exit = UnityUpdateMgr:CheckDownload(v["name"])
                if exit then  --已经下载
                    self.receiveSize = self.receiveSize + (v["size"] or 0)
                end
                self.totalSize = self.totalSize + (v["size"] or 0)
            end
            self.first = false
            return self.receiveSize, self.totalSize
        end
        return self.receiveSize + self:getReceiveSize(), self.totalSize
    end
end

function DownloadMgr:isDownload()
    return UnityUpdateMgr.IsDownload
end

function DownloadMgr:getReceiveSize()
    return UnityUpdateMgr:GetReceivedSize()
end

function DownloadMgr:stopDownload()
    -- print("@停止分包资源下载")
    self.allow4g = false
    if self.downTimer then
        mgr.TimerMgr:removeTimer(self.downTimer)
        self.downTimer = nil
    end
    UnityUpdateMgr:StopDownload()
end

function DownloadMgr:checkDownComplete()
    local info = conf.DownloadConf:getDownloadInfo()
    local res = info[#info]
    local check = UnityUpdateMgr:CheckDownload(res["name"])
    if check then
        return true
    end
    return false
end

function DownloadMgr:checkDownComplete2()
    local info = conf.DownloadConf:getDownloadInfo()
    for i=1, #info do
        local v = info[i]
        local exit = UnityUpdateMgr:CheckDownload(v["name"])
        if exit == false then
            return false
        end
    end
    return true
end

--如果是下载id 则检查是否已经下载，如果没有则返回true
--返回true则说明需要用替换的通用模型
function DownloadMgr:checkDownload(id, ab)
    if g_extend_res == false then
        return false
    end
    self:setThingIds()
    if self.thingIds[tostring(id)] then
        local check = PathTool.CheckResDown(ab)
        if not check then
            return true 
        end
        self.thingIds[tostring(id)] = nil
    end
    return false
end

--初始化后台下载对象
function DownloadMgr:setThingIds()
    if not self.thingIds then
        self.thingIds = {}
        local info = conf.DownloadConf:getDownloadInfo()
        for i=1, #info do
            local v = info[i]
            local list = v["list"]
            for j=1, #list do
                self.thingIds[tostring(list[j])] = 1
            end
        end
    end
end

function DownloadMgr:isWifi()
    --[[if self.test then
        print("@网络环境-4G")
        return false
    end]]
    if g_var.network == 2 then
        --print("@网络环境-WiFi")
        return true
    end
    return false
end

function DownloadMgr:loadIcon()
    local icon = "res/ui/_icons2"
    local check = PathTool.CheckResDown(icon..".unity3d")
    if check or g_extend_res == false or g_var.gameFrameworkVersion >= 22 then
        unity.createUIPackage(icon, "_icons2", function() end)
    end
end

function DownloadMgr:test4g()
    if not self.test then
        self.test = true
    else
        self.test = false
    end
end

return DownloadMgr