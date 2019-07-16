--
-- Author: 
-- Date: 2018-10-08 20:04:18
--

local JianShenEquipRank = class("JianShenEquipRank", import("game.base.Ref"))

function JianShenEquipRank:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function JianShenEquipRank:initPanel()
    self.view = self.mParent.view:GetChild("n8")
    self.actCountDownText = self.view:GetChild("n7")
    self.rankText = self.view:GetChild("n10")
    local btn1 = self.view:GetChild("n5") -- 前往寻宝
    local btn1Icon = btn1:GetChild("icon")
    btn1Icon.url = UIPackage.GetItemURL("shengyinrank","jianlingchushi_020")
    btn1.onClick:Add(self.btnOnClick,self)
    local btn2 = self.view:GetChild("n16") -- 查看规则
    btn2.onClick:Add(self.btnOnClick,self)
    local dec1 = self.view:GetChild("n13")
    dec1.url = UIPackage.GetItemURL("shengyinrank","jianlingchushi_015")
    local dec2 = self.view:GetChild("n14")
    dec2.url = UIPackage.GetItemURL("shengyinrank","jianlingchushi_016")

    self.awardList = self.view:GetChild("n1")
    self.awardList.itemRenderer = function (index,obj)
        self:setAwardData(index,obj)
    end
    self.awardList.numItems = 0
    self.awardList:SetVirtual()

    self.rankList = self.view:GetChild("n15")
    self.rankList.itemRenderer = function (index,obj)
        self:setRankData(index,obj)
    end
    self.rankList.numItems = 0
    self.rankList:SetVirtual()

end

--[[
变量名：lastTime    说明：剩余活动时间
变量名：myTimes 说明：我的次数
变量名：myRank  说明：我的排名
变量名：rankInfos   说明：排行信息
--]]

function JianShenEquipRank:setData(data)
    self.data = data
    -- printt("剑神装备排行>>>",data)
    self.confData = conf.ActivityConf:getJSEquipRank()
    local conf = conf.ActivityConf:getHolidayGlobal("js_find_rank_size") -- 最大上榜人数
    if data.myRank == 0 or data.myRank > conf then
        self.rankText.text = mgr.TextMgr:getTextColorStr(language.kuafu50, 14) 
    else
        self.rankText.text = data.myRank
    end
    self.rankList.numItems = conf
    self.awardList.numItems = #self.confData
end

function JianShenEquipRank:setAwardData(index,obj)
    local awardData = self.confData[index + 1]
    local lab = obj:GetChild("n6")
    if awardData.rank[1] == awardData.rank[2] then
        lab.text = awardData.rank[1]
    else 
        lab.text = string.format("%dg%d",awardData.rank[1],awardData.rank[2])
    end
    local awardList = obj:GetChild("n4")
    awardList.itemRenderer = function(_index,_obj)
        local info = awardData.awards[_index+1]
        local t = {}
        t.mid =  info[1]
        t.amount = info[2]
        t.bind = info[3] or 0 
        t.eStar = self:getStarNum(t)
        GSetItemData(_obj, t, true)
    end
    awardList.numItems = #awardData.awards
end

function JianShenEquipRank:getStarNum( data )
    local starCount = 0
    local birthAtt = {}
    local starNum = {}
    local maxColor = conf.ItemConf:getEquipColorGlobal("max_color")
    if conf.ItemConf:getBaseBirthAtt(data.mid) then
        birthAtt = conf.ItemConf:getBaseBirthAtt(data.mid) or {}
    end
    for k,v in pairs(birthAtt) do
        if k % 2 == 0 then
            local atti ={type = birthAtt[k - 1], value = birthAtt[k]}
            table.insert(starNum, atti)
            printt(starNum)
        end
    end
    for k,v in pairs(starNum) do
        local confData = conf.ItemConf:getEquipColorAttri(v.type)
        local colorAtt = confData and confData.color or 0
        if colorAtt == maxColor then--最高属性品质
            starCount = starCount + 1
            print(starCount)
        end
    end
    return starCount
end

function JianShenEquipRank:setRankData(index,obj)
    local data = self.data.rankInfos[index+1]
    local labrank = obj:GetChild("n6")
    local _labrank = obj:GetChild("n8")
    local labname = obj:GetChild("n0")
    local labpower = obj:GetChild("n2")
    local c1 = obj:GetController("c1")
    local kuaFuIcon = obj:GetChild("n9")
    if index < 3 then
        c1.selectedIndex = index
        labrank.visible = true
        _labrank.visible = false 
    else
        c1.selectedIndex = 3
        labrank.visible = false
        _labrank.visible = true 
    end
    if data then
        labrank.text = data.rank
        _labrank.text = data.rank
        labname.text = data.roleName 
        labpower.text = data.times
        local uId = string.sub(data.roleId,1,3)
        kuaFuIcon.visible = cache.PlayerCache:getRedPointById(10327) ~= tonumber(uId) and tonumber(data.roleId) > 10000
    else
        labrank.text = index + 1
        _labrank.text = index+1
        labname.text = language.kuafu104
        labpower.text = 0
        kuaFuIcon.visible = false
    end
end

function JianShenEquipRank:btnOnClick(context)
    local btn = context.sender
    if btn.name == "n5" then
        GOpenView({id = 1362})
    elseif btn.name == "n16" then
        GOpenRuleView(1149)
    end
end

function JianShenEquipRank:onTimer()
    if not self.data then return end
    if self.data.lastTime <= 0 then
        self.mParent:onBtnClose()
        return
    end
    if self.data.lastTime >= 86400 then
        self.actCountDownText.text = language.syph1.. mgr.TextMgr:getTextColorStr(GGetTimeData3(self.data.lastTime), 7)
    else
        self.actCountDownText.text = language.syph1.. mgr.TextMgr:getTextColorStr(GGetTimeData4(self.data.lastTime), 7)       
    end
    self.data.lastTime = math.max(self.data.lastTime - 1,0)
end

return JianShenEquipRank