--
-- Author: 
-- Date: 2018-02-22 14:31:48
--
--符文镶嵌
local RuneInlay = class("RuneInlay",import("game.base.Ref"))

function RuneInlay:ctor(mParent,moduleId)
    self.mParent = mParent
    self.moduleId = moduleId
    self:initPanel()
end

function RuneInlay:initPanel()
    local panelObj = self.mParent:getChoosePanelObj(self.moduleId)
    self.c1 = panelObj:GetController("c1")--选中符文是否解锁控制器
    self.holeList = {}--符文icon
    for i=2,9 do
        local hole = panelObj:GetChild("n"..i)
        hole.onClick:Add(self.onClickHole,self)
        table.insert(self.holeList, hole)
    end

    self.lineList = {}--符文线
    for i=10,21 do
        table.insert(self.lineList, panelObj:GetChild("n"..i))
    end

    self.runeItem = panelObj:GetChild("n25")
    self.runeName = panelObj:GetChild("n28")--符文名字

    self.attriTexts = {}
    table.insert(self.attriTexts, panelObj:GetChild("n29"))--符文属性1
    table.insert(self.attriTexts, panelObj:GetChild("n43"))--符文属性2

    panelObj:GetChild("n30").text = language.rune02

    self.attriTexts1 = {}
    table.insert(self.attriTexts1, panelObj:GetChild("n31"))--符文属性1
    table.insert(self.attriTexts1, panelObj:GetChild("n40"))--符文属性2

    self.arrows = {}--
    table.insert(self.arrows, panelObj:GetChild("n32"))--箭头1
    table.insert(self.arrows, panelObj:GetChild("n41"))--箭头2

    self.arrtiAddTexts = {}
    table.insert(self.arrtiAddTexts, panelObj:GetChild("n33"))--符文属性加成1
    table.insert(self.arrtiAddTexts, panelObj:GetChild("n42"))--符文属性加成2

    panelObj:GetChild("n34").text = language.rune03

    self.marrow = panelObj:GetChild("n36")--符文精华

    self.desc = panelObj:GetChild("n37")

    local replaceBtn = panelObj:GetChild("n38")--替换
    replaceBtn.onClick:Add(self.onClickReplace,self)

    local upBtn = panelObj:GetChild("n39")--升级
    self.upBtn = upBtn
    upBtn.onClick:Add(self.onClickUp,self)

    local runeOverBtn = panelObj:GetChild("n23")--符文背包
    runeOverBtn.onClick:Add(self.onClickOver,self)
    self:initAtti()
end

function RuneInlay:setData(data)
    self.mData = data
    self:setRuneData()
    self:setLineData()
    local confData = conf.RuneConf:getFuwenHoleByFloor(data.towerMaxLevel)
    if confData then
        local strTable = clone(language.rune05)
        strTable[2].text = string.format(strTable[2].text, confData.open_floor)
        self.desc.text = mgr.TextMgr:getTextByTable(strTable)
    else
        self.desc.text = mgr.TextMgr:getTextByTable(language.rune25)
    end
end
--符文孔信息
function RuneInlay:setRuneData()
    local isInlayRune = cache.RuneCache:isInlayRune()--判断是否有可镶嵌的符文
    for k,holeItem in pairs(self.holeList) do
        local c1 = holeItem:GetController("c1")
        local holeId = k + 1000
        local holeInfo = cache.RuneCache:getEquipFwDataByIndex(holeId)
        holeItem.data = {hole = holeId,data = holeInfo}
        local confData = conf.RuneConf:getFuwenHole(holeId)
        local openLv = confData and confData.open_lvl or 1
        local openFloor = confData and confData.open_floor or 0
        local towerMaxLevel = self.mData and self.mData.towerMaxLevel or 0
        local id = 0
        if holeInfo then
            id = mgr.RuneMgr:getDataAttiId(holeInfo)
        end
        local confData2 = conf.RuneConf:getFuwenlevelup(id + 1)
        local t2 = GConfDataSort(confData2)
        local exp = self.mData and self.mData.exp or 0--符文精华
        local needExp = confData2 and confData2.need_exp or 0
        local color = 14
        local isRed = false
        if exp >= needExp and #t2 > 0 then
            isRed = true
        end
        if cache.PlayerCache:getRoleLevel() < openLv or towerMaxLevel < openFloor then
            c1.selectedIndex = 0
        else
            if holeInfo then--有符文
                c1.selectedIndex = 2
                holeItem.icon = mgr.ItemMgr:getItemIconUrlByMid(holeInfo.mid)
            else
                if isInlayRune then
                    c1.selectedIndex = 1
                    isRed = true
                else
                    c1.selectedIndex = 3
                end
            end
        end
        holeItem:GetChild("red").visible = isRed
    end
    self.chooseData = self.chooseData or self.holeList[1].data
    self:setChoose()
end

function RuneInlay:setLineData()
    for k,line in pairs(self.lineList) do
        local confData = conf.RuneConf:getFuwenLine(k)
        local openHoles = confData and confData.open_holes or {}
        local num = 0
        for _,holeId in pairs(openHoles) do
            if cache.RuneCache:getEquipFwDataByIndex(holeId) then
                num = num + 1
            end
        end
        local c1 = line:GetController("c1")
        if num >= #openHoles then
            c1.selectedIndex = 1
        else
            c1.selectedIndex = 0
        end
    end
end

function RuneInlay:initAtti()
    for i=1,2 do
        self.attriTexts[i].text = ""
        self.attriTexts1[i].text = ""
        self.arrtiAddTexts[i].text = ""
        self.arrows[i].visible = false
    end
end
--设置选择的符文
function RuneInlay:setChoose()
    self:initAtti()
    local c1 = self.runeItem:GetController("c1")
    local confData = conf.RuneConf:getFuwenHole(self.chooseData.hole)
    local openLv = confData and confData.open_lvl or 1
    local openFloor = confData and confData.open_floor or 0
    local towerMaxLevel = self.mData and self.mData.towerMaxLevel or 0
    if cache.PlayerCache:getRoleLevel() < openLv or towerMaxLevel < openFloor then
        self.c1.selectedIndex = 1
        c1.selectedIndex = 0
        self.haveRune = false
    else
        self.c1.selectedIndex = 0
        c1.selectedIndex = 2
        self.haveRune = true--有符文
        local holeInfo = self.chooseData.data
        if holeInfo then--有符文
            self.runeItem.icon = mgr.ItemMgr:getItemIconUrlByMid(holeInfo.mid)
            local id = mgr.RuneMgr:getDataAttiId(holeInfo)
            local confData = conf.RuneConf:getFuwenlevelup(id)
            local t = GConfDataSort(confData)
            for k,v in pairs(t) do--当前属性
                self.attriTexts[k].text = conf.RedPointConf:getProName(v[1]).."+"..mgr.TextMgr:getTextColorStr(GProPrecnt(v[1],v[2]), 7)
                self.attriTexts1[k].text = conf.RedPointConf:getProName(v[1]).."+"..GProPrecnt(v[1],v[2])
                self.arrows[k].visible = true
            end

            local confData = conf.RuneConf:getFuwenlevelup(id + 1)
            local t2 = GConfDataSort(confData)
            if #t2 > 0 then--加成的
                for k,v in pairs(t2) do
                    self.arrtiAddTexts[k].text = mgr.TextMgr:getTextColorStr(GProPrecnt(v[1],v[2]), 7)
                end
            else
                self.arrtiAddTexts[1].text = language.rune04
                if #t > 1 then
                    self.arrtiAddTexts[2].text = language.rune04
                else
                    self.arrtiAddTexts[2].text = ""
                end
            end
            local exp = self.mData and self.mData.exp or 0--符文精华
            local needExp = confData and confData.need_exp or 0
            local color = 14
            if exp >= needExp and #t2 > 0 then
                color = 7
                self.upBtn.enabled = true
                self.upBtn:GetChild("red").visible = true
            else
                self.upBtn.enabled = false
                self.upBtn:GetChild("red").visible = false
            end
            self.marrow.text = mgr.TextMgr:getTextColorStr(exp.."/"..needExp, color)
            self.runeName.text = mgr.RuneMgr:getRuneName(holeInfo)
        else
            self.c1.selectedIndex = 1
        end
    end
    self:chooseHole(self.chooseData.hole)
end

function RuneInlay:chooseHole(holeId)
    for k,item in pairs(self.holeList) do
        local c2 = item:GetController("c2")
        if item.data.hole == holeId then
            c2.selectedIndex = 1
        else
            c2.selectedIndex = 0
        end
    end
end
--符文升级
function RuneInlay:severUpRune(data)
    local holeData = self.holeList[data.holeId - 1000].data
    if not holeData.data.propMap then
        holeData.data.propMap = {}
    end
    holeData.data.propMap[517] = data.level
    self.mData.exp = data.exp
    self.chooseData = holeData
    self:setRuneData()
end
--点击孔
function RuneInlay:onClickHole(context)
    local holeData = context.sender.data
    self.chooseData = holeData
    self:equipRune()
    self:setChoose()
end

function RuneInlay:equipRune()
    local hole = self.chooseData.hole
    local confData = conf.RuneConf:getFuwenHole(self.chooseData.hole)
    local openLv = confData and confData.open_lvl or 1
    local openFloor = confData and confData.open_floor or 0
    local towerMaxLevel = self.mData and self.mData.towerMaxLevel or 0
    if cache.PlayerCache:getRoleLevel() < openLv then
        GComAlter(string.format(language.rune01, openLv))
    elseif towerMaxLevel < openFloor then
        GComAlter(string.format(language.rune23, openFloor))
    else
        if not cache.RuneCache:getEquipFwDataByIndex(hole) then
            mgr.ViewMgr:openView2(ViewName.RunePackView, self.chooseData)
        end
    end
end

function RuneInlay:onClickReplace()
    local hole = self.chooseData and self.chooseData.hole or 0
    if hole == 0 then
        GComAlter(language.rune20)
    else
        mgr.ViewMgr:openView2(ViewName.RunePackView, self.chooseData)
    end
end

function RuneInlay:onClickUp()
    if not self.haveRune then
        GComAlter(language.rune26)
        return
    end
    proxy.RuneProxy:send(1500103,{holeId = self.chooseData.hole})
end
--符文总览
function RuneInlay:onClickOver()
    mgr.ViewMgr:openView2(ViewName.RuneOverView)
end

function RuneInlay:clear()
    self.chooseData = nil
end

return RuneInlay