--
-- Author: ohf
-- Date: 2017-02-22 16:17:05
--
--剑神系统
local AwakenView = class("AwakenView", base.BaseView)

local AwakenPanel = import(".AwakenPanel")--剑神区域

local AdvancedPanel = import(".AdvancedPanel")--进阶区域

local EquipAwakenpanel = import(".EquipAwakenpanel")--剑神装备

local SuitPanel = import(".SuitPanel")--套装 

local JianLing = import(".JianLing")--剑灵  

local ShengYinPanel = import(".ShengYinPanel")--圣印

local ShengZhuangPanel = import(".ShengZhuangPanel")--圣裝
local EightGatesPanel = import(".EightGatesPanel")--八门元素


function AwakenView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.openTween = ViewOpenTween.scale
end

function AwakenView:initData(data)
    if self.awakenPanel then
        self.awakenPanel:clear()
    end
    -- if self.EquipAwakenpanel then
    --     self.EquipAwakenpanel.model = nil 
    -- end

    GSetMoneyPanel(self.window2,self:viewName())
    --剑神红点
    local param = {panel = self.redPoint,text = self.redText, ids = {attConst.A10218},notnumber = true}
    mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())
    --套装红点
    
    --local param = {panel = self.redPoint_taozhuang, ids = {attConst.A10248},notnumber = true}
    --mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())
    
    self.signIcon.visible = self:checkBuy()

    local index =  data and data.index or 0 --默认选中哪个
    if index == self.c1.selectedIndex then
        self:onController1()
    else
        self.c1.selectedIndex = index
    end
    --避免断引导
    self.super.initData()
    self:refreshRed()
    if data and data.suitId then
        self.suitId = data.suitId--bxp时装升星跳转
      
    end
end

function AwakenView:refreshRed()
    -- body
    if not mgr.ModuleMgr:CheckView({id =1272} ) then
        self.redjianling.visible = false
    else
        self.redjianling.visible = G_RedWuXingQianghua()>0
        if self.c1.selectedIndex == 3 then
            if self.JianLing then
                self.JianLing:refreshRed()
            end
        end
    end 
    if not mgr.ModuleMgr:CheckView({id =1349} ) then
        self.redShengYin.visible = false
    else
        -- print("圣魂",GGetShengHunRed(),"强化",GGetSYstrengRed(),"高阶",GStrongShengYinRedNum(),"穿戴",GCanPutShengYin())
        self.redShengYin.visible = (GGetShengHunRed() + GGetSYstrengRed() + GStrongShengYinRedNum()+GCanPutShengYin()) > 0
        if self.c1.selectedIndex == 4 then
            if self.ShengYinPanel then
                self.ShengYinPanel:refreshRed()
            end
        end
    end 
    if not mgr.ModuleMgr:CheckView({id =1360} ) then --判定圣装模块红点
        self.redShengZhuang.visible = false
    else
        self.redShengZhuang.visible = G_isJSRed()>0
        -- self.redShengZhuang.visible =  > 0
        -- if self.c1.selectedIndex == 5 then
        --     if self.ShengZhuangPanel then
        --         self.ShengZhuangPanel:refreshRed()
        --     end
        -- end
    end 
    if not mgr.ModuleMgr:CheckView({id =1398} ) then
        self.redBM.visible = false
    else
        self.redBM.visible = GGetBMRed() > 0
        if self.c1.selectedIndex == 6 then
            if self.eightGatesPanel then
                self.eightGatesPanel:refreshRed()
            end
        end
    end 
end


function AwakenView:initView()
    self.window2 = self.view:GetChild("n0")

    local closeBtn = self.window2:GetChild("btn_close")
    closeBtn.onClick:Add(self.onClickClose,self)

    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController1,self)

    local btn = self.view:GetChild("n1")
    self.redPoint = btn:GetChild("n4")
    self.redText = btn:GetChild("n5")

    self.redjianling = self.view:GetChild("n15"):GetChild("n4")
    
    self.redShengYin = self.view:GetChild("n17"):GetChild("n4")

    self.redShengZhuang = self.view:GetChild("n18"):GetChild("n4")

    self.redBM = self.view:GetChild("n22"):GetChild("n4")

    local btn2 = self.view:GetChild("n6")
    btn2.visible = false
    btn2.title = language.awaken29

    local btn3 = self.view:GetChild("n7")
    btn3.title = language.awaken30
    btn3.visible = false
    self.redPoint_taozhuang = btn3:GetChild("n4")

    self.signIcon = self.view:GetChild("n5")
    self.signIcon.visible = false
end

function AwakenView:clear()
    -- body
    self.view:GetChild("n2").visible = false--形象区域
    self.view:GetChild("n3").visible = false--属性区域
    self.view:GetChild("n4").visible = false
end

function AwakenView:onController1()
    -- body
    if self.c1.selectedIndex == 3 then
        --检测是否开启
        if not mgr.ModuleMgr:CheckView({id =1272,falg = true} ) then

            self.c1.selectedIndex = 0
            return
        end
    end
    if self.c1.selectedIndex == 6 then
        --检测是否开启
        if not mgr.ModuleMgr:CheckView({id =1398,falg = true} ) then

            self.c1.selectedIndex = 0
            return
        end
    end
    if self.c1.selectedIndex == 4 then
        --检测是否开启
        if not mgr.ModuleMgr:CheckView({id =1349,falg = true} ) then

            self.c1.selectedIndex = 0
            return
        end
    end
    if self.c1.selectedIndex == 5 then
        --检测是否开启
        if not mgr.ModuleMgr:CheckView({id =1360,falg = true} ) then

            self.c1.selectedIndex = 0
            return
        end
    end

    if self.c1.selectedIndex == 0 then
        --剑神
        if not self.awakenPanel then
            self.awakenPanel = AwakenPanel.new(self)--剑神区域
        end
        self.awakenPanel:setVisible(true)

        if not self.advancedPanel then
            self.advancedPanel = AdvancedPanel.new(self)--进阶区域
        end
        self.advancedPanel:setVisible(false)
        --请求剑神信息
        proxy.AwakenProxy:send(1190101,{reqType = 1})
    elseif self.c1.selectedIndex == 1 then
        self:clear()
        --装备
        if not self.EquipAwakenpanel  then
            self.EquipAwakenpanel = EquipAwakenpanel.new(self)
        end
        self.EquipAwakenpanel:clear()
        self.EquipAwakenpanel:initModel()
        self.EquipAwakenpanel:setData()
    elseif self.c1.selectedIndex == 2 then
        --套装
        self:clear()
        if not self.SuitPanel then
            self.SuitPanel = SuitPanel.new(self)
        end
        self.SuitPanel:initModel()
        proxy.ForgingProxy:send(1100108,{roleId = 0,srvId = 0,reqType = 3})
    elseif self.c1.selectedIndex == 3 then
        --剑灵
        if self.awakenPanel then
            self.awakenPanel:onClickReturn()
        end
        self:clear()
        if not self.JianLing then
            self.JianLing = JianLing.new(self)
        end
        self.JianLing:setData()
        local param = {}
        param.part = 0
        param.roleId =  cache.PlayerCache:getRoleId()
        param.svrId =  cache.PlayerCache:getServerId()
       --printt(param)
        proxy.AwakenProxy:send(1530101,param)
    elseif self.c1.selectedIndex == 4 then--圣印
        self:clear()
        if not self.shengYinPanel then
            self.shengYinPanel = ShengYinPanel.new(self)
        end
        proxy.AwakenProxy:send(1600102)
        self.shengYinPanel:setData()
    elseif self.c1.selectedIndex == 5 then --圣裝
        self:clear()
        if not self.shengZhuangPanel then
            self.shengZhuangPanel = ShengZhuangPanel.new(self)
             proxy.AwakenProxy:send(1190203)
        end
        self.shengZhuangPanel:setData()
    elseif self.c1.selectedIndex == 6 then--八门元素
        self:clear()
        if not self.eightGatesPanel then
            self.eightGatesPanel = EightGatesPanel.new(self)
        end
        proxy.AwakenProxy:send(1610103)
        -- self.eightGatesPanel:setData()
    end
end

function AwakenView:addMsgCallBack(data,param)
    -- body
    if data.msgId == 5040403 or data.msgId == 5190201 or data.msgId == 8230801 or data.msgId == 5190203 then
        if self.c1.selectedIndex == 1 then
            if self.EquipAwakenpanel then
                self.EquipAwakenpanel:addMsgCallBack(data)
            end
        end
        if  self.c1.selectedIndex == 5  then
            if self.shengZhuangPanel then
                self.shengZhuangPanel:addMsgCallBack(data)
            end
        end
    elseif data.msgId == 5100108 or data.msgId == 5100107 then
        if self.c1.selectedIndex == 2 then
            if self.SuitPanel then
                self.SuitPanel:addMsgCallBack(data)
            end
        end
    elseif data.msgId == 5190102 then
        if self.awakenPanel then
            self.awakenPanel:updateSkins(data)
        end
        if self.shengZhuangPanel then
            self.shengZhuangPanel:addMsgCallBack(data)
        end
    elseif data.msgId == 5530101 or data.msgId == 5530102 or data.msgId == 5530103
    or 5100109 ==  data.msgId then
        if self.c1.selectedIndex == 3 then
            if self.JianLing then
                self.JianLing:addMsgCallBack(data,param)
            end
        end
    elseif data.msgId == 5600102 or data.msgId == 5600101 or data.msgId == 5600104 or data.msgId == 8230702 then--圣印
        if self.c1.selectedIndex == 4 then
            if self.shengYinPanel then
                self.shengYinPanel:addMsgCallBack(data)
            end
        end
    elseif data.msgId == 5610103 or data.msgId == 5610101 or data.msgId == 5610102 or data.msgId == 5610104 then--八门元素
        if self.c1.selectedIndex == 6 then
            if self.eightGatesPanel then
                self.eightGatesPanel:addMsgCallBack(data)
            end
        end
    end
end

function AwakenView:setChildIndex(index)
    self.childIndex = index
end

function AwakenView:refAttiData()
    if self.awakenPanel then
        self.awakenPanel:skinsAttiData()
    end
end

function AwakenView:setData(data)
    if self.c1.selectedIndex ~= 0 then
        return
    end
    self.mData = data
    self.awakenPanel:setData(data)

    -- self.advancedPanel:setData(data)
    local jsLevel = data and data.jsLevel or 0
    local confData = conf.AwakenConf:getJsAttr(jsLevel)
    local jie = confData and confData.starlv or 0
    if self.childIndex and jsLevel > 0 and jie < conf.AwakenConf:getEndMaxJie() then
        self.awakenPanel:setVisible(false)
    end
    self.childIndex = nil
    --bxp升星跳转
    if self.suitId then
        self:goSuitStar()
    end
end

function AwakenView:checkBuy()
    -- body
    return self:checkTehui() or self:checkBaiBei()
end

function AwakenView:checkTehui()
    -- body
    if true then
        --屏蔽特惠抢购 20180301
        return false
    end
    local data = cache.ActivityCache:get5030111()
    if not data then
        return false
    end
    local condata = conf.SysConf:getHwbSBItem("jiansheng0")
    if not condata then
        return false
    end
    local curday = data.openDay % 9
    if condata.open_day and curday  ~= condata.open_day then--有天数 要求
        return false
    end
    --没有购买要求
    if not condata.buy_id then
        return false
    end
    local _in = clone(condata.buy_id)
    if not condata.open_day then
        _in = {condata.buy_id[curday] or condata.buy_id[9]}
    end
    --检测是否购买了要求物品
    local key = g_var.accountId.."1026buy"
    local _localbuy = UPlayerPrefs.GetString(key)
    if _localbuy~="" then
        local _t = json.decode(_localbuy)
        local pairs = pairs

        local falg = false 
        for k,v in pairs(_in) do
            local innnerbuy = false--当前物品是否买过
            for i , j in pairs(_t) do
                if tonumber(j) == tonumber(v) then
                    innnerbuy = true 
                    break
                end
            end
            if not innnerbuy then --有个需求物品没有买
                falg = true
                break
            end
        end
        return falg
    else
        return true
    end
end

function AwakenView:checkBaiBei()
    -- body
    if true then
        --屏蔽特惠抢购 20180301
        return false
    end
    if cache.PlayerCache:getRedPointById(attConst.A30111)<=0 then
        return false
    end
    local data = cache.ActivityCache:get5030111()
    if not data then
        return false
    end

    local condata = conf.SysConf:getHwbSBItem("jiansheng0")
    if not condata then
        return false
    end
    local curday = data.openDay % 9
    if condata.open_day and curday  ~= condata.open_day then--有天数 要求
        return false
    end
    
    --没有购买要求
    if not condata.buy_danci then
        return false
    end
    local _in = clone(condata.buy_danci)
    if not condata.open_day then
        _in = {condata.buy_danci[curday] or condata.buy_danci[9]}
    end
    --printt(_in)
    --检测是否购买了要求物品
    local key = g_var.accountId.."3010buy"
    local _localbuy = UPlayerPrefs.GetString(key)
    if _localbuy~="" then
        local _t = json.decode(_localbuy)
        local pairs = pairs

        local falg = false 
        for k,v in pairs(_in) do
            local innnerbuy = false--当前物品是否买过
            for i , j in pairs(_t) do
                if tonumber(j) == tonumber(v) then
                    innnerbuy = true 
                    break
                end
            end
            if not innnerbuy then --有个需求物品没有买
                falg = true
                break
            end
        end
        return falg
    else
        return true
    end
end

function AwakenView:getData()
    return self.mData
end

function AwakenView:getAwakenPanel()
    return self.awakenPanel
end

function AwakenView:getAdvancedPanel()
    return self.advancedPanel
end
--跳转到对应的升星界面bxp
function AwakenView:goSuitStar()
    if self.suitId and self.awakenPanel then
        self.awakenPanel:setArrPanel()
        self.awakenPanel:selectModel(self.suitId)
    end
end

function AwakenView:closeView()
    -- if self.advancedPanel and self.awakenPanel then
    --     if self.advancedPanel:getVisible() then
    --         self.advancedPanel:setVisible(false)
    --         self.awakenPanel:setVisible(true)
    --     else
            
    --     end
    --     self.advancedPanel:clear()
    -- end
    if self.suitId then--如果是从使用时装跳转进升星界面的bxp
        self.suitId = nil
    end
    self.super.closeView(self)
end

function AwakenView:doClearView(clear)
    cache.GuideCache:setIsJsguide(false)
end

function AwakenView:onClickClose()
    if self.suitId then--如果是从使用时装跳转进升星界面的bxp
        self.suitId = nil
    end
    self:closeView()
end

return AwakenView