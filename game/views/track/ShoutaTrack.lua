--
-- Author: 
-- Date: 2017-10-23 14:08:39
--
local module_id = 1130
local ShoutaTrack = class("ShoutaTrack",import("game.base.Ref"))

function ShoutaTrack:ctor(mParent,listView)
    self.mParent = mParent
    self.listView = listView
    self:initPanel()
end

function ShoutaTrack:initPanel()
    -- body
    self.nameText = self.mParent.nameText
    self:setFubenName()
end

function ShoutaTrack:onTimer()
    if not self.data then
        return
    end
    if not self._compent2 then
        return
    end
    self.data.boLeftSec = math.max(self.data.boLeftSec-1,0)
    local param = clone(language.fuben142)
    param[2].text = string.format(param[2].text,GTotimeString3(self.data.boLeftSec))
    self._compent2:GetChild("n2").text = mgr.TextMgr:getTextByTable(param)
end

function ShoutaTrack:setFubenName()
    -- body
    local sId = cache.PlayerCache:getSId()
    self.Sconf = conf.SceneConf:getSceneById(sId)
    self.nameText.text = self.Sconf.name 
end

function ShoutaTrack:initMsg()
    -- body
    if self.mParent.data.index == 10 then
        module_id = 1130
    elseif self.mParent.data.index == 12 then
        module_id = 1131
    end
    --print("self.mParent.index",self.mParent.data.index)
    self.data = cache.FubenCache:getsceneTaskMsg(module_id)
    if not self.data then
        print("守塔场景任务信息没有")
        return
    end
    self:setFubenName()
    --清理列表
    self.listView.numItems = 0
    --当前第几波
    local var = UIPackage.GetItemURL("track" , "Component3")
    self._compent1 = self.listView:AddItemFromPool(var)

    --距离下一波的刷新时间
    local var = UIPackage.GetItemURL("track" , "TimeTrack")
    local _compent2 = self.listView:AddItemFromPool(var)
    local param = clone(language.fuben142)
    param[2].text = string.format(param[2].text,GTotimeString3(0)) 
    _compent2:GetChild("n2").text = mgr.TextMgr:getTextByTable(param)
    self._compent2 = _compent2
    --mgr.TextMgr:getTextColorStr(language.fuben142,1)
    -- local var = UIPackage.GetItemURL("track" , "TimeTrack")
    -- self._compent2 = self.listView:AddItemFromPool(var)
    -- self._compent2:GetChild("n2").text = ""

    --已击杀波数
    local var = UIPackage.GetItemURL("track" , "TimeTrack")
    local _compent1 = self.listView:AddItemFromPool(var)
    local param = clone(language.fuben143)
    param[2].text = string.format(param[2].text,"")
    _compent1:GetChild("n2").text = mgr.TextMgr:getTextByTable(param)
    self._compent3 = _compent1
    --mgr.TextMgr:getTextColorStr(language.fuben143,1)

    --获得奖励
    local var = UIPackage.GetItemURL("track" , "TimeTrack")
    local _compent4 = self.listView:AddItemFromPool(var)
    _compent4:GetChild("n2").text = language.fuben182

    local var = UIPackage.GetItemURL("track" , "TimeTrack")
    self._compent4 = self.listView:AddItemFromPool(var)
    self._compent4:GetChild("n2").text = ""

    if self.timer then
        self.mParent:removeTimer(self.timer)  
    end
    self:onTimer()
    self.timer = self.mParent:addTimer(1, -1, handler(self,self.onTimer))

    self:setMsg()
end

function ShoutaTrack:setMsg()
    -- body
    printt("任务追踪信息",self.data)
    if not self.data then
        return
    end
    if not self._compent1 then
        return
    end
    self._compent1:GetChild("n0").text = string.format(language.fuben144,self.data.curBo)
    if not self._compent3 then
        return
    end
    local str = ""
    if module_id == 1130 then
        str = self.data.killBo.."/100"
    elseif module_id == 1131 then
        str = self.data.killBo.."/40"
    end
    local param = clone(language.fuben143)
    param[2].text = string.format(param[2].text,str)
    self._compent3:GetChild("n2").text =mgr.TextMgr:getTextByTable(param)

    --奖励
    local s = ""
    local number = table.nums(self.data.drops)
    local i = 0

    if module_id == 1130 then
        --单人守塔
        local tq_amount 
        local _t = {
            PackMid.bindCopper,
            PackMid.lingtong1,
            PackMid.lingtong,
            PackMid.lington2
        }
        for k ,v in pairs(_t) do
            if self.data.drops[v] and self.data.drops[v] ~= 0 then
                if s ~= "" then
                    s = s.. "\n"
                end
                local condata = conf.ItemConf:getItem(v)
                s = s .. condata.name .. "*" .. GTransFormNum(self.data.drops[v])
            end
        end
    elseif module_id == 1131 then
        --多人守塔
        if self.data.drops[PackMid.xiuwei] and self.data.drops[PackMid.xiuwei] ~= 0 then
            if s ~= "" then
                s = s.. "\n"
            end
            s = s .. language.fuben184 .. "*"..GTransFormNum(self.data.drops[PackMid.xiuwei])
        end

        if self.data.drops[PackMid.bindCopper] and self.data.drops[PackMid.bindCopper] ~= 0 then
            if s ~= "" then
                s = s.. "\n"
            end
            local condata = conf.ItemConf:getItem(PackMid.bindCopper)
            s = s .. condata.name .. "*"..GTransFormNum(self.data.drops[PackMid.bindCopper])
        end

        for k ,v in pairs(self.data.drops) do
            if k ~= PackMid.xiuwei and k~= PackMid.bindCopper then
                i = i + v--bxp  原来i = i +1
            end
        end

        if i ~= 0 then
            if s ~= "" then
                s = s.. "\n"
            end
            s = s .. language.fuben183 .. "*" .. GTransFormNum(i)
        end
    end
   
    self._compent4:GetChild("n2").text = mgr.TextMgr:getTextColorStr(s, 7)
end

function ShoutaTrack:releaseTimer()
    if self.timer then
        self.mParent:removeTimer(self.timer)
        self.timer = nil
    end
end
function ShoutaTrack:endFuben()
    self:releaseTimer()
end
function ShoutaTrack:onClickQuit()
    self:endFuben()
    mgr.FubenMgr:quitFuben()
end
return ShoutaTrack