--
-- Author: 
-- Date: 2017-06-27 15:24:23
--

local TeamFuben = class("TeamFuben",import("game.base.Ref"))

local delay = 5 --自动加入或者创建
local delaysend = 10 --发送消息间隔
function TeamFuben:ctor(param)
    self.view = param
    self:initView()
    self.delayTime = delay
end

function TeamFuben:initView()
    -- body

    self.controllerC1 =  self.view:GetController("c1")
    self.controllerC2 =  self.view:GetController("c2")

    --副本列表
    self.listfuben = self.view:GetChild("n1")
    self.listfuben.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listfuben.numItems = 0
    self.listfuben.onClickItem:Add(self.onItemCallBack,self)
    ---副本奖励信息
    self.title = self.view:GetChild("n5")--当前通关次数:0/30

    self.mubiaodec = self.view:GetChild("n8")
    self.mubiaodec.text = ""
    self.mubiaoItemobj = self.view:GetChild("n37")
    self.mubiaoItemobj.numItems = 0
    self.mubiaoItemobj.itemRenderer = function(index,obj)
        self:cellmubiaodata(index, obj)
    end

    self.titleName = self.view:GetChild("n24")
    self.titleName.text = ""

    --基本信息
    self.radio5 = self.view:GetChild("n13")
    self.radio5.touchable = false
    --self.radio5.onClick:Add(self.onAutoCreate,self)
    local dec1 = self.view:GetChild("n15")
    self.dectime = dec1
    self.dectime.text = string.format(language.kuafu04,delay) 

    self.radioAuto = self.view:GetChild("n14")
    self.radioAuto.touchable = false
    --self.radioAuto.onClick:Add(self.onReadCall,self)

    --2018 - 2 - 7 策划要求
    --双倍消耗
    self.radio6 = self.view:GetChild("n39")
    self.radio6.onClick:Add(self.onAutoCiShu,self)

    local dec1 = self.view:GetChild("n40")
    dec1.text = language.kuafu172


    local dec1 = self.view:GetChild("n16")
    dec1.text = language.kuafu05

    self.moneyicon = self.view:GetChild("n25")
    self.money = self.view:GetChild("n29")

    --查看副本队伍
    self.listteam = self.view:GetChild("n23")
    self.listteam:SetVirtual()
    self.listteam.itemRenderer = function(index,obj)
        self:cellteamdata(index, obj)
    end
    self.listteam.numItems = 0
    self.listteam.onClickItem:Add(self.onItemTeam,self)
    --自己的队伍
    self.listself = self.view:GetChild("n34")
    
    self.listself.itemRenderer = function(index,obj)
        self:cellselfdata(index, obj)
    end
    self.listself.numItems = 0
    self.radio2 = self.view:GetChild("n32")
    self.radio2.touchable = false
    --self.radio2.onClick:Add(self.onManRen,self)

    local dec1 = self.view:GetChild("n33")
    dec1.text = language.kuafu10
    local dec2 = self.view:GetChild("n35")
    dec2.text = language.kuafu11
    local btngrap = self.view:GetChild("n36")
    btngrap.onClick:Add(self.onSend,self)


    local btnCreate = self.view:GetChild("n17")
    btnCreate.onClick:Add(self.CreateTeam,self)

    local btnDuihuan = self.view:GetChild("n22")
    btnDuihuan.onClick:Add(self.DuiHuan,self)

    local btnGuize = self.view:GetChild("n31")
    btnGuize.onClick:Add(self.onGuize,self)

    -- local btnStart = self.view:GetChild("n17")
    -- btnStart.onClick:Add(self.StartFuben,self)

    local btnOut = self.view:GetChild("n18")
    btnOut.onClick:Add(self.outFuben,self)

    self.labtex = self.view:GetChild("n38")
    self.labtex.text = ""
    ----副本配置信息
    self.condata = {}
    for i = Fuben.kuafuteam , Fuben.kuafuteam + PassLimit do
        local var = conf.SceneConf:getSceneById(i)
        if var then
            table.insert(self.condata,var)
        else
            break
        end
    end
end

function TeamFuben:onController2()
    -- body
    if self.controllerC2.selectedIndex == 1 then
        self.view:GetChild("n13").visible = false
        self.view:GetChild("n15").visible = false
        self.view:GetChild("n14").visible = false
        self.view:GetChild("n16").visible = false
    else
        if self.data and self.data.teamId ~= 1 then
            self.view:GetChild("n13").visible = true
            self.view:GetChild("n15").visible = true
            self.view:GetChild("n14").visible = true
            self.view:GetChild("n16").visible = true
        end
    end
end

function TeamFuben:celldata( index, obj )
    -- body
    local data = self.condata[index+1] --副本信息
    local isFirst = false
    if self.data and self.data.fubenFirstMap then
        isFirst = self.data.fubenFirstMap[data.id*1000 + 1] --副本服务器信息--是否打通过
    end
    local c1 =  obj:GetController("c1")
    local bgurl = obj:GetChild("n6")
    local c2 = obj:GetController("c2")

    

    local fubendata = conf.FubenConf:getPassData(data.id,1)
    bgurl.url = UIItemRes.kuafu..tostring(fubendata.view_icon)
    --UIPackage.GetItemURL("kuafu" , tostring(fubendata.view_icon))
    local passreward = fubendata.normal_drop or {}
    local firstreward = fubendata.first_pass_award or {}
    local labname = obj:GetChild("n4")
    local list = obj:GetChild("n8")
    list.itemRenderer = function(i,cell)
        --local info = data.reward
        -- local innerdata 
        -- if not isFirst then
        --     innerdata = firstreward[i+1]
        -- else
        --     innerdata = passreward[i+1]
        -- end
        local innerdata = passreward[i+1]
        if innerdata then
            local t = {mid = innerdata[1],amount=innerdata[2],bind = innerdata[3]}
            GSetItemData(cell,t,true)
        end
    end
    --副本名字
    local lv = (data.lvl or 1)
    labname.text = data.name .. " Lv." .. lv
    
    if lv <= cache.PlayerCache:getRoleLevel() then
        c2.selectedIndex = 1
    else
        c2.selectedIndex = 0
    end
    
    -- if not isFirst then
    --     list.numItems = #firstreward
    --     c1.selectedIndex = 0
    -- else
    --     list.numItems = #passreward
    --     c1.selectedIndex = 1
    -- end
    list.numItems = #passreward
    c1.selectedIndex = 1

 


    local param = clone(data)
    param.selectedIndex = index
    obj.data = param
end

function TeamFuben:onItemCallBack(context)
    -- body
    local cell = context.data
    local data = cell.data
    --选择某个副本

    if cache.PlayerCache:getRoleLevel()>= (data.lvl or 1) then
        self.mdata = cell.data --bxp 用于扫荡数据
        if self:doSelectOne(data) then
            self.selectedIndex = data.selectedIndex
        else
            if not self.data then
                return
            end
            if self.controllerC2.selectedIndex == 1 then
            else
                GComAlter(language.kuafu23)
            end
        end
    else
        GComAlter(string.format(language.gonggong07,(data.lvl or 1)))
        self.listfuben:AddSelection(self.selectedIndex,false)
    end
    
    
end

--目标奖励
function TeamFuben:cellmubiaodata( index, obj)
    -- body
    local data = self.mubiaoreward[index+1]
    local t = {mid = data[1],amount = data[2],bind = data[3],isGet=self.isGet}
    GSetItemData(obj,t,true)
end

--副本队伍信息
function TeamFuben:cellteamdata(index, obj)
    -- body
    local data = self.data.teams[index+1]
    local labname = obj:GetChild("n5")
    local dec = obj:GetChild("n6")
    local c1 =  obj:GetController("c1")
    --队长
    labname.text = data.captainRoleName
    --人数
    c1.selectedIndex = data.memberNum - 1
    --
    if data.maxAutoPlay == 1 then
        dec.text = language.kuafu15
    else
        dec.text = language.kuafu16
    end
    obj.data = data
end
function TeamFuben:onItemTeam(context)
    -- body
    if not self.data or not self.maxPass then
        return
    end

    if self.data.curPassNum >= self.maxPass then
        GComAlter(language.kuafu24)
        return
    end

     --等级不足
    if self.controllerC2.selectedIndex == 1 then
        GComAlter(language.kuafu21)
        return
    end

    local data = context.data.data
    if self.data.teamId == 1 then
        return
    end

    if data.memberNum >= 3 then
        GComAlter(language.kuafu17)
        return
    end
    --副本中不能进行
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:checkScene(sId) or mgr.FubenMgr:isFlameScene(sId)  then
        GComAlter(language.gonggong41)
        return
    elseif cache.TeamCache:getTeamId() ~= 0 then
        GComAlter(language.gonggong104)
        return
    end
    --请求加入某个队伍
    local param = {}
    param.reqType = 2
    param.password = 0
    param.teamId = data.teamId
    param.sceneId = self.sceneId
    proxy.KuaFuProxy:sendMsg(1380102,param)
end

--自己队伍信息
function TeamFuben:cellselfdata(index, obj)
    -- body
    local data = self.data.teamMembers[index+1]
    local labname = obj:GetChild("n11")
    local power = obj:GetChild("n12")
    local roleimg =  obj:GetChild("n10")
    local c1 = obj:GetController("c1")

    local btnout = obj:GetChild("n15")
    btnout.title = language.kuafu19
    btnout.data = data
    btnout.onClick:Add(self.onTichu,self)
    btnout.visible = false

    if self.msg and self.msg.captain == 1 then
        if data.roleId ~= cache.PlayerCache:getRoleId() then
            btnout.visible = true
        end
    end

    if data.captain == 1 then
        c1.selectedIndex = 0
    else
        if data.teamMemberReady == 1 then
            c1.selectedIndex = 1
        else
            c1.selectedIndex = 2
        end
    end

    labname.text = data.roleName
    power.text = language.kuafu22..data.power

    --头像
    local t = {roleIcon = data.roleIcon,roleId = data.roleId }
    GBtnGongGongSuCai_050(roleimg,t)
end
--踢出某个队员
function TeamFuben:onTichu(condtext)
    -- body
    local data = condtext.sender.data
    if not self.msg then
        return
    end
    if self.msg.captain == 1 then
        proxy.KuaFuProxy:sendMsg(1380104,{reqType = 4,tarRoleId = data.roleId })
    end
end


--选择了某个副本
function TeamFuben:doSelectOne(data)
    -- body
    if not data then
        return false
    end
    if not self.data then
        return false
    end
    --改变奖励显示
   
    --创建队伍，创建队伍选择了副本后，队长和队员
    --都不能再在副本主界面选择其他难度的副本 ，也不让点击
    --plog("self.data.teamId",self.data.teamId)
    if self.data.teamId~=0 and self.sceneId ~= data.id then
        self.listfuben:AddSelection(self.selectedIndex,false)
        return false
    end
    

    local Sconf = conf.SceneConf:getSceneById(data.id)
    -- self.passreward = Sconf.normal_drop or {}
    -- self.listreward.numItems = #self.passreward
    --local confdata = conf.SceneConf:getSceneById(self.sceneId)
    self.titleName.text = Sconf.name
    
    --请求副本队伍信息
    if self.data.teamId==0 then
        proxy.KuaFuProxy:sendMsg(1380105,{page = 1,sceneId = data.id})
    end

    return true
end

function TeamFuben:quickCreate()
    -- body
    if not self.data then
        return
    end

    if self.data.curPassNum >= self.maxPass then
        GComAlter(language.kuafu24)
        return
    end

    --副本中不能进行创建动作
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:checkScene()
    or mgr.FubenMgr:isFlameScene(sId) then
        GComAlter(language.gonggong41)
        return
    elseif cache.TeamCache:getTeamId() ~= 0 then
        GComAlter(language.gonggong104)
        return
    end

    local param = {}
    param.reqType = 1
    param.password = 0
    param.teamId = 0
    param.sceneId = self.sceneId
    proxy.KuaFuProxy:sendMsg(1380102,param)
end

------------------一键扫荡功能bxp---------------
function TeamFuben:SweepFuben(leftNum) --leftNum 剩余次数
    local tempCost --= conf.FubenConf:getValue("cross_jinjie_sd_cost")
    local roleLv = cache.PlayerCache:getRoleLevel()
    for k,v in pairs(self.condata) do
        -- printt(v.sd_cost)
        -- if roleLv >= v.lvl then 
        --     tempCost = v.sd_cost[2]
        -- end
        if self.mdata.id == v.id then
            tempCost = v.sd_cost[2]
        end
    end

    local cost = tempCost * leftNum
    local times = conf.FubenConf:getValue("cross_jinjie_sd_item_coef") / 10
    local param = {}
    param.type = 14
    local ss = clone(language.kuafu170)
    ss[2].text = string.format(ss[2].text,times)
    ss[5].text = string.format(ss[5].text,cost)
    ss[7].text = string.format(ss[7].text,leftNum)
    param.richtext = mgr.TextMgr:getTextByTable(ss)
    --string.format(language.kuafu170,times,UIItemRes.moneyIcons[MoneyType.gold],cost,leftNum)
    param.sure = function()
        if not cache.PlayerCache:VipIsActivate(3) then
            GComAlter(language.kuafu171)
            GOpenView({id = 1050})
        elseif cache.PackCache:getPackDataById(PackMid.gold).amount < cost then
            GGoVipTequan(0)
        else
            proxy.KuaFuProxy:sendMsg(1380107,{sceneId = self.mdata.id})
        end
    end
    GComAlter(param)
end
--创建队伍
function TeamFuben:CreateTeam()
    -- body
    if self.labtex.text ~= "" then
        GComAlter(self.labtex.text)
        return
    elseif cache.TeamCache:getTeamId() ~= 0 then
        GComAlter(language.gonggong104)
        return
    end

    if not self.data or not self.maxPass then
        return
    end

    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:checkScene()
    or mgr.FubenMgr:isFlameScene(sId) then
        GComAlter(language.gonggong41)
        return
    end

    -- if self.data.curPassNum >= self.maxPass then
    --     GComAlter(language.kuafu24)
    --     return
    -- end

    if self.controllerC1.selectedIndex == 0 then --创建
        --检测是否已经是队伍的一个成员
        if self.data.teamId == 1 then
            return
        end
        --bxp加入扫荡功能
        local leftNum = self.maxPass - self.data.curPassNum --剩余挑战次数
        if self.data.curPassNum >= self.maxPass then
            GComAlter(language.kuafu24)
            return
        else
            self:SweepFuben(leftNum)
        end
        --开始创建
        -- local view = mgr.ViewMgr:get(ViewName.KuaFuCreateTeam)
        -- if view then
        --     return
        -- end
        -- local data = {self.condata,self.sceneId,self.data}
        -- mgr.ViewMgr:openView2(ViewName.KuaFuCreateTeam,data)
    elseif self.controllerC1.selectedIndex == 1 then --开始
        if self.data.teamId == 0 then
            return
        end
        self:StartFuben()
    elseif self.controllerC1.selectedIndex == 2 or self.controllerC1.selectedIndex == 3 then --准备
        if self.data.teamId == 0 then
            return
        end
        proxy.KuaFuProxy:sendMsg(1380104,{reqType = 2,tarRoleId = 0}) 
    end
end
--快速加入
function TeamFuben:QuickAdd()
    -- body

    if not self.data or not self.maxPass then
        return
    end
    if self.data.curPassNum >= self.maxPass then
        GComAlter(language.kuafu24)
        return
    end

    if self.controllerC1.selectedIndex ~= 0 then
        return
    end
    --等级不足
    if self.controllerC2.selectedIndex == 1 then
        GComAlter(language.kuafu21)
        return
    end

    --检测是否已经是队伍的一个成员 
    if self.data.teamId == 1 then
        return
    end

    if self.listteam.numItems == 0 then
        --点击后快速加入队伍，如果没有队伍，则自动创建
        --开始创建bxp
        -- local view = mgr.ViewMgr:get(ViewName.KuaFuCreateTeam)
        -- if view then
        --     return
        -- end
        -- local data = {self.condata,self.sceneId,self.data}
        -- mgr.ViewMgr:openView2(ViewName.KuaFuCreateTeam,data)
        self:quickCreate()
        return
    end
    --副本中不能进行
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:checkScene(sId) 
    or mgr.FubenMgr:isFlameScene(sId) then
        GComAlter(language.gonggong41)
        return
    elseif cache.TeamCache:getTeamId() ~= 0 then
        GComAlter(language.gonggong104)
        return
    end
    local param = {}
    param.reqType = 3
    param.password = 0
    param.teamId = 0
    param.sceneId = self.sceneId
    proxy.KuaFuProxy:send(1380102,param)
end
--兑换
function TeamFuben:DuiHuan()
    -- body
    --s商店跳转
    GOpenView({id = 1072})
end
--发送寻求队伍公告
function TeamFuben:onSend()
    -- body
    local lastsend = cache.KuaFuCache:getLastsend()
    if lastsend and lastsend ~= 0 and os.time()-lastsend<delaysend then
        GComAlter(language.kuafu18)
        return
    end
    GComAlter(language.kuafu102)
    cache.KuaFuCache:setLastsend()
    proxy.KuaFuProxy:send(1380106)
end
--规则
function TeamFuben:onGuize()
    -- body
    GOpenRuleView(1040)
end
--开始副本
function TeamFuben:StartFuben()
    -- body
    if not self.data then
        return
    end
    if self.data.teamId == 0 then
        return
    end
    --检测是否有队员没有准备
    for k ,v in pairs(self.data.teamMembers) do
        if v.captain~=1 and v.teamMemberReady ~= 1 then
            GComAlter(language.kuafu20)
            return
        end
    end
    proxy.KuaFuProxy:send(1380104,{reqType = 1,tarRoleId = 0})
end
--退出退伍
function TeamFuben:outFuben()
    -- body
    if self.labtex.text ~= "" then
        GComAlter(self.labtex.text)
        return
    end
    if not self.data then
        return
    end
        
    if self.controllerC1.selectedIndex == 0 then
        self:QuickAdd()
    else
        if self.data.teamId == 0 then
            return
        elseif not self.sceneId or self.sceneId == 0 then
            return
        end
        --发送离开队伍信息
        proxy.KuaFuProxy:send(1380104,{reqType = 3,tarRoleId = 0})
    end
end

function TeamFuben:onAutoCreate()
    -- body
    if self.labtex.text ~= "" then
        GComAlter(self.labtex.text)
        return
    end
    proxy.KuaFuProxy:send(1380103,{reqType = 1})
end

function TeamFuben:onReadCall()
    -- body
    if self.labtex.text ~= "" then
        GComAlter(self.labtex.text)
        return
    end
    --自动准备 --服务器会取反 操作
    proxy.KuaFuProxy:sendMsg(1380103,{reqType = 2})
end

function TeamFuben:onAutoCiShu()
    -- body
    --
    if not self.data then
        return
    end
    if self.radio6.selected then 
        if cache.PlayerCache:getRoleLevel() < SHUZI.teamfuben then
            GComAlter(language.kuafu173)
            self.radio6.selected = false
            return
        elseif self.data.curPassNum >= (self.maxPass - 1) then
            self.radio6.selected = false
            GComAlter(language.kuafu175)
            return
        end
        --2次窗口
        local param = {}
        param.type = 5  
        param.sure = function()
            -- body
            proxy.KuaFuProxy:sendMsg(1380103,{reqType = 4})
        end
        param.richtext = language.fuben206
        param.titleIcon = UIItemRes.fuben11
        GComAlter(param)
        return
    end
    --取消
    proxy.KuaFuProxy:sendMsg(1380103,{reqType = 4})
end

function TeamFuben:onManRen( ... )
    -- body

    --满人 --服务器会取反 操作
    proxy.KuaFuProxy:sendMsg(1380103,{reqType = 3})
end

--
function TeamFuben:onTimer()
    -- body

    if not self.data or not self.delayTime then
        return
    end

    if self.data.autoCreate ~= 1 then
        return
    end
    if self.data.teamId == 0 then --副本信息
        local view = mgr.ViewMgr:get(ViewName.KuaFuCreateTeam)
        if view then
            return
        end
        local view = mgr.ViewMgr:get(ViewName.Alert14)
        if view then
            return
        end
        local view = mgr.ViewMgr:get(ViewName.Alert5)
        if view then
            return
        end

        self.delayTime = self.delayTime - 1
        self.dectime.text = string.format(language.kuafu04,self.delayTime) 
        if self.delayTime <= 0 then

            self.delayTime = delay --回复
            --再次请求副本队伍信息
            --plog("5秒请求副本当前信息")
            proxy.KuaFuProxy:sendMsg(1380105,{page = self.page,sceneId = self.sceneId})
            --print("self.data.autoCreate",self.data.autoCreate,self.controllerC2.selectedIndex )
            if self.data.autoCreate == 1 then
                if self.controllerC2.selectedIndex == 0 then
                    if self.listteam.numItems == 0 then
                        self:quickCreate()
                    else
                        self:QuickAdd()
                    end
                end
            end
        end 
    end
end

function TeamFuben:setFubenTeam(data)
    -- body
    if data.teams then
        self.sceneId = data.sceneId
        self.page = math.max(data.page,1) 
        self.pageSum = data.pageSum 
        self.data.teams = data.teams
        self.listteam.numItems = #data.teams
    else
        self.page = 1
        self.pageSum = 1
        self.data.teams = {}
        self.listteam.numItems = 0
    end
end
--自己队伍信息
function TeamFuben:setTeamInfo(data)
    -- body
    if not data or not data.teamMembers then
        return
    end
    
    if  data.sceneId  then
        self.sceneId = data.sceneId
    end
    
    self.data.teamId = data.teamId
    --是否在队伍里面
    if self.data.teamId == 0 then
        self.controllerC1.selectedIndex = 0
    end

    self.data.teamMembers = data.teamMembers

    table.sort(self.data.teamMembers,function(a,b)
        -- body
        return a.captain > b.captain

    end)

    self.listself.numItems = #data.teamMembers

    self.msg = {}
    for k ,v in pairs(data.teamMembers) do
        if v.roleId == cache.PlayerCache:getRoleId() then
            self.msg = v 
            if v.captain == 1 then --如果自己是队长
                self.controllerC1.selectedIndex = 1
            else
                if v.teamMemberReady == 1 then
                    self.controllerC1.selectedIndex = 3
                else
                    self.controllerC1.selectedIndex = 2
                end
            end
            break
        end
    end
end

function TeamFuben:setWillOpen()
    -- body
    local temp = os.date("*t",cache.KuaFuCache:isWillOpenByid(2)) 
    local str = ""
    --str = str .. temp.year .. language.gonggong78
    str = str .. temp.month .. language.gonggong79
    str = str .. temp.day  .. language.gonggong80 ..language.kuafu109
    self.labtex.text = str

    self.money.text = cache.PlayerCache:getTypeMoney(MoneyType.gongxun)

    self.listfuben.numItems = #self.condata

    self.controllerC1.selectedIndex = 0
end

function TeamFuben:clear()
    -- body

end

---
function TeamFuben:addMsgCallBack(data)
    -- body
    --消息返回之后的处理
    self.money.text = cache.PlayerCache:getTypeMoney(MoneyType.gongxun)

    if 5380101 == data.msgId then-- 请求跨服进阶副本信息
        self.data = data
        self.labtex.text = ""

        --printt(self.data.fubenFirstMap)
        --设置副本信息
        self.listfuben.numItems = #self.condata
        
        
        --当前通过关卡次数
        local maxPass = conf.FubenConf:getValue("cross_jinjie_pass_max")
        self.maxPass = maxPass
        self.title.text = string.format(language.kuafu14,data.curPassNum,maxPass)
        --目标奖励
        local var = conf.FubenConf:getValue("cross_jinjie_tar_count")
        self.mubiaodec.text = string.format(language.kuafu03,var)

        self.isGet = data.curPassNum >= var
        self.mubiaoreward = conf.FubenConf:getValue("crpss_jinjie_tar_items")
        --printt("self.mubiaoreward",self.mubiaoreward)
        self.mubiaoItemobj.numItems = #self.mubiaoreward
        --设置副本队伍
        self:setFubenTeam(data)
        self.radioAuto.selected = (self.data.autoReady == 1)
        --plog(self.data.autoReady,"self.data.autoReady")
        self.radio5.selected = (self.data.autoCreate == 1)
        --plog(self.data.autoCreate,"self.data.autoCreate")
        --
        self.radio6.selected = (self.data.doubleCost == 1)
        --设置自己队伍信息
        self.listself.numItems = #data.teamMembers
        self.radio2.selected = (self.data.maxAutoPlay == 1)
        --plog(self.data.maxAutoPlay,"self.data.maxAutoPlay")


        self:setTeamInfo(data)
        --重置cd
        self.delayTime = delay

        self.quitstart = false
        local sId = cache.KuaFuCache:getQuitAdd()
        if not sId then
            sId = data.sceneId
        else
            self.quitstart = true
        end

        self.selectedIndex = 0
        cache.KuaFuCache:setQuitAdd()
        for k ,v in pairs(self.condata) do
            if v.id == sId then
                self.selectedIndex = k - 1
                self.listfuben:AddSelection(self.selectedIndex,false)
                self.listfuben:ScrollToView(self.selectedIndex, false)
                self:doSelectOne(v)
                self.mdata = v -- bxp 扫荡
                break
            end
        end

        --红点清理
        if data.curPassNum >= self.maxPass then
            mgr.GuiMgr:redpointByVar(attConst.A50117,0)
        end
    elseif 5380102 == data.msgId then
        self.data.sceneId = data.sceneId
        self.data.teamId = data.teamId
        self.data.teamMembers = data.teamMembers
        if data.status == 0 then
            if data.reqType == 1 then--创建队伍 
                self:setTeamInfo(data)
                --选中创建的副本
                for k ,v in pairs(self.condata) do
                    if v.id == data.sceneId then
                        self.selectedIndex = k - 1 
                        self.listfuben:AddSelection(self.selectedIndex,false)
                        self.listfuben:ScrollToView(self.selectedIndex, false)
                        self:doSelectOne(v)
                        break
                    end
                end
            elseif data.reqType == 2 then -- 加入队伍 
                self:setTeamInfo(data)
            elseif data.reqType == 3 then -- 快速加入队伍 
                self:setTeamInfo(data)
            end
        end
    elseif 5380103 == data.msgId then --  请求跨服进阶副本设置
        --plog("data.reqType",data.reqType,data.maxAutoPlay)
        if data.reqType == 1 then--1:5秒后自动创建或加入队伍
            self.data.autoCreate = data.autoCreate
            self.radio5.selected = (self.data.autoCreate == 1)

        elseif data.reqType == 2 then-- 2:自动准备
            self.data.autoReady = data.autoReady
            self.radioAuto.selected = (self.data.autoReady == 1)

        elseif data.reqType == 3 then-- 3:满员自动开启 
            self.data.maxAutoPlay = data.maxAutoPlay
            self.radio2.selected = (self.data.maxAutoPlay == 1)
 
            --self.radio2.selected = self.data.maxAutoPlay == 1
        elseif data.reqType == 4 then--4:双倍消耗
            self.data.doubleCost = data.doubleCost
            self.radio6.selected = (self.data.doubleCost == 1)
        end
    elseif 5380104 == data.msgId then--跨服进阶副本成员操作
        if data.reqType == 1 then --开始
            --在广播处理
        elseif data.reqType == 2 then --队员准备
            --在广播处理
        elseif data.reqType == 3 then --退出队伍
            --在广播处理
        elseif data.reqType == 4 then --队长T人
            --在广播处理
        elseif data.reqType == 5 then --请求队员信息
            --printt(data)
            local param = {}
            param.teamId = self.data.teamId
            param.teamMembers = data.teamMembers

            self.data.maxAutoPlay = data.maxAutoPlay
            self.radio2.selected = (self.data.maxAutoPlay == 1)

            self:setTeamInfo(param)
        end
    elseif 5380105 == data.msgId then
        self:setFubenTeam(data)
        if self.quitstart then
            self.quitstart = false
            self:QuickAdd()
        end
    elseif 8150101 == data.msgId then
        if data.reqType == 1 then--队长开始 
            local data = {sceneId = self.sceneId}--副本信息
            mgr.ViewMgr:openView2(ViewName.StartGoView,data)
        elseif data.reqType == 2 then--队员准备 
            proxy.KuaFuProxy:sendMsg(1380104,{reqType = 5,tarRoleId = 0})
        elseif data.reqType == 3 then--退出队伍
            if cache.PlayerCache:getRoleId() == data.tarRoleId then
                --清理队伍信息
                self.delayTime = delay
                local param = {}
                param.teamId = 0
                param.teamMembers = {}
                self:setTeamInfo(param)
                --请求副本队伍信息
                proxy.KuaFuProxy:sendMsg(1380105,{page = 1,sceneId = self.sceneId})
            else
                --请求队员信息
                proxy.KuaFuProxy:sendMsg(1380104,{reqType = 5,tarRoleId = 0})
            end
        elseif data.reqType == 4 then--被T了
            --plog(".data.reqType.",data.reqType,data.tarRoleId)
            if cache.PlayerCache:getRoleId() == data.tarRoleId then
                --清理队伍信息
                local param = {}
                param.teamId = 0
                param.teamMembers = {}
                self:setTeamInfo(param)
                --请求副本队伍信息
                proxy.KuaFuProxy:sendMsg(1380105,{page = 1,sceneId = self.sceneId})
                self.delayTime = delay
            else
                --请求队员信息
                proxy.KuaFuProxy:sendMsg(1380104,{reqType = 5,tarRoleId = 0})
            end
        end
    elseif 8010101 == data.msgId then
        if data.status == 2290005 then
            --请求副本队伍信息
            proxy.KuaFuProxy:sendMsg(1380105,{page = 1,sceneId = self.sceneId})
        elseif data.status == 2290006 then
            --
            self:quickCreate()
            --self:CreateTeam()
        end
    end
end
return TeamFuben