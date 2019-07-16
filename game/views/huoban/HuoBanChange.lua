--
-- Author: 
-- Date: 2017-03-11 17:27:31
--

local HuoBanChange = class("HuoBanChange", base.BaseView)

function HuoBanChange:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
end

function HuoBanChange:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n2")
    btnClose.onClick:Add(self.onBtnClose,self)

    self.listView = self.view:GetChild("n5")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        -- body
        self:RenderListItem(index,obj)  --填值函数
    end
    self.listView.numItems = 0
    self.listView.onClickItem:Add(self.onUiItemCallBack,self)  --列表中的单选点击

end

function HuoBanChange:RenderListItem( index,obj )
    -- body
    local data = self.confData[index+1]
    --obj.touchable = false

    local name = obj:GetChild("n6")
    name.text = data.name
    local c1 = obj:GetController("c1")  --获得状态。。 0获得 1未获得
    c1.selectedIndex = 1

    if self.data then
        for k ,v in pairs(self.data.skins) do

            if v.sign == 2 then --EVE 判断是否领取 2已领取
                if tonumber(v.skinId) == tonumber(data.id) then
                    c1.selectedIndex = 0
                    name.text = v.name
                    --obj.touchable = true
                    break
                end
            end
        end
    end

    local icon = obj:GetChild("n7")
    icon.url = ResPath.iconRes(data.icon) --UIPackage.GetItemURL("_icons" , ""..data.icon)

    local icon_type1 = obj:GetChild("n2")
    icon_type1.visible = false
    local icon_type2 = obj:GetChild("n3")
    icon_type2.visible = false

    if data.type then
        for k ,v in pairs(data.type) do
            if k > 2 then
                break
            end
            if k == 1 then
                icon_type1.url = UIItemRes.huoban02[v]
                icon_type1.visible = true
            else
                icon_type2.url = UIItemRes.huoban02[v]
                icon_type2.visible = true
            end
        end
    end
    --位置
    local width = 0 
    if icon_type1.visible then
        width = width + icon_type1.width
    end
    if icon_type2.visible then
        width = width + icon_type2.width
    end
    if icon_type1.visible and icon_type2.visible then
        width = width + 5
    end

    local x = (obj.width - width)/2
    if icon_type1.visible then
        icon_type1.x = x 
        x = x + icon_type1.width+5
    end
    if icon_type2.visible then
        icon_type2.x = x 
    end


    obj.data = data
end

function HuoBanChange:onUiItemCallBack(context)
    -- body
    local data = context.data.data
    --self:closeView()

    --EVE 添加伙伴切换方法
    --宠物等级为0，提示未激活
    if self.data.lev == 0 then
        GComAlter(language.zuoqi68)
        return
    end

    --如果要选择的皮肤已领取，则不再发消息请求
    local flag = false
    for k ,v in pairs(self.data.skins) do
        if v.sign == 2 then --EVE 判断是否领取 2已领取
            if tonumber(v.skinId) == tonumber(data.id) then
                flag = true
                break
            end
        end
    end
    if not flag then
        GComAlter(language.zuoqi73)
        return
    end

    --当前皮肤已穿戴，则提示穿戴中
    local var = cache.PlayerCache:getSkins(Skins.huoban)
    if var == data.modle_id then
        GComAlter(language.huoban34[Skins.huoban])
        return
    end

    proxy.HuobanProxy:send(1200105,{skinId = data.id,reqType = 0})
    self:closeView()
    --EVE end
end

function HuoBanChange:setData(index)
    self.confData = conf.HuobanConf:getLeftData(0)
    table.sort(self.confData,function (a,b)
        -- body
        return a.id < b.id
    end)
    self.listView.numItems = #self.confData

    for k ,v in pairs(self.confData) do

        if tonumber(index) == tonumber(v.id) then
            self.listView:AddSelection(k-1,false)
        end
    end

    -- plog(cache.PlayerCache:getSkins(Skins.huoban))
    -- printt(self.confData)
end

function HuoBanChange:onBtnClose()
    -- body
    self:closeView()
end

function HuoBanChange:addMsgCallBack(data)
    -- body
    self.data = data
    self.listView:RefreshVirtualList()
end

return HuoBanChange