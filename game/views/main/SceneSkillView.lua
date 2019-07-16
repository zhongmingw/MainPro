--
-- Author: 
-- Date: 2017-10-12 19:17:50
--

local SceneSkillView = class("SceneSkillView", base.BaseView)

function SceneSkillView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level1 
end

function SceneSkillView:initView()

end

function SceneSkillView:setData(data_)

end

function SceneSkillView:initData()
    -- body
    if self._timer then
        self:removeTimer(self._timer)
        self._timer = nil
    end
    if self._timerBegin then
        self:removeTimer(self._timerBegin)
        self._timerBegin = nil 
    end
    --移除当前界面上的按钮
    if self.btnlist then
        for k ,v in pairs(self.btnlist) do
            v:Dispose()
        end
    end
    self.btnlist = {}

    self.textDes = nil 
    self.textBG = nil
    --self.view:RemoveChildren()
    if self.coolTimer then
        for k ,v in pairs(self.coolTimer) do
            self:removeTimer(v)
        end
    end
    self.coolTimer = {}
    --技能冷却
    self.coolData = {}
    --按场景ID读取当前场景的技能
    local sId = cache.PlayerCache:getSId()
    self.confdata = conf.SceneConf:getSceneSkill(sId)
    if not self.confdata then
        --场景无技能
        return
    end
    self.skilllist = self.confdata.skill_id_1
    if self.confdata.skill_id_2 and #self.confdata.skill_id_2 > 0 then
        --区分男女
        if cache.PlayerCache:getSex() == 2 then
            self.skilllist = self.confdata.skill_id_2
        end
    end

    self.callback = {}
    --设置技能
    for k , v in pairs(self.skilllist) do
        local confdata = conf.SkillConf:getSkillConfByid(v[1])
        local preid = confdata.s_pre

        local _affect = conf.SkillConf:getSkillByIdAndLevel(preid,1)
        local coolTime = _affect.cd_time/1000

        local var = UIPackage.CreateObject("main" , "CoolDownBtnScene")
        var = self.view:AddChild(var)
        table.insert(self.btnlist,var)


        var.data = v[1]
        var.x = v[2]
        var.y = v[3]- 35
        var:GetChild("icon").url = ResPath.iconRes(preid)
        var:GetChild("n6").asImage.fillAmount = 0
        var.title = _affect.name
        var.onClick:Add(self.onSkillCall,self)

        self.callback[var.name] =  function(p1,p2)
            -- body
            self:LongPressReduce(p1,p2)
        end
        self:LongPress(var,self.callback[var.name])

        var:AddRelation(self.view,RelationType.Right_Right)
        var:AddRelation(self.view,RelationType.Top_Top)
        
        self.coolData[v[1]] = {
            totalTime = coolTime, 
            curTime = coolTime, 
            btn=var, 
            cool=false
        }
    end

    if self.skilllist then 
        --EVE 设置技能表描述文本
        local textDesPanel = UIPackage.CreateObject("main" , "SceneSkillText")
        textDesPanel = self.view:AddChild(textDesPanel)
        table.insert(self.btnlist,textDesPanel)
        textDesPanel.x = 886
        textDesPanel.y = 154
        self.textBG = textDesPanel:GetChild("n0")
        self.textBG.visible = false
        self.textDes = textDesPanel:GetChild("n1")
        self.textDes.text = ""
        --EVE END
    end 
end

function SceneSkillView:LongPressReduce(btn,falg)
    -- body
    -- plog(btn.data,falg)
    if not self.textBG or not self.textDes then
        return
    end

    if not falg then
        self:removeTimer(self._timer)
        self._timer = nil 
        self.textDes.text = ""
        self.textBG.visible = false
    else
        if not self._timer then
            
            local skillId = btn.data
            local confdata = conf.SkillConf:getSkillConfByid(skillId)
            local _affect = conf.SkillConf:getSkillByIdAndLevel(confdata.s_pre,1)
            self.textBG.visible = true
            self.textDes.text = _affect.dec
            -- print("长按完成",_affect.dec)          
        end
    end
end

--长按测试
function SceneSkillView:LongPress(btn,callback,timer)
    -- body
    if not btn then
        return
    end

    btn.onTouchBegin:Clear()
    btn.onTouchEnd:Clear()
    btn.onRollOut:Clear()

    btn.onTouchBegin:Add(self.onTouchBegin,self)
    btn.onTouchEnd:Add(self.onTouchEnd,self)
    btn.onRollOut:Add(self.onTouchEnd,self)
end

function SceneSkillView:onTouchBegin(context)
    -- body
    local btn = context.sender

    if self._timerBegin then
        self:removeTimer(self._timerBegin)
        self._timerBegin = nil 
    end

    self._timerBegin = self:addTimer(0.5, 1, function()
        -- body
        self.callback[btn.name](btn,true)
    end, "SceneSkillView")
end

function SceneSkillView:onTouchEnd(context)
    -- body
    local btn = context.sender
    self:removeTimer(self._timerBegin)
    self._timerBegin = nil 
    if self.callback[btn.name] then
        self.callback[btn.name](btn,false)
    end
end

function SceneSkillView:onSkillCall(context)
    -- body
    local btn = context.sender
    local id = btn.data
    if not id then
        return
    end
    if not self.coolData[id] then
        return
    end
    if self.coolData[id].cool then
        --冷却中
        return
    end
    gRole:skillAttack(id)
end


function SceneSkillView:coolDown(sId)
    if not sId or not self.coolData then
        return
    end
    if not self.coolData[sId] then return end
    local coolInfo = self.coolData[sId]
    local coolTimer = self.coolTimer[sId]

    if coolInfo.cool == false then
        local btn = coolInfo.btn
        -- btn.touchable = false --EVE 原因：技能冷却时也需要长按查看技能描述，下同
        coolInfo.cool = true

        local mask = btn:GetChild("n6").asImage
        local shap = btn:GetChild("n9")

        local totalT = coolInfo.totalTime
        local cutT = coolInfo.curTime
        mask.fillAmount = 1-(totalT - cutT) / totalT

        local delay = 0.2

        self:removeTimer(coolTimer)
        self.coolTimer[sId] = self:addTimer(delay, -1, function()
            -- body
            --防止错误
            if coolInfo.cool == false then
                -- btn.touchable = true --EVE
                mask.fillAmount = 0
                self:removeTimer(coolTimer)
                return 
            end
            --plog(coolInfo.curTime,"coolInfo.curTime")
            coolInfo.curTime = coolInfo.curTime - delay
            mask.fillAmount = 1-(totalT - coolInfo.curTime) / totalT
            if coolInfo.curTime < 0.1 then
                coolInfo.curTime = coolInfo.totalTime
                coolInfo.cool = false
                mask.fillAmount = 0
                -- btn.touchable = true --EVE 

                self:playEff(shap,4020106)
                self:removeTimer(coolTimer)
            end
        end)
    end
end

function SceneSkillView:playEff(panel,id)
    if panel.data then
        self:removeUIEffect(panel.data)
        panel.data = nil
    end
    panel.data = self:addEffect(id,panel)
    panel.data.LocalPosition = Vector3.New(panel.width/2,-panel.height/2,-50)
end

return SceneSkillView