--
-- Author: Your Name
-- Date: 2018-01-08 16:00:43
--

local RankAwardsView = class("RankAwardsView", base.BaseView)

function RankAwardsView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
end

function RankAwardsView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)

    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController,self)
    self.rankList = self.view:GetChild("n8")
    self.rankList.numItems = 0
    self.rankList.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.rankList:SetVirtual()

    self.awardsList = self.view:GetChild("n20")
    self.awardsList.numItems = 0
    self.awardsList.itemRenderer = function(index,obj)
        self:awardsCell(index, obj)
    end
    self.awardsList:SetVirtual()
    
    self.view:GetChild("n16").text = language.qualifier10
end

function RankAwardsView:onController()
    if self.c1.selectedIndex == 0 then
        proxy.QualifierProxy:sendMsg(1480102,{reqType = 0})
    elseif self.c1.selectedIndex == 1 then
        self.rankings = {}
        proxy.QualifierProxy:sendMsg(1480103,{page = 1})
    end
end

function RankAwardsView:initData(data)
    if self.c1.selectedIndex == data.index then
        self:onController()
    else
        self.c1.selectedIndex = data.index
    end
end

function RankAwardsView:cellData( index,obj )
    if index + 1 >= self.rankList.numItems then
        if not self.rankings then
            return 
        end 
        if self.maxPage == self.page then 
            --没有下一页了
            --return
        elseif self.page and self.page < self.maxPage then
            local param = {page=self.page+1}
            proxy.QualifierProxy:sendMsg(1480103,param)
        end
    end
    local data = self.rankings[index+1]
    if data then
        local bgIcon = obj:GetChild("n0")
        local numIcon = obj:GetChild("n1")
        numIcon.visible = true
        if index == 0 then
            bgIcon.url = UIPackage.GetItemURL("paiwei" , "meili_008")
            numIcon.url = UIPackage.GetItemURL("paiwei" , "meili_003")
        elseif index == 1 then
            bgIcon.url = UIPackage.GetItemURL("paiwei" , "meili_009")
            numIcon.url = UIPackage.GetItemURL("paiwei" , "meili_004")
        elseif index == 2 then
            bgIcon.url = UIPackage.GetItemURL("paiwei" , "meili_010")
            numIcon.url = UIPackage.GetItemURL("paiwei" , "meili_005")
        else
            bgIcon.url = UIPackage.GetItemURL("_others" , "ditu_004")
            numIcon.visible = false
        end
        local rank = obj:GetChild("n2")
        local roleName = obj:GetChild("n3")
        local gangName = obj:GetChild("n4")
        local power = obj:GetChild("n5")
        local pwLev = obj:GetChild("n6")
        local stars = obj:GetChild("n8")
        local roleId = data.roleId --玩家id
        local uId = string.sub(roleId,1,3) 
        obj:GetChild("n9").visible = false
        if cache.PlayerCache:getRedPointById(10327) ~=tonumber(uId) and tonumber(roleId) > 10000 then
            obj:GetChild("n9").visible=true
        end
       
        rank.text = data.rank
        roleName.text = data.roleName
        gangName.text = data.gangName == "" and language.friend38 or data.gangName
        power.text = data.power
        local pwData = conf.QualifierConf:getPwsDataByLv(data.pwLev)
        pwLev.text = pwData.name
        stars.text = pwData.stars
    end
end

function RankAwardsView:awardsCell( index,obj )
    local data = self.awardsConf[index+1]
    if data then
        local needLv = obj:GetChild("n1")
        local stateTxt = obj:GetChild("n2")
        local c1 = obj:GetController("c1")
        local getBtn = obj:GetChild("n7")
        local listView = obj:GetChild("n4")
        local pwData = conf.QualifierConf:getPwsDataByLv(data.con)
        needLv.text = pwData.name .. pwData.stars .. language.gonggong118
        getBtn.data = data
        getBtn.onClick:Add(self.onClickGet,self)

        listView.numItems = 0
        -- print("奖励。。。。",#data.item)
        for k,v in pairs(data.item) do
            local url = UIPackage.GetItemURL("_components" , "ComItemBtn")
            local item = listView:AddItemFromPool(url)
            local mId = v[1]
            local amount = v[2]
            local bind = v[3]
            local info = {mid = mId,amount = amount,bind = bind}
            GSetItemData(item,info,true)
        end
        local flag = false
        for k,v in pairs(self.awardsData.awardSigns) do
            if k == data.id then
                flag = true
            end
        end
        local pwLev = self.awardsData.pwLev
        if pwLev >= data.con then
            c1.selectedIndex = 1
        else
            c1.selectedIndex = 0
        end
        if flag then
            c1.selectedIndex = 2
        end
    end
end

function RankAwardsView:onClickGet(context)
    local data = context.sender.data
    proxy.QualifierProxy:sendMsg(1480102,{reqType = 1,cfgId = data.id})
end

-- 变量名：awardSigns  说明：已领取的奖励配置id
-- 变量名：cfgId   说明：奖励配置id
-- 变量名：items   说明：奖励
-- 变量名：reqType 说明： 0:显示 1:领取
function RankAwardsView:setAwardsData(data)
    -- printt("单人排位赛目标奖励",data)
    self.awardsData = data
    self.awardsConf = {}
    local confData = conf.QualifierConf:getPwsAimAwardsData()
    for k,v in pairs(confData) do
        if data.awardSigns[v.id] then--已领取的放到最后
            confData[k].sort = 1
        else
            confData[k].sort = 0
        end
        table.insert(self.awardsConf,v)
    end
    table.sort(self.awardsConf,function(a,b)
        if a.sort ~= b.sort then
            return a.sort < b.sort
        elseif a.id ~= b.id then
            return a.id < b.id
        end
    end)
    self.awardsList.numItems = #self.awardsConf
    self.awardsList:ScrollToView(0,false)
    local myDuanwei = self.view:GetChild("n22")
    local myPwData = conf.QualifierConf:getPwsDataByLv(data.pwLev)
    -- print("1111111111111",myDuanwei,myPwData,data.pwLev)
    myDuanwei.text = myPwData.name .. myPwData.stars .. language.gonggong118
end

function RankAwardsView:setRankData(data)
    self.pwData = data

    for k,v in pairs(data.rankList) do
        table.insert(self.rankings,v)
    end
    self.page = data.page
    self.maxPage = data.pageSum
    self.rankList.numItems = #self.rankings
    
    local myRankTxt = self.view:GetChild("n6")
    myRankTxt.text = data.myRank > 0 and data.myRank or language.rank04
    local myDuanwei = self.view:GetChild("n7")
    local myPwData = conf.QualifierConf:getPwsDataByLv(data.myPwLev)
    print("我的段位",myPwData,data.myPwLev)
    myDuanwei.text = myPwData.name .. myPwData.stars .. language.gonggong118

end

function RankAwardsView:doClearView(clear)
    self.rankings = {}
end

return RankAwardsView