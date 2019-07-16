--
-- Author: 
-- Date: 2017-02-17 10:33:26
--

local SkillPanel = class("SkillPanel",import("game.base.Ref"))

function SkillPanel:ctor(param)
    self.parent = param
    self.view = param.view:GetChild("n43")
    self:initData()
    self:initView()

    
end

function SkillPanel:initData( ... )
    -- body
    local career = cache.PlayerCache:getSex()
    self.confData = conf.SkillConf:getSkillByCareer(career)

    
end

function SkillPanel:initView()
    -- body
    self.controllerC2 = self.view:GetController("c1")
    self.controllerC3 = self.view:GetController("c2")
      --升级技能
    local btnUpskill = self.view:GetChild("n14")
    btnUpskill.onClick:Add(self.onbtnUpskill,self)

    local btnOneKeyUp = self.view:GetChild("n15")
    btnOneKeyUp.onClick:Add(self.onOneKeyUp,self)
    self.redimg = btnOneKeyUp:GetChild("red")
    --技能展示
    local btnShowSkill = self.view:GetChild("n16")
    btnShowSkill.onClick:Add(self.onbtnShowSkill,self)
    self.btnShowSkill = btnShowSkill
    self.imgShow = self.view:GetChild("n24") 
    if g_ios_test then    --EVE ios版属，技能展示屏蔽
        btnShowSkill.scaleX = 0
        btnShowSkill.scaleY = 0
        self.imgShow.scaleX = 0
        self.imgShow.scaleY = 0
    end 
    --技能列表
    self.listView = self.view:GetChild("n25")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
    self.listView.onClickItem:Add(self.onUIClickCall,self)

    self:initDec()

    if g_is_banshu then
        btnShowSkill:SetScale(0,0)
        self.imgShow:SetScale(0,0)
    end
end

function SkillPanel:initDec()
    -- body
    self.iconSkill = self.view:GetChild("n42")
    self.dec1 = self.view:GetChild("n27")
    self.dec1.text = ""
    self.dec2 = self.view:GetChild("n28")
    self.dec2.text = ""
    self.dec3 = self.view:GetChild("n29")
    self.dec3.text = ""

    self.decPower = self.view:GetChild("n26")
    self.decPower.text = 0
    --当前效果
    --self.decCur = self.view:GetChild("n36")
    --self.decCur.text = ""

    self.listViewCur = self.view:GetChild("n37")
    self.listViewCur.itemRenderer = function(index,obj)
        self:cellCurdata(index, obj)
    end
    self.listViewCur.numItems = 0

    --next 
    self.listViewNext = self.view:GetChild("n40")
    self.listViewNext.itemRenderer = function(index,obj)
        self:cellNextdata(index, obj)
    end
    self.listViewNext.numItems = 0
    --self.decNext = self.view:GetChild("n31")
    --self.decNext.text = ""
    --
    self.decTiaojian1 = self.view:GetChild("n32")
    self.decTiaojian1.text = ""
    self.decTiaojian1Value = self.view:GetChild("n34")
    self.decTiaojian1Value.text = ""

    self.decTiaojian2 = self.view:GetChild("n33")
    self.decTiaojian2.text = ""
    self.decTiaojian2Value = self.view:GetChild("n35")
    self.decTiaojian2Value.text = ""
    --激活条件
    --self.decJihuo = self.view:GetChild("n30") 
    --self.decJihuo.text = ""
    self.listViewJihuo = self.view:GetChild("n39")
    self.listViewJihuo.itemRenderer = function(index,obj)
        self:cellCurdata(index, obj)
    end
    self.listViewJihuo.numItems = 0

    self.panle_model = self.view:GetChild("n1") 

    --self:addModel()
    self.view:GetChild("n45").text = language.skill24
    local btnRadio = self.view:GetChild("n44")
    btnRadio.onClick:Add(self.onBtnRadio,self)
end

function SkillPanel:addModel()
    -- body

    self.modelObj = self.parent:addModel(RoleSexModel[cache.PlayerCache:getSex()].id,self.panle_model)
    self.modelObj:setSkins(nil,3020101)
    self.modelObj:setPosition(self.panle_model.actualWidth/2,-self.panle_model.actualHeight-20,500)
    self.modelObj:setRotationXYZ(0,-180,0)
    self.modelObj:setScale(130)--fangd

    local node = self.view:GetChild("n41")
    local effect = self.parent:addEffect(4020102,node)
    effect.LocalPosition = Vector3(node.actualWidth/2,-node.actualHeight+180,500)
end


function SkillPanel:celldata( index, obj )
    -- body
    obj.data = index

    local confData = self.confData[index+1]
    local data = self:getServerSkill(confData.id)
    local level = data and data.skillLevel or 1
    local affectData = conf.SkillConf:getSkillByIdAndLevel(confData.id,level)
    if not affectData then
        return
    end
    local icon = obj:GetChild("n6")
    icon.url =  ResPath.iconRes(confData.icon) --UIPackage.GetItemURL("_icons" , ""..confData.icon) --"ui://nrhffbtde31w1j"--


    local labname = obj:GetChild("n4")
    labname.text = confData.name

    local lablevel = obj:GetChild("n5")
    lablevel.text = string.format(language.skill03,level)

    --是否可升级
    local c1 = obj:GetController("c1")
    --c1.selectedIndex = 0
    if not affectData.up_condition then
        c1.selectedIndex = 0
    else
        local flag = self:isCanUpSkill(affectData)
        if flag then
            self.redimg.visible = true
        else
            self.redimg.visible = false
        end

        if flag and data then
            c1.selectedIndex = 1
        else
            c1.selectedIndex = 0
        end
    end
end

function SkillPanel:onUIClickCall( context )
    -- body
    local cell = context.data
    self.selectindex = cell.data
    self:setSelectData()
end

function SkillPanel:setData( data )
    -- body
    self.data = data
    self.listView.numItems = #self.confData

    if not self.selectindex then
        self.selectindex = 0
    end
    self.listView:AddSelection(self.selectindex,false)
    self:setSelectData()
end


function SkillPanel:getServerSkill(id)
    -- body
    for k ,v in pairs(self.data.skillInfo) do
        if v.skillId == id then
            return v 
        end
    end

    return nil 
end

function SkillPanel:isCanUpSkill( affectData )
    -- body
    local flag = true

    if affectData and  affectData.up_condition  then
        for k ,v in pairs(affectData.up_condition) do
            if k == 1 then
                local activeLv = cache.PlayerCache:getSkins(14) or 0
                local attrConfData = conf.ImmortalityConf:getAttrDataByLv(v)
                local sign = cache.PlayerCache:getAttribute(20139)
                if (activeLv>=v and activeLv%10 ~= 0) or (activeLv%10 == 0 and sign ~= 0 and activeLv >= v) then
                else
                --if cache.PlayerCache:getRoleLevel()<v then
                    flag = false
                    break
                end
            else
                if v > 0 then
                    local money = cache.PlayerCache:getTypeMoney(MoneyType.copper)
                    +cache.PlayerCache:getTypeMoney(MoneyType.bindCopper)

                    if money < v then
                        flag = false
                        break
                    end
                end
            end
        end
    else
        flag = false
    end

    return flag
end

function SkillPanel:cellCurdata( index,obj )
    -- body
    local _lab = obj:GetChild("n0")--
    _lab.text =  self.curDec
    obj.height = _lab.height + 20
end

function SkillPanel:cellNextdata( index,obj  )
    -- body
    --plog("cellNextdata")
    local _lab = obj:GetChild("n0")--self.curDec
    _lab.text =  self.nextDec
    obj.height = _lab.height + 20
end

--设置当前选中技能信息
function SkillPanel:setSelectData(data)
    -- body
    local confData = self.confData[self.selectindex+1]
    local data = self:getServerSkill(confData.id)
    local level = data and data.skillLevel or 1
    local affectData = conf.SkillConf:getSkillByIdAndLevel(confData.id,level)

    if not affectData then
        return
    end

    self.decPower.text = math.floor((affectData.power/10)*1.1)
    --技能名字
    self.iconSkill.text = confData.name--"ui://nrhffbtdi6pox"--UIPackage.GetItemURL("skill" , "font"..confData.id)
--等级
    self.dec1.text =  string.format(language.skill03,level) 
    --类型
    self.dec2.text = string.format(language.skill04,confData.etypedec) 
    --cd
    if affectData and affectData.cd_time then
        self.dec3.text = string.format(language.skill05,affectData.cd_time/1000)
    else
        self.dec3.text = ""
    end
    --当前等级效果
    self.curDec = ""
    local nextconf = nil  
    if data then --返回就是激活了
        self.controllerC2.selectedIndex = 0
        self.curDec = affectData.dec
        self.listViewJihuo.numItems = 1
        nextconf = conf.SkillConf:getSkillByIdAndLevel(confData.id,level+1)

        self.controllerC3.selectedIndex = 1
    else --没有激活
        local str = ""
        if affectData.stype == 1 then
            str = language.skill06
        else
            str = string.format(language.skill07,confData.open_lvl)
        end
        self.controllerC2.selectedIndex = 1
        self.curDec = str
        self.listViewCur.numItems = 1
        
        nextconf = affectData

        self.controllerC3.selectedIndex = 0
    end
    --下级效果
    self.nextDec = ""
    if not nextconf then
        self.nextDec = language.skill08
    else
        self.nextDec = nextconf.dec
    end
    self.listViewNext.numItems = 1
    --升级条件
    self.iscanUp = {false,false}
    if affectData.up_condition then
        for k ,v in pairs(affectData.up_condition) do
            if k == 1 then
                self.decTiaojian1.text = language.skill09
                local str = ""
                local activeLv = cache.PlayerCache:getSkins(14) or 0
                local attrConfData = conf.ImmortalityConf:getAttrDataByLv(v)
                local sign = cache.PlayerCache:getAttribute(20139)
                if (activeLv>=v and activeLv%10 ~= 0) or (activeLv%10 == 0 and sign ~= 0 and activeLv >= v) then
                    self.iscanUp[1] = true --等级满足
                    str = mgr.TextMgr:getTextColorStr(attrConfData.name.. attrConfData.period_name .."  "..language.skill12,7)
                else
                    str = mgr.TextMgr:getTextColorStr(attrConfData.name.. attrConfData.period_name .."  "..language.skill11,14)
                end 
                self.decTiaojian1Value.text = str
            else
                if v > 0 then
                    self.decTiaojian2.text = language.skill10

                    local money = cache.PlayerCache:getTypeMoney(MoneyType.copper)
                    +cache.PlayerCache:getTypeMoney(MoneyType.bindCopper)

                    local str = ""
                    if money >= v then
                        self.iscanUp[2] = true --铜钱满足
                        str = mgr.TextMgr:getTextColorStr(v .."  "..language.skill12,7)
                    else
                        str = mgr.TextMgr:getTextColorStr(v .."  "..language.skill11,14)
                    end
                    self.decTiaojian2Value.text = str 
                else
                    self.iscanUp[2] = true --铜钱满足
                    self.decTiaojian2.text = ""
                    self.decTiaojian2Value.text = ""
                end             
            end
        end
    else
        self.decTiaojian1.text = ""
        self.decTiaojian1Value.text = ""

        self.decTiaojian2.text = ""
        self.decTiaojian2Value.text = ""
    end

    --plog("confData.stype") 1 主动技能 2 被动 3 普通
    if tonumber(confData.stype) == 1 then
        self.btnShowSkill.visible = true
        self.imgShow.visible = true
    else
        self.btnShowSkill.visible = false
        self.imgShow.visible = false
    end
    --红点清理
    -- for k ,v in pairs(self.iscanUp) do
    --     if v then
    --         mgr.GuiMgr:redpointByID(10219)
    --         break
    --     end
    -- end
end

--技能展示
function SkillPanel:onbtnShowSkill()
    -- body
    if Time.getTime() - (self.playTime or 0 )> 2 then
        self.playTime = Time.getTime()

        local confData = self.confData[self.selectindex+1]
        if confData then
            local skllid = confData.id.."01"
            local confAction = conf.SkillConf:getSkillConfByid(skllid)
            if confAction then
                self.modelObj:startFight(confData.id, confAction.action.."0")

                local effectid = confAction.attack_effect[1]
                local effectConf = conf.EffectConf:getEffectById(effectid)
                if effectConf.next_effect then
                    if checkint(effectConf.next_effect[1][2]) ~= 0 then
                        effectid = effectConf.next_effect[1][2]
                    end
                end

                local e = self.parent:addEffect(effectid,self.view:GetChild("n0"))
                e.LocalPosition = Vector3.New(self.panle_model.actualWidth/2,-self.panle_model.actualHeight+180,500)
                e.Scale = Vector3.New(130,130,130) 
                if confAction.attack_effect[1] == 4010208 or 4010108 == confAction.attack_effect[1]  then
                    e.LocalRotation = Vector3.New(20,-135,0) --特殊旋转角度
                    self.modelObj:setRotationXYZ(0,-135,0) --模型角度
                else
                    e.LocalRotation = Vector3.New(20,-180,0)--特效旋转角度
                    self.modelObj:setRotationXYZ(0,180,0)--模型角度
                end 
            end
        end
    else
        --plog("需要间隔")
    end
end



--升级技能
function SkillPanel:onbtnUpskill()
    -- body
    if not self.data then
        return
    end
    
    if not self.iscanUp then
        GComAlter(language.skill13)
        return
    end

    for k ,v in pairs(self.iscanUp) do
        if not v then
            if k == 1 then
                GComAlter(language.gonggong06)
            else
                GComAlter(language.gonggong05)
            end
            --
            return
        end
    end

    local confData = self.confData[self.selectindex+1]
    local param = {}
    param.reqType = 1
    param.skillId = confData.id
    proxy.SkillProxy:send(1110102,param)
    
end
--一键升级所有技能
function SkillPanel:onOneKeyUp()
    -- body
    if not self.data then
        return
    end

    local flag = false
    for k ,v in pairs(self.confData) do
        local data = self:getServerSkill(v.id)
        if data then --有这个技能
            local affectData = conf.SkillConf:getSkillByIdAndLevel(v.id,data.skillLevel)
            if self:isCanUpSkill(affectData) then
                flag = true
                break
            end
        end
    end
    if not flag then
        GComAlter(language.skill14)
        return
    end
    local param = {}
    param.reqType = 2
    param.skillId = 0
    proxy.SkillProxy:send(1110102,param)
end


function SkillPanel:onBtnRadio(context)
    -- body
    if not self.data then
        print("1")
        return
    end
    if not self.selectindex then
        print("2")
        return
    end
    local confData = self.confData[self.selectindex+1]
    if not confData then
        print("3")
        return
    end
    local btn = context.sender
    local index = btn.selected and 1 or 0
    print("存入confData.id",index)
    UPlayerPrefs.SetInt(confData.id.."_SkillPanel",index)
end
return SkillPanel