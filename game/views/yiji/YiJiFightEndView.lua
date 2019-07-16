--
-- Author: Your Name
-- Date: 2018-12-19 11:36:04
--

local YiJiFightEndView = class("YiJiFightEndView", base.BaseView)

function YiJiFightEndView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
end

function YiJiFightEndView:initView()
    local closeBtn = self.view:GetChild("n9")
    closeBtn.onClick:Add(self.onCloseView,self)
    self.c1 = self.view:GetController("c1")
    --获胜奖励
    self.awardsList = self.view:GetChild("n6")
    self.awardsList.numItems = 0
    self.awardsList.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.awardsList:SetVirtual()
    self.winTxt = self.view:GetChild("n7")
    self.defeatTxt = self.view:GetChild("n8")
    self.timeTxt = self.view:GetChild("n10")--
end

function YiJiFightEndView:initData(data)
    if not data then
        return
    end
    self.lastTime = 10
    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil
    end
    self.timeTxt.text = string.format(language.fuben11,self.lastTime)
    self.timer = self:addTimer(1, -1, handler(self, self.onTimer))
    if data.result == 1 then--获胜
        self.c1.selectedIndex = 0
        local cityId = cache.YiJiTanSuoCache:getCityId()
        local confData = conf.YiJiTanSuoConf:getCityInfoById(cityId)
        self.winTxt.text = string.format(language.yjts20,data.name,confData.name)
        if data.items and #data.items > 0 then
            self.items = data.items
            self.awardsList.numItems = #data.items
        end
    else--失败
        self.c1.selectedIndex = 1
        self.defeatTxt.text = string.format(language.yjts21,data.name)
    end
end

function YiJiFightEndView:onTimer()
    if self.lastTime > 0 then
        self.lastTime = self.lastTime - 1
        self.timeTxt.text = string.format(language.fuben11,self.lastTime)
    else
        self:onCloseView()
    end
end

function YiJiFightEndView:celldata(index,obj)
    local data = self.items[index+1]
    if data then
        GSetItemData(obj, data, true)
    end
end

function YiJiFightEndView:onCloseView()
    print("关闭界面>>>>>>>>>>>>>>>>>>")
    local view = mgr.ViewMgr:get(ViewName.ArenaFightView) 
    if view then
        view:onCloseView()
    end
    self:closeView()
end

return YiJiFightEndView