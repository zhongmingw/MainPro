--
-- Author: 
-- Date: 2017-06-07 16:52:19
--

local DownLoadView = class("DownLoadView", base.BaseView)

local MB = 1024

function DownLoadView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
    self.uiClear = UICacheType.cacheTime
    self.speedIndex = 0
    self.beishu = ""
end

function DownLoadView:initData()
    proxy.ActivityProxy:send(1030202,{reqType = 1})
    self.downLoadBtn.enabled = true
    self.closeBtn.enabled = true

    self:addTimer(1, -1, function()
        self:setProgress()
    end)
    self:setDownBtn()
end

function DownLoadView:initView()
    self.arleayImg = self.view:GetChild("n5")
    self.progressBar = self.view:GetChild("n6")
    self.progressText = self.view:GetChild("title")
    self.downLoadBtn = self.view:GetChild("n8")
    self.downLoadBtn.onClick:Add(self.onClickDownLoad,self)
    self.closeBtn = self.view:GetChild("n7")
    self.closeBtn.onClick:Add(self.onClickClose,self)
    self.view:GetChild("n9").text = language.download01
    self.awardListView = self.view:GetChild("n4")
    self.speedTxt = self.view:GetChild("n14")
    self.awardListView:SetVirtual()
    self.awardListView.itemRenderer = function(index,obj)
        self:cellAwardsData(index, obj)
    end
    self.view:GetChild("n11").text = language.download04
    self:setProgress()

    if g_var.gameFrameworkVersion >= 12 then
        self.speedBtn = self.view:GetChild("n19")
        self.speedBtn.onClick:Add(self.addSpeed, self)
    end
end

function DownLoadView:addSpeed()
    self.speedIndex = (self.speedIndex + 1)%4
    local str = ""
    if self.speedIndex == 0 then
        str = "1024,3"
        self.beishu = ""
    elseif self.speedIndex == 1 then
        str = "1024,1"
        self.beishu = "(2倍)"
    elseif self.speedIndex == 2 then
        str = "1024,0"
        self.beishu = "(4倍)"
    elseif self.speedIndex == 3 then
        str = "2048,0"
        self.beishu = "(8倍)"
    end
    GameUtil.ExtendFunc(1003,str)
end

function DownLoadView:setData(data)
    self.mData = data
    local visible = true
    if data.isUsed == 0 then--未领取
        visible = false
    end
    self.arleayImg.visible = false
    self.awards = conf.SysConf:getValue("download_gift")
    self.awardListView.numItems = #self.awards
end
--
function DownLoadView:onClickDownLoad()
    if mgr.DownloadMgr:isDownload() then--暂停
        mgr.DownloadMgr:stopDownload()
    else --果断下载
        mgr.DownloadMgr:startLoad(true)
    end
    if mgr.DownloadMgr.isArleayDownload then--分包资源已下载
        if cache.PlayerCache:getDownloadGift() then--有大礼包可以领取
            proxy.ActivityProxy:send(1030202,{reqType = 2})
        end
        self.downLoadBtn.icon = UIItemRes.download03
    end
    self:setDownBtn()
end

function DownLoadView:setDownBtn()
    self.downLoadBtn.enabled = true
    if mgr.DownloadMgr:isDownload() then
        self.downLoadBtn.icon = UIItemRes.download02
    else--果断下载
        self.downLoadBtn.icon = UIItemRes.download01
    end
    if mgr.DownloadMgr.isArleayDownload then--分包资源已下载
        if not cache.PlayerCache:getDownloadGift() then--没有大礼包可以领取了
            self.downLoadBtn.enabled = false
        end
        self.downLoadBtn.icon = UIItemRes.download03
    end
end

function DownLoadView:setProgress()
    local value, max = mgr.DownloadMgr:downProgress()
    self.progressBar.value = value
    self.progressBar.max = max
    if value > max then
        value = max
    end
    local value1 = string.format("%.2fM", value / MB)
    local max1 = string.format("%.2fM", max / MB)
    self.progressText.text = value1.."/"..max1
    self.speedTxt.text = UnityUpdateMgr:GetSpeed().."kb/s"..self.beishu
end
--奖励列表
function DownLoadView:cellAwardsData(index,cell)
    local data = self.awards[index + 1]
    local itemData = {mid = data[1],amount = data[2], grayed = self.arleayImg.visible}
    GSetItemData(cell, itemData, true)
end
--无视
function DownLoadView:onClickClose()
    self:closeView()
end

return DownLoadView