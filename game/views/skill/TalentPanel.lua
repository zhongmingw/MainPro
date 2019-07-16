--
-- Author: 
-- Date: 2017-02-17 10:33:26
--

local TalentPanel = class("TalentPanel",import("game.base.Ref"))

function TalentPanel:ctor(param)
    self.parent = param
    self.page=1
    self.view = param.view:GetChild("n44")
    -- self:initData()
end

function TalentPanel:initData( ... )
    
    self.talentSkillLevelMap={{},{},{}}
    self.view:GetChild("n63").text=language.talent01
    self.view:GetChild("n65").text=language.talent02
    
    self.view:GetChild("n70").text=language.talent05
    self.view:GetChild("n73").text=language.talent06
    self.view:GetChild("n80").text=language.talent07
    self.view:GetChild("n74").text=language.talent08
    self.view:GetChild("n76").text=language.talent09
    self.view:GetChild("n78").text=language.talent10

    self.descs={{},{}}

    self.bloodPanel=self.view:GetChild("n96")
    self.powerPanel=self.view:GetChild("n97")
    self.giantPanel=self.view:GetChild("n99")

    self.totalNum=self.view:GetChild("n75")
    self.canUseNum=self.view:GetChild("n77")
    self.nextLevel=self.view:GetChild("n79")
    self.currNum=self.view:GetChild("n81")
    self.currNum.text=0
    self.totalNum.text=0

    
    self.name=self.view:GetChild("n40")
    self.level=self.view:GetChild("n64")
    
    self.greText=self.view:GetChild("n71")
    self.redText=self.view:GetChild("n72")
    self.greText.text=""
    self.redText.text=""

    local btnGrade=self.view:GetChild("n82")
    btnGrade.onClick:Add(self.onClickBtnGrade,self)
    local btnClear=self.view:GetChild("n7")
    btnClear.onClick:Add(self.onClickBtnClear,self)

    self.listView = self.view:GetChild("n102")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 1

    --技能展示

    local btnRule = self.view:GetChild("n101")
    btnRule.onClick:Add(self.onClickBtnRule,self)

    self.controllerC2 = self.view:GetController("c1")
    self.controllerC2.onChanged:Add(self.onClickBtnPage,self)
    self.controllerC2.selectedIndex = 0
    self.TalentID=1101
    
    self.talentGlobal=conf.TalentConf:getTalentGlobal()
    self.nextLevel.text=self.talentGlobal.talent_init_level
    self.talentSkill=conf.TalentConf:getTalentSkillAttr()

    self.Flag=false
    local startLevel = self.talentGlobal.talent_init_level
    local level=cache.PlayerCache:getRoleLevel()
    if level>=startLevel then
        self.Flag=true
    end
    -- body
    local talentTree=conf.TalentConf:getTalentTree()
    self.baseConf={{{},{},{}},{{},{},{}},{{},{},{}}}
    for k,v in pairs(talentTree) do
        local i=math.floor(v.id/1000)
        local j=math.floor(v.id/100%10)
        local k=math.floor(v.id%100)
        self.baseConf[i][j][k]=v
    end

    self.btns={{{},{},{}},{{},{},{}},{{},{},{}}}
    local k=1
    for i=1,3 do
        local idx=1
        for key,value in pairs(self.baseConf[1][i]) do
            local btn= self.bloodPanel:GetChild("n"..60+k)
            self:setTalent(1,i,btn,value,idx)
            k=k+1
            idx=idx+1
        end
    end

    k=1
    for i=1,3 do
        local idx=1
        for key,value in pairs(self.baseConf[2][i]) do
            local btn= self.powerPanel:GetChild("n"..48+k)
            self:setTalent(2,i,btn,value,idx)
            k=k+1
            idx=idx+1
        end
    end

    k=1
    for i=1,3 do
        local idx=1
        for key,value in pairs(self.baseConf[3][i]) do
            local btn= self.giantPanel:GetChild("n"..61+k)
            self:setTalent(3,i,btn,value,idx)
            k=k+1
            idx=idx+1
        end
    end
    self.btn=self.btns[1][1][1]
    self:isCanGrade(self.page)
    self:setTalentInfo(self.btn)
end

function TalentPanel:onClickBtnRule(context)
    GOpenRuleView(1001)
end

function TalentPanel:celldata( index, obj )
    -- body
    self.currDesc=obj:GetChild("n1")
    self.nextDesc=obj:GetChild("n3")
    obj:GetChild("n0").text=language.talent03
    obj:GetChild("n2").text=language.talent04

    self.descs[1][1]=obj:GetChild("n0")
    self.descs[1][2]=obj:GetChild("n1")
    self.descs[2][1]=obj:GetChild("n2")
    self.descs[2][2]=obj:GetChild("n3")
end

function TalentPanel:setTalent(page,line,btn,value,idx)
    btn.onClick:Add(self.onClickBtn,self)
    local data={}

    data.line=line
    data.page=page --分页
    data.lv=0
    data.idx=idx
    data.maxLv=value.max_level
    btn.data=data
    self.btns[page][line][idx]=btn
    local text=btn:GetChild("title")
    text.text="0/"..data.maxLv

    local img=btn:GetChild("n8")
    img.visible=false
end

function TalentPanel:onClickBtnPage()
    self.page = self.controllerC2.selectedIndex+1
    local param={ reqType = self.controllerC2.selectedIndex+1 }
    if self.Flag then
        proxy.TalentProxy:send(1110103,param)
    else
        self:setTalentInfo(self.btns[self.page][1][1])
        self:isCanGrade(self.page)
    end
end

function TalentPanel:onClickBtnGrade()
    if self.Flag then
        --mgr.GuiMgr:redpointByID(10220)
        proxy.TalentProxy:send(1110104,{skillId=self.TalentID})
    else
        GComAlter(language.talent16)
    end
end

function TalentPanel:onClickBtnClear()
    if self.Flag then
        proxy.TalentProxy:send(1110105)
    else
        GComAlter(language.talent16)
    end
end

function TalentPanel:onClickBtn(context)
    local btn = context.sender
    self:setTalentInfo(btn)
end

function TalentPanel:setTalentInfo(btn)
    local data = btn.data
    local page = data.page
    local idx = data.idx
    local line = data.line
    if self.preBtn then
        local img=self.preBtn:GetChild("n8")
        img.visible=false
    end

    self.preBtn=btn

    local img=btn:GetChild("n8")
    img.visible=true

    local talentInfo=self.baseConf[page][line][idx]
    self.TalentID=talentInfo.id

    local talentConf=self.baseConf[data.page][data.line][data.idx]

    local talentid=talentConf.id*1000+data.lv

    self.level.text=data.lv.."/"..data.maxLv
    self.name.text=talentInfo.name

    local index=1
    local talentDateil=self.talentSkill[talentid..""]
    if talentDateil and talentDateil.dec then 
        self.currDesc.text=talentDateil.dec
        self.descs[index][1].text=language.talent03
        self.descs[index][2].text=talentDateil.dec
        index=index+1
    else
        self.currDesc.text=""
    end

    local nexttalentid=talentid+1
    local nexttalentDateil=self.talentSkill[nexttalentid..""]
    if nexttalentDateil and nexttalentDateil.dec then
        self.nextDesc.text=nexttalentDateil.dec
        self.descs[index][1].text=language.talent04
        self.descs[index][2].text=nexttalentDateil.dec
        index=index+1
    else
        self.nextDesc.text=language.talent18
    end
    if index==2 then
        self.descs[index][1].text=""
        self.descs[index][2].text=""
    end

    self.redText.color=Color.green
    self.greText.color=Color.green
    if talentDateil and talentDateil.pre_skill_level then
        local level=self.talentSkillLevelMap[page][talentDateil.pre_skill_level[1]]
        if level and level>=talentDateil.pre_skill_level[2] then
            self.redText.text="[color=#0B8109]"..language.talent13..talentDateil.pre_skill_level[2]..language.talent12.."[/color]"
        else
            self.redText.text="[color=#DA1A27]"..language.talent13..talentDateil.pre_skill_level[2]..language.talent11.."[/color]"
        end
    else
        self.redText.text=""
    end
    
    if talentDateil and talentDateil.cost_point then
        if self.data and self.data.curUsePoint and self.data.curUsePoint>=talentDateil.cost_point then
            self.greText.text="[color=#0B8109]"..language.talent14..talentDateil.cost_point..language.talent12.."[/color]"
        else
            self.greText.text="[color=#DA1A27]"..language.talent14..talentDateil.cost_point..language.talent11.."[/color]"
        end
    else
        self.greText.text="[color=#0B8109]"..language.talent15.."[/color]"
    end
end

function TalentPanel:setTalentItem(key,value)
    local i=math.floor(key/1000)
    local j=math.floor(key/100%10)
    local k=math.floor(key%100)

    if not(self.page==i) then
        return
    end
    
    local btn=self.btns[self.page][j][k]
    btn.data.lv=value
    btn:GetChild("icon").grayed=false

    btn:GetChild("n6").visible=true

    local text=btn:GetChild("title")
    text.text=value.."/"..btn.data.maxLv
end

function TalentPanel:setData( data )
    self.data = data
    self.canUseNum.text=self.data.canUseTalentPoint
    self.totalNum.text=self.data.allTalentPoint
    self.currNum.text=self.data.curUsePoint

    self.talentSkillLevelMap[self.page]=data.talentSkillLevelMap
    for k,v in pairs(data.talentSkillLevelMap) do
        self:setTalentItem(k,v)
    end
 
    self:setTalentInfo(self.btns[self.page][1][1])

    self:isCanGrade(self.page)

    local startLevel = self.talentGlobal.talent_init_level
    local startUpLevel = self.talentGlobal.talent_inc_point[1]
    local Mul= self.talentGlobal.talent_inc_point[2]

    local level=cache.PlayerCache:getRoleLevel()
    if level<startLevel then
        self.nextLevel.text=startLevel
    elseif level>=startLevel and level<startUpLevel then
        self.nextLevel.text=startUpLevel
    else
        self.nextLevel.text=(math.floor(level/Mul)+1)*Mul
    end
end

function TalentPanel:add5110104(data)
    self.data = data
    self.canUseNum.text=self.data.canUseTalentPoint
    self.currNum.text=self.data.curUsePoint
    
    self.talentSkillLevelMap[self.page][self.TalentID]=data.skillLevel
    for k,v in pairs(self.talentSkillLevelMap[self.page]) do
        self:setTalentItem(k,v)
    end
    self:isCanGrade(self.page)

    local i=math.floor(self.TalentID/1000)
    local j=math.floor(self.TalentID/100%10)
    local k=math.floor(self.TalentID%100)
    local btn=self.btns[i][j][k]
    self:setTalentInfo(btn)
    GComAlter(language.talent17)
end

function TalentPanel:add5110105(data)
    self.canUseNum.text=data.canUseTalentPoint
    self.currNum.text=data.curUsePoint

    self.data=data
    for i=1,3 do
        for j=1,3 do
            for k,v in pairs(self.btns[i][j]) do
                v.data.lv=0
                local text=v:GetChild("title")
                text.text="0/"..v.data.maxLv
                v:GetChild("icon").grayed=true
                v:GetChild("n6").visible=true
            end
        end
        self.talentSkillLevelMap[i]={}
        self:isCanGrade(i)
    end
end

function TalentPanel:isCanGrade(page)
    for j=1,3 do
        for k,v in pairs(self.btns[page][j]) do
            local flag=true

            local conf=self.baseConf[page][j][v.data.idx]
            local talentid=conf.id*1000+v.data.lv
            local talentDateil=self.talentSkill[talentid..""]

            if talentDateil.pre_skill_level then
                local level=self.talentSkillLevelMap[page][talentDateil.pre_skill_level[1]]
                if not(level and level>=talentDateil.pre_skill_level[2]) then
                    flag=false
                end
            end
            if talentDateil.cost_point then
                if not(self.data and self.data.curUsePoint and self.data.curUsePoint>=talentDateil.cost_point) then
                    flag=false
                end
            end

            if not(self.data) then
                flag=false
            end

            if self.data and self.data.canUseTalentPoint <= 0 then
                flag=false
            end

            if not(self.Flag) then
                flag=false
            end
            
            if v.data.maxLv<=v.data.lv then
                flag=false
            end
            v:GetChild("n6").visible=flag
        end
    end
    
end

return TalentPanel