--
-- Author: 
-- Date: 2017-11-21 22:36:59
--

local AlertView19 = class("AlertView19", base.BaseView)

function AlertView19:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale 
end

function AlertView19:initView()
    local window4 = self.view:GetChild("n0")
    self.window4 = window4
    local closeBtn = window4:GetChild("n2")
    local cancelBtn = self.view:GetChild("n2")
    closeBtn.onClick:Add(self.onClickClose,self)
    cancelBtn.onClick:Add(self.onClickClose,self)
    self.confirmBtn = self.view:GetChild("n1")

    self.conList = self.view:GetChild("n5")
    self.conTxt = self.conList:GetChild("n0")
    self.conTxt.text = ""
end

function AlertView19:initData(data)
    self.fubenGlobalData = conf.FubenConf:getValue("xylt_max_bo")
    self.fubenSdDian = conf.FubenConf:getValue("xylt_sd_bo_dian")
    self.fubenTime = conf.FubenConf:getValue("xylt_one_bo_time")
    self.window4.icon = UIItemRes.fuben09
    self.data = data
    if self.data.reqType then   -- 扫荡奖励列表
        if self.data.reqType == 1 then
            --printt(self.data)
            local str = string.format(language.fuben194,self.data.killBo,self.data.killBo*self.fubenTime ) --节约多少秒
            str = str .."\n".."获得奖励："
            self.confirmBtn.onClick:Add(self.onClickClose,self)
            self.window4.icon = UIItemRes.fuben10 
            local list = {}
            for k,v in pairs(self.data.items) do
                if v.mid == PackMid.bindCopper then  --等于铜钱
                    table.insert(list, v)
                    break
                end
            end
            for k,v in pairs(self.data.items) do
                if v.mid ~= PackMid.bindCopper then 
                    table.insert(list, v)
                end
            end
            self.data.items = list 
            for k,v in pairs(self.data.items) do
                str = str.."\n".. conf.ItemConf:getName(v.mid).."*"..mgr.TextMgr:getTextColorStr(v.amount,7)
            end
            self.conTxt.text = str
        else
            self.confirmBtn.onClick:Add(self.onSweep,self)
            local str = ""
            for i=self.fubenSdDian,1,-1 do
                passId = Fuben.xianyulingta * 1000 + i
                self.sweepData = conf.FubenConf:getFubenSweepCost(passId)
                if self.sweepData then
                    if self.data.maxRecordBo >= self.sweepData.bo then
                        self.sweepBo = self.sweepData.bo
                        str = string.format(language.fuben193,self.data.maxRecordBo,self.sweepBo,self.sweepBo+1)
                        break
                    end
                end
            end
            self.conTxt.text = str
        end
    end
end

function AlertView19:setData(data_)

end

function AlertView19:onSweep()
    local sceneId = Fuben.xianyulingta
    if self.data.maxRecordBo < self.fubenGlobalData then
        mgr.FubenMgr:gotoFubenWar(sceneId,self.sweepBo)
    end
    cache.FubenCache:setXyltReqtype(1)--缓存请求类型
    self:closeView()
end

function AlertView19:onClickClose()
    self:closeView()

end

return AlertView19