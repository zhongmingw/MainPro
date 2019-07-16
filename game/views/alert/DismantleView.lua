--
-- Author: 
-- Date: 2018-10-16 17:45:58
--

local DismantleView = class("DismantleView", base.BaseView)

function DismantleView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function DismantleView:initView()
    self:setCloseBtn(self.view:GetChild("n0"):GetChild("n2"))
    self:setCloseBtn(self.view:GetChild("n2"))
    local dec = self.view:GetChild("n4")
    dec.text = language.pack47
    
    self.listView = self.view:GetChild("n5")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:cellData(index, obj)
    end
    
    local sureBtn = self.view:GetChild("n1")
    sureBtn.onClick:Add(self.onClickSureBtn,self)
end
-- int8变量名：isComp  说明：是否合成装备 1:否(显示问号)
function DismantleView:initData(data)
    if data then
        -- printt("data",data)
        self.data = data
        local packData = cache.PackCache:getPackDataByIndex(data.index)
        local condata = conf.ItemConf:getItem(packData.mid)
        local godEquipCost = {}
        
        if data.msgId == 5100402 then--神装装备
            local id = ((100+condata.color)*100+condata.stage_lvl)*100+condata.part
            godEquipCost = conf.ForgingConf:getGodEquipCompose(id)
            self.view:GetChild("n0").icon = UIPackage.GetItemURL("alert" , "hecheng_0034")
        elseif data.msgId == 5580104 then--仙装神装
            local id = ((((100+Pack.xianzhuang)*100+condata.color)*100+condata.stage_lvl)*100+condata.part)
            godEquipCost = conf.ForgingConf:getXianEquipCompose(id)
            self.view:GetChild("n0").icon = UIPackage.GetItemURL("alert" , "hecheng_0034")--TODo
        end
        
        local needEquipNum = godEquipCost and godEquipCost.need_amount or 0
        if data.isComp == 1 then
            self.listView.numItems = #self.data.items + needEquipNum
        else
            self.listView.numItems = #self.data.items
        end
    end
end

function DismantleView:cellData( index,obj )
    local data = self.data.items[index+1]
    if data then
        for i = 0 , obj.numChildren-1 do
            local varCom = obj:GetChildAt(i)
            varCom.visible = true
        end
        GSetItemData(obj,data)
    else
        local _t = {["n1"] = 1,["icon"] = 1,["n21"] = 1}
        for i = 0 , obj.numChildren-1 do
            local varCom = obj:GetChildAt(i)
            if not _t[varCom.name] then
                varCom.visible = false
            end
        end
        local iconObj = obj:GetChild("icon")
        local itemFrame = obj:GetChild("n1")
        local c1 = obj:GetController("c1")
        c1.selectedIndex = 4
        local iconUrl = ResPath.iconRes(tostring(221071574))
        iconObj.url = iconUrl
        itemFrame.url = ResPath.iconRes("beibaokuang_007")
    end
end

function DismantleView:onClickSureBtn()
    if self.data.msgId == 5100402 then--装备
        local param = {}
        param.index = self.data.index
        param.reqType = 2
        proxy.ForgingProxy:send(1100402,param)
    elseif self.data.msgId == 5580104 then--仙-神
        local param = {}
        param.index = self.data.index or 0
        param.reqType = 2
        proxy.FeiShengProxy:send(1580104,param)
    end
    self:closeView()
end

return DismantleView