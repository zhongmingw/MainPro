--
-- Author: Your Name
-- Date: 2018-07-23 17:05:07
--
--帝王将相
local DiWangView = class("DiWangView", base.BaseView)

function DiWangView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
end

function DiWangView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n3")
    self:setCloseBtn(closeBtn)
    local guizeBtn = self.view:GetChild("n1")
    guizeBtn.onClick:Add(self.onClickGuize,self)
    self.roleList = {}
    for i=1,10 do
        local item = self.view:GetChild("btn"..i)
        table.insert(self.roleList,item)
    end
    self.huifuTime = self.view:GetChild("n4")
    self.huifuBtn = self.view:GetChild("n2")
    self.huifuBtn.onClick:Add(self.onClickHuiFu,self)
    self.xianweiTitleBtn = self.view:GetChild("n5")
    self.xianweiTitleBtn.onClick:Add(self.onClickTitle,self)
    self.decTxt = self.view:GetChild("n3")
end

function DiWangView:onTimer()
    if self.leftColdTime > 0 then
        self.leftColdTime = self.leftColdTime - 1
        self.huifuTime.text = GTotimeString3(self.leftColdTime)
        self.huifuBtn.visible = true
        self.decTxt.text = language.diwang09
    else
        self.huifuTime.text = ""
        self.huifuBtn.visible = false
        self.decTxt.text = language.diwang10
    end
end

function DiWangView:initData()
    self.leftColdTime = 0
    self.huifuTime.text = ""
    self.huifuBtn.visible = false
    self.decTxt.text = language.diwang10
end

--加载模型
function DiWangView:initModel()
    -- for k,v in pairs(self.roleList) do
    --     local item = v
    --     local modelPanel = item:GetChild("n1")
    --     local nameTxt = item:GetChild("n0")
    --     nameTxt.text = self.roleListData[k].roleName
    --     local clothesId = self.roleListData[k].skins[1]
    --     local wuqiId = self.roleListData[k].skins[2]

    --     local modelObj = self:addModel(clothesId,modelPanel)
    --     modelObj:setSkins(nil,wuqiId,nil)
    --     modelObj:setScale(70)
    --     modelObj:setPosition(0,-400,1100)
    --     modelObj:setRotationXYZ(0,150,0)
    --     item.data = self.roleListData[k]
    --     item.onClick:Add(self.onClickGetXianWeiView,self)
    -- end
    local num = 1
    self:addTimer(0.02, 10, function()
        local item = self.roleList[num]
        local modelPanel = item:GetChild("n1")
        local nameTxt = item:GetChild("n0")
        nameTxt.text = self.roleListData[num].roleName
        local roleId = self.roleListData[num].roleId --玩家id
        local uId = string.sub(roleId,1,3)
         item:GetChild("n9").visible = false
        if cache.PlayerCache:getRedPointById(10327) ~= tonumber(uId) and tonumber(roleId) > 10000 then
           
            item:GetChild("n9").visible = true
        end
        local clothesId = self.roleListData[num].skins[1]
        local wuqiId = self.roleListData[num].skins[2]
        --服装模型是否带有特效
        local modelData = conf.RoleConf:getFashionUiModel(clothesId)
        if modelData then
            clothesId = modelData.modelId .. "_s"--模型缩放
        end

        local modelObj = self:addModel(clothesId,modelPanel)
        modelObj:setSkins(nil,wuqiId,nil)
        modelObj:setScale(70)
        modelObj:setPosition(0,-400,1100)
        modelObj:setRotationXYZ(0,150,0)
        item.data = self.roleListData[num]
        item.onClick:Add(self.onClickGetXianWeiView,self)
        num = num + 1
    end)
end

--外部跳转
function DiWangView:nextSkip(rank)
    self.skipRank = rank
end

-- int64   变量名: roleId 说明: 角色id
-- 2   string  变量名: roleName   说明: 角色名
-- 3   int32   变量名: power  说明: 战力
-- 4   int32   变量名: roleIcon   说明: 头像
-- 5   map<int32,int32>    变量名: skins  说明: 外观
-- 6   int32   变量名: rank   说明: 玩家排名
-- 7   int8    变量名: robot  说明: 1表示机器人
function DiWangView:setData(data)
    printt("帝王将相信息>>>>>>>>>>>>>",data)
    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil
    end
    self.leftColdTime = data.leftColdTime
    self.rank = data.rank
    if self.leftColdTime > 0 then
        self.huifuTime.text = GTotimeString3(self.leftColdTime)
        self.decTxt.text = language.diwang09
    else
        self.huifuTime.text = ""
        self.decTxt.text = language.diwang10
    end
    self.timer = self:addTimer(1, -1, handler(self, self.onTimer))
    self.roleListData = data.roles
    table.sort(self.roleListData,function(a,b)
        if a.rank ~= b.rank then
            return a.rank < b.rank
        end
    end)
    self:initModel()
    --外部跳转时
    if self.skipRank then
        local item = self.roleList[self.skipRank]
        item.data = self.roleListData[self.skipRank]
        item.onClick:Add(self.onClickGetXianWeiView,self)
        item.onClick:Call()
    end
end

function DiWangView:refreshCdTime(data)
    self.leftColdTime = data.leftColdTime
end

function DiWangView:onClickHuiFu()
    if self.leftColdTime > 0 then
        mgr.ViewMgr:openView2(ViewName.DiWangHuiFuTips, {leftColdTime = self.leftColdTime})
    end
end

function DiWangView:onClickGetXianWeiView(context)
    local data = context.sender.data
    mgr.ViewMgr:openView2(ViewName.XianWeiDetails, {roleData = data,leftColdTime = self.leftColdTime,myRank = self.rank})
end

function DiWangView:onClickTitle()
    mgr.ViewMgr:openView2(ViewName.XianWeiAttr, {})
end

function DiWangView:onClickGuize()
    GOpenRuleView(1111)
end

return DiWangView