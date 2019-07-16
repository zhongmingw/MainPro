--
-- Author: 
-- Date: 2018-11-26 19:10:27
--

local DiHunMainView = class("DiHunMainView", base.BaseView)
local VALUE = {0,0,8,18,36,66,80,91,100}--拱形进度条value不固定

function DiHunMainView:ctor()
    DiHunMainView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function DiHunMainView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)

    self.goBtn = self.view:GetChild("n6")
    self.goBtn.onClick:Add(self.onClickCallBack,self)

    local ruleBtn = self.view:GetChild("n9")
    ruleBtn.onClick:Add(self.onClickCallBack,self)

    self.listView = self.view:GetChild("n18")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView:SetVirtual()

    -- self.diHunTitle = self.view:GetChild("n3")
    self.diHunIcon = self.view:GetChild("n13")  
    self.dec = self.view:GetChild("n14")
    self.leftTimeTxt = self.view:GetChild("n15")

    self.bar = self.view:GetChild("n7"):GetChild("n8")
    self.taskList = {}
    for i=1,8 do
        local btn = self.view:GetChild("n7"):GetChild("n"..(i+8))
        btn.data = i
        table.insert(self.taskList,btn)
    end

    self.modelPanel = self.view:GetChild("n8")
    self.effectPanel = self.view:GetChild("n20")
    
end

function DiHunMainView:initData()

    local skillConf = conf.DiHunConf:getDhSkillById(1001)--这个界面暂时作成固定的
    self.diHunIcon.icon = ResPath.iconRes(skillConf.skill_icon)
    self.dec.text = skillConf.ms

       --设置模型
    local confData = conf.DiHunConf:getDiHunInfoByType(1)
    local  modelObj = self:addModel(confData.modle_id,self.modelPanel)
    modelObj:setScale(confData.scale)
    modelObj:setRotationXYZ(confData.rot[1],confData.rot[2],confData.rot[3])
    modelObj:setPosition(53,-383,500)


  
end


function DiHunMainView:addMsgCallBack(data)
    -- printt("返回data",data)
    self.data = data
    self.confData = conf.DiHunConf:getDhTaskInfo()
    
    for k,v in pairs(self.confData) do
        if #v == 1 then
            if self.data.gotSigns[k+1000] then
                v.sort = 2--已领取
            else
                local finishTime = self.data.taskInfo[v[1].id] or 0
                if finishTime >= v[1].condition[1]  then
                    v.sort = 0--可领取
                else
                    v.sort = 1--未达成
                end
            end
        else
            if self.data.gotSigns[k+1000] then
                v.sort = 2--已领取
            else
                local finishTime = self.data.taskInfo[v[1].id] or self.data.taskInfo[v[2].id] or 0
                local _condition = 1
                if self.data.taskInfo[v[1].id] then
                    _condition = v[1].condition[1]
                elseif self.data.taskInfo[v[2].id] then
                    _condition = v[2].condition[1]
                end
                if finishTime >= _condition  then
                    v.sort = 0--可领取
                else
                    v.sort = 1--未达成
                end
            end 
        end
    end
    table.sort(self.confData,function(a,b)
        return a.sort < b.sort
    end)
    self.listView.numItems = table.nums(self.confData)

    self.effectPanel.visible = #self.data.gotSigns < 8
    local effectObj = self:addEffect(4020184,self.effectPanel)
    effectObj.LocalRotation = Vector3.New(0,180,0)
    effectObj.LocalPosition = Vector3.New(50,45,-50)
    
    local dhInfo = cache.DiHunCache:getDiHunInfoByType(1)--固定雷神
    if dhInfo.star == -1 then--未激活
        self.effectPanel.visible = true
        self.goBtn.visible = true
    else
        self.effectPanel.visible = false
        self.goBtn.visible = false
    end

    self:setBar()
    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
    self.time = data.leftTime
    self.leftTimeTxt.text = GTotimeString2(self.time)
end

function DiHunMainView:setBar()
    for k,v in pairs(self.taskList) do
        local c1 = v:GetController("c1")
        local icon = v:GetChild("n2")
        local str = "dihun_0"..(v.data+17)
        icon.url = UIPackage.GetItemURL("dihun",str)
        local effectPanel = v:GetChild("n3")
        if v.data <= table.nums(self.data.gotSigns) then
            c1.selectedIndex = 0
            effectPanel.visible = true
            local effectObj = self:addEffect(4020183,effectPanel)
            effectObj.LocalPosition = Vector3.New(effectPanel.width/2,-effectPanel.height/2,-50)
        else
            c1.selectedIndex = 1
            effectPanel.visible = false
        end
    end
    self.bar.value = VALUE[table.nums(self.data.gotSigns)+1]

end

function DiHunMainView:cellData(index,obj)
    local c1 = obj:GetController("c1")
    local itemObj = obj:GetChild("n20")
    local name = obj:GetChild("n21")
    local time = obj:GetChild("n22")
    local btn = obj:GetChild("n23")
    btn.onClick:Add(self.onClickListBtn,self)
    local data = self.confData[index+1]
    if data then 
        local t = {}
        t.mid = data[1].items[1]
        t.amount = data[1].items[2]
        t.bind = data[1].items[3]
        GSetItemData(itemObj, t, true)

        local finishTime = 0
        local _condition = 1
        local cfgId = 0
        local skipId = 0

        if #data == 1 then
            name.text = data[1].ms
            _condition = data[1].condition[1]
            finishTime = math.min((self.data.taskInfo[data[1].id] or 0) ,_condition)
            cfgId = data[1].id
            skipId = data[1].skipId
        else
            name.text = data[1].ms.."/"..data[2].ms
            if self.data.taskInfo[data[1].id] then
                _condition = data[1].condition[1]
                cfgId = data[1].id
                skipId = data[1].skipId
            elseif self.data.taskInfo[data[2].id] then
                _condition = data[2].condition[1]
                cfgId = data[2].id
                skipId = data[2].skipId
            end
            finishTime = math.min((self.data.taskInfo[data[1].id] or self.data.taskInfo[data[2].id] or 0),_condition)
        end
        local color = finishTime >= _condition and 7 or 14
        local str = finishTime
        time.text = "("..mgr.TextMgr:getTextColorStr(str,color).."/".._condition..")"
        if data.sort == 0 then
            c1.selectedIndex = 1 --可领取
        elseif data.sort == 1 then
            c1.selectedIndex = 0 --不可领
        elseif data.sort == 2 then
            c1.selectedIndex = 2 --已领取
        end
        -- local preId = math.floor(data.id/1000)
        -- if self.data.gotSigns[preId] then
        --     c1.selectedIndex = 2 --已领取
        -- else
        --     if color == 7 then
        --         c1.selectedIndex = 1 --可领取
        --     else
        --         c1.selectedIndex = 0 --不可领
        --     end
        -- end
        btn.data = {index = c1.selectedIndex,cfgId = cfgId,skipId = skipId}
    end
end

function DiHunMainView:onClickListBtn(context)
    local btn = context.sender
    local data = btn.data
    local index = data.index
    local cfgId = data.cfgId
    local skipId = data.skipId
    if index == 0 then
        if skipId then
            GOpenView({id = skipId})
        end
    elseif index == 1 then
        proxy.DiHunProxy:sendMsg(1620108,{reqType = 1,cid = cfgId})
    end
end


function DiHunMainView:onTimer()
    if self.time then
        self.leftTimeTxt.text = GTotimeString2(self.time)
        if self.time <= 0 then
            -- self:releaseTimer()
            proxy.DiHunProxy:sendMsg(1620108,{reqType = 0,cid = 0})
        end
        self.time = self.time - 1
    end
end
function DiHunMainView:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

function DiHunMainView:onClickCallBack(context)
    local btn = context.sender
    if btn.name == "n6" then
        GOpenView({id = 1408})
    elseif btn.name == "n9" then
        GOpenRuleView(1164)
    end
end

return DiHunMainView