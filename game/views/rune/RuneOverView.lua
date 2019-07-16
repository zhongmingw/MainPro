--
-- Author: 
-- Date: 2018-02-22 17:23:34
--
--符文总览
local RuneOverView = class("RuneOverView", base.BaseView)

function RuneOverView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
    self.uiClear = UICacheType.cacheTime
    self.openTween = ViewOpenTween.scale
end

function RuneOverView:initView()
    local closeBtn = self.view:GetChild("n2")
    self:setCloseBtn(closeBtn)
    self.listView = self.view:GetChild("n7")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
end

function RuneOverView:initData(data)
    local belongs = conf.RuneConf:getFuwenGlobal("fuwen_over_belongs")
    self.list = {}
    local i = 1
    for k,belong in pairs(belongs) do
        self.list[i] = {["title"] = belong}
        local items = conf.RuneConf:getFuwenOverTitle(k)
        i = i + 1
        self.list[i] = {}
        for k,item in pairs(conf.RuneConf:getFuwenOverItems()) do
            if item.belong == belong then
                if #self.list[i] >= 4 then
                    i = i + 1
                    self.list[i] = {}
                end
                table.insert(self.list[i], item)
            end
        end
        table.sort(self.list[i],function(a,b)
            local acolor = conf.ItemConf:getQuality(a.id)
            local bcolor = conf.ItemConf:getQuality(b.id)
            return acolor < bcolor
        end)
        i = i + 1
    end
    self.listView.numItems = #self.list
end

function RuneOverView:cellData(index,obj)
    local data = self.list[index + 1]
    local c1 = obj:GetController("c1")
    if data.title then
        c1.selectedIndex = 0
        local confData = conf.RuneConf:getFuwenOverTitle(data.title)
        obj:GetChild("n10").text = confData and confData.desc or ""
    else
        c1.selectedIndex = 1
        for i=0,3 do
            local holeInfo = data[i + 1]
            local rune = obj:GetChild("n"..i)
            if holeInfo then
                rune:GetController("c1").selectedIndex = 2
                rune.icon = mgr.ItemMgr:getItemIconUrlByMid(holeInfo.id)
                rune.visible = true
            else
                rune.visible = false
            end
            rune.data = holeInfo
            rune.onClick:Add(self.onClickRune,self)
        end
        for i=4,7 do
            local holeInfo = data[i - 3]
            local text = obj:GetChild("n"..i)
            if holeInfo then
                text.text = mgr.TextMgr:getColorNameByMid(holeInfo.id)
                text.visible = true
            else
                text.visible = false
            end
        end
    end
end

function RuneOverView:onClickRune(context)
    local data = context.sender.data
    mgr.ViewMgr:openView2(ViewName.RuneIntroduceView, data)
end

return RuneOverView