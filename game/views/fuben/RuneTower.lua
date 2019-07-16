--
-- Author: 
-- Date: 2018-02-27 10:26:42
--
--符文塔
local RuneTower = class("RuneTower",import("game.base.Ref"))

function RuneTower:ctor(mParent)
    self.mParent = mParent
    self.sceneId = Fuben.runetower
    self:initPanel()
end

function RuneTower:initPanel()
    local panelObj = self.mParent:getChoosePanelObj(1218)
    self.bg = panelObj:GetChild("n3")

    self.awardsTitle = panelObj:GetChild("n12")--奖励标题

    self.awardslistView = panelObj:GetChild("n8")
    self.awardslistView.itemRenderer = function(index,obj)
        self:cellAwardsData(index, obj)
    end
    self.awardslistView.numItems = 0

    self.passTexts = {}
    for i=16,18 do--通关关卡
        table.insert(self.passTexts, panelObj:GetChild("n"..i))
    end
    panelObj:GetChild("n9").text = language.rune18
    panelObj:GetChild("n10").text = language.rune19
    self.passDesc = panelObj:GetChild("n13")
    panelObj:GetChild("n14").text = language.rune16

    panelObj:GetChild("n19").text = language.rune35

    self.runeListView = panelObj:GetChild("n15")--要解锁的符文
    self.runeListView.itemRenderer = function(index,obj)
        self:cellRunesData(index, obj)
    end
    self.runeListView.numItems = 0

    local warBtn = panelObj:GetChild("n11")
    warBtn.onClick:Add(self.onClickWar,self)
end

function RuneTower:setData(data)
    self.isMax = false
    self.sceneId = data and data.sceneId
    local passId = data.curPassId
    if data.curPassId ~= 0 then
        passId = passId + 1
    else
        passId = data.sceneId * 1000 + 1--显示的关卡+1
    end
    local pass = tonumber(string.sub(passId,7,9))
    if pass <= 1 then
        self.passTexts[1].text = language.rune21
        self.passTexts[2].text = 1
        self.passTexts[3].text = 2
    else
        local max = conf.FubenConf:getValue("fuwen_tower_max")
        local curPass = tonumber(string.sub(data.curPassId,7,9))
        if curPass == max then--如果当前关卡已经是最大了
            self.isMax = true
            pass = max
            passId = passId - 1
        end
        self.passTexts[1].text = pass - 1
        self.passTexts[2].text = pass
        if pass == max then
            self.passTexts[3].text = language.rune22
        else
            self.passTexts[3].text = pass + 1
        end
    end
    self.awardsTitle.text = string.format(language.rune17, pass)
    local confData = conf.FubenConf:getPassDatabyId(passId)
    self.awards = confData and confData.normal_drop or {}--通关奖励
    self.awardslistView.numItems = #self.awards
    self.runes = {}
    local runes = confData and confData.unlock_runes
    if runes then
        self.runes = runes
        self.passDesc.text = language.rune15
    else
        for i=passId,passId + 10 do
            local confData = conf.FubenConf:getPassDatabyId(i)
            local runes = confData and confData.unlock_runes
            if runes then
                self.runes = runes
                local pass = tonumber(string.sub(i,7,9))
                self.passDesc.text = string.format(language.rune30, pass)
                break
            end
        end
    end
    self.runeListView.numItems = #self.runes

    if self.bg.url and self.bg.url ~= "" then
        return
    end
    self.imgPath = UIItemRes.rune02
    self.mParent:setLoaderUrl(self.bg,self.imgPath)
end

function RuneTower:cellAwardsData(index,obj)
    local data = self.awards[index + 1]
    local itemData = {mid = data[1],amount = data[2], bind = data[3]}
    GSetItemData(obj, itemData, true)
end

function RuneTower:cellRunesData(index,obj)
    local holeInfo = self.runes[index + 1]
    obj:GetController("c1").selectedIndex = 2
    obj.icon = mgr.ItemMgr:getItemIconUrlByMid(holeInfo[1])
    obj.data = {mid = holeInfo[1]}
    obj.onClick:Add(self.onClickTip,self)
end

function RuneTower:onClickTip(context)
    local data = context.sender.data
    mgr.ViewMgr:openView2(ViewName.RuneIntroduceView, data)
end

function RuneTower:onClickWar()
    if self.isMax then
        GComAlter(language.rune32)
        return
    end
    mgr.FubenMgr:gotoFubenWar(self.sceneId)
end

function RuneTower:clear()
    self.bg.url = ""
end

return RuneTower