--
-- Author: Your Name
-- Date: 2017-07-24 17:16:16
--
READYTIME = 20

local DujieView = class("DujieView", base.BaseView)

function DujieView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function DujieView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    closeBtn.onClick:Add(self.onCloseView,self)
    self.dujieBtn = self.view:GetChild("n24")
    self.dujieBtn.onClick:Add(self.onClickDujie,self)
    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController1,self)
    self.agreeBtn = self.view:GetChild("n35")
    self.agreeBtn.onClick:Add(self.onClickAgree,self)
    self.refuseBtn = self.view:GetChild("n34")
    self.refuseBtn.onClick:Add(self.onClickRefuse,self)
    self.suggestPower = self.view:GetChild("n9")
    self.sumPowerTxt = self.view:GetChild("n10")
    self.dujieDecTxt = self.view:GetChild("n1")
    self.CDText = self.view:GetChild("n13")
    self.descText = self.view:GetChild("n12")
    self.readyTimeTxt = self.view:GetChild("n37")
    self.listView = self.view:GetChild("n25")
    self:initListView()
    self.powerSum = 0--队伍总战力
    self.djLevel = 0 --渡劫等级
    self.teamMembers = {} --组队信息
    self.roleList = {}
    self:initRoleInfo()
end

function DujieView:initListView()
    -- body
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
end

function DujieView:celldata( index,obj )
    local itemData = self.awards[index+1]
    local mId = itemData[1]
    local amount = itemData[2]
    local bind = 1
    local info = {mid = mId, amount = amount, bind = bind}
    GSetItemData(obj,info,true)
end

function DujieView:initData(data)
    self.descText.text = language.xiuxian26
    self.isDujie = false
    self.c1.selectedIndex = data and data.index or 0
end

--重置同意状态
function DujieView:resetAgree(flag)
    self.isAgree = flag
    self.readyTime = 20
end

--界面设置
function DujieView:initInfo()
    local roleId = cache.PlayerCache:getRoleId()
    local isCaptain = cache.TeamCache:getIsCaptain(roleId)
    if isCaptain then--如果我是队长
        self.dujieBtn.grayed = false
        self.dujieBtn.touchable = true
        self.dujieBtn.visible = true
        self.view:GetChild("n38").visible = false
        self.view:GetChild("n36").visible = false
        self.readyTimeTxt.visible = false
        self.CdLeftTime = cache.PlayerCache:getDujieCD()
        -- print("剩余CD时间",self.CdLeftTime)
        if self.timer then
            mgr.TimerMgr:removeTimer(self.timer)
            self.timer = nil
            self.readyTime = nil
        end
        if self.CdLeftTime > 0 then
            self.CDText.visible = true
            self.CDText.text = GTotimeString(self.CdLeftTime) .. language.xiuxian11
            self.timer = self:addTimer(1, -1, handler(self,self.onTimer))
        else
            -- print("队长是否点了渡劫",self.isDujie)
            if self.isDujie then
                if self.timer then
                    mgr.TimerMgr:removeTimer(self.timer)
                    self.timer = nil
                    self.CdLeftTime = nil
                end
                self.view:GetChild("n38").visible = true
                self.view:GetChild("n36").visible = true
                self.readyTimeTxt.visible = true
                self.dujieBtn.visible = false
                self.readyTime = 20
                self.readyTimeTxt.text = "("..self.readyTime..")"
                self.timer = self:addTimer(1, -1, handler(self,self.onTimer))
            else
                self.CDText.visible = false
            end
        end
    else
        self.CDText.visible = false
        self.view:GetChild("n38").visible = true
        self.view:GetChild("n36").visible = true
        self.readyTimeTxt.visible = true
        if self.timer then
            mgr.TimerMgr:removeTimer(self.timer)
            self.timer = nil
            self.CdLeftTime = nil
        end
        if self.readyTime then
            self.readyTimeTxt.text = "("..self.readyTime..")"
        else
            self.readyTimeTxt.text = "(0)"
        end
        self.timer = self:addTimer(1, -1, handler(self,self.onTimer))
        if 0 == self.c1.selectedIndex then
            self.dujieBtn.grayed = true
            self.dujieBtn.touchable = false
            self.CDText.visible = false
        end
    end
end

function DujieView:onTimer()
    if self.CdLeftTime then
        self.CdLeftTime = self.CdLeftTime - 1
        if self.CdLeftTime > 0 then
            self.CDText.text = GTotimeString(self.CdLeftTime) .. language.xiuxian11
        else
            self.CDText.visible = false
        end
    end
    if self.readyTime then
        self.readyTime = self.readyTime - 1
        if self.readyTime > 0 then
            self.readyTimeTxt.text = "("..self.readyTime..")"
        else
            self.readyTimeTxt.text = "(0)"
            local roleId = cache.PlayerCache:getRoleId()
            local isCaptain = cache.TeamCache:getIsCaptain(roleId)
            if isCaptain then
                self:setIsDujie(false)
                proxy.ImmortalityProxy:sendMsg(1290203)
            else
                -- print("self.isAgree111",self.isAgree)
                if not self.isAgree then
                    self:onClickRefuse()
                else
                    -- print("关闭")
                    self:resetAgree(false)
                    self:refreshAgree(false)
                    if self.timer then
                        mgr.TimerMgr:removeTimer(self.timer)
                        self.timer = nil
                        self.readyTime = nil
                        if self.CdLeftTime then
                            cache.PlayerCache:setDujieCD(self.CdLeftTime)
                            self.CdLeftTime = nil
                        end
                    end
                    self.isDujie = false
                    self:closeView()
                end
            end
        end
    end
end

function DujieView:onController1()
    --请求队员准备状态
    proxy.ImmortalityProxy:sendMsg(1290203)
end

function DujieView:onClickAgree()
    proxy.ImmortalityProxy:sendMsg(1290202,{reqType = 1})
end

function DujieView:onClickRefuse()
    proxy.ImmortalityProxy:sendMsg(1290202,{reqType = 2})    
end

--同意刷新
function DujieView:refreshAgree(flag)
    self.agreeBtn.visible = not flag
    self.refuseBtn.visible = not flag
    self.view:GetChild("n38").visible = flag
end

function DujieView:updateTeamInfo(data)
    -- printt("队伍信息",data)
    self.teamMembers = cache.TeamCache:getTeamMembers()
    local readyMap = data and data.readyMap or {}
    local djLevel = data and data.djLev or 0--渡劫等级
    local powerSum = 0
    self.djLevel = djLevel
    for k,v in pairs(self.teamMembers) do
        local roleItem = self.roleList[k]
        local roleIcon = roleItem:GetChild("n9"):GetChild("n0")
        local nameText = roleItem:GetChild("n3")
        local powerText = roleItem:GetChild("n4")
        local addBtn = roleItem:GetChild("n5")
        local captainIcon = roleItem:GetChild("n6")
        local readyIcon = roleItem:GetChild("n7")
        local roleInfoBtn = roleItem:GetChild("n8")
        addBtn.onClick:Add(self.addTeamMembers,self)
        if v and v.roleId then
            roleInfoBtn.data = {data = v,index = k}
            roleInfoBtn.onClick:Add(self.onClickRole,self)
            if v.captain == 1 then--1队长,否则普通队员
                captainIcon.visible = true
                readyIcon.visible = false
            else
                readyIcon.visible = true
                captainIcon.visible = false
            end
            roleIcon.visible = true
            roleInfoBtn.visible = true
            addBtn.visible = false
            -- local roleIconUrl = GGetMsgByRoleIcon(v.roleIcon).headUrl
            roleIcon.url = GGetMsgByRoleIcon(v.roleIcon,v.roleId,function(t)
                if roleIcon then
                    roleIcon.url = t.headUrl
                end
            end).headUrl
            -- roleIcon.url = roleIconUrl
            if readyMap[v.roleId] == 1 then
                readyIcon.url = UIPackage.GetItemURL("immortality" , "dujie_001")
            else
                readyIcon.url = UIPackage.GetItemURL("immortality" , "dujie_002")
            end
            nameText.text = v.roleName
            powerText.text = v.power
            powerSum = powerSum + v.power
        else
            readyIcon.visible = false
            captainIcon.visible = false
            roleIcon.visible = false
            roleInfoBtn.visible = false
            addBtn.visible = true
            nameText.text = language.xiuxian19
            powerText.text = 0
        end
    end
    --护法奖励
    local confData = conf.ImmortalityConf:getAttrDataByLv(djLevel)
    local awards = confData.hufa_awards
    if awards then
        self.awards = awards
        self.listView.numItems = #self.awards
    end
    --渡劫描述
    if confData.dujie_dec then
        self.dujieDecTxt.text = confData.dujie_dec
    end
    self.sumPowerTxt.text = language.xiuxian10 .. powerSum
    self.powerSum = powerSum
    if confData.suggest_power then
        self.suggestPower.text = language.xiuxian12 .. confData.suggest_power
    else
        self.suggestPower.visible = false
    end
    self:initInfo()
end

--申请渡劫界面显示
function DujieView:applyShow()
    self.c1.selectedIndex = 1
    self.agreeBtn.visible = true
    self.refuseBtn.visible = true
    self.view:GetChild("n38").visible = false
end

--打开邀请组队
function DujieView:addTeamMembers()
    mgr.ViewMgr:openView(ViewName.TeamSearchView, function(view)
        view:onController1()
    end)
end

function DujieView:initRoleInfo()
    for i=31,33 do
        local roleItem = self.view:GetChild("n"..i)
        table.insert(self.roleList,roleItem)
    end
end

function DujieView:setIsDujie(flag)
    self.isDujie = flag
end

function DujieView:onClickDujie()
    local xiuxianLv = cache.PlayerCache:getSkins(14) or 0
    local attrConf = conf.ImmortalityConf:getAttrDataByLv(xiuxianLv)
    local var = cache.PlayerCache:getAttribute(20139)
    if var == 0 and xiuxianLv > 1 and xiuxianLv%10 == 0 then
        -- local teamNums = cache.TeamCache:getTeamMemberNum()
        -- -- print("队伍信息",teamNums)
        -- if teamNums > 1 then
        --     GComAlter(language.xiuxian21)
        -- end
        -- proxy.ImmortalityProxy:sendMsg(1290201)
        local confData = conf.ImmortalityConf:getAttrDataByLv(xiuxianLv)
        if self.powerSum < confData.suggest_power then
            local param = {}
            param.type = 2
            param.richtext = language.xiuxian27
            param.sure = function()
                self:setIsDujie(true)
                proxy.FubenProxy:send(1027305,{sceneId = GGetDujieSceneId(),reqType = 1})
            end
            param.cancel = function()
                
            end
            GComAlter(param)
        else
            self:setIsDujie(true)
            proxy.FubenProxy:send(1027305,{sceneId = GGetDujieSceneId(),reqType = 1})
        end
        
    else
        GComAlter(language.xiuxian17)
    end
end

function DujieView:onClickRole(context)
    -- body
    local data = context.sender.data.data
    local index = context.sender.data.index
    local posList = {
        [1] = {0,60},
        [2] = {249,60},
        [3] = {500,60},
    }
    local pos = posList[index]
    if data and data.roleId and data.roleId ~= cache.PlayerCache:getRoleId() then
        local params = {roleId = data.roleId,roleName = data.roleName,level = data.level,captain = data.captain,teamId = data.teamId,pos = {x = pos[1],y = pos[2]},roleIcon = data.roleIcon,trade = true}
        mgr.ViewMgr:openView(ViewName.FriendTips,function(view)
            view:setData(params)
        end)
    end
end

function DujieView:onCloseView()
    -- body
    if self.timer then
        mgr.TimerMgr:removeTimer(self.timer)
        self.timer = nil
        self.readyTime = nil
        if self.CdLeftTime then
            cache.PlayerCache:setDujieCD(self.CdLeftTime)
            self.CdLeftTime = nil
        end
    end
    self.isDujie = false
    self:refreshAgree(false)
    self:resetAgree(false)
    local roleId = cache.PlayerCache:getRoleId()
    local isCaptain = cache.TeamCache:getIsCaptain(roleId)
    if not isCaptain then
        local isNotTeam = cache.TeamCache:getIsNotTeam()
        if not isNotTeam then
            self:onClickRefuse()
        end
    end
    self:closeView()
end

return DujieView