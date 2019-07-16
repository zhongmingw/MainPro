--
-- Author: Your Name
-- Date: 2018-08-01 22:18:25
--冲战达人
local ActWarExpertView = class("ActWarExpertView", base.BaseView)

function ActWarExpertView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function ActWarExpertView:initView()
    local closeBtn = self.view:GetChild("n9")
    self:setCloseBtn(closeBtn)
    self.listView = self.view:GetChild("n15")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
    self.lastTimeTxt = self.view:GetChild("n17")
    self.lastTime = 0
    self.titleIcon = self.view:GetChild("icon")
end

function ActWarExpertView:celldata(index,obj)
    local data = self.awardsData[index+1]
    if data then
        local ybTxt1 = obj:GetChild("n2")
        local ybTxt2 = obj:GetChild("n6")
        ybTxt1.text = data.quota
        ybTxt2.text = data.quota
        local goBtn = obj:GetChild("n9")
        goBtn.onClick:Add(self.onClickCharge,self)
        local listView = obj:GetChild("n10")
        listView.numItems = 0
        for k,v in pairs(data.awards) do
            local url = UIPackage.GetItemURL("_components" , "ComItemBtn")
            local itemObj = listView:AddItemFromPool(url)
            local itemInfo = {mid = v[1],amount = v[2],bind = v[3]}
            GSetItemData(itemObj, itemInfo, true)
        end
    end
end

function ActWarExpertView:onTimer()
    if self.lastTime > 0 then
        self.lastTime = self.lastTime - 1
        self.lastTimeTxt.text = GGetTimeData2(self.lastTime)
    else
        self:closeView()
    end
end
    
-- 变量名：lastTime    说明：剩余时间
-- 变量名：mulActId    说明：多开活动id
function ActWarExpertView:initData(data)
    self.lastTime = data.lastTime

    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil
    end
    self.lastTimeTxt.text = GGetTimeData2(self.lastTime)
    self.timer = self:addTimer(1, -1, handler(self, self.onTimer))

    local confData = conf.ActivityConf:getMulActById(data.mulActId)
    self.titleIcon.url = UIPackage.GetItemURL("rechargedraw" , confData.title_icon)
    self.awardsData = conf.ActivityConf:getCzdrAwards(confData.award_pre)
    self.listView.numItems = #self.awardsData
end

function ActWarExpertView:onClickCharge()
    GOpenView({id = 1042})
end

return ActWarExpertView