--
-- Author: 
-- Date: 2017-01-04 16:23:50
--

local EquipPanel = import("game.views.pack.EquipPanel") --装备区域

local PropsPanel = import(".PropsPanel")

local PropsEquipPanel = import(".PropsEquipPanel")--装备道具界面

local EquipSuitPanel = import(".EquipSuitPanel")--套装区域

local TitlePanel = import(".TitlePanel")--称号区域

local FashionPanel = import(".FashionPanel")--时装区域

local AchievementPanel = import(".AchievementPanel") --成就

local ImmortalityPanel = import(".ImmortalityPanel") --修仙

local AureolePanel = import(".AureolePanel") --光环

local FeiSheng = import(".FeiSheng") --飞升属性区域

local JueSeMainView = class("JueSeMainView", base.BaseView)
local BtnNumber = 9

local openlist = {
    1069,--属性
    1325,--飞升
    1109,--套装
    1106,--称号
    1107,--时装
    1301,--光环
    1067,--修仙
    1222,--成就
    0,--装备
}

local _uilist = {
    1069,1325,1109,1106,1107,1067,1222,1301,0
}



function JueSeMainView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.openTween = ViewOpenTween.scale
end
function JueSeMainView:initData(data)
    -- body
    if not data.index then 
        data.index = 1
    elseif data.index > BtnNumber then 
        data.index = 1 
    end 
    if data.index == 2 then
        --装备模块已移除
        data.index = 1
    end
    --头饰特殊处理
    self.indexId = data.indexId or 0
    --检测开启
    local index = 1
    for k ,v in pairs(openlist) do
        if v == 1325 then
            if mgr.ModuleMgr:CheckSeeView({id = v }) then
                self.modulbtn[v].visible = true
                self.modulbtn[v].xy = self.btnpos[index]
                index = index + 1
            end
        else
            if v < 99 then
                self.modulbtn[v].visible = false
            else
                --print(v,index,self.btnpos[index],self.modulbtn[v].name)
                self.modulbtn[v].visible = true
                self.modulbtn[v].xy = self.btnpos[index]
                index = index + 1
            end
        end
    end


    if self.equipPanel then
       self.equipPanel:clear()
    end
    if self.EquipPanel1 then
       self.EquipPanel1.model = nil 
    end
    self.childIndex = data.childIndex
    self.grandson = data.grandson
    self:setData(data.notself)
    self.curSelect = data.index - 1
    self.controllerC1.selectedIndex = self.curSelect
    self:onbtnController()
    self:initRedPoint()

    
    GSetMoneyPanel(self.window2,self:viewName()) 
end


function JueSeMainView:initView()
    --
    self.window2 = self.view:GetChild("window2")
    local closeBtn = self.window2:GetChild("btn_close")
    closeBtn.onClick:Add(self.onClickClose,self)

    self.controllerC1 =  self.view:GetController("c1")
    self.controllerC1.onChanged:Add(self.onbtnController,self)

    self.btnList = {}
    self.btnpos = {}
    self.modulbtn = {}
    for i=1,9 do
        local num = 100 + i
        local btn = self.view:GetChild("n"..num)
        if i > 3 and (g_is_banshu or g_ios_test) then
            btn.visible = false
        end
        self.modulbtn[_uilist[i]] = btn 
        table.insert(self.btnList, btn)
        self.btnpos[i] = btn.xy
    end
    self.view:GetChild("n103").title = "时装\n套装"
    
    --星级属性面板按钮
    self.starAttrBtn = self.view:GetChild("n22")
    self.starAttrBtn.onClick:Add(self.onClickStarAtt,self)

    --EVE 屏蔽(称号、套装、时装、成就)
    if g_ios_test then  
        local hideTitle = self.view:GetChild("n102")   --称号
        hideTitle.visible = false
        local hideTitle = self.view:GetChild("n104")   --称号
        hideTitle.visible = false
        local move01 = self.view:GetChild("n105")     --时装 
        move01.visible = false
        local move02 = self.view:GetChild("n106")     --成就
        move02.visible = false
        local move03 = self.view:GetChild("n103")     --套装
        move03.visible = false
    end 
end

function JueSeMainView:initRedPoint()
    if g_is_banshu then
        return
    end

    local redList = {{attConst.A504},{10000},{attConst.A10235},{attConst.A10236},{attConst.A10237,attConst.A10267},{attConst.A10203},{attConst.A10245},{attConst.A10266}}
    for k,v in pairs(self.btnList) do
        local redPanel = v:GetChild("n4")
        local redText = v:GetChild("n5")
        -- print("红点注册>>>>>>>>>>>",v:GetChild("title").text,redList[k],cache.PlayerCache:getRedPointById(attConst.A10266))
        local param = {panel = redPanel,text = redText, ids = redList[k],notnumber = true}
        -- print("k,v",k,redList[k])
        mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())
    end
end

--默认点击那个
function JueSeMainView:AutoClick(index)
    -- body
    
end
--更新套装
function JueSeMainView:updateSuitData(data)
    if self.equipSuitPanel then
        self.equipSuitPanel:setData(data)
    end
    self.childIndex,self.grandson = nil,nil
end
--激活返回
function JueSeMainView:updateSuitId(suiltEffectId)
    if self.equipSuitPanel then
        self.equipSuitPanel:updateSuitId(suiltEffectId)
    end
end

function JueSeMainView:updateEquipMsg(param)
    -- body
    if self.equipPanel then
        if self.controllerC1.selectedIndex == 8 then

            self.equipPanel:setData(cache.PackCache:getXianEquipData())
        else
            self.equipPanel:setData(param)
        end
        
    end
end

function JueSeMainView:updateEquipPro()
    if self.propsEquipPanel then
        self.propsEquipPanel:setData()
    end
end

function JueSeMainView:updateJueseMsg( param )
    -- body
    if self.isself then 
        param = {}
        param.roledata  = cache.PlayerCache:getData()
        param.propsdata = self.propsdata or {}
        param.isself = self.isself
    end 
    if self.propsPanel then
        self.propsPanel:setData(param)
    end
end

function JueSeMainView:setRoleIcon()
    if self.propsPanel then
        self.propsPanel:setRoleIcon()
    end
end
--称号列表
function JueSeMainView:updateTitleList(data)
    if self.titlePanel then
        self.titlePanel:setData(data)
    end
    self.childIndex,self.grandson = nil,nil
end
--请求佩戴称号（1:穿戴 2:脱下）
function JueSeMainView:updateTitleData(data)
    if self.titlePanel then
        self.titlePanel:updateTitleData(data)
    end
end
--请求称号佩戴数量购买
function JueSeMainView:updateNumData(data)
    if self.titlePanel then
        self.titlePanel:calculateNum(data)
    end
end

--请求时装列表
function JueSeMainView:updateFashList(data)
    if self.fashionPanel then
        self.fashionPanel:setData(data)
    end
    self.childIndex,self.grandson = nil,nil
end
--请求时装穿戴
function JueSeMainView:updateFashData(data)
    if self.fashionPanel then
        self.fashionPanel:updateFashData(data)
    end
end
--请求成就信息
function JueSeMainView:updataAchieveData( data )
    if self.AchievementPanel then
        self.AchievementPanel:setData(data)
    end
end
--请求修仙信息
function JueSeMainView:updateXiuxianData( data )
    if self.ImmortalityPanel then
        self.ImmortalityPanel:setData(data)
    end
end
--光环列表
function JueSeMainView:updateAureoleData(data)
    if self.AureolePanel then
        self.AureolePanel:setData(data)
    end
    self.childIndex,self.grandson = nil,nil
end
--请求佩戴光环（1:穿戴 2:脱下）
function JueSeMainView:updateHaloData(data)
    if self.AureolePanel then
        self.AureolePanel:updateHaloData(data)
    end
end
--头饰列表
function JueSeMainView:updateHeadWearListData(data)
    if self.AureolePanel then
        self.AureolePanel:setHeadWearData(data)
    end
    self.childIndex,self.grandson = nil,nil
end
--请求佩戴头饰（1:穿戴 2:脱下）
function JueSeMainView:updateHeadWearData(data)
    if self.AureolePanel then
        self.AureolePanel:updateHeadWearData(data)
    end
end
--请求头饰升级
function JueSeMainView:updateHeadWearLevelData(data)
    if self.AureolePanel then
        self.AureolePanel:updateHeadWearLevelData(data)
    end
end

--刷新头像边框
function JueSeMainView:refreshFrame()
    if self.propsPanel then
        self.propsPanel:setRoleIcon()
    end
end
--时装藏品信息返回
function JueSeMainView:updateCollectionInfo(data)
    if self.fashionPanel then
        self.fashionPanel:setCollectionInfo(data)
    end
end
--时装藏品红点刷新
function JueSeMainView:updateCollectionRed()
    if self.fashionPanel then
        self.fashionPanel:refreshCollectionRed()
    end
end

function JueSeMainView:onbtnController()
    -- body
    mgr.ItemMgr:setPackIndex(0)
    self:clear()

    if self.controllerC1.selectedIndex == 8 then
        --神经病策划 --只判断飞升
        if not mgr.ModuleMgr:CheckView({id = 1325,falg = true} ) then
            if self.oldselect then
                self.controllerC1.selectedIndex = self.oldselect
            else
                self.controllerC1.selectedIndex = 0
            end
            return
        end
    end

    self.oldselect = self.controllerC1.selectedIndex
    if self.controllerC1.selectedIndex == 0 then --属性
        if not self.propsPanel then 
            self.propsPanel = PropsPanel.new(self)
        end
        self.propsPanel:initRoleMsg()
        self.propsPanel:initPropsMsg()
        if not self.equipPanel then 
            self.equipPanel = EquipPanel.new(self)--装备区域
        end
        if self.isself then --如果是自己 就请求一下属性面板信息
            proxy.PlayerProxy:send(1010103)
            self:updateEquipMsg()
        else
            --请求别的人装备信息 和 属性面板信息
        end
    elseif self.controllerC1.selectedIndex == 1 then --装备
        mgr.ItemMgr:setPackIndex(Pack.equipIndex)
        if not self.propsEquipPanel then
            self.propsEquipPanel = PropsEquipPanel.new(self)
        end
        self:updateEquipMsg()
        self:updateEquipPro()
    elseif self.controllerC1.selectedIndex == 2 then --套装
        if not self.equipSuitPanel then
            self.equipSuitPanel = EquipSuitPanel.new(self)
        end
        self.equipSuitPanel:setForviewIndex(self.childIndex,self.grandson)
        --刷新锻造装备套装数据
        proxy.ForgingProxy:send(1100108,{roleId = 0,srvId = 0,reqType = 0})
    elseif self.controllerC1.selectedIndex == 3 then --称号
        if not self.titlePanel then   
            self.titlePanel = TitlePanel.new(self)
        end
        -- self.titlePanel:setForviewIndex(self.childIndex,self.grandson)
        proxy.PlayerProxy:send(1270101)
    elseif self.controllerC1.selectedIndex == 4 then --时装
        if not self.fashionPanel then
            self.fashionPanel = FashionPanel.new(self)
        end
        --藏品红点
        self.fashionPanel:refreshCollectionRed()
        self.fashionPanel:setForviewIndex(self.childIndex,self.grandson)
        proxy.PlayerProxy:send(1270104)
    elseif self.controllerC1.selectedIndex == 5 then --成就
        if not self.AchievementPanel then
            self.AchievementPanel = AchievementPanel.new(self)
        end
        self.AchievementPanel:onController1()
    elseif self.controllerC1.selectedIndex == 6 then --修仙
        if not self.ImmortalityPanel then
            self.ImmortalityPanel = ImmortalityPanel.new(self)
        end
        proxy.ImmortalityProxy:sendMsg(1290101)
        -- self.ImmortalityPanel:onController1()
    elseif self.controllerC1.selectedIndex == 7 then --光环
        if not self.AureolePanel then
            self.AureolePanel = AureolePanel.new(self)
        end
        self.AureolePanel:refreshTopRed()
        self.AureolePanel.controller.selectedIndex =self.indexId
        self.AureolePanel:setForviewIndex(self.childIndex,self.grandson)
        if self.AureolePanel.controller.selectedIndex == 0 then
            proxy.PlayerProxy:send(1570101)--请求光环列表
        else
            proxy.PlayerProxy:send(1570201)--请求头饰列表
        end
    elseif self.controllerC1.selectedIndex == 8 then --飞升
        if not self.FeiSheng then
            self.FeiSheng = FeiSheng.new(self)
        end
        --self.FeiSheng:initData()
        self:updateEquipMsg(cache.PackCache:getXianEquipData())
        proxy.FeiShengProxy:sendMsg(1580201,{reqType = 0})
    end
end

function JueSeMainView:clear()
    if self.fashionPanel then self.fashionPanel:clear() end
end
--不是自己的时候传true
function JueSeMainView:setData(notself)
    if notself and notself == true then 
        self.isself = false
    else
        self.isself = true
    end
end
--属性面板信息
function JueSeMainView:setPropsData(data)
    -- body
    self.propsdata = data
    self:updateJueseMsg()
end
--装备星级界面
function JueSeMainView:onClickStarAtt()
    -- print("装备星级界面>>>>>>>>>>>>>>")
    mgr.ViewMgr:openView2(ViewName.StarAttrView, {})
end

function JueSeMainView:closeView()
    self:clear()
    mgr.ItemMgr:setPackIndex(0)
    if self.equipPanel then
        self.equipPanel:clear()
    end
    self.super.closeView(self)
end

function JueSeMainView:onClickClose()
    if self.AureolePanel and self.AureolePanel.actTimer then
        self.AureolePanel.actTimer =  nil
        self:removeTimer(self.AureolePanel.actTimer)
    end
    self:closeView()
end


function JueSeMainView:add5020201( data )
    -- body
    proxy.PlayerProxy:send(1010103)
end

function JueSeMainView:add5020202(data)
    -- body
    
    local view = mgr.ViewMgr:get(ViewName.JueSeHead)
    if view then
        view:initData()
    end
    mgr.ViewMgr:openView(ViewName.JueSeHead,function(view)
        -- body
        --view:setData()
    end,data)
end

function JueSeMainView:add5020203()
    -- body
    if self.propsPanel then
        self.propsPanel:add5020203()
    end
end

function JueSeMainView:add5020204()
    -- body
    if self.propsPanel then
        self.propsPanel:add5020204()
    end
end

function JueSeMainView:addMsgCallBack(data)
    -- body
    if self.controllerC1.selectedIndex == 8 then
        if self.FeiSheng then
            self.FeiSheng:addMsgCallBack(data)
        end
    end
end

return JueSeMainView