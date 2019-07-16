--
-- Author: 
-- Date: 2017-02-27 17:50:43
--

local HuobanOtherSkinView = class("HuobanOtherSkinView", base.BaseView)

function HuobanOtherSkinView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function HuobanOtherSkinView:initData(data)
    -- body
    
    self.curSelect = nil 
    self.data = data
    self.skin = {}
    if self.data.skins then
        for k,v in pairs(self.data.skins) do
            if type(v) == "table" then
                self.skin[v.skinId] = 1
            else
                self.skin[v] = 1
            end
        end
    end
    --self:setData()
end

function HuobanOtherSkinView:initView()
    self.c1 = self.view:GetController("c1")

    local btnClose = self.view:GetChild("n8")
    btnClose.onClick:Add(self.onBtnClose,self)

    self.listView = self.view:GetChild("n9")
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
    self.listView.onClickItem:Add(self.onCallBackItem,self)
end

function HuobanOtherSkinView:celldata(index, obj)
    -- body
    local data = self.confData[index+1]
    local lab = obj:GetChild("n2")
    lab.text = data.name
    local lab2 = obj:GetChild("n3")
    lab2.text = ""

    obj.data = data
    if self.data.skins[data.id] then --已经拥有

    end

    if self.curSelect == index then
        local t = {Skins.huoban,Skins.huobanxianyu,Skins.huobanshenbing,Skins.huobanfabao,Skins.huobanxianqi}
        lab2.text = language.huoban33[t[self.c1.selectedIndex+1]][2]
    end
end

function HuobanOtherSkinView:onCallBackItem(context)
    -- body
    local item = context.data

    local view = mgr.ViewMgr:get(ViewName.HuobanView)
    if view then
        view:onSkincallBack(item.data.id)
    end

    self:closeView()
end

function HuobanOtherSkinView:setData(index)
    self.confData = {}
    local condata = conf.HuobanConf:getAllOtherSkin(index)
    for k ,v in pairs(condata) do
        if v.buysee then
            --如果拥有才可见
            if self.skin[v.id] then --已经拥有
                table.insert(self.confData,v)
            end
        else
            table.insert(self.confData,v)
        end
    end


    self.c1.selectedIndex = index
    

    local t = {Skins.huoban,Skins.huobanxianyu,Skins.huobanshenbing,Skins.huobanfabao,Skins.huobanxianqi}
    local var = t[index+1]
    local id = cache.PlayerCache:getSkins(var) --当前选择
    local info = cache.PlayerCache:getSkins(Skins.huobanteshu)
    if index == 0 then
        id = info or 0
    end

    for k , v in pairs(self.confData) do
        if id and v.modle_id == id then
            self.curSelect = k -1 
            
            break
        end
    end

    self.listView.numItems = #self.confData
    if self.curSelect then
        --self.listView:AddSelection(self.curSelect,false)
    end
end

function HuobanOtherSkinView:onBtnClose()
    -- body
    self:closeView()
end

return HuobanOtherSkinView