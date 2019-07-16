--
-- Author: 
-- Date: 2018-12-18 14:19:36
--元旦投资
local YuanDan1002 = class("YuanDan1002",import("game.base.Ref"))

function YuanDan1002:ctor(mParent,modelId)
    self.mParent = mParent
    self.modelId = modelId
    self:initPanel()
end
function YuanDan1002:initPanel()
    local panelObj = self.mParent:getPanelObj(self.modelId)

    self.timeTxt = panelObj:GetChild("n2")
    self.timeTxt.text = ""
    
    local decTxt = panelObj:GetChild("n3")
    decTxt.text = language.yuandan02


    local num = conf.YuanDanConf:getValue("ny_invest_cost")
    self.quota = num
    panelObj:GetChild("n5").text = num
    local touZiBtn = panelObj:GetChild("n11")
    touZiBtn.title = string.format(language.yuandan04,num)
    touZiBtn:GetChild("red").visible = false
    touZiBtn.onClick:Add(self.onClickTouZiBtn,self)

    self.listView = panelObj:GetChild("n10")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:cellData(index, obj)
    end
    self.listView:SetVirtual()

    self.c1 = panelObj:GetController("c1")



end

function YuanDan1002:onTimer()

end
--int8变量名：investSign  说明：是否已经投资 （1 已投资 0 未投资）
function YuanDan1002:setData(data)
    -- printt("投资",data)
    if data then
        if data.reqType == 1 then
            GComAlter(language.yuandan08)
        elseif data.reqType == 2 then
            GOpenAlert3(data.items)
        end
        self.data = data 
        self.timeTxt.text = GToTimeString12(data.actStartTime) .. "-" .. GToTimeString12(data.actEndTime)

        self.c1.selectedIndex = data.investSign

        self.confData = conf.YuanDanConf:getTouZiData()
        self.listView.numItems = #self.confData
    end
end

function YuanDan1002:cellData(index,obj)
    local awardList = obj:GetChild("n8")
    local getBtn = obj:GetChild("n9")
    local btnC1 = getBtn:GetController("c1")
    getBtn:GetChild("red").visible = false
    getBtn.onClick:Add(self.onClickGetBtn,self)
    local c1 = obj:GetController("c1")

    local title = obj:GetChild("n7")

    local data = self.confData[index+1]
    if data then
        local str = mgr.TextMgr:getTextColorStr(data.id%10000,10)
        title.text = string.format(language.yuandan03,str)
        GSetAwards(awardList, data.items)
        if self.data.gotSigns[data.id] then
            c1.selectedIndex = 2
        else
            if  self.data.investSign  and self.data.investSign == 1 and self.data.curDay and tonumber(self.data.curDay) >= data.id%10000 then
                c1.selectedIndex = 1 --可领取
                btnC1.selectedIndex = 0
                getBtn:GetChild("red").visible = true
            else
                c1.selectedIndex = 0
                btnC1.selectedIndex = 1
            end
        end
        getBtn.data = {id = data.id,selectedIndex = c1.selectedIndex}
    end
end



function YuanDan1002:onClickTouZiBtn()
    local param = {
        type = 14,
        richtext = string.format(language.yuandan07,self.quota),
        sure = function()
            proxy.YuanDanProxy:sendMsg(1030678,{reqType = 1,cid = 0})
        end
    }
    GComAlter(param)
end


function YuanDan1002:onClickGetBtn(context)
    local btn = context.sender
    local data = btn.data 
    if data.selectedIndex == 0 then
        GComAlter(language.ge04)
    elseif data.selectedIndex == 1 then
        proxy.YuanDanProxy:sendMsg(1030678,{reqType = 2,cid = data.id})
    end
end



return YuanDan1002
