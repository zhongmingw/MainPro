--
-- Author: 
-- Date: 2017-07-24 14:32:44
--

local MarryQingYuan = class("MarryQingYuan",import("game.base.Ref"))

function MarryQingYuan:ctor(param)
    self.parent = param
    self.view = self.parent.view:GetChild("n4")
    self:initView()
end

function MarryQingYuan:initView()
    -- body
    --爱心
    self.pp = self.view:GetChild("n21")
    self.c1 = self.pp:GetController("c1")
    self.xin = self.view:GetChild("n20")
    self.c2 = self.xin:GetController("c1")
    self.pp2 = self.view:GetChild("n35")
    self.c3 = self.pp2:GetController("c1")
    self.bgImg = self.view:GetChild("n34")
    self.bgImg.visible = false

    self.jieName = self.view:GetChild("n22")
    self.jie = self.view:GetChild("n23")

    self.power = self.view:GetChild("n27")
    --属性
    self.proList = {}
    for i = 12 , 18 do
        local item = self.view:GetChild("n"..i)
        item.text = ""
        table.insert(self.proList,item)
    end
    --进度
    self.bar = self.view:GetChild("n7")
    self.labqm = self.view:GetChild("n19")
    self.labqm.text = ""

    local btnPlus = self.view:GetChild("n9")
    self.btnPlus = btnPlus
    btnPlus.onClick:Add(self.onPlus,self)

    self.btnUp = self.view:GetChild("n8")     -- 进阶
    self.btnUp.onClick:Add(self.onLevelUp,self)
    self.btnAutoUp = self.view:GetChild("n33") -- EVE 自动进阶
    self.btnAutoUp.onClick:Add(self.onAutoLevelUp,self)


    self.imgmax = self.view:GetChild("n28")

    self.ismarry = self.view:GetChild("n29")
    self.img1 = self.view:GetChild("n30") 
    self.radio = self.view:GetChild("n31")
    self.radiotile = self.view:GetChild("n32")
    self.radiotile.text = language.marryiage22

    self.img1.visible = false
    self.radio.visible = false
    self.radiotile.visible = false
end

function MarryQingYuan:onPlus()
    -- body
    --点击加号弹出鲜花的获取途径
    local param = {}
    param.mId = PackMid.hua3
    GGoBuyItem(param)
end

function MarryQingYuan:onLevelUp()
    -- body
    if not self.data then
        return
    end
    if not self.condata.step then
        return
    end
    -- if cache.PlayerCache:getCoupleName()=="" then
    --     GComAlter(language.kuafu99)
    --     return
    -- end
    if not self.nextconf then
        return
    end
    if self.data.qmValue < self.condata.exp then
        return
    end

    proxy.MarryProxy:sendMsg(1390203)
end

--EVE 自动升阶
function MarryQingYuan:onAutoLevelUp()
    self.radio.selected = true
    self:onLevelUp()
end

function MarryQingYuan:initMsg(flag)
    -- body
    if not self.data then
        return
    end
    if self.data.qyLev == 0 then 
        proxy.MarryProxy:sendMsg(1390203)
    end
    self.condata = conf.MarryConf:getQingyuanItem(self.data.qyLev)
    self.nextconf = conf.MarryConf:getQingyuanItem(self.data.qyLev+1) 
    if not self.condata or not self.condata.step then
        --还没有过结婚
        self.c1.selectedIndex = 0
        self.c2.selectedIndex = 0
        self.labqm.text = language.kuafu72

        self.btnUp.visible = false
        self.btnAutoUp.visible = false
        self.bar.visible = false

        self.jieName.text = ""
        self.jie.url = nil
        self.power.text = 0

        self.imgmax.visible = false

        self.img1.visible = false
        self.radio.visible = false
        self.radiotile.visible = false
        --红点清理
        mgr.GuiMgr:redpointByID(10244)
    else      
        self.imgmax.visible = false 
        local _nameList = conf.MarryConf:getValue("jie_name")
        self.power.text = self.condata.power or 0
        if not self.nextconf then
            self.labqm.text = ""
            self.btnUp.visible = false
            self.btnAutoUp.visible = false
            self.bar.visible = false
            self.btnPlus.visible = false
            self.imgmax.visible = true

            self.img1.visible = false
            self.radio.visible = false
            self.radiotile.visible = false
            --红点清理
            mgr.GuiMgr:redpointByID(10244)
        else

            -- self.img1.visible = true
            -- self.radio.visible = true
            -- self.radiotile.visible = true

            local param = {}
            local t = {color = 6 ,text = language.kuafu73}
            table.insert(param,t)
            self.btnUp.visible = true
            self.btnAutoUp.visible = true
            self.bar.visible = true
            self.btnPlus.visible = true
            if self.data.qmValue >= self.condata.exp then
                local t = {color = 7 ,text = self.data.qmValue}
                self.btnUp.enabled = true
                self.btnAutoUp.enabled = true
                table.insert(param,t)
            else
                local t = {color = 14 ,text = self.data.qmValue}
                self.btnUp.enabled = false
                self.btnAutoUp.enabled = false
                table.insert(param,t)
                --红点清理
                mgr.GuiMgr:redpointByID(10244)
            end
            local t = {color = 7 ,text = "/"..self.condata.exp}
            table.insert(param,t)

            self.bar.value = self.data.qmValue
            self.bar.max = self.condata.exp
            self.labqm.text = mgr.TextMgr:getTextByTable(param)
        end

        if self.condata.step and self.condata.step < 24 then
            if self.condata.step < 13 then
                self.bgImg.visible = false
                self.pp2.visible = false
                self.pp.visible = true
                self.c1.selectedIndex = self.condata.step
            else
                self.bgImg.visible = false
                self.pp2.visible = true
                self.pp.visible = false
                self.c3.selectedIndex = self.condata.step - 12
            end
        else
            self.pp.visible = false
            self.pp2.visible = false
            self.bgImg.visible = true
        end
        -- self.c1.selectedIndex = self.condata.step > 12 and 12 or self.condata.step
        self.c2.selectedIndex = self.condata.star

        self.jieName.text = _nameList[self.condata.step]
        self.jie.url =  UIItemRes.jieshu[self.condata.step]

        local width = (self.pp.width - self.jieName.width - self.jie.width)/2
        self.jieName.x = width
        width = width + self.jieName.width

        --bxp 未结婚开启
        -- if cache.PlayerCache:getCoupleName()=="" then
        --     --单身中
        --     self.btnUp.enabled = false  
        --     self.btnAutoUp.enabled = false
        -- end
    end

    --属性设置
    for k ,v in pairs(self.proList) do
        v.text = ""
    end

    local t = GConfDataSort(self.condata)
    for k ,v in pairs(t) do
        if self.proList[k] then
            self.proList[k].text = conf.RedPointConf:getProName(v[1]).." "..GProPrecnt(v[1],v[2])
        end
    end
    --bxp 未结婚开启
    ---是否结婚过
    -- if cache.PlayerCache:getCoupleName()== "" then
    --     self.ismarry.visible = true
    --     self.xin.visible = false
    --     self.bar.visible = false
    --     self.btnPlus.visible = false
    --     self.btnUp.visible = false
    --     self.btnAutoUp.visible = false
    --     self.imgmax.visible = false
    --     self.labqm.text = ""
    --     self.img1.visible = false
    --     self.radio.visible = false
    --     self.radiotile.visible = false
    -- else
        self.ismarry.visible = false
        self.xin.visible = true
        --是否自动升级检测
        if flag and self.radio.selected then
            self.btnUp.onClick:Call() --??? What is this?
        end
    -- end
end


function MarryQingYuan:addMsgCallBack(data)
    -- body

    if data.msgId == 5390201 then
        self.data = data
        self.radio.selected = false
        self:initMsg()
    elseif data.msgId == 5390203 then
        self.data.qyLev = data.qyLev
        self.data.qmValue = data.qmValue
        self.data.power = data.power
        self:initMsg(true)
    end
end



return MarryQingYuan