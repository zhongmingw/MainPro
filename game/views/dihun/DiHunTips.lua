--
-- Author: 
-- Date: 2018-11-27 11:12:11
--

local DiHunTips = class("DiHunTips", base.BaseView)

function DiHunTips:ctor()
    DiHunTips.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
end

function DiHunTips:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)

    self.c1 = self.view:GetController("c1")


    local btn = self.view:GetChild("n7")
    btn.onClick:Add(self.onClickBtn,self)

    local panel = self.view:GetChild("n1")
    self.dec1 = panel:GetChild("n1")
    self.dec1.text = language.dihun11
    self.context1 = panel:GetChild("n2")

    self.dec2 = panel:GetChild("n3")
    self.dec2.text = language.dihun12
    self.context2 = panel:GetChild("n4")


    self.dec3 = panel:GetChild("n5")
    self.dec3.text = language.dihun13
    self.context3 = panel:GetChild("n7")

end

function DiHunTips:initData(data)
    if data then
        self.point = data.point
        self.dhInfo = data.dhInfo
        local confData = conf.DiHunConf:getDiHunInfoByType(data.dhInfo.type)
        self.view:GetChild("n8").text = confData.name
        --选中点（ 属性读当前点）
        local attConfData = conf.DiHunConf:getDhAttById(data.dhInfo.type,data.dhInfo.star,self.point)
        --前一个点（升级需要读  point之前的一个）
        local needConfData = conf.DiHunConf:getDhAttById(data.dhInfo.type,data.dhInfo.star,self.point-1)
        if not attConfData or not needConfData then
            return 
        end
        local needMid = needConfData.items and needConfData.items[1]
        local needAmont = needConfData.items and needConfData.items[2] or 0
        local packData = cache.PackCache:getPackDataById(needMid)
        local color = tonumber(packData.amount) >= tonumber(needAmont) and 7 or 14
        local textData = {
            {text = packData.amount,color = color},
            {text = "/"..needAmont,color = 7},
        }

        if self.point <= data.dhInfo.point then
            self.c1.selectedIndex = 2--已激活
        elseif self.point == data.dhInfo.point + 1 then
            if tonumber(packData.amount) >= tonumber(needAmont) then
                self.c1.selectedIndex = 1--可激活
            else
                self.c1.selectedIndex = 0--未激活
            end
        else
            self.c1.selectedIndex = 0--未激活
        end
        local str = ""
        local curAtt = GConfDataSort(attConfData)--选中点
        local lastAtt = GConfDataSort(needConfData)--上一个点
        local t = self:removeSameType(curAtt,lastAtt)
        for k,v in pairs(t) do
            if v[2] == 0 then
                table.remove(t,k)
            end
        end
        for k,v in pairs(t) do
            if v[2] ~= 0 then
                local str1 =conf.RedPointConf:getProName(v[1]).." "..mgr.TextMgr:getTextColorStr(GProPrecnt(v[1],math.floor(v[2])),7)
                if k ~= #t then
                    str1 = str1.."\n"
                end
                str = str..str1
            end
        end

        self.context1.text = str
        if self.c1.selectedIndex == 2 then--已激活
            self.dec2.text = ""
            self.dec3.text = ""
            self.context2.text = ""
            self.context3.text = ""
        else
            self.dec2.text = language.dihun12
            self.context2.text = conf.ItemConf:getName(needMid).."   ".. mgr.TextMgr:getTextByTable(textData)
            self.dec3.text = language.dihun13
            self.context3.text = needConfData.way or ""
        end
    end
end
--tar:被减函数
--temp:减函数
function DiHunTips:removeSameType(tar,temp)
    for k,v in pairs(tar) do
        local flag = false
        for i,j in pairs(temp) do
            if j[1] == v[1] then
                tar[k][2] = v[2]- j[2]
            end
        end
    end
    return tar
end


function DiHunTips:onClickBtn()
    if self.c1.selectedIndex == 0 then
        if self.point == self.dhInfo.point + 1 then
            GComAlter(language.dihun14)
        else
            GComAlter(language.dihun15)
        end
    elseif self.c1.selectedIndex == 1 then--可激活
        proxy.DiHunProxy:sendMsg(1620102,{reqType = self.dhInfo.type})
        self:closeView()
    end
end

return DiHunTips