--
-- Author: EVE 
-- Date: 2018-01-24 16:27:32
-- 小年登录

local ActiveDL = class("ActiveDL",import("game.base.Ref"))

function ActiveDL:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end
function ActiveDL:initPanel()
    local panelObj = self.mParent:getPanelObj(3045)

    self.timeText = panelObj:GetChild("n4") --活动时间
    
    local decTxt = panelObj:GetChild("n5")  --活动内容描述
    decTxt.text = language.lunaryear02 

    self.listView = panelObj:GetChild("n1")
    self:initListView()
end

function ActiveDL:initListView()
    self.listView.numItems = 0
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index,obj)
    end
end

function ActiveDL:cellData(index,obj)
    local data = self.confData[index+1]
    if data then 
        --奖励ICON
        local awardList = obj:GetChild("n7")
        GSetAwards(awardList, data.awards)

        --领取按钮
        local c1 = obj:GetController("c1")
        local getBtn = obj:GetChild("n3")
        getBtn.data = data
        getBtn.touchable = true
        -- getBtn:GetChild("red").visible = false
        getBtn.onClick:Add(self.getAwards,self)

        --日期 & 领取状态
        local dateTxt = obj:GetChild("n4")
        for _,v in pairs(self.data.itemGotDatas) do
            if v.cid == data.id then
                --日期
                local dateTab = os.date("*t",v.time)
                dateTxt.text = (dateTab.month) .. language.gonggong79 .. (dateTab.day) .. language.gonggong80
                --领取状态
                if v.gotStatus == 0 then --不可领取
                    c1.selectedIndex = 0
                    getBtn.touchable = false

                elseif v.gotStatus == 1 then --已领取
                    c1.selectedIndex = 2                  

                elseif v.gotStatus == 2 then --已错过
                    c1.selectedIndex = 3

                else --可领取
                    c1.selectedIndex = 1
                end
            end
        end
    end
end

function ActiveDL:getAwards(context)
    local data = context.sender.data
    -- print("发送的id：",data.id)
    proxy.ActivityProxy:sendMsg(1030175, {reqType = 2,cid = data.id,actId = 3045})
end

function ActiveDL:setData(data)
    self.data = data

    self.confData = conf.ActivityConf:getLoginAwardPublic(3045)
    
    self.timeText.text = GToTimeString8(data.actStartTime).."—"..GToTimeString8(data.actEndTime)
    
    self.listView.numItems = #self.confData
end

return ActiveDL