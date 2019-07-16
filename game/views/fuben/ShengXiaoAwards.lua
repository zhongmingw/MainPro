--
-- Author: Your Name
-- Date: 2019-01-07 11:33:26
--

local ShengXiaoAwards = class("ShengXiaoAwards", base.BaseView)

local ATTRDATA = {--相冲属性对应
    [550] = 556,
    [551] = 557,
    [552] = 558,
    [553] = 559,
    [554] = 560,
    [555] = 561,
    [556] = 550,
    [557] = 551,
    [558] = 552,
    [559] = 553,
    [560] = 554,
    [561] = 555,
}

function ShengXiaoAwards:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function ShengXiaoAwards:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)

    self.titleIcon = self.view:GetChild("n0"):GetChild("icon")
    self.decTxt = self.view:GetChild("n5")
    self.listView = self.view:GetChild("n3")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.numItems = 0
end

function ShengXiaoAwards:initData(data)
    -- print("生肖ID>>>>>>",data.id)
    self.confData = conf.FubenConf:getSxslPassById(data.id)
    local allAttrs = conf.ShengXiaoConf:getAllSpecialAttrs()
    self.myAttris = {}--自己的生肖之力
    for k,v in pairs(GConfDataSort(allAttrs)) do
        self.myAttris[v[1]] = v[2]
    end

    local fubenData = conf.FubenConf:getSxslFubenDataById( data.id )
    self.decTxt.text = language.fuben250
    self.titleIcon.url = UIPackage.GetItemURL("fuben",fubenData.title_icon)
    self.listView.numItems = #self.confData
end

function ShengXiaoAwards:cellData(index,obj)
    local data = self.confData[index+1]
    if data then
        local lvTxt = obj:GetChild("n2")
        local valueTxt = obj:GetChild("n3")
        local list = obj:GetChild("n4")
        list.numItems = 0
        local fbId = data.pass_id
        local fubenData = conf.FubenConf:getPassDatabyId(fbId)
        

        local monsterId = fubenData.pass_con[1][1]
        local monsterData = conf.MonsterConf:getInfoById(monsterId)
        local awardsData = monsterData.normal_drop
        local myAttr = 9999999--当前最低生肖之力
        local needAttr = 99999--所需最低生肖之力
        for k,v in pairs(data.xx_power) do
            local temp = self.myAttris[ATTRDATA[v[1]]] or 0
            local temp2 = v[2]
            if myAttr > temp then
                myAttr = temp
            end
            if needAttr > temp2 then
                needAttr = temp2
            end
        end
        if myAttr >= needAttr then
            lvTxt.text = mgr.TextMgr:getTextColorStr(monsterData.level,7)
            valueTxt.text = mgr.TextMgr:getTextColorStr(needAttr,7)
        else
            lvTxt.text = mgr.TextMgr:getTextColorStr(monsterData.level,14)
            valueTxt.text = mgr.TextMgr:getTextColorStr(needAttr,14)
        end
        list.itemRenderer = function(index,cell)
            local awards = awardsData[index+1]
            if awards then
                local itemInfo = {mid = awards[1],amount = awards[2]}
                GSetItemData(cell,itemInfo,true)
            end
        end
        list.numItems = #awardsData
    end
end

return ShengXiaoAwards