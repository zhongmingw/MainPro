--
-- Author: Your Name
-- Date: 2017-12-07 20:58:40
--

local TaskTipsView = class("TaskTipsView", base.BaseView)

function TaskTipsView:ctor()
    self.super.ctor(self)
    self.isBlack = true
    self.uiLevel = UILevel.level2 
end

function TaskTipsView:initView()
    self:setCloseBtn(self.view)
    self.icon = self.view:GetChild("n2"):GetChild("n0")
    self.name = self.view:GetChild("n14")
    self.counts = self.view:GetChild("n15")
    self.actTime = self.view:GetChild("n8")
    self.limitTxt = self.view:GetChild("n9")
    self.decTxt = self.view:GetChild("n7")
    self.actNum = self.view:GetChild("n11")
    self.awardsList = self.view:GetChild("n13")
    self.awardsList.numItems = 0
    self.awardsList.itemRenderer = function(index,obj)
        self:itemData(index, obj)
    end
    self.awardsList:SetVirtual()
end

function TaskTipsView:itemData( index,obj )
    local data = self.awards[index+1]
    if data then
        local mid = data[1]
        local amount = data[2]
        local bind = data[3]
        local itemInfo = {mid = mid,amount = amount,bind = bind}
        GSetItemData(obj, itemInfo, true)
    end
end

function TaskTipsView:initData(data)
    self.name.text = data.name
    self.counts.text = data.counts
    self.actTime.text = data.actTime
    if data.iconImg then
        local iconUrl = UIPackage.GetItemURL("_icons" , data.iconImg)
        if not iconUrl then
            iconUrl = UIPackage.GetItemURL("_icons2" , data.iconImg)
        end
        self.icon.url = iconUrl
    end
    --开启限制
        -- print("999999999",data.skipId)
    local moduleConf = conf.SysConf:getModuleById(data.skipId)
        if moduleConf then
            if moduleConf.open_lev then
                self.limitTxt.text = string.format(language.guide07,moduleConf.open_lev)
            elseif moduleConf.openTask then
                local confdata = conf.TaskConf:getTaskById(moduleConf.openTask)
                if confdata.trigger_lev then
                    self.limitTxt.text = string.format(language.dailytask02,confdata.trigger_lev)
                else
                    self.limitTxt.text = language.dailytask03
                end
            else
                self.limitTxt.text = language.juese04
            end
        else
            self.limitTxt.text = language.juese04
        end
    local textData = {--
        {text = language.dailytask04,color = 6},
        {text = data.decTxt,color = 7},
    }
    self.decTxt.text = mgr.TextMgr:getTextByTable(textData)
    local oneceExp = data.actNum
    local isvip3 = cache.PlayerCache:VipIsActivate(3)
    if isvip3  then
        local add = conf.ImmortalityConf:getValue("xiuxian_add_plus")
        oneceExp = math.ceil(data.actNum + data.actNum * (add/100))
    end
    self.actNum.text = oneceExp
    self.awards = data.awards
    self.awardsList.numItems = #self.awards
end

return TaskTipsView