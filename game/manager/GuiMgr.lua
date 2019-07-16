--
-- Author: yr
-- Date: 2017-01-10 20:25:29
--

local GuiMgr = class("GuiMgr", import("game.base.Ref"))

function GuiMgr:ctor()
    -- 01-金钱管理
    self.moneyList = {}
    -- 02-红点管理
    self.redPointList = {}
    -- 03-双倍副本管理
    self.doubleFubenList = {}
end

--------------------------01-金钱管理----------------------------
--注入控件
function GuiMgr:registerMoneyPanel(panel,vName)
    if g_ios_test then    --EVE ios版属屏蔽货币旁加号
        local btn1 = panel:GetChild("btn1")
        if nil ~= btn1 then
            btn1.visible =false
        end
        local btn2 = panel:GetChild("btn2")
        if nil ~= btn2 then
            btn2.visible =false
        end
        local btn4 = panel:GetChild("btn4")
        if nil ~= btn4 then
            btn4.visible =false
        end
    end
    self:setMoneyPanel(panel, true)
    self.moneyList[vName] = panel

    local bg2 = panel:GetChild("n56")
    if bg2 then
        bg2.url = nil
    end

    ---添加一个特效
    local effpanel = panel:GetChild("eff4020101")
    local view = mgr.ViewMgr:get(vName)
    if view and effpanel then
        local effect = view:addEffect(4020101,effpanel)
        effect.Scale = Vector3.New(50,50,50)
        effect.LocalPosition = Vector3(effpanel.actualWidth/2+79,-effpanel.actualHeight+63,50)
    end
end
--更新
function GuiMgr:updateMoneyPanels()
    for k, v in pairs(self.moneyList) do
        self:setMoneyPanel(v, false)
    end
end

function GuiMgr:setMoneyPanel(panel, event)
    for i=1,12 do--设置金钱  --EVE 上限由11改成12，加入了家园币。
        local iconObj = panel:GetChild("icon"..i)
        if iconObj then
            iconObj.url = UIItemRes.moneyIcons[i]
        end
        local titleObj = panel:GetChild("title"..i)
        if titleObj then
            titleObj.text = GTransFormNum(cache.PlayerCache:getTypeMoney(i))
        end
        if event then
            local btn = panel:GetChild("btn"..i)
            if btn then
                btn.data = i
                btn.onClick:Add(self.onBtnClick,self)
            end
        end
    end
end

--事件
function GuiMgr:onBtnClick(context)
    local index = context.sender.data
    local view = mgr.ViewMgr:get(ViewName.ShopMainView)
    local param = {}
    if index == 1 then --元宝
        -- if not view then
            GOpenView({id = 1042})
        -- else
        --     param.mId = MoneyPro2[MoneyType.gold]
        --     GGoBuyItem(param)
        -- end
    elseif index == 2 then--绑元
        -- if not view then
        --     GOpenView({id = 1042})
        -- else
            param.mId = MoneyPro2[MoneyType.bindGold]
            GGoBuyItem(param)
        -- end

    elseif index == 3 then--铜钱
        --GOpenView({id = 1042})
        param.mId = MoneyPro2[MoneyType.copper]
        GGoBuyItem(param)
    elseif index == 4 then--绑定铜钱
        param.mId = MoneyPro2[MoneyType.bindCopper]
        GGoBuyItem(param)
    elseif index == 5 then--
        param.mId = MoneyPro2[MoneyType.gx]
    elseif index == 6 then--荣誉币
        -- if not view then
        --     GOpenView({id = 1046})
        -- else
            param.mId = MoneyPro2[MoneyType.ry]
            GGoBuyItem(param)
        -- end

    elseif index == 7 then--功勋
        -- GOpenView({id = 1046})
        param.mId = MoneyPro2[MoneyType.gongxun]
        GGoBuyItem(param)
    elseif index == 8 then--爬塔积分
        if not view then
            GOpenView({id = 1024})
        else
            param.mId = MoneyPro2[MoneyType.pt]
            GGoBuyItem(param)
        end
    elseif index == 10 then--声望
        if not view then
            GOpenView({id = 1094})
        else
            param.mId = MoneyPro2[MoneyType.sw]
            GGoBuyItem(param)
        end
    elseif index == 11 then--战功
        if not view then
            GOpenView({id = 1117})
        else
            param.mId = MoneyPro2[MoneyType.wm]
            GGoBuyItem(param)
        end
    elseif index == 12 then--EVE 家园币
        if not view then
            GOpenView({id = 1137})
        else
            param.mId = MoneyPro2[MoneyType.home]
            GGoBuyItem(param)
        end
    end

    -- if view then
    --     GGoBuyItem(param)
    -- end
end
--------------------------02-红点管理-----------------------------
--注入控件
-- param.panel  红点底图
-- param.text   显示文本
-- param.ids    红点定义
-- param.notnumber  --是否不显示数字 --默认显示
function GuiMgr:registerRedPonintPanel(param,vName)
    if g_is_banshu then
        return
    end

    if not param.ids or not param.panel then
        return
    end
    if param.panel then
        param.panel.visible =false
    end
    if param.text then
        param.text.visible = false
    end
    if not self.redPointList[vName] then
        self.redPointList[vName] = {}
    end

    for k ,v in pairs(param.ids) do
        if not self.redPointList[vName][v..""] then
            self.redPointList[vName][v..""]= param
        end
    end
    self:setRedPoint(param)
end
--更新
function GuiMgr:updateRedPointPanels(id)
    --有红点改变刷新一下变强红点
    local view = mgr.ViewMgr:get(ViewName.MainView)
    if view then
        view:setGrowthTips()
    end

    for k ,v in pairs(self.redPointList) do --循环打开的界面

        if id and v[id..""] then

            local t = string.split(k,".")
            local viewname = t[1].."."..t[2]
            -- if id == 50110 or id == 50108 then
            --     plog("viewname",viewname)
            -- end
            if self.redPointList[viewname..""] and self.redPointList[viewname..""][id..""] then
                -- if id == 50110 or id == 50108 then
                --     plog("viewname11111")
                -- end
                self:setRedPoint(self.redPointList[viewname..""][id..""])
            end
            for rid = 1 , 2 do
                if self.redPointList[viewname.."."..rid] and self.redPointList[viewname.."."..rid][id..""] then
                    -- if id == 50110 or id == 50108 then
                    --     plog("viewname22",rid)
                    -- end
                    self:setRedPoint(self.redPointList[viewname.."."..rid][id..""])
                end
            end
            return
        else
            for i , j in pairs(v) do
                self:setRedPoint(j)
            end
        end
    end
end

function GuiMgr:setRedPoint(param)
    -- body
    local number = 0
    --计算红点数量
    for k , v in pairs(param.ids) do
        -- plog(v,cache.PlayerCache:getRedPointById(v))
        if v == attConst.A504 then
            --人物潜力点
            number = cache.PlayerCache:getAttribute(attConst.A504)
        elseif v == 20150 then--仙盟圣火结束时间
            if GIsXianMengFlameTime() then
                number = number + 1
            else
                -- number = 0
            end
        elseif v == 50133 then
            number = cache.PlayerCache:getRedPointById(v)
        else
            local _count = cache.PlayerCache:getRedPointById(v)
            if _count >= 999 then _count = 0 end
            number = number + _count
            if v == attConst.A20127 then --等级礼包特殊情况
                if cache.PlayerCache:getRedPointById(v) > 100 then
                    number = 0
                end
            elseif v == attConst.A10233 then--合成
                number = number + GGetCompseNum()
                local c1 = conf.ForgingConf:getItemCompose(58)
                if c1.openlv <= cache.PlayerCache:getRoleLevel() then
                    number = number + GGetCompseXianNum(5) + GGetCompseXianNum(6) + GGetCompseNum2(1) +  GGetCompseNum2(2)
                end


                local c1 = conf.ForgingConf:getItemCompose(21)
                if c1.openlv <= cache.PlayerCache:getRoleLevel() then
                    number = number + GGetCompseNum1(9) +  GGetCompseNum1(10)
                end

                local c2 = conf.ForgingConf:getItemCompose(25)
                if c2.openlv <= cache.PlayerCache:getRoleLevel() then
                    number = number + GGetCompseNum1(11) + GGetCompseNum1(12)
                end

                local c3 = conf.ForgingConf:getItemCompose(31)
                if c3.openlv <= cache.PlayerCache:getRoleLevel() then
                    number = number + GGetCompsePetNum()
                end

                 local c4 = conf.ForgingConf:getItemCompose(43)
                if c4.openlv <= cache.PlayerCache:getRoleLevel() then
                    for i = 1 , 5 do
                        number = number + GGetCompseWuxingNum(i,5)
                    end
                end


                local c5 = conf.ForgingConf:getItemCompose(48)
                if c5.openlv <= cache.PlayerCache:getRoleLevel() then
                    for i = 1 , 5 do
                        number = number + GGetCompseWuxingNum(i,6)
                    end
                end

                local c6 = conf.ForgingConf:getItemCompose(53)
                if c6.openlv <= cache.PlayerCache:getRoleLevel() then
                    for i = 1 , 5 do
                        number = number + GGetCompseWuxingNum_1(i)
                    end
                end
                local c7openlv = conf.ForgingConf:getComposeOpenLvByType(21)--神装
                if c7openlv <= cache.PlayerCache:getRoleLevel() then
                    number = GGetCompseGod1() + number
                end

                local c8openlv = conf.ForgingConf:getComposeOpenLvByType(22)--神兽神装
                if c8openlv <= cache.PlayerCache:getRoleLevel() then
                    number = GGetCompseShenShouGod() + number
                end
                local c9openlv = conf.ForgingConf:getComposeOpenLvByType(23)--神兽三星
                if c9openlv <= cache.PlayerCache:getRoleLevel() then
                    number = GGetCompseShenShouNum() + number
                end

                local c10openlv = conf.ForgingConf:getComposeOpenLvByType(24)--元素三星
                if c10openlv <= cache.PlayerCache:getRoleLevel() then
                    number = GGetElementCompse() + number
                end

                local c11openlv = conf.ForgingConf:getComposeOpenLvByType(25)--仙装神装


                if c11openlv <= cache.PlayerCache:getRoleLevel() then
                    for i = 1 , 12 do
                        number = number + GGetCompseXianGodNum(i)
                    end
                end


                number = GGetCompseSY() + number

                number = GGetCompseJS() + number



            elseif v == attConst.A10265 then--神兽装备穿戴红点
                local flag = cache.ShenShouCache:isCanPromote()
                if flag then--已助战神兽有可提升战力的装备时给红点
                    number = number + 1
                end
            end
        end
    end
    if number > 0 then

        if param.panel then
            param.panel.visible = true

        else
            return
        end
        if param.text then
            param.text.text = number
        end


        if param.notnumber and param.text then
            param.text.visible = false
        else
            if param.text then
                param.text.visible = true
            end
        end
    else
        if param.panel then
            param.panel.visible = false
            if param.text then
                param.text.visible = false
            end
        end
    end

    if param.panel_add1 and param.panel then
        param.panel_add1.visible = param.panel.visible
    end
end
--刷新主界面红点
function GuiMgr:refreshMainRed()
    local view = mgr.ViewMgr:get(ViewName.MainView)
    if view then
        view:refreshRed()
    end
end
--刷右下角
function GuiMgr:refreshRedBottom()
    -- body
    local view = mgr.ViewMgr:get(ViewName.MainView)
    if view then
        view:refreshRedBottom()
    end
end
--刷主界面顶部
function GuiMgr:refreshRedTop()
    -- body
     local view = mgr.ViewMgr:get(ViewName.MainView)
    if view then
        view:refreshRedTop()
    end
end


--红点改变
function GuiMgr:redpointByID(id,num)
    -- body
    --刷新红点
    local var = cache.PlayerCache:getRedPointById(id) - (num or 1)
    if var < 0 then
        var = 0
    end
    --plog(id,var)
    cache.PlayerCache:setRedpoint(id, var)
    self:updateRedPointPanels(id)
    self:refreshRedTop()
    self:refreshRedBottom()
end
--红点改变 直接赋值refType 1.顶部 2.右下角 3.全部没有默认为1
function GuiMgr:redpointByVar(id,num,refType)
    -- body
    --local var = cache.PlayerCache:setRedpoint(id,num)
    cache.PlayerCache:setRedpoint(id, num)

    self:updateRedPointPanels(id)
    local iType = refType or 1
    if iType == 1 then
        self:refreshRedTop()
    elseif iType == 2 then
        self:refreshRedBottom()
    elseif iType == 3 then
        self:refreshRedTop()
        self:refreshRedBottom()
    end
end

------
--清理View时候调用。BaseView中调用
function GuiMgr:disposePanel(vName, clear)
    if self.moneyList[vName] then
        self.moneyList[vName] = nil
    end

    --多个界面共享的事件，所有界面都关闭了才去清理事件
    local len = table.nums(self.moneyList)
    if len <= 0 then
        if clear then
            self:removeAllEvent()
        end
    end

    if self.redPointList  then
        self.redPointList[vName] = nil
        for rid = 1 , 2 do
            if self.redPointList[vName.."."..rid] then
                self.redPointList[vName.."."..rid] = nil
            end
        end
    end
end


--返回装备铸星 进阶需要的东西
function GuiMgr:get912PartNeed()
    -- body
    local equip_jinjie_min_cfg = conf.ForgingConf:getValue("equip_jinjie_min_cfg")
    local equip_zuxing_min_cfg = conf.ForgingConf:getValue("equip_zuxing_min_cfg")
    local _t = {}
    local list = conf.ForgingConf:getDataByType(2)
    for k ,v in pairs(list) do
        local data = cache.PackCache:getEquipDataByPart(v.part)
        if data then
            local condata = conf.ItemConf:getItem(data.mid)
            --进阶消耗
            if condata.stage_lvl+1 <= 9
            and condata.stage_lvl >= equip_jinjie_min_cfg[1]
            and condata.color >= equip_jinjie_min_cfg[2]
            and mgr.ItemMgr:getColorBNum(data) >= equip_jinjie_min_cfg[3] then
                local needconf = conf.ForgingConf:getJingjieById(data.mid)
                if needconf then
                    _t[needconf.cost_item[1][1]] = true
                end
            end
        end
    end
    local list = conf.ForgingConf:getDataByType(1)
    for k , v in pairs(list) do
        local data = cache.PackCache:getEquipDataByPart(v.part)
        if data then
            local condata = conf.ItemConf:getItem(data.mid)
            --铸星
            if condata.stage_lvl >= equip_zuxing_min_cfg[1]
            and condata.color >= equip_zuxing_min_cfg[2]
            and mgr.ItemMgr:getColorBNum(data) == equip_zuxing_min_cfg[3] then
                local needconf = conf.ForgingConf:getZhuxinById(data.mid)
                if needconf then
                    _t[needconf.cost_item[1][1]] = true
                end
            end
        end
    end
    return _t
end
--[[
注册双倍副本
obj 双倍标志
moduleId 模块id
]]
function GuiMgr:registerDoubleFuben(param,vName)
    if g_is_banshu then
        return
    end

    if not param.moduleId or not param.obj then
        return
    end
    if not self.doubleFubenList[vName] then
        self.doubleFubenList[vName] = {}
    end
    self.doubleFubenList[vName][param.moduleId] = param
    self:setFubenDouble(param)
end

function GuiMgr:setFubenDouble(data)
    if cache.ActivityCache:get5030168(data.moduleId) then
        data.obj.visible = true
    else
        data.obj.visible = false
    end
end
--刷新双倍副本
function GuiMgr:refreshDoubleFuben()
    for vName,modules in pairs(self.doubleFubenList) do
        if mgr.ViewMgr:get(vName) then
            for k,v in pairs(modules) do
                self:setFubenDouble(v)
            end
        end
    end
end

return GuiMgr