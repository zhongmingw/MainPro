--
-- Author: 
-- Date: 2018-08-13 10:49:25
--
local MonthCardPanel = class("MonthCardPanel", import("game.base.Ref"))

local BG1 = {
    [1] = "yueka_003",--4800
    [2] = "yueka_012",--10240
}

local BG2 = {
    [1] = "yueka_005",--4800
    [2] = "yueka_014",--10240
}


local QuotaImg = {
    [1] = "yueka_021",--"600元宝"
    [2] = "yueka_016",--"1280元宝"
}

local BtnImg = {
    [0] = "yueka_018",--"补投680元宝"
    [1] = "yueka_006",--"投资600元宝"
    [2] = "yueka_019",--"投资1280元宝"
}

function MonthCardPanel:ctor(mParent)
    self.parent = mParent
    self:initView()
end

function MonthCardPanel:initView()
    self.view = self.parent.view:GetChild("n46")
    self.c1  = self.view:GetController("c1")
    local investBtn = self.view:GetChild("n3")
    self.investBtn = investBtn
    investBtn.onClick:Add(self.goInvest,self)
    self.listView = self.view:GetChild("n13")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView:SetVirtual()

    self.bg1 = self.view:GetChild("n1")
    self.bg2 = self.view:GetChild("n2")
    --提示字
    self.titleIcon = self.view:GetChild("n15")

    --新加额度
    self.quotaPanel = self.view:GetChild("n29")
    self.quotaPanel.visible = true
    self.quotaTxt = self.view:GetChild("n19")
    self.quotaImg = self.view:GetChild("n16")
    self.quotaLv = 2
    self.quotaImg.url = UIPackage.GetItemURL("vip" , QuotaImg[self.quotaLv])
    self.investBtn.icon = UIPackage.GetItemURL("vip" , BtnImg[self.quotaLv])

    self.bg1.icon = UIPackage.GetItemURL("vip" , BG1[self.quotaLv])
    self.bg2.icon = UIPackage.GetItemURL("vip" , BG2[self.quotaLv])

    self.quotaTxt.text = language.month10[self.quotaLv]

    local levelBtn = self.view:GetChild("n20")--等阶筛选按钮
    levelBtn.onClick:Add(self.onClickLevCal,self)
    --筛选组件
    self.Panel = self.view:GetChild("n27")
    self.Panel.visible = false
    self.listPanel = self.view:GetChild("n22")
    self.listPanel.itemRenderer = function(index,obj)
        self:cellPanelData(index, obj)
    end
    self.listPanel.numItems = 0
    self.listPanel.onClickItem:Add(self.onlistPanel,self)

    self.monthCost = conf.ActivityConf:getValue("month_card_cost")
    self.monthReturn = conf.ActivityConf:getValue("month_return")
end

--额度筛选
function MonthCardPanel:onClickLevCal(context)
    local btn = context.sender 
    if self.Panel.visible then 
        self.Panel.visible = false
        return
    end
    self:callset(btn)
end

function MonthCardPanel:callset(btn)
    self.Panel.x = btn.x - self.Panel.width + btn.width + 5
    self.Panel.y = btn.y + 25
    self.Panel.visible = true
    local temp = 0
    self.listPanel.numItems = #language.month10 
    self.listPanel:AddSelection(self.quotaLv-temp,false)
end

function MonthCardPanel:cellPanelData(index,obj)
    obj.data = index + 1
    obj.title = language.month10[index+1]
end

--选择档位
function MonthCardPanel:onlistPanel(context)
    local data = context.data.data
    --购买月卡档位
    self.quotaLv = data
    self:setIcon(self.quotaLv)
    proxy.ActivityProxy:sendMsg(1030512,{reqType = 0,pos = self.quotaLv,awardId = 0})
    self.Panel.visible = false

end

function MonthCardPanel:setIcon(quotaLv)
    self.quotaImg.url = UIPackage.GetItemURL("vip" , QuotaImg[quotaLv])
    self.investBtn.icon = UIPackage.GetItemURL("vip" , BtnImg[quotaLv])
    self.quotaTxt.text = language.month10[self.quotaLv]
    self.bg1.icon = UIPackage.GetItemURL("vip" , BG1[quotaLv])
    self.bg2.icon = UIPackage.GetItemURL("vip" , BG2[quotaLv])
end

function MonthCardPanel:addMsgCallBack(data)
    self.data = data
    -- printt("月卡信息",data)
    if data.buySign == 1 then
        if data.pos == 2 then--投资了第二档
            self.quotaPanel.visible = false
            self.quotaLv = 2
            self:setIcon(self.quotaLv)
            self.titleIcon.url = UIPackage.GetItemURL("vip" ,"yueka_024")--所有档位都投资过了
            self.c1.selectedIndex = 1--已投资
        else
            self.quotaPanel.visible = true
            if self.quotaLv > data.pos then--投资的第一档，选择的第二档
                self.c1.selectedIndex = 0--补投
                self.investBtn.icon = UIPackage.GetItemURL("vip" , BtnImg[0])
                self.titleIcon.url = UIPackage.GetItemURL("vip" ,"yueka_023")--投资过，还可以在投资
                self.quotaImg.url = UIPackage.GetItemURL("vip" ,"yueka_017")--680元宝(差额)
            else
                self.titleIcon.url = UIPackage.GetItemURL("vip" ,"yueka_024")
                self.c1.selectedIndex = 1--已投资
            end
        end
    else
        self.quotaPanel.visible = true
        self.c1.selectedIndex = 0--可投资
        self.titleIcon.url = UIPackage.GetItemURL("vip" ,"yueka_022")--从未投资过
    end
    self.confData = conf.ActivityConf:getMonthCardByPos(self.quotaLv)
    self.isGot = {}
    for k,v in pairs(data.reGotSign) do
        self.isGot[v] = 1
    end
    for k,v in pairs(self.confData) do
        if data.buySign == 0 then
            self.confData[k].sort = 1 --未达成
        else
            --sort 0:可领取 1:未达成 2:已领取
            if data.pos == 2 and data.oldPos > 0 then
                if data.curDay > v.id%1000 then
                    if v.id%1000 == 0 then
                        if data.firstGotSign == 0 then
                            self.confData[k].sort = 0
                        elseif data.firstGotSign == 1 and not self.isGot[v.id] then
                            self.confData[k].sort = 0
                        else
                            self.confData[k].sort = 2
                        end
                    else
                        if self.isGot[v.id] and self.isGot[v.id] == 1 then
                            self.confData[k].sort = 2
                        else
                            self.confData[k].sort = 0
                        end
                    end
                elseif data.curDay == v.id%1000 then
                    if data.dayGotSign == 1 then
                        if self.isGot[v.id] and self.isGot[v.id] == 1 then
                            self.confData[k].sort = 2
                        else
                            self.confData[k].sort = 0
                        end
                    else
                        self.confData[k].sort = 0
                    end
                else
                    self.confData[k].sort = 1 --未达成
                end
            elseif data.pos == 2 then--
                self:setSort(k,v)
            elseif data.pos == 1 then--
                if self.quotaLv > data.pos then--选择的档位大于以投资的档位
                    self.confData[k].sort = 1 --未达成
                else
                    self:setSort(k,v)
                end
            end
        end
    end
    table.sort(self.confData,function(a,b)
        if a.sort ~= b.sort then
            return a.sort < b.sort
        elseif a.id ~= b.id then
            return a.id < b.id
        end
    end)


    self.listView.numItems = #self.confData

end

function MonthCardPanel:setSort(k,v)
    if self.data.curDay > v.id%1000 then
        if v.id%1000 == 0 then
            if self.data.firstGotSign == 0 then
                self.confData[k].sort = 0
            else
                self.confData[k].sort = 2
            end
        else
            self.confData[k].sort = 2
        end
    elseif self.data.curDay == v.id%1000 then
        if self.data.dayGotSign == 1 then
            self.confData[k].sort = 2
        else
            self.confData[k].sort = 0
        end
    else
        self.confData[k].sort = 1
    end
end

function MonthCardPanel:cellData(index,obj)
    local c1 = obj:GetController("c1")
    local item = obj:GetChild("n7")
    local title = obj:GetChild("n8")
    local money = obj:GetChild("n10")
    local specialDec = obj:GetChild("n11")
    local getBtn = obj:GetChild("n12")

    local data = self.confData[index+1]
    if data then

        if data.sort == 0 then
            c1.selectedIndex = 1
        elseif data.sort == 1 then
            c1.selectedIndex = 0
        elseif data.sort == 2 then
            c1.selectedIndex = 2
        end
        local itemData = {mid = PackMid.bindGold,amount = 0 ,bind = 1}
        GSetItemData(item, itemData,true)

        if data.id%1000 == 0 then
            title.text = language.month01[1]
        else
            title.text = string.format(language.month03,data.id%1000)
        end
        --只投了第一档(所选档位大于投资档位)  or 所选档位等于投资档位且补投过 
        if self.quotaLv > self.data.pos or (self.quotaLv == self.data.pos and self.data.oldPos > 0 ) then
            if data.id%1000 == 0 then
                if self.data.firstGotSign == 0 then--投资立返没有领取
                    money.text = data.yb
                elseif not self.isGot[data.id] and self.data.firstGotSign == 1 then--补领投资立返
                    money.text = self.monthCost[2] - self.monthCost[1]
                else
                    money.text = data.yb
                end
            else
                if self.data.curDay == data.id%1000 and  self.data.dayGotSign == 0 then--今天没领过
                    money.text = data.yb
                elseif not self.isGot[data.id] and
                    (self.data.curDay > data.id%1000 or 
                    (self.data.curDay == data.id%1000 and self.data.dayGotSign == 1)) then--补领之前的(天数)
                    money.text = self.monthReturn[2] - self.monthReturn[1]
                else
                    money.text = data.yb
                end
            end
        else
            money.text = data.yb
        end

        getBtn.data = {id =  data.id}
        getBtn.onClick:Add(self.onClickGetBtn,self)
        if data.mul then
            specialDec.text = string.format(language.month04,tonumber(data.mul))
        else
            if data.id == 0 then
                specialDec.text = language.month09
            else
                specialDec.text = ""
            end
        end
    end
end

function MonthCardPanel:onClickGetBtn(context)
    local data = context.sender.data
    local id = data.id 
    local reqType = 0
    if id%1000 == 0 then
        if self.data.firstGotSign == 0 then--投资立返没有领取
            reqType = 3
        elseif self.data.firstGotSign == 1 and self.data.oldPos > 0 and not self.isGot[id] then--补领投资立返
            reqType = 4
        end
    else
        if self.data.dayGotSign == 0 then--今天没领过
            reqType = 1
        elseif self.data.dayGotSign == 1 and self.data.oldPos > 0 and not self.isGot[id] then--补领之前的(天数)
            reqType = 4
        end
    end

    -- local reqType = id%1000 == 0 and 3 or 1 
    local awardId = reqType == 4 and id or 0
    -- print("reqType",reqType,"pos",self.quotaLv,"awardId",awardId)
    proxy.ActivityProxy:sendMsg(1030512,{reqType = reqType,pos = self.quotaLv,awardId = awardId})
end

function MonthCardPanel:goInvest()
    local quota = 0
    if self.data.buySign == 0 then--没有投资过
        quota = self.monthCost[self.quotaLv]
    else
        if self.quotaLv > self.data.pos  then--选择的档位大于以投资的档位
            quota = self.monthCost[self.quotaLv] - self.monthCost[self.data.pos]
        else
            quota = self.monthCost[self.quotaLv]
        end
    end
    local param = {
        type = 14,
        richtext = string.format(language.month08,quota,quota),
        sure = function()
            if self.data.buySign == 0 or self.quotaLv > self.data.pos  then
                proxy.ActivityProxy:sendMsg(1030512,{reqType = 2,pos = self.quotaLv,awardId = 0})
            else
                GComAlter(language.month05)
            end
        end
    }
    GComAlter(param)
end


return MonthCardPanel