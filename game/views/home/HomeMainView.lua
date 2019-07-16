--
-- Author: wx
-- Date: 2017-11-16 14:39:51
-- 家园系统 不同区域不同的按钮

local HomeMainView = class("HomeMainView", base.BaseView)
local deay = 0.5 --检测时间
local delay_wenquan = 5--温泉检测间隔
function HomeMainView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level1
end

function HomeMainView:initView()

    --家园任务追踪界面
    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController1,self)

    self.c2 = self.view:GetController("c2")
    local btnJianTou = self.view:GetChild("n1")
    btnJianTou.onClick:Add(self.onJianTouCall,self)

    self.btn1 = self.view:GetChild("n6")
    self.btn1.onClick:Add(self.onLeftCall,self)

    self.btn2 = self.view:GetChild("n7")
    self.btn2.onClick:Add(self.onRightCall,self)


    self.dec1 = self.view:GetChild("n9")
    self.dec1.text = ""
    self.dec2 = self.view:GetChild("n10")
    self.dec2.text = ""
    local btn3 = self.view:GetChild("n11")
    btn3.onClick:Add(self.onGuize,self)

    self.btnOut = self.view:GetChild("n8")
    self.btnOut.onClick:Add(self.onCloseView,self)


    self.listView = self.view:GetChild("n4")
    self.listView.numItems = 0

    self.nameText = self.view:GetChild("n0"):GetChild("n355")

    self.imgos = self.view:GetChild("n22")
    --self.imgos.icon = nil
    self.imgos.onClick:Add(self.onOScancel,self)
end

function HomeMainView:initData()
    -- body
    mgr.HomeMgr:initData()
    self:setMainView(false)
    if self.timer then
        self:removeTimer(self.timer)
    end
    if self.timer1 then
        self:removeTimer(self.timer1)
    end
    self.secend_wenquan = 0

    local view = mgr.ViewMgr:get(ViewName.HomeOS)
    if view then
        view:closeView()
    end

    --清理额外控件
    if self.btnlist then
        for k ,v in pairs(self.btnlist) do
            for i , j in pairs(v) do
                for h , g in pairs(j) do
                    g:Dispose()
                end
            end
        end
    end
    self.btnlist = {}
    self:setData()
    self.pageIndex = 1
    self.c1.selectedIndex = 0
    self.c2.selectedIndex = 0
    self:onController1()
    self:changePageBtn()
    self.timer = self:addTimer(deay,-1, handler(self,self.update))
    self.timer1 = self:addTimer(1,-1, handler(self,self.onTimer))
end

function HomeMainView:onTimer()
    -- body
    if not self.data then
        return
    end
    if self.c1.selectedIndex == 0 then
        local _t = clone(language.home17)
        _t[2].text = string.format(_t[2].text,GTotimeString(self.data.leftHotSpringSec) )
        self.var6.text = mgr.TextMgr:getTextByTable(_t)
    elseif self.c1.selectedIndex == 2 then
        --剩余时间
         --当前收益
        if not self.wenquandata then
            return
        end
        local _t = clone(language.home39)
        _t[2].text = string.format(_t[2].text,self.wenquandata.income)
        self.var4.text = mgr.TextMgr:getTextByTable(_t)

        local _t = clone(language.home41)
        _t[2].text = string.format(_t[2].text,GTotimeString(self.wenquandata.leftHotSpringSec))
        self.var6.text = mgr.TextMgr:getTextByTable(_t)

        local _t = clone(language.home38)
        _t[2].text = string.format(_t[2].text,self.wenquandata.minIncome)
        self.var3.text = mgr.TextMgr:getTextByTable(_t)

        if self.wenquandata.startHotSpringTime > 0 then
            self.secend_wenquan = self.secend_wenquan + 1
            self.wenquandata.leftHotSpringSec = math.max(self.wenquandata.leftHotSpringSec - 1,0)

            if self.wenquandata.leftHotSpringSec <= 0 then
                proxy.HomeProxy:sendMsg(1460109,{reqType = 2})
            elseif self.secend_wenquan % delay_wenquan == 0  then
                proxy.HomeProxy:sendMsg(1460102)
            end
        end
    end
end

function HomeMainView:changeBody()
    -- body
    --改变形象
    local ff = false
    if self.pageIndex == 4 then
        ff  =true
    end
    cache.HomeCache:setHomeSpring(ff)
end

function HomeMainView:update()
    -- body
    if not self.data then
        --没有数据的时候不处理
        return
    end

    local pairs = pairs
    local players = mgr.ThingMgr:objsByType(ThingType.player)
    --检测场景里的玩家是否在温泉区域
    local _ccc = conf.HomeConf:getScenesInfoById(4)
    if _ccc.ponit then
        for k, v in pairs(players) do
            local ff = false
            for i , j in pairs(_ccc.ponit) do
                local point = Vector3.New(j[1], gRolePoz, j[2])
                local _dis = GMath.distance(point, v:getPosition())
                if _dis <= j[3] then
                    ff = true
                    break
                end
            end
            v:setHome(ff)
            
            
            
        end
    end
    --检测一下是否有温泉数据，不是在温泉了 要发送取消泡温泉的协议
    if self.wenquandata then
        if self.pageIndex ~= 4 and self.wenquandata.startHotSpringTime ~=0 then
            proxy.HomeProxy:sendMsg(1460109,{reqType = 2})
        end
    end
    for k ,v in pairs(self.sConf) do
        for i , j in pairs(v.ponit) do
            local point = Vector3.New(j[1], gRolePoz, j[2])
            local dis = GMath.distance(point, gRole:getPosition())
            if dis <= j[3] then
                --在这个区域了
                --self:changeBody()
                if self.pageIndex ~= v.id then
                    self.pageIndex = v.id
                    self:changePageBtn()
                    self:changeBody()
                    if self.pageIndex == 3 then
                        self.c1.selectedIndex = 1
                    elseif self.pageIndex == 4 then
                        self.c1.selectedIndex = 2
                    end
                    return
                end
                return
            end
        end
    end
    cache.HomeCache:setHomeSpring(false)
    --隐藏操作
    self:onOScancel()
    self.pageIndex = 1
    self.c1.selectedIndex = 0
    self:changePageBtn()
end

function HomeMainView:addComponent(j,i)
    -- body
    local condata = conf.HomeConf:getBtnInfo(j)
    local var = UIPackage.CreateObject("home" , "Component15")
    local btn = var:GetChild("n0")
    local lab = var:GetChild("n1")
    btn.icon = UIPackage.GetItemURL("home" , tostring(condata.icon))
    lab.text = ""
    btn.data = j
    btn.onClick:Add(self.onSkillCall,self)

    var.data = j
    var = self.view:AddChild(var)
    var.visible = false

    if i == 1 then
        if j == 16 then
            self.labWaterself =  lab
        end
    else
        if j == 16 then
            self.labWaterother =  lab
        end
    end
    --温泉
    if j == 9 then
        self.btnhot = btn
    end

    var.x = condata.postions[1]
    var.y = condata.postions[2]

    return var
end

function HomeMainView:setData(data_)
    --创建所有按钮
    self.sConf = conf.HomeConf:getScenesInfo()
    local pairs = pairs
    self.btnlist = {}
    self.btnlist.me = {}
    self.btnlist.other = {}
    for k, v in pairs(self.sConf) do
        self.btnlist.me[k] = {}
        if v.btnlist then
            for i , j in pairs(v.btnlist) do
                table.insert(self.btnlist.me[k],self:addComponent(j,1))
            end
        end
        self.btnlist.other[k] = {}
        if v.btnlist_other then
            for i , j in pairs(v.btnlist_other) do
                table.insert(self.btnlist.other[k],self:addComponent(j,2))
            end
        end
    end
    local sId = cache.PlayerCache:getSId()
    local Sconf = conf.SceneConf:getSceneById(sId)
    self.nameText.text = Sconf.name
end

function HomeMainView:changePageBtn(flag)
    -- body
    if not self.data then
        return
    end
    if not self.btnlist then
        return
    end
    --切换的时候关闭os
    if not flag then
        local view = mgr.ViewMgr:get(ViewName.HomeOS)
        if view then
            view:closeView()
        end
    end


    local t = self.btnlist.me
    if not self.isSelf then
        t = self.btnlist.other
    end
    for k , v in pairs(t) do
        local ff = false
        if k == self.pageIndex then
            ff = true
        else
            ff = false
        end

        if self.pageIndex == 2 then
            local _view = mgr.ViewMgr:get(ViewName.HomeOS)
            if _view then

                ff = false
            end
        end

        for i ,j in pairs(v) do
            if self.pageIndex == 4 and j.data == 9 then
                --是温泉并且在温泉区域
                if self.data.hotSpringLev > 0 then
                    --升级温泉
                    local condata = conf.HomeConf:getBtnInfo(j.data)
                    self.btnhot.icon = UIPackage.GetItemURL("home" , tostring(condata.icon))
                else
                    --建筑温泉
                    local condata = conf.HomeConf:getBtnInfo(11)
                    self.btnhot.icon = UIPackage.GetItemURL("home" , tostring(condata.icon))
                end
            end
            j.visible = ff
        end
    end
end

function HomeMainView:setonOSsure()
    -- body
    local var = cache.HomeCache:getOsTye()
    if not var then
        self:onOScancel()
        return
    end
    if var == 1 then
        self.imgos.icon = UIPackage.GetItemURL("home" , "jiayuan_097")
    elseif var == 2 then
        self.imgos.icon = UIPackage.GetItemURL("home" , "jiayuan_096")
    elseif var == 5 then
        self.imgos.icon = UIPackage.GetItemURL("home" , "jiayuan_095")
    end
    self.imgos.visible = true
end

function HomeMainView:onOScancel()
    -- body
    cache.HomeCache:setOsTye()
    self.imgos.visible = false
end

function HomeMainView:onSkillCall(context)
    -- body
    local btn = context.sender
    local data = btn.data
    --print("按钮点击",data)
    --切换的时候关闭os
    local view = mgr.ViewMgr:get(ViewName.HomeOS)
    if view then
        view:closeView()
    end
    --cache.HomeCache:setOsTye()
    self:onOScancel()
    if tonumber(data) == 1 then
        --种植
        mgr.ViewMgr:openView2(ViewName.HomePlantingChoose)
    elseif tonumber(data) == 2 then
        --浇水
        if not  mgr.HomeMgr:isHavePlant() then
            self:setonOSsure()
            GComAlter(language.home128)
            return
        end

        if mgr.HomeMgr:getWater()>0 then
            cache.HomeCache:setOsTye(2)
            self:setonOSsure()
        else
            GComAlter(language.home92)
        end
    elseif tonumber(data) == 3 then
        --全体炊熟
        local _t = mgr.HomeMgr:getAllCrops()
        local info = {}
        for k ,v in pairs(_t) do
            table.insert(info,v.data)
        end
        mgr.HomeMgr:doAccelerate(info)
    elseif tonumber(data) == 4 then
        --一键全收
        local _t = mgr.HomeMgr:getMature()
        local info = {}
        for k ,v in pairs(_t) do
            table.insert(info,v.data)
        end

        self.iteminfo = mgr.HomeMgr:doHarvest(info)
    elseif tonumber(data) == 5 then
        --偷窃
        if not  mgr.HomeMgr:isHavePlant() then
            self:setonOSsure()
            GComAlter(language.home128)
            return
        end

        cache.HomeCache:setOsTye(5)
        self:setonOSsure()
    elseif tonumber(data) == 6 then
        --清理
        cache.HomeCache:setOsTye(6)
        self:setonOSsure()
    elseif tonumber(data) == 10 then
        --兽元
        mgr.ViewMgr:openView2(ViewName.HomeMonster)
    elseif tonumber(data) == 11 then
        --建造温泉
        if not self.data then
            return
        end
        mgr.HomeMgr:doBuildSpring()
    elseif tonumber(data) == 9 then
        --升级温泉
        mgr.HomeMgr:doBuildSpring()
    elseif tonumber(data) == 12 then
        --泡温泉
        mgr.HomeMgr:doSpring(self.wenquandata)
    elseif tonumber(data) == 13 then
        --家园商店
        --GOpenView({id = 1043,index = 7 })  --EVE 家园商城不是这个，所以备注掉
        GOpenView({id = 1159})
    elseif tonumber(data) == 14 then
        mgr.ViewMgr:openView2(ViewName.HomeMonster,1)
    elseif tonumber(data) == 15 then
        --一件种植
        mgr.HomeMgr:doOneKeyPlant()
    elseif tonumber(data) == 16 then
        --一键浇水
        mgr.HomeMgr:doOneKeyWater()
    end
end
--单独收获一个
function HomeMainView:getOne(data)
    -- body
    self.iteminfo = mgr.HomeMgr:doHarvest({data})
end

---隐藏主界面任务面板
function HomeMainView:setMainView(visible)
    -- body
    local mv = mgr.ViewMgr:get(ViewName.MainView)
    if mv then
        mv.view:GetChild("n208").visible = visible
        mv.view:GetChild("n209").visible = visible
        mv.view:GetChild("n224").visible = visible
        mv:setTeamBtnVisible(visible)
        local selectedIndex = 1
        if visible then
            selectedIndex = 0
        end
        mv.c6.selectedIndex = selectedIndex
        mv.c4.selectedIndex = selectedIndex
        mv.c7.selectedIndex = selectedIndex
        if mv.taskorTeam then
            mv.taskorTeam:gotoWar()
        end
    end
end

function HomeMainView:addComponent8()
    -- body
    local var = UIPackage.GetItemURL("home" , "Component8")
    local _compent1 = self.listView:AddItemFromPool(var)
    return _compent1:GetChild("n0")
end

function HomeMainView:addComponent9()
    -- body
    local var = UIPackage.GetItemURL("home" , "Component9")
    local _compent1 = self.listView:AddItemFromPool(var)
    return _compent1
end
--检测住宅
function HomeMainView:checkHomeLv()
    -- body
    local _t = clone(language.home12)
    _t[2].text = string.format(_t[2].text,self.data.houseLev)
    if self.isSelf then
        --是自己的住宅
        local iii = 1001
        local _condata = conf.HomeConf:getHomeThing(iii)
        if _condata.maxlv > self.data.houseLev then
            --可升级 条件检测
            local condata = conf.HomeConf:getHomeLev(iii,self.data.houseLev)
            local flag = cache.PlayerCache:getTypeMoney(MoneyType.gold) > condata.cost[2]
            if flag then
               flag = G_HomeComponstCon(condata,self.data)
            end
            if flag then
                table.insert(_t,language.home77)
            end
        else
            --已满级
            table.insert(_t,language.home78)
        end
    end
    self.var2.text = mgr.TextMgr:getTextByTable(_t)
end
--检测灵田
function HomeMainView:checkLingtian()
    -- body
    if self.c1.selectedIndex ~= 0 then
        return
    end

    local num = 0
    local param = {0,0,0,0}
    local monster = mgr.ThingMgr:objsByType(ThingType.monster)
    if monster then
        for k , v in pairs(monster) do
            if v.data.kind == WidgetKind.home then
                local condata = conf.HomeConf:getHomeThing(v.data.ext01)
                if condata.type == 5  then
                    -- printt("v.data.attris",)
                    -- for jjj,vvv in pairs(v.data.attris) do
                    --     print(jjj,vvv)
                    -- end
                    if v.data.ext02 > 0 then
                        num  = num + 1
                        if v.data.attris and v.data.attris[605] and v.data.attris[605]>0 then
                            --种植了东西
                            local var = v.data.attris[605]+v.data.attris[606]- mgr.NetMgr:getServerTime()
                            if var <= 0 then
                                --可收获
                                param[1] = param[1] + 1
                            elseif v.data.attris[607] <= 0 and G_HomeWater() > 0 then
                                param[3] = param[3] + 1
                            else
                                --等待收货
                                param[4] = param[4] + 1
                            end
                        else
                            --可种植
                            param[2] = param[2] + 1
                        end
                    end
                end
            end
        end
    end
    local _t = clone(language.home13)
    _t[2].text = string.format(_t[2].text,num)
    if self.isSelf then
        --是自己
        for k ,v in pairs(param) do
            if v > 0 then
                table.insert(_t,language.home86[k])
                break
            end
        end
    else
        for k ,v in pairs(param) do
            --可收获 或者 可浇水
            if (k == 1 or k == 3) and v > 0 then
                table.insert(_t,language.home86[k])
                break
            end
        end
    end
    self.var3.text = mgr.TextMgr:getTextByTable(_t)
end

function HomeMainView:cellvar8Data( index,obj)
    -- body
    local data = self.monsterdata.rankList[index+1]
    local rank = obj:GetChild("n0")
    rank.text = data.rank

    local labname = obj:GetChild("n1")
    labname.text = data.roleName

    local hurtPercent = obj:GetChild("n2")
    hurtPercent.text = string.format("%.2f%%",data.hurtPercent/100)
end

function HomeMainView:setMsg()
    -- body
    if self.c1.selectedIndex == 0 then
        --我的家园
        if self.isSelf then
            local _t = clone(language.home11)
            _t[2].text = string.format(_t[2].text,self.data.homeName)
            self.var1.text = mgr.TextMgr:getTextByTable(_t)
            --宅邸
            self:checkHomeLv()
        else
            local _t = clone(language.home125)
            _t[1].text = string.format(_t[1].text,self.data.ownerName)
            _t[2].text = string.format(_t[2].text,self.data.homeName)
            self.var1.text = mgr.TextMgr:getTextByTable(_t)
        end
        --围墙
        --self:checkLingtian()
        local _t = clone(language.home13)
        _t[2].text = string.format(_t[2].text,self.data.wallLev)
        self.var3.text = mgr.TextMgr:getTextByTable(_t)
        --兽园
        local _t = clone(language.home14)
        _t[2].text = string.format(_t[2].text,self.data.zooLev)
        self.var4.text = mgr.TextMgr:getTextByTable(_t)
        --温泉
        local _t = clone(language.home15)
        if self.data.hotSpringLev > 0 then
            _t[2].text = string.format(_t[2].text,self.data.hotSpringLev)
        else
            _t[2].text = string.format(_t[2].text,language.zuoqi26)
            table.remove(_t,3)
        end
        self.var5.text = mgr.TextMgr:getTextByTable(_t)
        --护院圣兽
        local _t = clone(language.home16)
        _t[2].text = string.format(_t[2].text,self.data.hyssName)
        self.var6.text = mgr.TextMgr:getTextByTable(_t)
    elseif self.c1.selectedIndex == 1 then
        if mgr.HomeMgr:getIsCallMonster() then
            local bar = self.var8:GetChild("n2")
            bar.value = self.monsterdata.curHpPercent/100
            bar.max = 100

            self.var8_listview.numItems = #self.monsterdata.rankList

            local lab = self.var8:GetChild("n7")
            lab.text = self.monsterdata.hurtPercent/100 .. "%"
        else
            if self.isSelf then
                local _t = clone(language.home11)
                _t[2].text = string.format(_t[2].text,self.data.homeName)
                self.var1.text = mgr.TextMgr:getTextByTable(_t)
                --宅邸
                self:checkHomeLv()
            else
                local _t = clone(language.home125)
                _t[1].text = string.format(_t[1].text,self.data.ownerName)
                _t[2].text = string.format(_t[2].text,self.data.homeName)
                self.var1.text = mgr.TextMgr:getTextByTable(_t)
            end

            --兽园
            local _t = clone(language.home14)
            _t[2].text = string.format(_t[2].text,self.data.zooLev)
            self.var2.text = mgr.TextMgr:getTextByTable(_t)

            --兽园
            local _t = clone(language.home138)
            local confdata = conf.HomeConf:getBossLev(self.data.zooLev)
            local mConf = conf.MonsterConf:getInfoById(confdata.monster_ref[1])

            _t[2].text = string.format(_t[2].text,mConf.name)
            self.var3.text = mgr.TextMgr:getTextByTable(_t)
        end
    elseif self.c1.selectedIndex == 2 then
        --我的家园
        if self.isSelf then
            local _t = clone(language.home11)
            _t[2].text = string.format(_t[2].text,self.data.homeName)
            self.var1.text = mgr.TextMgr:getTextByTable(_t)
            --宅邸
            self:checkHomeLv()
        else
            local _t = clone(language.home125)
            _t[1].text = string.format(_t[1].text,self.data.ownerName)
            _t[2].text = string.format(_t[2].text,self.data.homeName)
            self.var1.text = mgr.TextMgr:getTextByTable(_t)
        end
        --温泉
         local _t = clone(language.home15)
        _t[2].text = string.format(_t[2].text,self.data.hotSpringLev)
        self.var2.text = mgr.TextMgr:getTextByTable(_t)
        --温泉效果
        -- local sss = mgr.HomeMgr:getSelectSkin()
        -- local info = conf.HomeConf:getSkins(sss[3001])

        -- local _t = clone(language.home38)
        -- _t[2].text = string.format(_t[2].text,info.desc)
        -- self.var3.text = mgr.TextMgr:getTextByTable(_t)

        --我的家园币
         local _t = clone(language.home40)
         local var = cache.PlayerCache:getTypeMoney(MoneyType.home)
        _t[2].text = string.format(_t[2].text,var)
        self.var5.text = mgr.TextMgr:getTextByTable(_t)

    end
end

function HomeMainView:initListView()
    -- body
    self.listView.numItems = 0
    if not self.data then
        return
    end
    if self.c1.selectedIndex == 0 then
        --我的家园
        self.var1 = self:addComponent8()
        self.var1.text = ""
        --宅邸
        self.var2 = self:addComponent8()
        self.var2.text = ""
        --围墙
        self.var3 = self:addComponent8()
        self.var3.text = ""
        --兽园
        self.var4 = self:addComponent8()
        self.var4.text = ""
        --温泉
        self.var5 = self:addComponent8()
        self.var5.text = ""
        --护院圣兽
        self.var6 = self:addComponent8()
        self.var6.text = ""
        --温泉剩余时间
        self.var7= self:addComponent8()
        self.var7.text = ""
    elseif self.c1.selectedIndex == 1 then
        if mgr.HomeMgr:getIsCallMonster() then
            self.var8 = self:addComponent9()
            local btngo = self.var8:GetChild("n1")
            btngo.title = language.home103
            btngo.onClick:Add(self.onGo,self)

            local dec1 = self.var8:GetChild("n3")
            dec1.text = language.home18
            local dec1 = self.var8:GetChild("n4")
            dec1.text = language.home19
            local dec1 = self.var8:GetChild("n5")
            dec1.text = language.home20

            self.var8_listview = self.var8:GetChild("n6")
            self.var8_listview.itemRenderer = function(index, obj)
                self:cellvar8Data(index, obj)
            end
            self.var8_listview.numItems = 0
        else
            --我的家园
            self.var1 = self:addComponent8()
            self.var1.text = ""
            --兽园
            self.var2 = self:addComponent8()
            self.var2.text = ""
            --兽园boss
            self.var3 = self:addComponent8()
            self.var3.text = ""
        end
    elseif self.c1.selectedIndex == 2 then
        --我的家园
        self.var1 = self:addComponent8()
        self.var1.text = ""
        --温泉
        self.var2 = self:addComponent8()
        self.var2.text = ""
        --温泉效果
        self.var3 = self:addComponent8()
        self.var3.text = ""
        --当前收益
        self.var4 = self:addComponent8()
        self.var4.text = ""
        --我的家园币
        self.var5 = self:addComponent8()
        self.var5.text = ""
        --剩余时间
        self.var6 = self:addComponent8()
        self.var6.text = ""
    end
    self:setMsg()
    self.listView.scrollPane:ScrollTop()
end

function HomeMainView:setRedPoint()
    -- body
    self:addTimer(1, 1, function( ... )
        -- body
        local red1 = self.btn2:GetChild("red")
        if self.isSelf then
            if self.c1.selectedIndex == 0 then
                red1.visible = mgr.HomeMgr:getTianRedPoint()>0 or mgr.HomeMgr:isEmtyTianAndSeed()
            else
                red1.visible = false
            end

            if not self.btn2:GetChild("red").visible then
                mgr.GuiMgr:redpointByVar(10252,0,2)
            else
                mgr.GuiMgr:redpointByVar(10252,1,2)
            end
        else
            red1.visible = false
        end
    end)
end

function HomeMainView:onController1()
    -- body

    if self.c1.selectedIndex == 0 then
        --家园
        self.btn1.title = language.home07
        self.btn2.title = language.home08

        proxy.HomeProxy:sendMsg(1460103)
    elseif self.c1.selectedIndex == 1 then
        --怪兽
        proxy.HomeProxy:sendMsg(1460112)
    elseif self.c1.selectedIndex == 2 then
        --温泉
        self.btn1.title = language.home10
        self.btn2.title = language.home09

        proxy.HomeProxy:sendMsg(1460102)
    end

end

function HomeMainView:onJianTouCall()
    -- body
    if self.c2.selectedIndex == 0 then
        self.c2.selectedIndex = 1
    else
        self.c2.selectedIndex = 0
    end
end

function HomeMainView:onGuize()
    -- body
    GOpenRuleView(1064)
end

function HomeMainView:onLeftCall()
    -- body
    if self.c1.selectedIndex == 1 then
        return
    end
    if self.c1.selectedIndex == 0 then
        mgr.ViewMgr:openView2(ViewName.HomeWelCome)
    else
        --泡温泉
        mgr.HomeMgr:doSpring(self.wenquandata)
        --mgr.HomeMgr:doBuildSpring()

    end
end

function HomeMainView:onRightCall()
    -- body
    if self.c1.selectedIndex == 1 then
        return
    end
    if self.c1.selectedIndex == 0 then

        if not self.isSelf then
            --拜访
            mgr.ViewMgr:openView2(ViewName.HomeSeeOther)
        else
            --拜访记录
            mgr.ViewMgr:openView2(ViewName.HomeRecord)
        end

    else
        --离开温泉
        mgr.HomeMgr:goPosition(1)
        --mgr.HomeMgr:doSpring(self.wenquandata)
    end
end

function HomeMainView:onGo()
    -- body
    --print("不知道前往那里")
    mgr.ViewMgr:openView2(ViewName.HomeMonster)
end

function HomeMainView:onCloseView()
    -- body
    if self.isSelf  then
        cache.HomeCache:setHomeSpring(false)
        mgr.FubenMgr:quitFuben()
        self:closeView()
    else
        proxy.HomeProxy:sendMsg(1460108,{roleId = cache.PlayerCache:getRoleId()})
    end
end

function HomeMainView:addMsgCallBack(data)
    -- body
    --家园
    self.data  = cache.HomeCache:getData()
    self.isSelf = cache.HomeCache:getisSelfHome()

    if self.isSelf then
        self.btnOut.icon = UIPackage.GetItemURL("home" , "xianmengshenghuo_029")
        if self.labWaterself then
            self.labWaterself.text = string.format(language.home112,
                cache.HomeCache:getWaterSelf(),conf.HomeConf:getValue("water_self_count"))
        end

        if self.c1.selectedIndex == 0 then
            self.btn1.title = language.home07
            self.btn2.title = language.home08
        end
    else
        self.btnOut.icon = UIPackage.GetItemURL("home" , "jiayuan_094")
        if self.labWaterother then
            self.labWaterother.text =string.format(language.home112
            ,cache.HomeCache:getOtherSelf(),conf.HomeConf:getValue("water_other_count"))
        end

        if self.c1.selectedIndex == 0 then
            self.btn1.title = language.home119
            self.btn2.title = language.home120
        end
    end


    if data.msgId == 5460103 then
        self:initListView()
        --麻烦的操作
        self:addTimer(1, 1, function( ... )
            -- body
            self:checkTuojian()
        end)
        self:setRedPoint()
    elseif data.msgId == 5460102 then

        self.secend_wenquan = 0
        self.wenquandata = data
        if self.c1.selectedIndex == 2 then
            self:setMsg()
        else
            self:initListView()
        end
    elseif data.msgId == 5460112 then
        self.monsterdata = data
        self:initListView()
    elseif 5460104 == data.msgId
    or 5460105 == data.msgId then
        self:setMsg()
        if 5460105 == data.msgId   then
            if data.reqType == 3001 and data.lev == 1 then
                self:changePageBtn()
            elseif data.reqType == 1001 then
                self:checkTuojian()
            end
        end

    elseif 8220101 ==  data.msgId then
        if not self.monsterdata then
            return
        end
        self.monsterdata.curHpPercent = data.curHpPercent
        self.monsterdata.hurtPercent = data.hurtPercent
        self.monsterdata.rankList = data.rankList
        self.monsterdata.hateRoleName = data.hateRoleName
        if self.c1.selectedIndex == 1 then
            if mgr.HomeMgr:getIsCallMonster() and  self.var8 then
                self:setMsg()
            end
        end
    elseif 5460111 == data.msgId then
        if data.reqType == 4 then
            if self.iteminfo then
                table.insert(data.items,self.iteminfo[1])
            end
            GOpenAlert3(data.items)
        end
        self:setRedPoint()
        self:checkTuojian()
    elseif 5460108 == data.msgId then
        self.pageIndex = 1
    elseif 8220103 == data.msgId then
        self:setMsg()
    elseif 5460114 == data.msgId then
        if self.c1.selectedIndex == 1 then
            if data.reqType == 3 then
                self:addTimer(1,1,function()
                    -- body
                    self:initListView()
                    self:setMsg()
                end)
            end
        end
    elseif 5090104 == data.msgId then 
        self:setRedPoint()
    end
end


function HomeMainView:checkTuojian()
    -- body
    if true then
        --家园灵田变成自动有 屏蔽拓建
        return
    end
    local cc = conf.HomeConf:getHomeLev(1001,self.data.houseLev)
    local number = cc.tiancount --可拥有的田的数量

    local getnumber = 0
    local param = {}
    local monster = mgr.ThingMgr:objsByType(ThingType.monster)
    if monster then
        for k , v in pairs(monster) do
            if v.data.kind == WidgetKind.home then
                local condata = conf.HomeConf:getHomeThing(v.data.ext01)
                if condata.type == 5  then
                    if v.data.ext02 == 0 then
                        table.insert(param,v)
                    else
                        getnumber = getnumber + 1
                    end
                end
            end
        end
    end
    --print("getnumber",getnumber)
    --可以插上扩建的图标
    local tuojian = number - getnumber
    local max = 5000 + getnumber  + tuojian
    self:addTimer(0.8,1,function( ... )
        -- body
        for k ,v in pairs(param) do
            if  v.data.ext01<= max  then
                v:createHead({homeKuajian = true})
            end
        end
    end)

end
return HomeMainView
