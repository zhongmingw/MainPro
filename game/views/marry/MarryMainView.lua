--
-- Author: 
-- Date: 2017-07-19 16:02:34
--
local MarryFuben = import(".MarryFuben")--组队副本
local MarryXinDong = import(".MarryXinDong")--心动
local MarryQingYuan = import(".MarryQingYuan")--情缘
local MarryShop = import(".MarryShop")--情缘商店
local MarryMsg = import(".MarryMsg")--夫妻信息
local MarriageTree = import(".MarriageTree")--姻缘树
local PetXianTong = import(".PetXianTong")--有仙童
local ZeroXianTong = import(".ZeroXianTong")--无仙童
local HunJiePanel = import(".HunJiePanel")--婚戒
local HunJieUp = import(".HunJieUp")--婚戒
local XianWaZhuZhan = import(".XianWaZhuZhan")--仙娃助战
local MarryMainView = class("MarryMainView", base.BaseView)
--  心动（结婚后隐藏）->结婚->心相印-姻缘树->过情关->洞房->仙童->婚戒->爱情盒
local list = {
    1098,
    1102,
    1100,
    1112,
    1099,
    1310,
    1304,
    1402,
    1313,
    1101,
}

local open = {
    [1096] = 0,--引导心动 
    [1098] = 1,--心动
    [1099] = 2,--副本
    [1100] = 3,--情缘
    [1101] = 4,--商店
    [1102] = 5,--夫妻信息
    [1112] = 6,--姻缘树
    [1304] = 7,--仙童
    [1310] = 8,--生育
    [1313] = 9,--婚戒
    [1402] = 10,--仙娃助战
}
function MarryMainView:ctor()
    self.super.ctor(self)
    self.drawcall = false
    self.uiLevel = UILevel.level2 
    self.openTween = ViewOpenTween.scale
end

function MarryMainView:initData(data)
    -- body
    self.lastId = nil 
    
    self.index = data and data.index and data.index or 1
    self.hunjieup = data.childIndex
    if not self.index or self.index == 1 then
        if cache.PlayerCache:getCoupleName() == "" then
            self.index = 1
        else
            self.index = 5
        end
    end
    if self.PetXianTong and self.PetXianTong.model then
        self.PetXianTong.model = nil
    end


    GSetMoneyPanel(self.window2,self:viewName())
    self:checkOpen()
end

function MarryMainView:initView()
    self.window2 = self.view:GetChild("n0")
    self.bg = self.window2:GetChild("n54")
    self.bg2 = self.window2:GetChild("n56")
    self.listView = self.view:GetChild("n1")
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
    self.listView.onClickItem:Add(self.onItemCall,self)

    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController1,self)

    local btnClose = self.view:GetChild("n0"):GetChild("btn_close")
    btnClose.onClick:Add(self.onBtnClose,self)

    local btn1 = self.view:GetChild("n16")
    btn1.onClick:Add(self.onBtnCallBack,self)
    local btn2 = self.view:GetChild("n17")
    btn2.onClick:Add(self.onBtnCallBack,self)
end

function MarryMainView:onBtnCallBack( context)
    -- body
    if self.listView.numItems == 0 then
        return
    end
    local btn = context.sender
    if "n16" == btn.name then
        self.listView:ScrollToView(0)
    elseif "n17" == btn.name then
        self.listView:ScrollToView(self.listView.numItems-1)
    end
end

function MarryMainView:checkOpen()
    -- body

    if cache.GuideCache:getMarry() then
        cache.GuideCache:setMarry(nil)
        self.openlist = {}
        table.insert(self.openlist,1096)
        self.listView.numItems = 1
        --加一个特效 --花瓣
        mgr.ViewMgr:openView2(ViewName.Alert15, 4020127)
        --引导关闭
        mgr.TimerMgr:addTimer(1.0,1,function()
            -- body
            local data = conf.XinShouConf:getOpenModule(1120)
            self:startGuide(data)
        end)
        self.c1.selectedIndex = 0
        self:onController1()
    else
        self.openlist = {}
        if cache.PlayerCache:getCoupleName()=="" then
            for k ,v in pairs(list) do
                if v ~= 1096 then
                    if (v == 1402 and mgr.ModuleMgr:CheckSeeView(v)) or v ~= 1402 then
                        table.insert(self.openlist,v)
                    end
                end
            end
        else
            for k ,v in pairs(list) do
                if v ~= 1096 and v ~= 1098 then
                    if (v == 1402 and mgr.ModuleMgr:CheckSeeView(v)) or v ~= 1402 then
                        table.insert(self.openlist,v)
                    end
                end
            end
        end

        self.listView.numItems = #self.openlist
        --默认选择一个
        for k ,v in pairs(self.openlist) do
            if open[tonumber(v)] == self.index then
                self.listView:AddSelection(k-1,false)
                self.c1.selectedIndex = self.index
                self:onController1()
                break
            end
        end
    end
end

function MarryMainView:celldata(index,obj)
    -- body
    local data = self.openlist[index+1]
    local title = obj:GetChild("title")
    title.text = language.kuafu63[open[tonumber(data)]]
    obj.data = data
    local redImg = obj:GetChild("n4")
    local param = {}
    if tonumber(data)  == 1100 then
        param = {panel = redImg,ids = {10244}}
    elseif tonumber(data)  == 1112 then
        param = {panel = redImg,ids = {attConst.A10247}}
    elseif tonumber(data)  == 1304 then
        param = {panel = redImg,ids = {10263}}
    elseif tonumber(data)  == 1313 then
        param = {panel = redImg,ids = {10264}}
    end
    if param.ids then
        mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())
    end
end

function MarryMainView:onController1()
    if self.c1.selectedIndex ~= 7 then
        self.lastId = self.c1.selectedIndex
    end

    self.bg.url = ""
    self.bg2.url = ""
    if self.c1.selectedIndex == 0 then
        --mgr.ViewMgr:openView2(ViewName.Alert15, 4020127)

        if not self.MarryXinDong then
            self.MarryXinDong = MarryXinDong.new(self)
        end
        self.MarryXinDong:setData(0)

    elseif 1 == self.c1.selectedIndex then
        if not self.MarryXinDong then
            self.MarryXinDong = MarryXinDong.new(self)
        end
        self.MarryXinDong:setData(1)
    elseif 2 == self.c1.selectedIndex then
        if not self.marryFuben then
            self.marryFuben = MarryFuben.new(self)
        end
        --请求情缘副本信息
        self.bg.url = UIItemRes.marrybg
        proxy.MarryProxy:sendMsg(1027101)
    elseif 3 == self.c1.selectedIndex then
        if not self.MarryQingYuan then
            self.MarryQingYuan = MarryQingYuan.new(self)
        end
        -- 请求姻缘信息
        proxy.MarryProxy:sendMsg(1390201)
    elseif 4 == self.c1.selectedIndex then 
        if not self.MarryShop then
            self.MarryShop = MarryShop.new(self)
        end
        --请求爱情盒购买信息
        proxy.MarryProxy:sendMsg(1390106,{reqType = 1 ,itemId = 0 })
    elseif 5 == self.c1.selectedIndex then
        if not self.MarryMsg then
            self.MarryMsg = MarryMsg.new(self)
        end 
        local confData = conf.SysConf:getLoadingConfById(2)
        self.bg2.url = UIItemRes.loading01..confData.loadimg
        -- 请求姻缘信息
        self.MarryMsg:initName()
        proxy.MarryProxy:sendMsg(1390201)
    elseif 6 == self.c1.selectedIndex then
        if not self.marriageTree then
            self.marriageTree = MarriageTree.new(self)
        end
        self.bg.url = UIItemRes.marryTreeBg
        proxy.MarryProxy:sendMsg(1390204,{reqType = 0})
    elseif 7 == self.c1.selectedIndex then
        --仙童
        if not self.PetXianTong then
           self.PetXianTong = PetXianTong.new(self)
        end
        self.PetXianTong:setVisible(false)
        proxy.MarryProxy:sendMsg(1390601)
    elseif 8 == self.c1.selectedIndex then
        self.bg.url = UIItemRes.marryxiantong
        if not self.ZeroXianTong then
            self.ZeroXianTong = ZeroXianTong.new(self)
        end
        self.ZeroXianTong:setVisible(true)
        self.ZeroXianTong:setData()
    elseif 9 == self.c1.selectedIndex then
        if not self.HunJiePanel then
            self.HunJiePanel = HunJiePanel.new(self)
        end
        if not self.HunJieUp then
            self.HunJieUp = HunJieUp.new(self)
        end
        self.HunJiePanel:setVisible(true)
        self.HunJieUp:setVisible(false)
        -- 请求姻缘信息
        proxy.MarryProxy:sendMsg(1390201)
    elseif 10 == self.c1.selectedIndex then--仙娃助战
        if not self.XianWaZhuZhan then
            self.XianWaZhuZhan = XianWaZhuZhan.new(self)
        end
        print("请求仙童助战信息")
        proxy.MarryProxy:sendMsg(1390610,{reqType = 0})
    end
end
--刷新姻缘树种子红点
function MarryMainView:refreshTreeRed()
    if self.marriageTree then
        self.marriageTree:refreshRed()
    end
end

function MarryMainView:onItemCall(context)
    -- body
    local cell = context.data
    local data = cell.data
    self.c1.selectedIndex = open[tonumber(data)]
end

function MarryMainView:goToById(id)
    -- body
    --默认选择一个
    for k ,v in pairs(self.openlist) do
        if tonumber(v) == id then
            self.listView:AddSelection(k-1,false)
            self.c1.selectedIndex = open[v]
            self:onController1()
            break
        end
    end
end
function MarryMainView:goToByC1(id)
    -- body
    --默认选择一个
    for k ,v in pairs(self.openlist) do
        if open[v] == id then
            self.listView:AddSelection(k-1,false)
            self.c1.selectedIndex = open[v]
            self:onController1()
            break
        end
    end
end

function MarryMainView:setData(data_)

end

function MarryMainView:onBtnClose()
    if self.marryFuben then
        self.marryFuben:clear()
    end
    if self.marriageTree then
        self.marriageTree:clear()
    end
    

    if self.c1.selectedIndex == 0 then
        GgoToMainTask()
    end

    self:closeView()
end

function MarryMainView:addMsgCallBack(data)
    -- body
    --printt(self.c1.selectedIndex,data)
    if self.marryFuben then
        self.marryFuben:clear()
    end
    if self.c1.selectedIndex == 0 then
        
    elseif self.c1.selectedIndex == 1 then
        if self.MarryXinDong then
            self.MarryXinDong:addMsgCallBack(data)
        end
    elseif self.c1.selectedIndex == 2 then
        if not self.marryFuben then
            return
        end
        self.marryFuben:addMsgCallBack(data)
    elseif self.c1.selectedIndex == 3 then
        if self.MarryQingYuan then
            self.MarryQingYuan:addMsgCallBack(data)
        end
    elseif self.c1.selectedIndex == 4 then
        if self.MarryShop then
            self.MarryShop:addMsgCallBack(data)
        end
    elseif self.c1.selectedIndex == 5 then
        if self.MarryMsg then
            self.MarryMsg:addMsgCallBack(data)
        end
    elseif self.c1.selectedIndex == 6 then
        if self.marriageTree then
            self.marriageTree:addMsgCallBack(data)
        end
    elseif self.c1.selectedIndex == 7 then
        if self.PetXianTong then
            self.PetXianTong:addMsgCallBack(data)
        end
    elseif self.c1.selectedIndex == 9 then
        if self.HunJiePanel then
            self.HunJiePanel:addMsgCallBack(data)
        end
        if self.HunJieUp then
            self.HunJieUp:addMsgCallBack(data)
        end
        if self.hunjieup then
            --别的地方跳转的时候是否进入到升阶界面
            self.hunjieup = nil 
            self:goToUPpanel()
        end
    elseif self.c1.selectedIndex == 10 then
        if self.XianWaZhuZhan then
            self.XianWaZhuZhan:addMsgCallBack(data)
        end
    end
end

function MarryMainView:goToUPpanel()
    -- body
    if self.c1.selectedIndex == 9 then
        if self.HunJieUp then
            --判定当前是否有下一阶段
            if cache.MarryCache:getIsNext() then
                self.HunJieUp:setVisible(true)
               

                if self.HunJiePanel then
                    self.HunJiePanel:setVisible(false)
                end
            end
        end
    end
end

function MarryMainView:BackTo()
    -- body
    if self.c1.selectedIndex == 9 then
        if self.HunJiePanel then
            self.HunJiePanel:setVisible(true)
        end
        if self.HunJieUp then
            self.HunJieUp:setVisible(false)
        end
    end
end

return MarryMainView