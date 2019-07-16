--
-- Author: 
-- Date: 2017-02-06 15:34:48
--

local SkillPanel = import(".SkillPanelnew")
local TalentPanel = import(".TalentPanel")
local SkillXianFa = import(".SkillXianFa")
local SkillView = class("SkillView", base.BaseView)

function SkillView:ctor()
    self.super.ctor(self)
    self.uiClear = UICacheType.cacheTime
    self.openTween = ViewOpenTween.scale
    -- self.uiLevel = UILevel.level3 
end

function SkillView:initData(data)
    -- body
    if data and data > 2 then
        data = 0
    end
    if self.SkillPanel  then
        self.SkillPanel.modelObj = nil 
    end
    GSetMoneyPanel(self.window2,self:viewName())

    local index = 1
    for k ,v in pairs(self.btnlist) do
        if k == 1 then--技能
            v.visible = true
            v.xy = self.btnlist[index].xy
            index = index + 1 
            if not g_is_banshu then
                self:initRedPoint(v,{10219})
            end
        elseif k == 2 then
            --仙法
            if mgr.ModuleMgr:CheckSeeView(1158) then
                v.visible = true
                v.xy = self.btnlist[index].xy
                index = index + 1 
            else
                v.visible = false
            end
        elseif k == 3 then
            if not g_is_banshu then
                self:initRedPoint(v,{10220})
            end
            local talentGlobal=conf.TalentConf:getTalentGlobal()
            local startLevel = talentGlobal.talent_init_level
            local level=cache.PlayerCache:getRoleLevel()
            if level<startLevel then
                v.visible = false
            else
                v.visible = true
                v.xy = self.btnlist[index].xy
                index = index + 1 
                
            end
        end
    end

    self.controllerC1.selectedIndex = data or 0
    self:onController1()  

    --EVE 在仙法中模拟initData函数
    if self.SkillXianFa then 
        self.SkillXianFa:initData2()
    end 
end

function SkillView:initView()
    --技能 天赋
    self.window2 = self.view:GetChild("n0")
    local closeBtn = self.window2:GetChild("btn_close")
    closeBtn.onClick:Add(self.onClickClose,self)

    self.controllerC1 = self.view:GetController("c1")
    self.controllerC1.onChanged:Add(self.onController1,self)

    self.btnlist = {}
    for i = 101 , 103 do
        local btn1 = self.view:GetChild("n"..i)
        btn1:GetChild("title").text = language.skill21[i-100]
        table.insert(self.btnlist,btn1)
    end


    -- local btn1 = self.view:GetChild("n101")
    -- btn1:GetChild("title").text = language.skill01
    -- self.btn1 = btn1
    -- self.btnlist[1].xy = self.btn1.xy

    -- local btn2 = self.view:GetChild("n102")
    -- btn2:GetChild("title").text = language.skill02
    -- self.btn2 = btn2
    -- self.btnlist[3] = self.btn2.xy
    
    -- self.btn3 = self.view:GetChild("n103")
    -- self.btn3:GetChild("title").text = language.skill21
    -- self.btnlist[2] = self.btn3.xy
end

function SkillView:initRedPoint(btn,ids)
    -- body
    --注册红点
    local redImg = btn:GetChild("n4")
    local param = {panel = redImg,ids = ids}
    mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())
end

function SkillView:onController1()
    -- body
    if 0 == self.controllerC1.selectedIndex  then --技能
        if not self.SkillPanel then
            self.SkillPanel = SkillPanel.new(self)
        end
        --self.SkillPanel:addModel()
        proxy.SkillProxy:send(1110101)
    elseif 2 == self.controllerC1.selectedIndex then
        --仙法
        if not self.SkillXianFa then
            self.SkillXianFa = SkillXianFa.new(self)
        end
        proxy.SkillProxy:send(1110106)
    else --天赋
        if not self.TalentPanel then
            self.TalentPanel = TalentPanel.new(self)
        end
        self.TalentPanel:initData()
        proxy.TalentProxy:send(1110103,{reqType=1})
    end
end

function SkillView:setData(data_)

end

function SkillView:onClickClose()
    -- body
    if self.SkillPanel then
        self.SkillPanel.modelObj = nil 
    end
    self:closeView()
end


--消息返回之后
-------------请求技能界面显示
function SkillView:add5110101(data)
    -- body
    if self.SkillPanel then
        self.SkillPanel:setData(data,self.isup)
        self.isup = false
    end
end
--技能升级之后
function SkillView:add5110102(data,flag)
    -- body
    self.isup = flag
    self.iscanUp = nil
    self:onController1()
    mgr.SoundMgr:playSound(Audios[2])
end

--天赋
function SkillView:add5110103(data)
    -- body
    if self.TalentPanel then
        self.TalentPanel:setData(data)
    end
end

--天赋
function SkillView:add5110104(data)
    if self.TalentPanel then
        self.TalentPanel:add5110104(data)
    end
end

--天赋
function SkillView:add5110105(data)
    if self.TalentPanel then
        self.TalentPanel:add5110105(data)
    end
end

function SkillView:add5110106(data)
    -- body
    if self.SkillXianFa then
        self.SkillXianFa:setData(data)
    end
end

return SkillView