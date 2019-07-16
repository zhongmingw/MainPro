--
-- Author:
-- Date: 2018-07-23 15:09:58
--奖励展示

local AwardShowPanel = class("AwardShowPanel",import("game.base.Ref"))


function AwardShowPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function AwardShowPanel:initPanel()
    self.c1 = self.mParent.view:GetController("c1")
    self.view = self.mParent.view:GetChild("n3")
    self.ctr1 = self.view:GetController("c1")
    self.bgIcon = self.view:GetChild("n7")
    local dec1 = self.view:GetChild("n10")
    dec1.text = language.xianlv01
    local dec2 = self.view:GetChild("n11")
    dec2.text = language.xianlv02
    
    local goMatch = self.view:GetChild("n8")
    goMatch.onClick:Add(self.onClickMatch,self)

    -- local data = cache.ActivityCache:get5030111()
    -- if data.acts and data.acts[1135] == 1 then
    --     local date1 = self.view:GetChild("n14")
    --     local date2 = self.view:GetChild("n15")
    --     local startTime = cache.PlayerCache:getRedPointById(50130)
        
    --     date1.text = self:toTimeString(startTime+86400)
    --     date2.text = self:toTimeString(startTime+86400+86400)
    -- end


    self.leftPanel = self.view:GetChild("n16")
    self.rightPanel = self.view:GetChild("n17")

end

function AwardShowPanel:addMsgCallBack(data)
    self.data = data
    --多开活动配置
    self.mulConfData = conf.ActivityConf:getMulActById(self.data.mulActiveId)
    local bgIconStr = self.mulConfData and self.mulConfData.bg_icon or "xianlvpk_009"
    self.bgIcon.url = UIPackage.GetItemURL("xianlvpk" , bgIconStr)
    if string.trim(bgIconStr) == "xianlvpk_009" or string.trim(bgIconStr) == "xianlvpk_064" then
        self.ctr1.selectedIndex = 0--左侧浅色
    elseif string.trim(bgIconStr) == "xianlvpk_065" or string.trim(bgIconStr) == "xianlvpk_068" then
        self.ctr1.selectedIndex = 1--中间蓝色
    elseif string.trim(bgIconStr) == "xianlvpk_070" then 
        self.ctr1.selectedIndex = 2--中间紫色
    end
    if self.mulConfData and  self.mulConfData.model_id then
        local left = self.mParent:addModel(self.mulConfData.model_id[1][1],self.leftPanel)
        left:setSkins(self.mulConfData.model_id[1][1], self.mulConfData.model_id[1][2])
        left:setScale(140)
        left:setRotationXYZ(0,166,0)
        left:setPosition(45,-170,100)

        local right = self.mParent:addModel(self.mulConfData.model_id[2][1],self.rightPanel)
        right:setSkins(self.mulConfData.model_id[2][1], self.mulConfData.model_id[2][2])
        right:setScale(140)
        right:setRotationXYZ(0,166,0)
        right:setPosition(45,-170,100)
    end

    local date1 = self.view:GetChild("n14")
    -- local actConfData = conf.ActivityConf:getActiveById(1114)--防空
    local actData = cache.ActivityCache:get5030111()
    local startTime = data.startTime
    if data.msgId == 5540101 then--跨服
        if actData.acts and actData.acts[1135] == 1 then--预告
            startTime = startTime + 86400
        elseif actData.acts and actData.acts[1114] == 1 then
             startTime = data.startTime
        end
    elseif data.msgId == 5540201 then--全服
        if actData.acts and actData.acts[5009] == 1 then--预告
            startTime = startTime + 86400
        elseif actData.acts and actData.acts[5010] == 1 then
            startTime = data.startTime
        end
    end


    date1.text = self:toTimeString(startTime)

    local date2 = self.view:GetChild("n15")

    date2.text = self:toTimeString(startTime+86400)
end

function AwardShowPanel:onClickMatch()
    local actData = cache.ActivityCache:get5030111()
    if self.data.msgId == 5540101 then--跨服
        if actData.acts[1135] and actData.acts[1135] == 1 then 
            GComAlter(language.xianlv35)
        else
            self.c1.selectedIndex = 1
        end
    elseif self.data.msgId == 5540201 then--全服
        if actData.acts[5009] and actData.acts[5009] == 1 then 
            GComAlter(language.xianlv35)
        else
            self.c1.selectedIndex = 1
        end
    end

end

function AwardShowPanel:toTimeString(time)
    local timeTab = os.date("*t",time)
    return string.format("%s月%s日",timeTab.month,timeTab.day)
end




return AwardShowPanel