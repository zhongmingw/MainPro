--
-- Author: 
-- Date: 2017-07-21 17:09:06
--

local MarryRespons = class("MarryRespons", base.BaseView)
local poslist = {}
function MarryRespons:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function MarryRespons:initData()
    -- body
    self.data = cache.MarryCache:getFirstResponsData()
    if not self.data then
        self:closeView()
        return
    end
    for k ,v in pairs(self.list) do
        self:initItem(v,k-1)
    end

    self.c1.selectedIndex = self.data.grade - 1
    self.c2.selectedIndex = 0
    --放个特效
    mgr.ViewMgr:openView2(ViewName.Alert15,4020127)

    local condata = conf.MarryConf:getGradeItem(self.data.grade)
    self.name.text = string.format(language.kuafu39,self.data.reqName,condata.name)

    self:setIcon(self.data)
    --默认180秒拒绝一次
    if not self.tiemer then
        self:removeTimer(self.tiemer)
    end
    self:addTimer(60*3,1,handler(self, self.onCancel))
end

function MarryRespons:setIcon( data )
    -- body
    local t = GGetMsgByRoleIcon(data.roleIcon,data.reqRoleId,function(tab)
        if tab then
            self.topicon.url = tab.headUrl
        end
    end)
    self.topicon.url =  t.headUrl --UIPackage.GetItemURL("_icons" , "jiehun_025")
end

function MarryRespons:initView()
    self.topicon = self.view:GetChild("n1"):GetChild("n2"):GetChild("n3")
    -- if cache.PlayerCache:getSex() == 1 then
    --     self.topicon.url = UIPackage.GetItemURL("_icons" , "jiehun_025")
    -- else
    --     self.topicon.url = UIPackage.GetItemURL("_icons" , "jiehun_024")
    -- end 

    self.name = self.view:GetChild("n2"):GetChild("title")
    

    local btnSure = self.view:GetChild("n4")
    btnSure.onClick:Add(self.onSure,self)

    local btnRe = self.view:GetChild("n6")
    btnRe.onClick:Add(self.onCancel,self)

    self.c1 = self.view:GetController("c1")
    self.c2 = self.view:GetController("c2")

    local btn1 = self.view:GetChild("n9")
    btn1.onClick:Add(self.onReward,self)

    local btn1 = self.view:GetChild("n10")
    btn1.onClick:Add(self.onReward,self)

    self.list = {}
    for i = 11 , 13 do
        local item = self.view:GetChild("n"..i)
        --self:initItem(item,i-11)
        table.insert(poslist,item.xy)
        table.insert(self.list,item)
    end

    local item = self.view:GetChild("n15")
    item.onTouchBegin:Add(self.onTouchBegin,self)
    item.onTouchEnd:Add(self.onTouchEnd,self)

    local panel = self.view:GetChild("n14")
    panel.onClick:Add(self.onReward,self)

    local btnClose = self.view:GetChild("n16")
    btnClose.onClick:Add(self.onCancel,self)
end

function MarryRespons:onTouchBegin(context)
    -- body
    self.bx = context.data.x
end

function MarryRespons:onTouchEnd(context)
    -- body
    if not self.bx then
        return
    end
    self.ex = context.data.x
    local dist = self.ex - self.bx
    if math.abs(dist) > 40 then
        if dist < 0 then --左动作
            self:move(-1)
        else --右动作
            self:move(1)
        end
    end
end

function MarryRespons:move(dist)
    -- body
    if self.action and table.nums(self.action)>0 then
        plog("前面的动作还未结束")
        return
    end
    self.action = {}
    local speed = 0.2
    for k ,v in pairs(self.list) do
        local nextpos = v.data + dist
        if nextpos > 2 then
            nextpos = 0
        elseif nextpos < 0 then
            nextpos = 2
        end
        local topos = Vector2.New(poslist[nextpos+1].x,poslist[nextpos+1].y)
        self.action[k] = UTransition.TweenMove2(v,topos,speed, false, function(v)
            self.action[k] = nil 
            v.data = nextpos
        end)
    end
end

function MarryRespons:initItem(item,i)
    -- body
    item.data = i

     local c1 = item:GetController("c1")
    c1.selectedIndex = i 

    local condata = conf.MarryConf:getGradeItem(i+1)
    local cost = item:GetChild("n10") 
    cost.text = condata.cost

    local itemObj = {}
    table.insert(itemObj,item:GetChild("n6"))
    table.insert(itemObj,item:GetChild("n7"))

    for k ,v in pairs(itemObj) do
        v.visible = false
    end
    if condata.show then
        for k ,v in pairs(condata.show) do
            local cell = itemObj[k]
            if cell then
                local t = {mid=v[1],amount=v[2],bind=v[3]}
                GSetItemData(cell,t,true)
            end
        end
    end
    --专属昵称
    self:initName(item)
end

function MarryRespons:initName(item)
    -- body
    local lab1 = item:GetChild("n12")
    local lab2 = item:GetChild("n13")
    local sex = cache.PlayerCache:getSex()
    local name = cache.PlayerCache:getRoleName()
    local i = item:GetController("c1").selectedIndex

    local name = cache.PlayerCache:getRoleName()
    local var = self.data.reqName
    if sex == 1 then
        lab1.text = string.format(language.kuafu78[i+1][1], var)
        lab2.text = string.format(language.kuafu78[i+1][2],name)
    else
        lab1.text = string.format(language.kuafu78[i+1][1],name )
        lab2.text = string.format(language.kuafu78[i+1][2],var)
    end
end

function MarryRespons:onReward()
    -- body
    if self.c2.selectedIndex == 0 then
        self.c2.selectedIndex = 1
    else
        self.c2.selectedIndex = 0
    end
end

function MarryRespons:setData(data_)

end

function MarryRespons:onSure()
    -- body
    local param = {}
    param.reply = 1
    param.reqRoleId = self.data.reqRoleId
    param.grade = self.data.grade
    proxy.MarryProxy:sendMsg(1390103, param)
end

function MarryRespons:onCancel()
    -- body
    local param = {}
    param.reply = 2
    param.reqRoleId = self.data.reqRoleId
    param.grade = self.data.grade
    proxy.MarryProxy:sendMsg(1390103, param)
end

return MarryRespons