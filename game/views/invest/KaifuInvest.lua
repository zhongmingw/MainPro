--开服投资
local KaifuInvest = class("KaifuInvest", import("game.base.Ref"))

function KaifuInvest:ctor(mParent)
    -- body
    self.parent = mParent
    self:initPanel()
end

function KaifuInvest:initPanel()
    -- body
    self.view = self.parent.view:GetChild("n8")
    self.listView = self.view:GetChild("n1")
    self.timeTxt = self.view:GetChild("n3")
    self.investBtn = self.view:GetChild("n4")
    self.timeTxt.visible = false
    self.timeTxt.text = ""
    self.lastTime = 0
    self.mainTimer = self.parent:addTimer(1.0, -1, handler(self, self.timerClick))
    self:initListView()
end

function KaifuInvest:setData(data)
    -- body
    self.investBtn.data = data
    if data.isBuy == 1 then
        self.investBtn:GetChild("icon").url = UIPackage.GetItemURL("invest" , "touzijihua_016")
    else
        self.investBtn:GetChild("icon").url = UIPackage.GetItemURL("invest" , "touzijihua_012")
    end
    self.investBtn.onClick:Add(self.onClickBuy,self)
    self.data = data
    self.confData = conf.ActivityConf:getOpenInvestment()
    self.listView.numItems = #self.confData
    self.lastTime = data.lastTime
    if self.lastTime < 0 then
        self.parent:hideOpenInvest()
    end
    self.timeTxt.text = GtimeTransition(self.lastTime)
    self.timeTxt.visible = true
    self.view:GetChild("n2").visible = true
end

function KaifuInvest:timerClick()
    -- body
    if self.lastTime > 0 then
        self.lastTime = self.lastTime - 1
        self.timeTxt.text = GtimeTransition(self.lastTime)
    else
        self.timeTxt.visible = false
        self.view:GetChild("n2").visible = false
        self.investBtn.visible = false
        self.parent:hideOpenInvest()
    end
end

function KaifuInvest:initListView()
    -- body
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
end

function KaifuInvest:celldata( index,obj )
    -- body
    local itemData = self.confData[index+1]
    if itemData then
        local list = obj:GetChild("n2")
        list.numItems = 0
        for k,v in pairs(itemData.awards) do
            local mId = v[1]
            local amount = v[2]
            local bind = v[3]
            local url = UIPackage.GetItemURL("_components" , "ComItemBtn")
            local obj = list:AddItemFromPool(url)
            -- local info = {mid=mId,amount = amount,bind = conf.ItemConf:getBind(mId) or 0}
            local info = {mid=mId,amount = amount,bind = bind}
            GSetItemData(obj,info,true)
        end
        if list.numItems > 2 then
            list.x = 9
        elseif list.numItems > 1 then
            list.x = 38
        else
            list.x = 62
        end
        local dec = obj:GetChild("n1")
        if itemData.open_day == 1 then
            dec.text = language.invest01
        else
            local t = clone(language.invest02)
            t[2].text = string.format(t[2].text,itemData.open_day)
            dec.text = mgr.TextMgr:getTextByTable(t)
        end
        local btnGet = obj:GetChild("n5")
        btnGet.visible = true
        btnGet:GetChild("icon").url = UIPackage.GetItemURL("_imgfonts" , "fulidating_052")
        if self.data.isBuy == 1 then
            if self.data.openDay>=itemData.open_day then
                local bol = false
                for k,v in pairs(self.data.gotList) do
                    if v == itemData.id then
                        bol = true
                    end
                end
                if bol then
                    btnGet:GetChild("icon").url = UIPackage.GetItemURL("invest" , "sanshitiandenglu_035")
                    btnGet.touchable = false
                    btnGet.grayed = true
                else
                    btnGet.touchable = true
                    btnGet.grayed = false
                end
            else
                btnGet.touchable = false
                btnGet.grayed = true
            end
        else
            btnGet.touchable = false
            btnGet.grayed = true
        end

        btnGet.data = itemData
        btnGet.onClick:Add(self.onClickGet,self)
    end
end

function KaifuInvest:onClickBuy( context )
    -- body
    local cell = context.sender
    local data = cell.data
    if data.isBuy  == 0 then
        local ybNum = conf.ActivityConf:getValue("open_investment_quota")
        local t = {
                {color = 8,text=language.invest10},
                {color = 7,text=string.format("%d",ybNum)},
                {color = 8,text=language.invest06}
            }
        local param = {}
        param.type = 2
        param.richtext = mgr.TextMgr:getTextByTable(t)
        param.sure = function()
            proxy.ActivityProxy:sendMsg(1030118,{reqType = 1})
        end
        param.cancel = function ()
            -- body
        end
        GComAlter(param)
    end
end

function KaifuInvest:onClickGet( context )
    -- body
    local cell = context.sender
    local data = cell.data
    proxy.ActivityProxy:sendMsg(1030118,{reqType = 2,awardId = data.id})
end

return KaifuInvest