--
-- Author: 
-- Date: 2018-11-27 19:57:04
--

local HunShiStrengView = class("HunShiStrengView", base.BaseView)

function HunShiStrengView:ctor()
    HunShiStrengView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.openTween = ViewOpenTween.scale
end

function HunShiStrengView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)

    self.listView = self.view:GetChild("n2")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index,obj)
    end
    self.c1 = self.view:GetController("c1")
    self.strengBtn = self.view:GetChild("n3")
    self.strengBtn.onClick:Add(self.onClickBtn,self)
end


function HunShiStrengView:initData(data)
    self.maxLvByColor = conf.DiHunConf:getValue("dh_stren_max_color")
    self.isMax = false
    if data then
        self.data = data
        local mid = data.mid
        self.subType = data.subType
        self.part = data.part
        local info = {mid = mid,amount = 1,bind = 0,isquan = true}
        GSetItemData(self.view:GetChild("n4"),info,false)
        self:setInfo(data.lv)
    end
end

function HunShiStrengView:setInfo(lv)
        local maxLv = 0
        local color = conf.ItemConf:getQuality(self.data.mid)
        for k,v in pairs(self.maxLvByColor) do
            if v[1] == color then
                maxLv = v[2]
            end
        end
        self.view:GetChild("n5").text = conf.ItemConf:getName(self.data.mid).."  "..mgr.TextMgr:getTextColorStr(string.format("Lv%d",lv),7)
        local curData = conf.DiHunConf:getDhStengById(self.subType,self.part,lv)
        local nextData = conf.DiHunConf:getDhStengById(self.subType,self.part,lv+1)
        self.curAttData = curData and GConfDataSort(curData)
        self.nextAttData = nextData and GConfDataSort(nextData)
        if lv >= maxLv then
            self.isMax = true
            self.nextAttData = {}
        end
        self.listView.numItems = #self.curAttData

        if nextData and curData.need_cost then
            self.c1.selectedIndex = 0
            local needMid = curData.need_cost[1][1]
            local quality = conf.ItemConf:getQuality(needMid)
            local haveScore = cache.DiHunCache:getScoreByColor(quality)
            self.view:GetChild("n7").url =  ResPath.iconRes(tostring(conf.ItemConf:getSrc(needMid)))
            local color = 7
            if tonumber(haveScore) >= tonumber(curData.need_cost[1][2]) then
                color = 7
                self.strengBtn.data = 1--足够
                self.strengBtn.grayed = false
            else
                color = 14
                self.strengBtn.data = 0
                self.strengBtn.grayed = true
            end
            local textData = {
                {text = haveScore,color = color},
                {text = "/"..curData.need_cost[1][2],color = 7},
            }
            self.view:GetChild("n8").text = mgr.TextMgr:getTextByTable(textData)
        else
            self.c1.selectedIndex = 1
        end

end
function HunShiStrengView:cellData(index,obj)
    local curData = self.curAttData[index+1]
    local nextData = self.nextAttData [index+1]
    local dec1 = obj:GetChild("n1")
    local dec2 = obj:GetChild("n2")
    if curData then
        dec1.text = conf.RedPointConf:getProName(curData[1])..":"..GProPrecnt(curData[1],math.floor(curData[2]))
    else
        dec1.text = "已满级"
    end
    if nextData then
        dec2.text = conf.RedPointConf:getProName(nextData[1])..":"..GProPrecnt(nextData[1],math.floor(nextData[2]))
    else
        dec2.text = "已满级"
    end
end

function HunShiStrengView:onClickBtn(context)
    if self.c1.selectedIndex == 1 then
        GComAlter(language.forging14)
        return
    end
    local btn = context.sender
    if self.isMax then
        GComAlter(language.dihun18)
        return
    end
    if btn.grayed then
        GComAlter(language.head02)
        return
    end
    local param = {}
    param.type = self.subType
    param.part = self.part
    proxy.DiHunProxy:sendMsg(1620105,param)
end

return HunShiStrengView