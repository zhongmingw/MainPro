--开服累充
local Activity1085 = class("Activity1085",import("game.base.Ref"))

function Activity1085:ctor(param)
    self.view = param
    self:initView()
end

function Activity1085:initView()
    -- body
    self.listView = self.view:GetChild("n1")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
    self.timeTxt = self.view:GetChild("n4")
    self.timeTxt.visible = false
    self.timeTxt.text = ""

    self.investBtn = self.view:GetChild("n2")

end

function Activity1085:celldata(index,obj)
    local itemData = self.confData[index + 1]
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
            if self.data.day>=itemData.open_day then
                local bol = false
                for k,v in pairs(self.data.gotList) do
                    if v == itemData.id then
                        bol = true
                    end
                end
                if bol then
                    btnGet:GetChild("icon").url = UIPackage.GetItemURL("hefu" , "sanshitiandenglu_035")
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

function Activity1085:onTimer()
    if not self.data then
        return
    end
    if self.lastTime > 0 then
        self.lastTime = self.lastTime - 1
        self.timeTxt.text = GtimeTransition(self.lastTime)
    else
        self.timeTxt.visible = false
        self.view:GetChild("n3").visible = false
        self.investBtn.visible = false
    end
end

function Activity1085:setCurId(id)
    -- body
    self.id = id
    
end

function Activity1085:setOpenDay( day )
    -- body
    
end

function Activity1085:onClickGet(context)
    local cell = context.sender
    local data = cell.data
    proxy.ActivityProxy:sendMsg(1030187,{reqType = 2,awardId = data.id})
end

function Activity1085:onClickBuy(context)
    local cell = context.sender
    local data = cell.data
    if data.isBuy  == 0 then
        local ybNum = conf.ActivityConf:getValue("merge_investment_quota")
        local t = {
                {color = 8,text=language.invest10},
                {color = 7,text=string.format("%d",ybNum)},
                {color = 8,text=language.invest06}
            }
        local param = {}
        param.type = 2
        param.richtext = mgr.TextMgr:getTextByTable(t)
        param.sure = function()
            proxy.ActivityProxy:sendMsg(1030187,{reqType = 1})
        end
        param.cancel = function ()
            -- body
        end
        GComAlter(param)
    end
end

function Activity1085:add5030187( data )
    self.data = data
    self.investBtn.data = data
    if data.isBuy == 1 then
        self.investBtn:GetChild("icon").url = UIPackage.GetItemURL("hefu" , "touzijihua_016")
    else
        self.investBtn:GetChild("icon").url = UIPackage.GetItemURL("hefu" , "touzijihua_012")
    end
    self.investBtn.onClick:Add(self.onClickBuy,self)

    self.confData = conf.ActivityConf:getMergeInvestment()
    self.listView.numItems = #self.confData
    self.lastTime = data.lastTime
    if self.lastTime < 0 then

    end
    self.timeTxt.text = GtimeTransition(self.lastTime)
    self.timeTxt.visible = true
    self.view:GetChild("n3").visible = true
    
end

return Activity1085