--
-- Author: 
-- Date: 2017-05-09 19:41:24
--

local AdvancedTipView = class("AdvancedTipView", base.BaseView)

function AdvancedTipView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level1
end

function AdvancedTipView:initData(data)
    self:setData(data)
end

function AdvancedTipView:initView()
    self.view:GetChild("n9").text = language.tip12
    self.icon = self.view:GetChild("n10")
    self.descText = self.view:GetChild("n6")
    local btn = self.view:GetChild("n3")
    btn.onClick:Add(self.onClickGoto,self)
    local closeBtn = self.view:GetChild("n4")
    closeBtn.onClick:Add(self.onClickClose,self)
    self.sclectBtn = self.view:GetChild("n8")
    self.sclectBtn.onChanged:Add(self.onCheck,self)
end

function AdvancedTipView:setData(data)
    self.data = data
    self.part = data.part--
    local modelId = data.modelId
    self.tabType = {}
    if not modelId then
        plog("提示的升阶道具id",data.mid)
        self.tabType = conf.ItemConf:getTabType(data.mid)
        modelId = self.tabType[1]
    else--数据是{modelId = 1029,step = 0,canUp = 1}
        self.tabType[1] = modelId
    end
    self.modelId = modelId
    self.icon.url = ResPath.iconRes(UIItemRes.advtip01[modelId])
    self.descText.text = language.tips08[modelId]
    self.sclectBtn.selected = false
    if not self.tipTimer then
        self.time = AdvanceTipTime
        self:onTimer()
        self.tipTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
end

function AdvancedTipView:releaseTimer()
    if self.tipTimer then
        self:removeTimer(self.tipTimer)
        self.tipTimer = nil
    end
end

function AdvancedTipView:onTimer()
    if self.time <= 0 then
        self:releaseTimer()
        self:onClickClose()
        return
    end
    self.time = self.time - 1
end

function AdvancedTipView:getData()
    return self.data
end

function AdvancedTipView:onClickGoto()
    local childIndex = self.part or self.tabType[2]
    GOpenView({id = self.tabType[1],childIndex = childIndex})
    self:releaseTimer()
    cache.PackCache:cleanAdvPros(true)
    if #cache.PackCache:getAdvPros() <= 0 then
        self:closeView()
    else
        mgr.ItemMgr:checkAdvPros()
    end
end

function AdvancedTipView:onCheck()
    if self.modelId then
        cache.PackCache:setNotAdvancedTip(self.modelId,self.sclectBtn.selected)
    end
end

function AdvancedTipView:onClickClose()
    self:releaseTimer()
    cache.PackCache:cleanAdvPros(true)
    if #cache.PackCache:getAdvPros() <= 0 then
        self:closeView()
    else
        mgr.ItemMgr:checkAdvPros()
    end
end

function AdvancedTipView:closeModule(modelId)
    if self.modelId and self.modelId == modelId then
        cache.PackCache:cleanAdvPros(true)
        if #cache.PackCache:getAdvPros() <= 0 then
            self:closeView()
        else
            mgr.ItemMgr:checkAdvPros()
        end
    else
        for k,v in pairs(cache.PackCache:getAdvPros()) do
            if v.modelId then
                if v.modelId == modelId then
                    table.remove(cache.PackCache:getAdvPros(),k)
                    break
                end
            else
                if v and v.mid then
                    local tabType1 = conf.ItemConf:getTabType(v.mid)
                    if tabType1 and type(tabType1) ~= "number" and tabType1[1] == modelId then
                        table.remove(cache.PackCache:getAdvPros(),k)
                        break
                    end
                end
            end
        end
    end
end

return AdvancedTipView