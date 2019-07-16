--等级投资
local LevelInvest = class("LevelInvest", import("game.base.Ref"))

function LevelInvest:ctor(mParent)
    -- body
    self.parent = mParent
    self:initPanel()
end

function LevelInvest:initPanel()
    -- body
    self.view = self.parent.view:GetChild("n9")
    self.listView = self.view:GetChild("n4")
    self.controllerC1 = self.view:GetController("c1")
    self.controllerC1.onChanged:Add(self.onController,self)
    self.investBtn = self.view:GetChild("n7")
    self.timeTxt = self.view:GetChild("n6")
    self.timeTxt.text = ""
    self.dec1 = self.view:GetChild("n8")
    self.dec2 = self.view:GetChild("n9")
    self.timeTxt.visible = false
    self.dec1.visible = false
    self.dec2.visible = false
    self.view:GetChild("n5").visible = false
    self.investBtn.visible = false
    self.lastTime = 0
    self.mainTimer = self.parent:addTimer(1.0, -1, handler(self, self.timerClick))
    --等级投资元宝数
    self.ybData = conf.ActivityConf:getValue("lvl_investment_quota")
    self:initListView()
end

function LevelInvest:setTab(flag)
    self.isFirst = flag
end

function LevelInvest:setData( data )
    -- body
    -- print("等级投资",data)
    -- printt(data)
    --投资按钮
    local var = cache.PlayerCache:getRedPointById(attConst.A20119)
    if var > 0 then
        for i=1,3 do
            self.view:GetChild("n"..i):GetChild("n5").visible = false
        end
        if data.curInvType > 0 then
            self.view:GetChild("n"..data.curInvType):GetChild("n5").visible = true
        end
    else
        for i=1,3 do
            self.view:GetChild("n"..i):GetChild("n5").visible = false
        end
    end
    self.investBtn.data = data
    self.lastTime = data.lastTime
    self.timeTxt.visible = true
    self.view:GetChild("n5").visible = true
    self.dec1.visible = false
    self.dec2.visible = false
    self.investBtn.visible = true
    if self.isFirst then
        self.controllerC1.selectedIndex = (data.curInvType-1)>=0 and (data.curInvType-1) or data.curInvType
        self.isFirst = false
    end
    if self.lastTime > 0 then
        if data.curInvType>0 then
            if data.curInvType < self.controllerC1.selectedIndex+1 then
                self.investBtn:GetChild("icon").url = UIPackage.GetItemURL("invest" , "touzijihua_013")
                self.dec1.visible = true
                self.dec2.visible = true
                local t = clone(language.invest08)
                local lvl = conf.ActivityConf:getValue("lvl_investment_append")
                t[2].text = string.format(t[2].text,lvl)
                self.dec1.text = mgr.TextMgr:getTextByTable(t)
                self.dec2.text = mgr.TextMgr:getTextByTable(language.invest09)
                self.timeTxt.visible = false
                self.view:GetChild("n5").visible = false
            elseif data.curInvType > self.controllerC1.selectedIndex+1 then
                self.timeTxt.visible = false
                self.view:GetChild("n5").visible = false
                self.dec2.visible = true
                self.dec2.text = language.invest12
                self.investBtn.visible = false
            else
                self.investBtn:GetChild("icon").url = UIPackage.GetItemURL("invest" , "touzijihua_016")
            end
        else
            self.investBtn:GetChild("icon").url = UIPackage.GetItemURL("invest" , "touzijihua_012")
        end
    else
        self.timeTxt.visible = false
        self.view:GetChild("n5").visible = false
        self.investBtn.visible = false
        self.dec1.visible = false
        self.dec2.visible = true
        self.dec2.text = language.invest07
    end
    self.investBtn.onClick:Add(self.onClickBuy,self)

    self.listView.numItems = 0
    self.data = data
    self.confData = conf.ActivityConf:getLvInvestment()
    local len = 0
    if self.confData[self.controllerC1.selectedIndex+1] then
        len = #self.confData[self.controllerC1.selectedIndex+1]
    end
    self.listView.numItems = len
    
    self.timeTxt.text = GtimeTransition(self.lastTime)
end

function LevelInvest:timerClick()
    -- body
    if self.lastTime > 0 then
        self.lastTime = self.lastTime - 1
        self.timeTxt.text = GtimeTransition(self.lastTime)
    else
        self.timeTxt.visible = false
        self.view:GetChild("n5").visible = false
        self.investBtn.visible = false
        self.dec1.visible = false
        self.dec2.visible = true
        self.dec2.text = language.invest07
    end
end

function LevelInvest:initListView()
    -- body
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
end

function LevelInvest:celldata(index, obj)
    -- body
    local itemData = self.confData[self.controllerC1.selectedIndex+1][index+1]
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
        if itemData.lvl == 1 then
            dec.text = language.invest03
        else
            local t = clone(language.invest04)
            t[1].text = string.format(t[1].text,itemData.lvl)
            dec.text = mgr.TextMgr:getTextByTable(t)
        end
        local btnGet = obj:GetChild("n5")
        btnGet.visible = true
        btnGet:GetChild("icon").url = UIPackage.GetItemURL("_imgfonts" , "fulidating_052")
        if self.data.curInvType == self.controllerC1.selectedIndex+1 then
            local lv = cache.PlayerCache:getRoleLevel()
            if lv>=itemData.lvl then
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
            if self.data.curInvType < self.controllerC1.selectedIndex+1 then
                btnGet.touchable = false
                btnGet.grayed = true
            else
                btnGet.visible = false
            end
        end

        btnGet.data = itemData
        btnGet.onClick:Add(self.onClickGet,self)
    end
end

--投资
function LevelInvest:onClickBuy( context )
    -- body
    local cell = context.sender
    local data = cell.data
    -- print("投资按钮按下",data.curInvType)
    local roleLv = cache.PlayerCache:getRoleLevel()
    local lvl = conf.ActivityConf:getValue("lvl_investment_append")
    if roleLv > lvl then
        GComAlter(language.invest11)
        return
    end
    if data.curInvType == 0 then
        local ybNum = self.ybData[self.controllerC1.selectedIndex+1]
        local t = {
                {color = 8,text=language.invest10},
                {color = 7,text=string.format("%d",ybNum)},
                {color = 8,text=language.invest06}
            }
        local param = {}
        param.type = 2
        param.richtext = mgr.TextMgr:getTextByTable(t)
        param.sure = function()
            proxy.ActivityProxy:sendMsg(1030119,{reqType = 1,invType = self.controllerC1.selectedIndex+1})
        end
        param.cancel = function ()
            -- body
        end
        GComAlter(param)
    else
        if data.curInvType < self.controllerC1.selectedIndex+1 then
            local ybNum = self.ybData[self.controllerC1.selectedIndex+1] - self.ybData[data.curInvType]
            local t = {
                {color = 8,text=language.invest05},
                {color = 7,text=string.format("%d",ybNum)},
                {color = 8,text=language.invest06}
            }
            local param = {}
            param.type = 2
            param.richtext = mgr.TextMgr:getTextByTable(t)
            param.sure = function()
                proxy.ActivityProxy:sendMsg(1030119,{reqType = 1,invType = self.controllerC1.selectedIndex+1})
            end
            param.cancel = function ()
                -- body
            end
            GComAlter(param)
        end
    end
end

function LevelInvest:onClickGet(context)
    -- body
    local cell = context.sender
    local data = cell.data
    proxy.ActivityProxy:sendMsg(1030119,{reqType = 2,invType = self.controllerC1.selectedIndex+1,invId = data.id})
end

function LevelInvest:onController()
    -- body
    if 0 == self.controllerC1.selectedIndex then
        proxy.ActivityProxy:sendMsg(1030119,{reqType = 0,invType = 1})
    elseif 1 == self.controllerC1.selectedIndex then
        proxy.ActivityProxy:sendMsg(1030119,{reqType = 0,invType = 2})
    elseif 2 == self.controllerC1.selectedIndex then
        proxy.ActivityProxy:sendMsg(1030119,{reqType = 0,invType = 3})
    end
end


return LevelInvest