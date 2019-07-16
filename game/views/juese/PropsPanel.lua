--
-- Author: 
-- Date: 2017-01-04 19:28:51
--

local PropsPanel = class("PropsPanel",import("game.base.Ref"))

local BtnNumber = 3
--角色信息显示
local JuesePro = {
    105,102,103,106,107,108,109,112
}
--基础信息显示
local JueseBase = {
    105,102,103,106,107,108,109,112
}
local JueseBaseAdd = {
    505,506,507 --潜能添加 
}
--特殊属性显示
local JueseMore= {
    110,111,112,305,306,324,323,216,116,311,312,119,314,117,319,320,315,316,317,318,321,322
}
function PropsPanel:ctor(mParent)
    self.mParent = mParent
    self:initView()
end

function PropsPanel:initView()
    -- body
    self.mParent.view.onClick:Add(self.doSpecialEffect,self)

    self.view = self.mParent.view:GetChild("rolepanel")

    self.view:GetChild("n28"):GetChild("icon").visible = false

    self.controllerC1 =  self.view:GetController("tabl")
    self.controllerC1.onChanged:Add(self.onbtnController,self)

    self.redImg1 = self.view:GetChild("n102"):GetChild("red")
    self.redImg2 = self.view:GetChild("n103"):GetChild("red")

    self.prodesc = self.view:GetChild("n46")

    if g_is_banshu then
        self.redImg1:SetScale(0,0)
        self.redImg2:SetScale(0,0)
    end
end

function PropsPanel:initRoleMsg()
    -- body
    local rolepanel = self.view:GetChild("n39")
    self.rolepanel = rolepanel

    self.roleIcon = rolepanel:GetChild("n27"):GetChild("n3")
    self.roleIcon.onClick:Add(self.onbtnChangeIcon,self)  --EVE 添加：将头像也注册为点击事件
    --头像框
    self.frameIcon = rolepanel:GetChild("n17")
    self.roleName = rolepanel:GetChild("n15")
    self.roleName.text = "" 
    self.roleRefineLv = rolepanel:GetChild("n40") --EVE 修仙等级
    self.roleRefineLv.url = ""
    self.rolevip = rolepanel:GetChild("n23") 
    self.rolevip.text = "0"
    --Vip特权
    self.controllerVipC1 =  rolepanel:GetController("c1")
    self.controllerVipC2 =  rolepanel:GetController("c2")
    self.controllerVipC3 =  rolepanel:GetController("c3")
    --战斗力
    self.rolePower = rolepanel:GetChild("n11")
    self.rolePower.text = "0"
    --帮派
    local dec1 = rolepanel:GetChild("n6") 
    dec1.text = language.juese01
    self.bangpaiName = rolepanel:GetChild("n7")

    if cache.PlayerCache:getGangId()~="0" then
        if cache.PlayerCache:getGangName()=="" then
            self.bangpaiName.text =  language.juese04
        else
            self.bangpaiName.text = cache.PlayerCache:getGangName()
        end
        
    else
        self.bangpaiName.text = language.juese04 
    end
    --配偶
    local dec2 = rolepanel:GetChild("n2")
    dec2.text = language.juese02
    self.peiouName = rolepanel:GetChild("n3")
    if cache.PlayerCache:getCoupleName()~="" then
        self.peiouName.text = cache.PlayerCache:getCoupleName()
    else
        self.peiouName.text = language.juese04 
    end
    --属性


    local imgChange = rolepanel:GetChild("n17")
    imgChange.onClick:Add(self.onbtnChangeIcon,self)

    local btnChange = rolepanel:GetChild("n19")     --EVE 更换头像按钮
    btnChange.onClick:Add(self.onbtnChangeIcon,self)
    self.btnChange = btnChange
    --btnChange.visible  = false

    local btnChangeName = rolepanel:GetChild("n20")
    btnChangeName.onClick:Add(self.onbtnChangeName,self)
    --self.btnChangeName = btnChangeName
    if g_ios_test then
        btnChangeName.visible = false
    else
        btnChangeName.visible = true
    end

    self.listView1 = rolepanel:GetChild("n39")
    self.listView1.numItems = 0
    self.listView1.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end 
    self.listView1:SetVirtual()
    self.listView1.scrollPane.onScroll:Add(self.doSpecialEffect, self)
end

function PropsPanel:doSpecialEffect()
    -- body
    self.prodesc.visible = false
end

function PropsPanel:initPropsMsg()
    -- body
    local props = self.view:GetChild("n40")
     --属性


    --self.listView = self.view:GetChild("")

    self.listView2 = props:GetChild("n97")
    self.listView2.numItems = 0 
    self.listView2.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end 
    self.listView2.scrollPane.onScroll:Add(self.doSpecialEffect, self)
    --潜能属性
    self.props2 = {}
    self.callback = {}
    for i = 1 , 3 do 
        local t = {}
        t.dec = props:GetChild("dec"..i)
        t.dec.text = ""
        t.value = props:GetChild("value"..i)
        t.value.text = ""
        t.reduce = props:GetChild("reduce"..i)
        t.reduce.visible = false
        t.reduce.data = i 
        t.add = props:GetChild("add"..i)
        t.add.text = ""
        t.plus = props:GetChild("plus"..i)
        t.plus.visible = false
        t.plus.data = i

        t.reduce.onClick:Add(self.onbtnReduce,self)
        --bxp 全加按钮 
        t.allPlus = props:GetChild("allPlus"..i)
        t.allPlus.data = i
        t.allPlus.visible = false
        t.allPlus.onClick:Add(self.onbtnAllPlus,self)


        self.callback[t.reduce.name] =  function(p1,p2)
            -- body
            self:LongPressReduce(p1,p2)
        end

        self.callback[t.plus.name] =  function(p1,p2)
            -- body
            self:LongPressPlus(p1,p2)
        end

        self:LongPress(t.reduce,self.callback[t.reduce.name])
        self:LongPress(t.plus,self.callback[t.plus.name])

        -- self:LongPress(t.plus,function(p1,p2)
        --     -- body
        --     self:LongPressPlus(p1,p2)
        -- end, 2)
       
        -- mgr.GuiMgr:LongPress(t.reduce,function(p1,p2)
        --     -- body
        --     self:LongPressReduce(p1,p2)
        -- end, 2)
        -- mgr.GuiMgr:LongPress(t.plus,function(p1,p2)
        --     -- body
        --     self:LongPressPlus(p1,p2)
        -- end, 2)

        t.plus.onClick:Add(self.onbtnPlus,self)

        --t.plus.onTouchBegin:Add(self.onTouchBegin,self)
       -- t.plus.onRollOut:Add(self.onRollOut,self)
        table.insert(self.props2,t)
    end
    --潜力点
    local dec1 = props:GetChild("n42")
    dec1.text = language.juese05

    for i = 98 , 101 do
        local btn = props:GetChild("n"..i)
        btn.data = JueseBaseAdd[i - 97] 
        if i == 101 then
            btn.data = 504
        end
        btn.onClick:Add(self.onKey2Call,self)
    end

    self.numberQianli =  props:GetChild("n81")
    self.numberQianli.text = 0
    --洗髓
    self.btnXiSui = props:GetChild("n92")
    self.btnXiSui.text = language.juese06
    self.btnXiSui.onClick:Add(self.onbtnXiSui,self)
    --推荐
    self.btnTuijian = props:GetChild("n93")
    self.btnTuijian.text = language.juese07
    self.btnTuijian.onClick:Add(self.onbtnTuiJian,self)
    --保存
    self.btnTuijian = props:GetChild("n94")
    self.btnTuijian.text = language.juese08
    self.btnTuijian.onClick:Add(self.onbtnSave,self)

    --
    local btnGuize = props:GetChild("n37")
    btnGuize.onClick:Add(self.onGuize,self)

    self.c1 = props:GetController("c1") --EVE 控制加点描述和加点按钮的切换

    local descText = props:GetChild("n102") --EVE 描述文本
    self.tempConf = conf.RoleConf:getValue("wash_cost_lev")
    descText.text = string.format(language.juese32, self.tempConf)

    self:setBtnAndTextDesc()
end

function PropsPanel:setBtnAndTextDesc()
    -- body
    local curLv = cache.PlayerCache:getRoleLevel()
    if curLv >= self.tempConf then 
        self.c1.selectedIndex = 0
    else
        self.c1.selectedIndex = 1
    end 
end

function PropsPanel:onreduceAction()
    -- body
    plog("..onAction..")
end

function PropsPanel:onKey2Call( context )
    -- body
    context:StopPropagation()
    local data = context.sender.data
    if not data then
        return
    end
    --plog("点击了潜力点",data)
    self:setMsg(context.sender)

end

function PropsPanel:onKeyClick(context)
    -- body
    context:StopPropagation()
    local sender = context.sender
    local data = sender.data
    if not data then
        return
    end
    --plog("点击了属性",data)
    self:setMsg(context.sender)
end

function PropsPanel:setMsg(sender)
    -- body
    local key = sender.data
    local dec = conf.RedPointConf:getDec(key)
    if dec and dec ~= "" then
        local xy = sender.parent:LocalToGlobal(sender.xy)
        xy = self.view:GlobalToLocal(xy)
        self.prodesc.xy = xy
        self.prodesc.visible = true

        local lab = self.prodesc:GetChild("n2")
        lab.text = dec

        self.prodesc.width = lab.width + 40
    end
end

function PropsPanel:celldata( index,obj )
    -- body
    local key1 = self.listdata[(index+1)*2-1] 
    local btn1 = obj:GetChild("n6")
    if not key1 then
        btn1.data = nil 
        return
    end
    
    btn1.data = key1
    btn1.onClick:Add(self.onKeyClick,self)

    local dec1 = obj:GetChild("n1")
    dec1.text = conf.RedPointConf:getProName(key1)  -- language.jueseprops[key1] 
    local value1 = obj:GetChild("n2")
    value1.text = GProPrecnt(key1,self:getValue(key1) or 0)  --self:getValue(key1) or 0

    local key2 = self.listdata[(index+1)*2] 
    local dec1 = obj:GetChild("n4")
    local value1 = obj:GetChild("n5")
    local btn2 = obj:GetChild("n7")
    dec1.text = ""
    value1.text = ""
    if not key2 then
        btn2.data = nil 
        return
    end 
    
    btn2.data = key2
    btn2.onClick:Add(self.onKeyClick,self)
    
    dec1.text = conf.RedPointConf:getProName(key2)  --language.jueseprops[key2]
    
    value1.text = GProPrecnt(key2,self:getValue(key2) or 0)
end

function PropsPanel:getValue(id)
    -- body
    if self.data.propsdata.attris and self.data.propsdata.attris[id]  then
        return self.data.propsdata.attris[id]
    end

    if self.data.propsdata.attris64 and self.data.propsdata.attris64[id] then 
        return self.data.propsdata.attris64[id]
    end 

    return nil
end

--设置属性
function PropsPanel:setProps(param,list)
    -- body
    self.listdata = param
    list.numItems = math.ceil(#param/2)
end
--潜力点展示
function PropsPanel:setQianLi(param)
    -- body
    for k ,v in pairs(self.props2) do
        self.props2[k].dec.text = ""
        self.props2[k].value.text = ""
        self.props2[k].reduce.visible = false
        self.props2[k].add.text = ""
        self.props2[k].plus.visible = false
        self.props2[k].allPlus.visible = false

    end

    for k ,v in pairs(param) do 
        if not self.props2[k] then
            break
        end
        --plog("v",v,conf.RedPointConf:getProName(v))
        self.props2[k].dec.text = language.jueseprops[v]
        self.props2[k].value.text = self:getValue(v) or 0
        self.props2[k].reduce.visible = true
        self.props2[k].add.text = 0 
        self.props2[k].plus.visible = true
        self.props2[k].allPlus.visible = true
    end
end

function PropsPanel:setRoleIcon()
    local t = GGetMsgByRoleIcon(cache.PlayerCache:getRoleIcon())
    self.roleIcon.url = t.headUrl--头像
    self.frameIcon.url = t.frameUrl--头像框
end

--角色信息
function PropsPanel:initRoleData()
    --EVE 玩家名字面板前面显示修仙等级 
    local refineLevel = cache.PlayerCache:getSkins(14) or 0    
    -- local var = cache.PlayerCache:getAttribute(20139)--渡劫已经没有了  bxp 2018/12/7
    -- if var == 0 and refineLevel > 1 and refineLevel%10 == 0 then 
    --     refineLevel = refineLevel - 1      
    -- end 
    local attrConf = conf.ImmortalityConf:getAttrDataByLv(refineLevel)
    if attrConf and attrConf.name_img then      
        self.roleRefineLv.url = UIPackage.GetItemURL("head", attrConf.name_img) or ""
    end 
    --EVE END

    self:setRoleIcon()
    self.roleName.text = self.data.roledata.roleName or ""

    self.rolevip.text = self.data.roledata.attris[503] or "0"
    --默认是0,
    local vipState = {0,0,0}
    for i=1,3 do
        if cache.PlayerCache:VipIsActivate(i) then
            vipState[i] = 1
        else
            vipState[i] = 0
        end
    end
    if not g_ios_test then   --EVE 屏蔽VIP标识
        self.controllerVipC1.selectedIndex = vipState[1]
        self.controllerVipC2.selectedIndex = vipState[2]
        self.controllerVipC3.selectedIndex = vipState[3]
    else
        for i=21, 26 do
            if i ~= 22 then 
                local temp = self.rolepanel:GetChild("n" .. i)
                temp.scaleX = 0
                temp.scaleY = 0
            end 
        end
    end

    self.rolePower.text = self.data.roledata.attris[501] or "0"
    
    --self.bangpaiName.text = ""
    --self.peiouName.text = ""

    if not self.data.isself then
        self.btnChange.visible = false
        --self.btnChangeName.visible = false
    else
        -- self.btnChange.visible = true
        if g_ios_test then
            self.btnChange.visible = false
        else
            self.btnChange.visible = true
        end
        --plog("cache.PlayerCache:getRedPointById(10301)",cache.PlayerCache:getRedPointById(10301))
        -- if cache.PlayerCache:getRedPointById(10301)>0 then
        --     self.btnChangeName.visible = false
        -- else
        --     self.btnChangeName.visible = true
        -- end
    end
    self:setProps(JuesePro,self.listView1)    
end

--基础属性
function PropsPanel:initPropDataBase()
    -- body
    self.numberQianli.text = self:getValue(504) or 0
    self:setProps(JueseBase,self.listView2)
    self:setQianLi(JueseBaseAdd) 
end
--
function PropsPanel:initPropDataMore()
    -- body
    self.numberQianli.text = self:getValue(504) or 0
    self:setProps(JueseMore,self.listView2) 
    self:setQianLi(JueseBaseAdd)
end

function PropsPanel:onbtnController()
    -- body
    self:doSpecialEffect()
    if self.controllerC1.selectedIndex == 0 then --角色信息
        self:initRoleData()
    elseif self.controllerC1.selectedIndex == 1 then --基础属性
        self:initPropDataBase()
    elseif self.controllerC1.selectedIndex == 2 then --特殊属性
        self:initPropDataMore()
    end
end
--[[
    param = {} 这两个参数必须有
    param.roledata  --人物信息
    param.propsdata  --属性信息
]]
function PropsPanel:setData(param)
    -- body
    if not param then 
        param = {}
        param.roledata = {}
        param.propsdata = {}
        param.isself = true
    end

    if not param.roledata then 
        param.roledata = {}
    end

    if not param.propsdata then
        param.propsdata = {}
        param.propsdata.attris = {}
        param.propsdata.attris64 = {}
    end
    self.data = param
    self:onbtnController()

    if self.data and (self:getValue(504) or 0) >0 then
        self.redImg2.visible = true
        self.redImg1.visible = true
    else
        self.redImg2.visible = false
        self.redImg1.visible = false
    end
end
--改变头像
function PropsPanel:onbtnChangeIcon()
    -- body
    if g_ios_test then return end
    if not self.data then
        return
    end
    proxy.PlayerProxy:send(1020202)
    -- mgr.ViewMgr:openView2(ViewName.JueSeHead) --自定义头像：屏蔽选系统头像的弹窗2018/06/25 bxp
    if g_var.gameFrameworkVersion >= 3 then
        mgr.ViewMgr:openView2(ViewName.HeadChooseView, {index = 0})
    end
    -- if self.data.isself then
    --     mgr.ViewMgr:openView2(ViewName.JueSeHead)
    --     --proxy.PlayerProxy:send(1020202)
    -- end
end
--换名字
function PropsPanel:onbtnChangeName()
    -- body
    --plog("换名字")
    mgr.ViewMgr:openView(ViewName.JueSeName,function(view)
        -- body
        --请求信息
        view:setData()
    end)
end

function PropsPanel:LongPressReduce(btn,falg)
    -- body
    --plog(btn.data,falg)
    --if 
    if not self.data then
        return
    end

    local i = btn.data

    if not falg then
        self.mParent:removeTimer(self._timer)
        self._timer = nil 
    else
        if not self._timer then
            self._timer = self.mParent:addTimer(0.02, tonumber(self.props2[i].add.text),function()
                -- body
                self.props2[i].add.text = tonumber(self.props2[i].add.text) - 1
                self.numberQianli.text = tonumber(self.numberQianli.text) + 1
            end)
        end
    end
end

--减号点击
function PropsPanel:onbtnReduce( context )
    -- body
    if not self.data then
        return
    end

    local btn = context.sender 
    local i = btn.data 
    --plog("减号按钮 "..i)
    if tonumber(self.props2[i].add.text)>0 then
        self.props2[i].add.text = tonumber(self.props2[i].add.text) - 1
        self.numberQianli.text = tonumber(self.numberQianli.text) + 1
    else
        --GComAlter(language.juese15)
    end
end
--加号点击
function PropsPanel:onbtnPlus( context )
    -- body

    if not self.data then
        return
    end
    local btn = context.sender 
    local i = btn.data 
    if tonumber(self.numberQianli.text) > 0 then
        --local var = JueseBaseAdd[i]
        self.props2[i].add.text = tonumber(self.props2[i].add.text) + 1
        self.numberQianli.text = tonumber(self.numberQianli.text) - 1
    else
        --GComAlter(language.juese15)
    end
end
--全部加点bxp
function PropsPanel:onbtnAllPlus(context)
    if not self.data then 
        return
    end
    local i = context.sender.data
    if tonumber(self.numberQianli.text) > 0 then
        local remain = tonumber(self.numberQianli.text)
        self.props2[i].add.text = tonumber(self.props2[i].add.text) + remain
        self.numberQianli.text = 0
    end
end

function PropsPanel:LongPressPlus(btn,falg)
    -- body
    if not self.data then
        return
    end
    local i = btn.data

    if not falg then
        self.mParent:removeTimer(self._timer)
        self._timer = nil 
    else
        if not self._timer then
            self._timer = self.mParent:addTimer(0.02, tonumber(self.numberQianli.text),function()
                -- body
                self.props2[i].add.text = tonumber(self.props2[i].add.text) + 1
                self.numberQianli.text = tonumber(self.numberQianli.text) - 1
            end)
        end
    end
end

function PropsPanel:onbtnXiSui()
    -- body
    if not self.data then
        return
    end
    local flag = false
    for k , v in pairs(JueseBaseAdd) do
        local value = self:getValue(v) or 0 --当前已经加的点数
        if value>0 then
            flag = true
             break 
        end 
    end

    if not flag then
        GComAlter(language.juese16)
        return
    end

    local function callback()
        -- body
         local param = {}
        param.opType = 2
        param.list = {0,0,0}      
        proxy.PlayerProxy:send(1020201,param)
    end

    local data = {}
    data.type = 2
    data.cancel = function( ... )
            -- body
    end 
    data.sure = callback
    --plog("wash_cost_lev = ",conf.RoleConf:getValue("wash_cost_lev"))
    if cache.PlayerCache:getRoleLevel() > conf.RoleConf:getValue("wash_cost_lev") then
        data.richtext =  string.format(language.juese11,conf.RoleConf:getValue("wash_cost"))  
    else
        data.richtext = language.juese15
    end
    GComAlter(data)
end
--推荐加点
function PropsPanel:onbtnTuiJian()
    -- body
    --分配比例
    if not self.data then
        return
    end

    local p504 =  self:getValue(504) or 0
    if p504 <=0 then
        GComAlter(language.juese17)
        return
    end

    for k ,v in pairs(self.props2) do
        v.add.text = 0
    end

    local confdata = conf.RoleConf:getValue("potential_add")
    local all = 0
    --推荐加点 2018/3/8重新写的 
    local _done_add = {}
    local total504 = p504
    for k ,v in pairs(confdata) do 
        --print("v[1]",v[1],self:getValue(v[1])

        _done_add[v[1]] = self:getValue(v[1]) or 0
        all = all + v[2]
        total504 = total504 + _done_add[v[1]]
    end

    --按比例分配之后的
    local _toend = {}
    local _nember = 0
    local num = 0
    for k ,v in pairs(confdata) do 
        local var = math.floor(v[2] / all * total504) - _done_add[v[1]]
        local value = math.max(var,0)
		
        value = math.min(value,p504) --避免超过潜力点
        --print("var",v[1],value)
		
		p504 = math.max(p504 - value,0)  
		
        _toend[v[1]] =  value
        _nember = _nember + _toend[v[1]]
    end
    --可能有剩余都加到第一个上
     _toend[confdata[1][1]] = _toend[confdata[1][1]] + math.max(p504 - _nember,0) 

    for k ,v in pairs(JueseBaseAdd) do
        if not self.props2[k] then
            break
        end
        self.props2[k].add.text =  _toend[v] or  0
    end

    self.numberQianli.text = 0 -- p504 - _nember



    --推荐加点 2018/3/8之前的
    -- local confRoledata = conf.RoleConf:getByRoleLevel(cache.PlayerCache:getRoleLevel())
    -- if confRoledata and confRoledata.pot then
    --     local t = {} --推荐加点数值
    --     local var = 0
    --     for k ,v in pairs(confdata) do 
    --         t[v[1]] = math.floor(v[2]/all*tonumber(confRoledata.pot))

    --         var = var +  t[v[1]]
    --     end

    --     local more = tonumber(confRoledata.pot) - var --预留的额外多出的
    --     t[JueseBaseAdd[1]] = t[JueseBaseAdd[1]] + more

    
    --     for k ,v in pairs(JueseBaseAdd) do 
    --         if not self.props2[k] then
    --             break
    --         end
    --         local value = self:getValue(v) or 0 --当前已经加的点数

    --         self.props2[k].value.text = value
            
    --         local _var = t[v] - value
           
    --         if _var > 0 and p504 > 0 then --需要点数
    --             local _addvalue = p504 > _var and _var or p504
    --             self.props2[k].add.text =  _addvalue

    --             p504 = p504 - _addvalue
    --         else
    --             --self.props2[k].value.text = 0
    --         end
    --     end
    -- end
    --self.numberQianli.text = p504
    --推荐加点 2018/3/8之前的
end
--保存加点
function PropsPanel:onbtnSave()
    -- body
    if not self.data then
        return
    end
    local param = {}
    param.opType = 1
    param.list = {}
    local flag = false
    for k ,v in pairs(JueseBaseAdd) do 
        local var = self.props2[k].add.text
        if tonumber(var) > 0 then
            flag = true
        end
        if v == 505 then
            param.list[1] = tonumber(var)
        elseif v == 506 then
            param.list[2] = tonumber(var)
        else
            param.list[3] = tonumber(var)
        end
    end

    if flag then 
        proxy.PlayerProxy:send(1020201,param)
    else
        GComAlter(language.juese14)
    end
end

function PropsPanel:add5020203()
    -- body
    self:onbtnController()
end

function PropsPanel:add5020204()
    -- body
    self:onbtnController()
end

function PropsPanel:onGuize( ... )
    -- body
    GOpenRuleView(1036)
end


--长按测试
function PropsPanel:LongPress(btn,callback,timer)
    -- body
    if not btn then
        return
    end

    btn.onTouchBegin:Clear()
    btn.onTouchEnd:Clear()
    btn.onRollOut:Clear()

    btn.onTouchBegin:Add(self.onTouchBegin,self)
    btn.onTouchEnd:Add(self.onTouchEnd,self)
    btn.onRollOut:Add(self.onTouchEnd,self)
end

function PropsPanel:onTouchBegin(context)
    -- body

    local btn = context.sender

    if self._timerBegin then
        self.mParent:removeTimer(self._timerBegin)
        self._timerBegin = nil 
    end

    local _presstime = 0
    self._timerBegin = self.mParent:addTimer(1, -1, function()
        -- body
        _presstime = _presstime + 1
        if _presstime%2 == 0 and self.callback[btn.name] then
            self.callback[btn.name](btn,true)
        end
    end, "PropsPanel")
end

function PropsPanel:onTouchEnd(context)
    -- body
    local btn = context.sender
    self.mParent:removeTimer(self._timerBegin)
    self._timerBegin = nil 
    if self.callback[btn.name] then
        self.callback[btn.name](btn,false)
    end
end



return PropsPanel