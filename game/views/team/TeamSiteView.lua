--
-- Author: 
-- Date: 2017-11-02 16:32:51
--

local TeamSiteView = class("TeamSiteView", base.BaseView)

local INUM = 10
local ISlIDER = 100

function TeamSiteView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.minLv = 0--记录选择的最低等级
    self.maxLv = 0--记录选择的最高等级
    self.playMaxLv = conf.SysConf:getValue("player_max_lv")
    self.mNum = self.playMaxLv / ISlIDER
end

function TeamSiteView:initView()
    self:setCloseBtn(self.view:GetChild("n2"))
    self.listView = self.view:GetChild("n8")
    -- self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.onClickItem:Add(self.onClickItem,self)
    self.view:GetChild("n9").text = language.team44[1]
    self.view:GetChild("n10").text = language.team44[2]
    self.minLvSlider = self.view:GetChild("n11")--最低等级控制
    self.minLvSlider.onChanged:Add(self.onChangedMinSlider,self)
    self.minLvSlider.onGripTouchEnd:Add(self.onGripMinTouchEnd,self)
    self.minLvText = self.minLvSlider:GetChild("n4")

    self.maxLvSlider = self.view:GetChild("n12")--最高等级控制
    self.maxLvSlider.onChanged:Add(self.onChangedMaxSlider,self)
    self.maxLvSlider.onGripTouchEnd:Add(self.onGripMaxTouchEnd,self)
    self.maxLvText = self.maxLvSlider:GetChild("n4")

    local minLeftBtn = self.view:GetChild("n13")
    minLeftBtn.onClick:Add(self.onClickMinLeft,self)
    local minRightBtn = self.view:GetChild("n14")
    minRightBtn.onClick:Add(self.onClickMinRight,self)
    local maxLeftBtn = self.view:GetChild("n15")
    maxLeftBtn.onClick:Add(self.onClickMaxLeft,self)
    local maxRightBtn = self.view:GetChild("n16")
    maxRightBtn.onClick:Add(self.onClickMaxRight,self)
    local btn = self.view:GetChild("n17")
    btn.onClick:Add(self.onClickBtn,self)
end

function TeamSiteView:initData(data)
    self.teamConfigs = conf.TeamConf:getTeamConfigs()----组队目标
    local index = 0
    self.listView.numItems = #self.teamConfigs
    if data.targetId then
        for k,v in pairs(self.teamConfigs) do
            if v.id == data.targetId then
                index = k - 1
                break
            end
        end
    end
    if #self.teamConfigs > 0 then
        self.listView:ScrollToView(index,false)
        local obj = self.listView:GetChildAt(index)
        obj.onClick:Call()
    end
end

function TeamSiteView:cellData(index, obj)
    local data = self.teamConfigs[index + 1]
    local name = data and data.name or "无"
    obj.title = name
    obj.selectedTitle = name
    obj.data = data
end
--选中目标
function TeamSiteView:onClickItem(context)
    local obj = context.data
    local chooseData = obj.data
    self.confData = conf.TeamConf:getTeamConfig(chooseData.id)
    local lvlSection = self.confData.lv_section or {0,0}
    local num = self.playMaxLv / 100
    self.minLvSlider.value = math.floor(lvlSection[1] / self.mNum)
    self.minLvText.text = lvlSection[1]
    self.minLv = lvlSection[1]
    self.maxLvSlider.value = math.floor(lvlSection[2] / self.mNum)
    self.maxLv = lvlSection[2]
    self.maxLvText.text = lvlSection[2]
end

function TeamSiteView:onChangedMinSlider()
    self.isClick = false
    self:setMinLv()
end

function TeamSiteView:onChangedMaxSlider()
    self.isClick = false
    self:setMaxLv()
end

function TeamSiteView:onGripMinTouchEnd()
    self.isClick = false
    self.minLvSlider.value = math.floor(self.minLv / self.mNum)
end

function TeamSiteView:onGripMaxTouchEnd()
    self.isClick = false
    self.maxLvSlider.value = math.floor(self.maxLv / self.mNum)
end
--设置最低等级
function TeamSiteView:setMinLv()
    local value = self:getValue(math.floor(self.minLvSlider.value / ISlIDER * self.playMaxLv))
    self.minLv = value
    self.minLvText.text = value
    if self.isClick then
        self.minLvSlider.value = math.floor(value / self.mNum)
    end
end

--设置最高等级
function TeamSiteView:setMaxLv()
    local value = self:getValue(math.floor(self.maxLvSlider.value / ISlIDER * self.playMaxLv))
    self.maxLv = value
    self.maxLvText.text = value
    if self.isClick then
        self.maxLvSlider.value = math.floor(value / self.mNum)
    end
end

function TeamSiteView:getValue(value)
    local lvlSection = self.confData.lv_section
    if lvlSection then
        local isTishi = false
        if value <= lvlSection[1] then
            isTishi = true
            value = lvlSection[1]
        elseif value >= lvlSection[2] then
            isTishi = true
            value = lvlSection[2]
        end
        if isTishi then
            GComAlter(string.format(language.team51, lvlSection[1],lvlSection[2]))
        end
    end
    return value
end

function TeamSiteView:onClickMinLeft()
    self.minLvSlider.value = math.max(self.minLvSlider.value - INUM, 0)
    self.isClick = true
    self:setMinLv()
end

function TeamSiteView:onClickMinRight()
    self.minLvSlider.value = math.min(self.minLvSlider.value + INUM, ISlIDER)
    self.isClick = true
    self:setMinLv()
end

function TeamSiteView:onClickMaxLeft()
    self.maxLvSlider.value = math.max(self.maxLvSlider.value - INUM, 0)
    self.isClick = true
    self:setMaxLv()
end

function TeamSiteView:onClickMaxRight()
    self.maxLvSlider.value = math.min(self.minLvSlider.value + INUM, ISlIDER)
    self.isClick = true
    self:setMaxLv()
end

function TeamSiteView:onClickBtn()
    if not self.confData then return end
    local lvlSection = self.confData.lv_section
    if lvlSection then
        local teamMinLv = lvlSection[1]
        if self.minLv < teamMinLv then--最低等级
            GComAlter(string.format(language.team45, teamMinLv))
            return
        end
        
        local sceneId = self.confData.sceneid or 0
        local sceneData = conf.SceneConf:getSceneById(sceneId)
        local lvl = sceneData and sceneData.lvl or 1
        if self.minLv < lvl then--最低等级
            GComAlter(string.format(language.team46, lvl))
        end
        local teamMaxLv = lvlSection[2]
        if self.minLv >= self.maxLv then
            GComAlter(language.team47)
            return
        end
        if self.maxLv > teamMaxLv then--最低等级
            GComAlter(string.format(language.team48, teamMaxLv))
            return
        end
    else
        self.minLv = 0
        self.maxLv = 0
    end
    local siteData = {targetId = self.confData.id,minLvl = self.minLv,maxLvl = self.maxLv}
    if cache.TeamCache:getTeamId() > 0 then
        proxy.TeamProxy:send(1300114,siteData)
    end
    local view = mgr.ViewMgr:get(ViewName.TeamView)
    if view then
        view:setTeamSite(siteData,true)
    end
    self:closeView()
end

function TeamSiteView:closeView()
    self.listView:ScrollToView(0,false)
    self.super.closeView(self)
end

return TeamSiteView