--
-- Author: 
-- Date: 2017-02-20 21:09:28
--

local ZuoQiOtherSkinView = class("ZuoQiOtherSkinView", base.BaseView)

function ZuoQiOtherSkinView:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
end

function ZuoQiOtherSkinView:initData(data)
    -- body
    self.confData = {}
    self.data = data
    self.skin = {}
    if self.data.skins then
    printt("皮肤信息",self.data.skins)
        for k,v in pairs(self.data.skins) do
            if type(v) == "number" then
                self.skin[v] = 1
            else
                self.skin[v.skinId] = 1
            end
        end
    end
        --self:setData()
end

function ZuoQiOtherSkinView:initView()
    self.c1 = self.view:GetController("c1")

    local btnClose = self.view:GetChild("n8")
    btnClose.onClick:Add(self.onBtnClose,self)

    self.listView = self.view:GetChild("n9")
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
    self.listView.onClickItem:Add(self.onCallBackItem,self)

    self.icon = self.view:GetChild("n10") 
end

function ZuoQiOtherSkinView:celldata(index, obj)
    -- body
    local data = self.confData[index+1]
    local lab = obj:GetChild("n2")
    lab.text = data.name

    obj.data = data
    -- if self.data.skins[data.id] then --已经拥有
        --lab.text = lab.text 
    -- end
end

function ZuoQiOtherSkinView:onCallBackItem(context)
    -- body
    local item = context.data
    if self.index then --查看别人的时候
        local view = mgr.ViewMgr:get(ViewName.SeeOtherMsg)
        if view then
            view:onSkincallBack(item.data)
        end
    else
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:onSkincallBack(item.data.id)
        end
    end
    self:closeView()
end

function ZuoQiOtherSkinView:setData(index)
    self.confData = {}
    local condata = conf.ZuoQiConf:getAllOtherSkin(index)
    --
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
    self.index = nil
    self.listView.numItems = #self.confData
end

function ZuoQiOtherSkinView:setDataOther(index)
    -- body
    self.index = index
    if self.index == 1 then -- 坐骑
        self.icon.url = UIPackage.GetItemURL("zuoqi","zuoqi_018")
        self.confData = conf.ZuoQiConf:getAllOtherSkin(0)
    elseif self.index == 2 then--法宝
        self.icon.url = UIPackage.GetItemURL("zuoqi","fabao_003")
        self.confData = conf.ZuoQiConf:getAllOtherSkin(2)
    elseif self.index == 3 then--仙羽
        self.icon.url = UIPackage.GetItemURL("zuoqi","xianyu_003")
        self.confData = conf.ZuoQiConf:getAllOtherSkin(3)
    elseif self.index == 4 then--仙器
        self.icon.url = UIPackage.GetItemURL("zuoqi","xianqi_003")
        self.confData = conf.ZuoQiConf:getAllOtherSkin(4)
    elseif self.index == 5 then--伙伴
        self.icon.url = UIPackage.GetItemURL("zuoqi","huoban_022")
        self.confData = conf.HuobanConf:getAllOtherSkin(0)
    elseif self.index == 6 then--伙伴仙器
        self.icon.url = UIPackage.GetItemURL("zuoqi","huobanxianqi_003")
        self.confData = conf.HuobanConf:getAllOtherSkin(4)
    elseif self.index == 7 then--伙伴神兵
        self.icon.url = UIPackage.GetItemURL("zuoqi","huobanshenbing_003")
        self.confData = conf.HuobanConf:getAllOtherSkin(2)
    elseif self.index == 8 then--伙伴法宝
        self.icon.url = UIPackage.GetItemURL("zuoqi","huobanfabao_003")
        self.confData = conf.HuobanConf:getAllOtherSkin(3)
    elseif self.index == 9 then--伙伴仙羽
        self.icon.url = UIPackage.GetItemURL("zuoqi","huobanxianyu_013")
        self.confData = conf.HuobanConf:getAllOtherSkin(1)
    elseif self.index == 10 then--神兵
        self.icon.url = UIPackage.GetItemURL("zuoqi","shenbin_002")
        self.confData = conf.ZuoQiConf:getAllOtherSkin(1)
    end
    self.listView.numItems = #self.confData
end



function ZuoQiOtherSkinView:onBtnClose()
    -- body
    self:closeView()
end

return ZuoQiOtherSkinView