--
-- Author: 
-- Date: 2018-12-04 11:39:55
--

local SeeGemPaoguang = class("SeeGemPaoguang", base.BaseView)

function SeeGemPaoguang:ctor()
    SeeGemPaoguang.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
    self.isBlack = true
end

function SeeGemPaoguang:initView()
    self:setCloseBtn(self.view:GetChild("n0"):GetChild("n2"))
    self.listView = self.view:GetChild("n2")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView:SetVirtual()
end

function SeeGemPaoguang:initData()
    self.gemMidList = conf.ForgingConf:getValue("max_lvl_gem_mid")
    self.listView.numItems = #self.gemMidList
end

function SeeGemPaoguang:cellData(index,obj)
    local data = self.gemMidList[index+1]
    local name = obj:GetChild("n4")
    if data then
        local mid = data
        local t = {}
        t.mid = mid
        t.amount = 1
        GSetItemData(obj:GetChild("n3"), t, true)
        name.text = conf.ItemConf:getName(mid).."：抛光度100%"
        local gemType = conf.ItemConf:getGemType(mid)
        local confData = conf.ForgingConf:getGemInfoByTypeAndPolish(gemType,100)
        local baseAtt = conf.ItemArriConf:getItemAtt(mid)
        local t1 = GConfDataSort(baseAtt)
        local str = ""
        for k,v in pairs(t1) do
            local var = math.floor(v[2])*(1+confData.gem_att/10000)
            local str1 = conf.RedPointConf:getProName(v[1]).." "..mgr.TextMgr:getTextColorStr(GProPrecnt(v[1],var),7)
            if k ~= #v then
                str1 = str1.."\n"
            end
            str = str..str1
        end
        --抛光加成
        local t2 = GConfDataSort(confData)
        for k,v in pairs(t2) do
            local str1 =conf.RedPointConf:getProName(v[1]).." "..mgr.TextMgr:getTextColorStr(GProPrecnt(v[1],math.floor(v[2])),7)
            if k ~= #t2 then
                str1 = str1.."\n"
            end
            str = str..str1
        end
        obj:GetChild("n5").text = str
    end
end

return SeeGemPaoguang