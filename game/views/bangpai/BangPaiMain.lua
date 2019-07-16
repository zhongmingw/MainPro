--
-- Author: 
-- Date: 2017-03-03 16:53:53
--
local PanelMsg = import(".PanelMsg") --帮派信息
local PanelSkill = import(".PanelSkill") --帮派技能
local PanelBag = import(".PanelBag") --仓库
local PanelBox = import(".PanelBox") --宝箱
local PanelFuben = import(".PanelFuben")--副本
local PanelBangPaiList = import(".PanelBangPaiList") --列表
local PanelFlame = import(".PanelFlame")--EVE 圣火
local PanelActivity = import(".PanelActivity")--仙盟活动
local PanelKeJi = import(".PanelKeJi")--仙盟科技

local BangPaiMain = class("BangPaiMain", base.BaseView)
--仙盟活动的id可以用里面随便一个模块的id（类似顶部按钮）
local opent = {
    1013,--信息
    1225,--仙盟科技
    1014,--技能
    1015,--仓库
    1016,--宗门宝箱 已屏蔽
    1017,--宗门秘境 
    1018,--宗门列表
    1127,--宗门圣火
    1139,--宗门争霸
    
} --EVE 1019圣火(客户端自定义)

local open_controller = {
    [1013] = 0,--信息
    [1014] = 1,--技能
    [1015] = 2,--仓库
    [1016] = 3,--宗门宝箱
    [1017] = 4,--宗门秘境
    [1018] = 5,--宗门列表
    [1127] = 7,--宗门圣火(帮派界面)
    [1139] = 7,--宗门争霸
    [1225] = 8,--仙盟科技
}

local controller_open = {
    [0] = 1013,--信息
    [1] = 1014,--技能
    [2] = 1015,--仓库
    [3] = 1016,--宗门宝箱
    [4] = 1017,--宗门秘境
    [5] = 1018,--宗门列表
    [6] = 1127,--宗门圣火(帮派界面)
    [7] = 1139,--宗门争霸
    [8] = 1225,--仙盟科技
}

function BangPaiMain:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2 
    self.drawcall = false
    self.openTween = ViewOpenTween.scale
end

function BangPaiMain:initData(data)
    -- body
    if self.PanelMsg and self.PanelMsg.ItemMsg and self.PanelMsg.ItemMsg.model then
        self.PanelMsg.ItemMsg.model = nil 
    end 
    --货币管理
    local window2 = self.view:GetChild("n0")
    GSetMoneyPanel(window2,self:viewName())

    local closeBtn = window2:GetChild("btn_close")
    closeBtn.onClick:Add(self.onClickClose,self)

    --4/20 把按钮拓展成列表
    self.index = open_controller[data.index or 1013]


    self.childIndex = data.childIndex
    self:initleftList()
    --print("帮派跳转index",self.index)
    self:goPageView(self.index) 
    
    -- self:setRedPoint()
    -- --按钮控制
    -- self:initBtn()


    -- self.index = data.index or 0
    -- self.childIndex = data.childIndex
    -- if self.c1.selectedIndex ~= self.index then
    --     self.c1.selectedIndex = self.index
    -- else
    --     self:onbtnController()
    -- end
    self:addTimer(1, -1,handler(self,self.onTimer))

    self.super.initData()

    if self.PanelFlame then 
        self.PanelFlame:initData()
    end
    if self.PanelFuben then 
        self.PanelFuben:initData()
    end
end

-- function BangPaiMain:initBtn()
--     -- body
--     local index = 1
--     for k ,v in pairs(opent) do
--         if v == 1016 or v == 1127 then --宝箱
--             self.listbtn[k].visible = false
--         else
--             self.listbtn[k].visible = true
--             self.listbtn[k].xy = self.listpos[index]
--             index = index + 1
--         end
--     end
-- end

-- function BangPaiMain:setRedPoint()
--     -- body
--     --红点注册
--     --圣火红点@呼叫钟铭
--     if not g_is_banshu then
--         for i = 9 , 16 do
--             local btn = self.view:GetChild("n"..i)
--             --注册红点
--             if i == 12 or i == 10 or i == 9 or i ==13 or i == 15 or i == 16 then 
--                 local redImg = btn:GetChild("n4")
--                 local param = {}--{panel = redImg,ids = {t[i-9]}}
--                 param.panel = redImg
--                 if i == 9 then
--                     param.ids = {10221,10313}
--                 elseif i == 10 then
--                     param.ids = {10222}
--                 elseif i == 12 then 
--                     param.ids = {10223}
--                     -- local temp = os.date("*t", mgr.NetMgr:getServerTime())
--                     -- if temp.hour>= 10 then
--                     --     param.ids = {10223}
--                     -- end
--                 elseif i == 13 then
--                     param.ids = {50108,50110,50112}
--                 elseif i == 15 then
--                     -- param.ids = {20150,10251}
--                 elseif i == 16 then--仙盟活动
--                     param.ids = {attConst.A20133,attConst.A20154,20150,10251}
--                     --print("仙盟活动红点刷新")
--                 end
--                 mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())
--             end
--         end
--     else
--         --屏蔽宝箱 和副本、仙盟圣火
--         local btn = self.view:GetChild("n12")
--         btn:SetScale(0,0)
--         local btn = self.view:GetChild("n13")
--         btn:SetScale(0,0)
--         local btn = self.view:GetChild("n15")
--         btn:SetScale(0,0)        
--     end
-- end

function BangPaiMain:addComponent(v)
    -- body
    if open_controller[v] then
        local var = UIPackage.GetItemURL("_components" , "Radiogoonggong_025")
        local _compent1 = self.listview:AddItemFromPool(var)
        _compent1.title = language.bangpai18[open_controller[v]+1] or ""
        _compent1.data = open_controller[v]

        --print(" open_controller[v]", open_controller[v])

        --_compent1.onClick:Clear()
        --_compent1.onClick:Add(self.onItemaCall,self)

        local redImg = _compent1:GetChild("n4")
        local param = {}
        param.panel = redImg
        --红点注册
        if v == 1013 then
            param.ids = {10221,10313}
        elseif v == 1014 then
            param.ids = {10222}
        elseif v == 1017 then 
            param.ids = {50108,50110,50112}
        elseif v == 1139 then
            param.ids = {attConst.A20133,attConst.A20154,20150,10251,attConst.A50133}
        elseif v == 1225 then 
            param.ids = {attConst.A30141}
        elseif v == 1127 or v == 1139 then
            param.ids = {10251,20150,attConst.A20133,attConst.A20154}
        end
        if param.ids then
            mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())
        end
    else
        print("代码缺少 open_controller ",v)
    end
end

function BangPaiMain:initleftList()
    -- body
    --清理列表
    self.listview.numItems = 0
    self.list_c = {}
    local index = 1
    for k ,v in pairs(opent) do
        if v == 1016 or v == 1127 then --屏蔽功能
        else
            --添加对应的选项
            self:addComponent(v)
            self.list_c[v] = index
            index = index + 1
        end
    end
end

function BangPaiMain:goPageView(index)
    -- body
    local _index = self.list_c[controller_open[index]] 
    --print("跳转index",index,_index)
    local cell = self.listview:GetChildAt(_index - 1 )
    if cell then
        cell.selected = true
        cell.onClick:Call()
    end
end

function BangPaiMain:onItemaCall(context)
    -- body
    local data = context.data.data
    if data then
        local t = controller_open

        --print("self.c1.selectedIndex",t[self.c1.selectedIndex])
        if data == 4 then
            local var = cache.BangPaiCache:getBangLev() 
            local condata =  conf.SceneConf:getSceneById(Fuben.gang)
            local ganglv = condata and (condata.gang_lvl or 0) or 0
            if var and var < ganglv then
                GComAlter(string.format(language.bangpai138,ganglv))
                --self.c1.selectedIndex = self.oldselect or 0
                self:goPageView(self.oldselect or 0)
                return
            end
        elseif  not GCheckView({id = t[data],falg = true }) then
            --self.c1.selectedIndex = self.oldselect or 0
            --print("self.oldselect",self.oldselect)
            self:goPageView(self.oldselect or 0)
            return
        end
        self.oldselect = data

        --print(data,"data")

        if self.c1.selectedIndex ~= data then
            self.c1.selectedIndex = data
        else
            self:onbtnController()
        end
    end
end

function BangPaiMain:initView()
    self.listview = self.view:GetChild("n35")
    self.listview.onClickItem:Add(self.onItemaCall,self)


    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onbtnController,self)

    -- self.listbtn = {}
    -- self.listpos = {}
    -- for i = 9 , 16 do
    --     local btn = self.view:GetChild("n"..i)
    --     table.insert(self.listpos,btn.xy)
    --     table.insert(self.listbtn,btn)
    -- end
    --self:initDec()
    ---
    self.oldselect = 0
end

function BangPaiMain:onTimer()
    -- body
    if self.c1.selectedIndex == 3 then
        if self.PanelBox then
            self.PanelBox:onTimer()
        end
    elseif self.c1.selectedIndex == 7 then
        if self.panelActivity then
            self.panelActivity:onTimer()
        end
    end
end

-- function BangPaiMain:initDec()
--     -- body
--     local index = 1
    
--     for k ,v in pairs(self.listbtn) do
--         v:GetChild("title").text = language.bangpai18[k]
--     end
-- end

function BangPaiMain:onbtnController()
    -- body
    -- local t = opent
    -- if self.c1.selectedIndex == 4 then
    --     local var = cache.BangPaiCache:getBangLev() 
    --     local condata =  conf.SceneConf:getSceneById(Fuben.gang)
    --     local ganglv = condata and (condata.gang_lvl or 0) or 0
    --     if var and var < ganglv then
    --         GComAlter(string.format(language.bangpai138,ganglv))
    --         self.c1.selectedIndex = self.oldselect or 0
    --         return
    --     end
    -- elseif  not GCheckView({id = t[self.c1.selectedIndex+1],falg = true }) then
    --     self.c1.selectedIndex = self.oldselect or 0
    --     return
    -- end
    -- self.oldselect = self.c1.selectedIndex
    self:resetSomeViewData(1)

    if self.c1.selectedIndex == 0 then
        proxy.BangPaiProxy:sendMsg(1250104)
        if not self.PanelMsg then
            self.PanelMsg = PanelMsg.new(self)
        end     
    elseif self.c1.selectedIndex == 1 then
        if not self.PanelSkill then
            self.PanelSkill = PanelSkill.new(self.view:GetChild("n18"))
        end
        proxy.BangPaiProxy:sendMsg(1250107,{reqType = 1,skillId = 0})
    elseif self.c1.selectedIndex == 2 then
        if not self.PanelBag then
            self.PanelBag = PanelBag.new(self.view:GetChild("n19"))
        end
        self.PanelBag:onbtnController2()
        proxy.BangPaiProxy:sendMsg(1250303)
    elseif self.c1.selectedIndex == 3 then
        if not self.PanelBox then
            self.PanelBox = PanelBox.new(self)
        end
        proxy.BangPaiProxy:sendMsg(1250307)
    elseif self.c1.selectedIndex == 4 then
        if not self.PanelFuben then
            self.PanelFuben = PanelFuben.new(self.view:GetChild("n30"))
        end
        proxy.FubenProxy:send(1024501)
    elseif self.c1.selectedIndex == 5 then
        if not self.PanelBangPaiList then
            self.PanelBangPaiList = PanelBangPaiList.new(self.view:GetChild("n20"))
        end
        self.PanelBangPaiList:setSelectC2(1)

        local param = {}
        param.gangName = ""
        param.page = 1
        proxy.BangPaiProxy:sendMsg(1250102, param)
    elseif self.c1.selectedIndex == 6 then  --EVE 圣火
        if not self.PanelFlame then
            self.PanelFlame = PanelFlame.new(self)
        end
        proxy.BangPaiProxy:send(1250502,{reqType=1})
    elseif self.c1.selectedIndex == 7 then--仙盟活动
        if not self.panelActivity then
            self.panelActivity = PanelActivity.new(self)
        end
        self.panelActivity:setData({index = self.childIndex})
        self.childIndex = nil
    elseif self.c1.selectedIndex == 8 then--仙盟科技
        if not self.panelKeJi then
            self.panelKeJi = PanelKeJi.new(self)
        end
        --请求个人科技信息
        proxy.BangPaiProxy:sendMsg(1250601,{reqType = 0,techType = 0})
    end
end

function BangPaiMain:setData(data_)
    self:onbtnController()
end

function BangPaiMain:onClickClose()
    -- body
    mgr.ItemMgr:setPackIndex(0)
    if self.PanelMsg and self.PanelMsg.ItemMsg then
        self.PanelMsg.ItemMsg.model = nil
    end
    self:resetSomeViewData(2)
    self:closeView()
end

function BangPaiMain:closeView()
    self.super.closeView(self)
end

--切换/关闭窗口时复位一些窗口的数据（1.切换的操作  2.关闭的操作）
function BangPaiMain:resetSomeViewData(value)
    -- body
    if value == 1 then
        if self.panelKeJi and self.c1.selectedIndex == 8 then 
            self.panelKeJi:reSetData()
        end 

        
    elseif value == 2 then 
        if self.panelKeJi then 
            self.panelKeJi:reSetData()
        end 
    end
end

function BangPaiMain:addMsgCallBack(data)
    -- body
    --plog(data.msgId,self.c1.selectedIndex)
    if self.c1.selectedIndex ~= 7 then
        if self.panelActivity then
            self.panelActivity:clear()
        end
    end
    if 5250104 == data.msgId and 0 == self.c1.selectedIndex then -- 请求帮派信息
        if self.PanelMsg then
            self.PanelMsg:setData()
        end

        if self.childIndex then
            self.PanelMsg:nextStep(self.childIndex)
            self.childIndex = nil 
        else
            --有限判定现在打开的是什么界面
            --local index = self.PanelMsg.c1.selectedIndex
            self.PanelMsg:nextStep(self.PanelMsg.c1.selectedIndex)
        end

        
    elseif 5250206 == data.msgId and 0 == self.c1.selectedIndex then -- 帮派公告修改
        if self.PanelMsg then
            self.PanelMsg:setData()
        end
    elseif 5250301 == data.msgId and 0 == self.c1.selectedIndex then -- 请求帮派签到
        GOpenAlert3(data.items)

        if self.PanelMsg then
            self.PanelMsg:add5250301(data)
        end
    elseif 5250103 == data.msgId and 0 == self.c1.selectedIndex then -- 请求帮派成员列表
        if self.PanelMsg then
            self.PanelMsg:add5250103(data)
        end
    elseif 5250203 == data.msgId and 0 == self.c1.selectedIndex then -- 请求逐出帮派
        if self.PanelMsg then
            self.PanelMsg:add5250103(data)
        end
    elseif 5250205 == data.msgId and 0 == self.c1.selectedIndex then --  请求禅让帮主
        if self.PanelMsg then
            self.PanelMsg:add5250103(data)
        end
    elseif 5250207 == data.msgId and 0 == self.c1.selectedIndex then --  请求设置位置
        if self.PanelMsg then
            self.PanelMsg:add5250103(data)
        end
    elseif 5250210 == data.msgId and 0 == self.c1.selectedIndex then --   请求弹劾帮主
        if self.PanelMsg then
            self.PanelMsg:add5250103(data)
        end
    elseif 5250302 == data.msgId and 0 == self.c1.selectedIndex then --    请求帮派商店
        if self.PanelMsg then
            self.PanelMsg:add5250302(data)
        end
    elseif 5250106 == data.msgId and 0 == self.c1.selectedIndex then --    帮派事件
        if self.PanelMsg then
            self.PanelMsg:add5250106(data)
        end
    elseif 5250108 == data.msgId and 0 == self.c1.selectedIndex then --     请求帮派周资金榜
        --plog("5250108",5250108,5250108)
        if self.PanelMsg then
            self.PanelMsg:add5250108(data)
        end
    elseif 5250107 == data.msgId and 1 == self.c1.selectedIndex then --     请求帮派技能
        if self.PanelSkill then
            self.PanelSkill:setData(data)
        end
    elseif 5250303 == data.msgId  and 2 == self.c1.selectedIndex then --请求帮派仓库    
        if self.PanelBag then
            self.PanelBag:setData(data,true)
        end
    elseif 5250304 == data.msgId  and 2 == self.c1.selectedIndex then -- 请求帮派仓库整理 
        if self.PanelBag then
            self.PanelBag:setData(data,true)
        end
    elseif 5250305 == data.msgId  and 2 == self.c1.selectedIndex then --  请求帮派仓库存取 
        if self.PanelBag then
            self.PanelBag:add5250305(data)
        end
    elseif 8030101 == data.msgId  and 2 == self.c1.selectedIndex then --  仓库
        if self.PanelBag then
            self.PanelBag:add8030101(data)
        end
    elseif  5040102 == data.msgId  and 2 == self.c1.selectedIndex then --  仓
        if self.PanelBag then
            self.PanelBag:add5040102(data)
        end
    elseif 5250102 == data.msgId  and 5 == self.c1.selectedIndex then --  帮会；列表
        if self.PanelBangPaiList then
            if not self.data then
                self.data = {}
            end
            self.data.page = data.page
            self.data.maxPage = data.maxPage
            self.data.gangName = data.gangName
            if self.data.page == 1 then
                self.data.gangList = data.gangList
            else
                for k ,v in pairs(data.gangList) do
                    table.insert(self.data.gangList,v)
                end
            end
            self.PanelBangPaiList:setData(self.data)
            if self.data.page == 1 then
                self.PanelBangPaiList:gotoTop()
                self.PanelBangPaiList:selectTop()
            end
        end
    elseif (5250307 == data.msgId or 5250309 ==data.msgId or 5250308==data.msgId
        or 5250310 == data.msgId)  
        and 3 == self.c1.selectedIndex then --   请求帮派宝箱列表
        if self.PanelBox then
            self.PanelBox:setData()
        end
    elseif 5250312 == data.msgId and 3 == self.c1.selectedIndex then --    请求协助帮派成员宝箱开启
        if self.PanelBox then
            self.PanelBox:add5250312(data)
        end
    elseif 5250314 == data.msgId and 3 == self.c1.selectedIndex then --     请求帮派宝箱协助记录
        if self.PanelBox then
            self.PanelBox:add5250314(data)
        end
    elseif 5250311 ==  data.msgId and 3 == self.c1.selectedIndex then --     请求帮派宝箱协助记录
        if self.PanelBox then
            self.PanelBox:add5250311(data)
        end
    elseif 5024501 == data.msgId and 4 == self.c1.selectedIndex then --      请求帮派副本显示
        if self.PanelFuben then
            self.PanelFuben:setData(data)
        end
    elseif 5024502 == data.msgId and 4 == self.c1.selectedIndex then --   请求帮派副本目标奖励领取
        if self.PanelFuben then
            self.PanelFuben:add5024502(data)
        end 
    elseif 5020204 == data.msgId and 0 == self.c1.selectedIndex then
        proxy.BangPaiProxy:sendMsg(1250104) --帮派改名重新请求帮派信息
    -- elseif 5250502 == data.msgId and 6 == self.c1.selectedIndex then --   EVE 请求仙盟BOSS信息返回
    --     if self.PanelFlame then
    --         self.PanelFlame:setData(data)
    --     end
    elseif 7 == self.c1.selectedIndex then--仙盟活动
        local msgIds = {[5360201] = 1,[5360202] = 2,[5360204] = 3,[5250502] = 3}
        if msgIds[data.msgId] and self.panelActivity then
            self.panelActivity:addMsgCallBack(data)
        end
    elseif 8 == self.c1.selectedIndex then--仙盟科技
        if 5250601 == data.msgId then
            if self.panelKeJi then
                self.panelKeJi:addMsgCallBack(data)
            end
        end
    end
end

function BangPaiMain:refreshActivity()
    if self.c1.selectedIndex == 7 then--仙盟活动
        self:onbtnController()
    end
end

function BangPaiMain:dispose(clear)
    if self.panelActivity then
        self.panelActivity:clear()
    end
    if g_var.gameFrameworkVersion >= 2 then
        UnityResMgr:ForceDelAssetBundle(UIItemRes.bangpai03)
        UnityResMgr:ForceDelAssetBundle(UIItemRes.bangpai04)
    end
    self.super.dispose(self, clear)
end

return BangPaiMain