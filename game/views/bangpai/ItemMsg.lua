--
-- Author: 
-- Date: 2017-03-06 20:46:25
--

local ItemMsg = class("ItemMsg",import("game.base.Ref"))

function ItemMsg:ctor(param)
    self.view = param
    self:initView()
end

function ItemMsg:initView()
    -- body
    self.c1 = self.view:GetController("c1")
    self.c2 = self.view:GetController("c2")

    self.labGangName = self.view:GetChild("n20")
    self.labMember = self.view:GetChild("n21")
    self.labPower = self.view:GetChild("n22")
    self.labLv = self.view:GetChild("n23")
    self.bar = self.view:GetChild("n12")
    self.labnotice = self.view:GetChild("n25")
    self.labName = self.view:GetChild("n26")

    local btnPlus = self.view:GetChild("n13")
    btnPlus.onClick:Add(self.onPlus,self)

    local btnChange = self.view:GetChild("n7")
    btnChange.onClick:Add(self.onChange,self)

    local btnApply = self.view:GetChild("n8")
    btnApply:GetChild("title").text = language.bangpai24
    btnApply.onClick:Add(self.onApply,self)
    --申请红点
    local param = {}
    param.panel = self.view:GetChild("n27")
    param.ids = {10313}
    mgr.GuiMgr:registerRedPonintPanel(param,"bangpai.BangPaiMain.2") 

    local btnApplyset = self.view:GetChild("n9")
    btnApplyset:GetChild("title").text = language.bangpai25
    btnApplyset.onClick:Add(self.onApplySet,self)

    local btnWorld = self.view:GetChild("n10")
    btnWorld:GetChild("title").text = language.bangpai26
    btnWorld.onClick:Add(self.onWorld,self)

    local btnOut = self.view:GetChild("n11")
    btnOut:GetChild("title").text = language.bangpai27
    btnOut.onClick:Add(self.onOutGang,self)

    self.modelPanel = self.view:GetChild("n6")

    local btnTovip = self.view:GetChild("n29")
    btnTovip:GetChild("title").text = language.bangpai145
    btnTovip.onClick:Add(self.btnTovip,self)

    local cost = self.view:GetChild("n32")
    cost.text = conf.BangPaiConf:getValue("upgrade_vip_cost") 

    self.btnChangeName = self.view:GetChild("n35")
    self.btnChangeName.onClick:Add(self.ChangeName,self)

    self:initDec()
end

function ItemMsg:initDec()
    -- body
    self.labGangName.text = ""
    self.labMember.text = ""
    self.labPower.text = ""
    self.labLv.text = ""
    self.bar.value = 0
    self.bar.max = 0
    self.labnotice.text = ""
    self.labName.text = ""

    local dec = self.view:GetChild("n14")
    dec.text = language.bangpai20

    dec = self.view:GetChild("n15")
    dec.text = language.bangpai21

    dec = self.view:GetChild("n16")
    dec.text = language.bangpai22

    dec = self.view:GetChild("n17")
    dec.text = language.bangpai23

    dec = self.view:GetChild("n19")
    dec.text = language.bangpai05
end

function ItemMsg:setParent(param)
    -- body
    self.parent = param
end

function ItemMsg:setData()
    -- body
    self.data = cache.BangPaiCache:getData()
    if self.data.gangType == 1 then
        self.c2.selectedIndex = 0
    else
        self.c2.selectedIndex = 1
    end
    self.labGangName.text = self.data.gangName
    --print("aaaaa",self.data.gangLevel,self.data.gangType)
    local confData = conf.BangPaiConf:getBangLev(self.data.gangLevel,self.data.gangType)
    local param = {}
    if self.data.memberNum < self.data.maxMemberNum then
        param = {
            {text = self.data.memberNum,color = 7},
            {text = "/"..self.data.maxMemberNum,color = 6}
        }
    else
        param = {
            {text = self.data.memberNum,color = 14},
            {text = "/"..self.data.maxMemberNum,color = 6}
        }
    end
    self.labMember.text =  mgr.TextMgr:getTextByTable(param)
    self.labPower.text = self.data.gangPower
    self.labLv.text = string.format(language.bangpai10,self.data.gangLevel)
    self.bar.value = self.data.gangExp
    self.bar.max = confData.exp or self.data.gangExp
    self.labnotice.text = mgr.TextMgr:splitStr(self.data.gangNotice,"")

    self.job = self.data.gangJob
    --job 0成员 1 精英 2长老  3副帮主  4帮主 
    if self.job == 0 or self.job == 1 then
        self.c1.selectedIndex = 0
    elseif self.job == 2 then
        self.c1.selectedIndex = 1
    elseif self.job == 3 then
        self.c1.selectedIndex = 2
    else
        self.c1.selectedIndex = 3
    end

    --[[if self.job == 3 or self.job == 4 then
        self.c1.selectedIndex = 1
    else
        self.c1.selectedIndex = 0
    end]]--

    if self.data.leftGangMergeFreeCount > 0 then
        self.btnChangeName.visible = true
    else
        self.btnChangeName.visible = false
    end
    self:initModel()
end

function ItemMsg:initModel()
    -- body
    self.labName.text = self.data.adminName
    local cansee = false
    if not self.model then
        local panel = self.modelPanel:GetChild("n0")
        local modelObj,cansee = self.parent:addModel(self.data.adminSkin[1],panel)
        modelObj:setPosition(panel.actualWidth/2,-panel.actualHeight-130,500)
        modelObj:setRotation(150)
        modelObj:setScale(150)

    
        self.model = modelObj
    end

    cansee = self.model:setSkins(self.data.adminSkin[1],self.data.adminSkin[2],self.data.adminSkin[3])
    self.view:GetChild("n33").visible = cansee
end

function ItemMsg:ChangeName()
    -- body
    -- mgr.ViewMgr.openView(ViewName.JueSeName,function(view)
    --     -- body
    --     view:setData()
    -- end)

    mgr.ViewMgr:openView(ViewName.JueSeName,function(view)
        -- body
        view:setDataBangPai()
    end)
end


function ItemMsg:onPlus()
    -- body
    mgr.ViewMgr:openView(ViewName.BangPaiExpInfo,function(view)
        -- body
        view:setData(self.data)
    end)

    -- --帮派签到
    -- if self.parent.PanelMsg then
    --     --self.parent.PanelMsg.c1.selectedIndex = 1
    --     self.parent.PanelMsg:setData(1)
    -- end
end

function ItemMsg:onApply()
    -- body
    mgr.ViewMgr:openView(ViewName.BangPaiApplyList,function(view)
        -- body
        proxy.BangPaiProxy:sendMsg(1250105, {page = 1})
    end)
end

function ItemMsg:onApplySet()
    -- body
    mgr.ViewMgr:openView(ViewName.BangPaiSetApply,function(view)
        -- body
        local param = {}
        param.level = 0
        param.vipLevel = 0
        param.power = 0
        param.reqType = 1
        proxy.BangPaiProxy:sendMsg(1250208, param)
    end)
end

function ItemMsg:onWorld()
    -- body
    --世界喊话
    local t1 = cache.BangPaiCache:getTime()
    if t1 == 0 then
        
    else
        local var = mgr.NetMgr:getServerTime() - t1
        local t2 = conf.BangPaiConf:getValue("chat_zhaoren_time")
        if var <=  t2 then
            GComAlter(string.format(language.bangpai28,t2))
            return
        end
    end
    cache.BangPaiCache:setTime(mgr.NetMgr:getServerTime())
    proxy.BangPaiProxy:sendMsg(1250209)    
end

function ItemMsg:onOutGang()
    -- body
--退出帮派
    local t = clone(language.bangpai29)
    t[2].text = string.format(t[2].text,self.data.gangName)

    local param = {}
    param.type = 2
    param.richtext = mgr.TextMgr:getTextByTable(t)
    param.sure = function( ... )
        -- body
        proxy.BangPaiProxy:sendMsg(1250204)
    end
    GComAlter(param)
    -- --称号位置调整
    -- if gRole then 
    --     gRole:setChenghao()
    -- end
end

function ItemMsg:onChange(context)
    -- body
    --改变公告
    if self.data.canModifyNotice == 1 then
        GComAlter(language.bangpai202)
    else
        mgr.ViewMgr:openView(ViewName.BangPaiNotice,function(view)
            -- body
            self:setData(self.data.gangNotice)
        end)
    end
end

function ItemMsg:btnTovip()
    -- body
    proxy.BangPaiProxy:sendMsg(1250405)
end

return ItemMsg