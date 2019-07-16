--
-- Author: Your Name
-- Date: 2018-06-29 17:38:50
--

local StrengthenView = class("StrengthenView", base.BaseView)
local QHSICON = {
    [1] = 221042661,
    [2] = 221042663,
    [3] = 221042665,
    [4] = 221043903,
}
function StrengthenView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function StrengthenView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)
    self.panel = self.view:GetChild("n1")
    self.c1 = self.panel:GetController("c1")
    local guizeBtn = self.panel:GetChild("n32")
    guizeBtn.onClick:Add(self.onClickGuize,self)
    self.strengthBtn = self.panel:GetChild("n27")
    self.strengthBtn.onClick:Add(self.onClickStrength,self)

    self.modelPanel = self.panel:GetChild("n51")

    self.lvTxt = self.panel:GetChild("n8")
    --强化升星属性列表
    self.strenList = {}
    for i=1,5 do
        local dec = self.panel:GetChild("n"..(i+99))
        local nowAtt = self.panel:GetChild("n"..(i+109))
        local img = self.panel:GetChild("n"..(i+18))
        local aimAtt = self.panel:GetChild("n"..(i+119))
        table.insert(self.strenList,{dec,nowAtt,img,aimAtt})
    end
    --附灵属性列表
    self.fulingList = {}
    for i=1,4 do
        local nameTxt = self.panel:GetChild("n"..(34+i))
        local valueTxt = self.panel:GetChild("n"..(38+i))
        table.insert(self.fulingList,{nameTxt,valueTxt})
    end
    --附灵上限属性列表
    self.flsxAttrList = {}
    for i=1,4 do
        local valueTxt = self.panel:GetChild("n"..(51+i))
        table.insert(self.flsxAttrList,valueTxt)
    end
end

function StrengthenView:initData(data)
    self.c1.selectedIndex = data.index
    self.data = data.info
    self.qhsMap = data.qhsMap
    printt("神器信息>>>>>>>>>",self.data)
    local nameTxt = self.panel:GetChild("n9")
    local confData = conf.ShenQiConf:getShenQiDataById(self.data.id)
    nameTxt.text = confData.name
    self.lvTxt.text = "."..self.data.qhLev
    if self.c1.selectedIndex == 0 then--强化
        self:initStrengthPanel()
    elseif self.c1.selectedIndex == 1 then--附灵
        self:initFulingPanel()
    elseif self.c1.selectedIndex == 2 then--升星
        self:initShengxingPanel()
    end

    local modelId = confData.modelId--self.modelPanel
    self.shenqi = self:addEffect(modelId,self.modelPanel)
    self.shenqi.Scale = Vector3.New(confData.scale,confData.scale,confData.scale)
    self.shenqi.LocalPosition = Vector3.New(confData.pos[1],confData.pos[2],confData.pos[3]-200)
end

--强化
function StrengthenView:initStrengthPanel()
    for k,v in pairs(self.strenList) do
        v[1].text = ""
        v[2].text = ""
        v[3].visible = false
        v[4].text = ""
    end
    self.lvTxt.text = "."..self.data.qhLev
    local qhLev = self.data.qhLev
    local id = self.data.id
    local confData = conf.ShenQiConf:getQhDataByLv(qhLev,id)
    local nextConf = conf.ShenQiConf:getQhDataByLv(qhLev+1,id)

    local qhData = GConfDataSort(confData)--当前强化属性
    for k,v in pairs(qhData) do
        local key = v[1]
        local value = v[2]
        local decTxt = self.strenList[k][1]
        local valueTxt = self.strenList[k][2]
        local attName = conf.RedPointConf:getProName(key)
        if attName ~= "" then
            decTxt.text = attName .. ":"
            valueTxt.text = value
        end
    end
    local costItem = self.panel:GetChild("n31")
    if nextConf then
        local nextQhData = GConfDataSort(nextConf)--下阶段强化属性
        for k,v in pairs(nextQhData) do
            local key = v[1]
            local value = v[2]
            local attName = conf.RedPointConf:getProName(key)
            if attName ~= "" then
                self.strenList[k][3].visible = true
                local valueTxt = self.strenList[k][4]
                valueTxt.text = value
            end
        end
        local costMid = confData.cost_qhs[1][1]
        local costAmount = confData.cost_qhs[1][2]
        local myCount = self.qhsMap[costMid]
        local textData = {
                {text = myCount,color = 7},
                {text = "/"..costAmount,color = 7},
        }
        if costAmount > myCount then
            textData[1].color = 14
        end
        self.panel:GetChild("n45").visible = true
        self.panel:GetChild("n45").text = mgr.TextMgr:getTextByTable(textData)
        costItem.visible = true
        local mid = QHSICON[costMid]
        local info = {mid = mid,amount = 0,bind = 0,hidenumber = true}
        GSetItemData(costItem,info,false)
    else
        costItem.visible = false
        self.panel:GetChild("n45").text = ""
    end
end

--附灵
function StrengthenView:initFulingPanel()
    for k,v in pairs(self.fulingList) do
        v[1].text = ""
        v[2].text = ""
    end
    for k,v in pairs(self.flsxAttrList) do
        v.text = ""
    end
    local flLev = self.data.flLev
    local id = self.data.id
    if flLev == 0 then
        flLev = flLev + 1
    end
    local confData = conf.ShenQiConf:getFlDataByLv(flLev,id)
    local nextConf = conf.ShenQiConf:getFlDataByLv(flLev+1,id)
    local flData = GConfDataSort(confData)--当前附灵属性
    local flConf = conf.ShenQiConf:getFlDataByLv(self.data.flLev,id)
    if flConf.sx_id then
        local sxConf = conf.ShenQiConf:getFlDataById(confData.sx_id)
        local flsxData = GConfDataSort(sxConf)--附灵上限属性
        for k,v in pairs(flsxData) do
            local key = v[1]
            local value = GProPrecnt(key,v[2])
            local valueTxt = self.flsxAttrList[k]
            local attName = conf.RedPointConf:getProName(key)
            if attName ~= "" then
                local str = "("..value..")"
                valueTxt.text = mgr.TextMgr:getTextColorStr(str,1)
            end
        end
    end

    for k,v in pairs(flData) do
        local key = v[1]
        local value = GProPrecnt(key,v[2])
        local decTxt = self.fulingList[k][1]
        local valueTxt = self.fulingList[k][2]
        local attName = conf.RedPointConf:getProName(key)
        if attName ~= "" then
            decTxt.text = mgr.TextMgr:getTextColorStr(attName .. ":", 1)
            valueTxt.text = mgr.TextMgr:getTextColorStr(value,1)
            if self.data.flLev == 0 then
                decTxt.text = mgr.TextMgr:getTextColorStr(attName .. ":", 16)
                valueTxt.text = mgr.TextMgr:getTextColorStr(value..language.shenqi05,16)
            end
        end
    end
    local costItem = self.panel:GetChild("n31")
    if nextConf then 
        local costMid = confData.cost_item[1][1]
        local costAmount = confData.cost_item[1][2]
        local info = {mid = costMid,amount = costAmount,bind = 1}
        GSetItemData(costItem, info, true)
        local myCount = cache.PackCache:getPackDataById(costMid).amount
        local textData = {
                {text = myCount,color = 7},
                {text = "/"..costAmount,color = 7},
        }
        if costAmount > myCount then
            textData[1].color = 14
        end
        self.panel:GetChild("n45").text = mgr.TextMgr:getTextByTable(textData)
        self.panel:GetChild("n45").visible = true
        costItem.visible = true
    else
        costItem.visible = false
        self.panel:GetChild("n45").text = ""
    end
end

--升星
function StrengthenView:initShengxingPanel()
    for k,v in pairs(self.strenList) do
        v[1].text = ""
        v[2].text = ""
        v[3].visible = false
        v[4].text = ""
    end
    local sxLev = self.data.sxLev
    local id = self.data.id
    local confData = conf.ShenQiConf:getSxDataByLv(sxLev,id)
    local nextConf = conf.ShenQiConf:getSxDataByLv(sxLev+1,id)
    -- print("当前星级>>>>>>>>>>>>",sxLev,nextConf)
    -- printt(nextConf)
    local c1 = self.panel:GetChild("n7"):GetController("c1")
    if confData.star ~= 0 then
        c1.selectedIndex = confData.star + 10
    else
        c1.selectedIndex = confData.star
    end

    local sxData = GConfDataSort(confData)--当前升星属性
    for k,v in pairs(sxData) do
        local key = v[1]
        local value = v[2]
        local decTxt = self.strenList[k][1]
        local valueTxt = self.strenList[k][2]
        local attName = conf.RedPointConf:getProName(key)
        if attName ~= "" then
            decTxt.text = attName .. ":"
            valueTxt.text = value
        end
    end
    local costItem = self.panel:GetChild("n31")
    if nextConf then
        local nextsxData = GConfDataSort(nextConf)--下阶段升星属性
        for k,v in pairs(nextsxData) do
            local key = v[1]
            local value = v[2]
            local attName = conf.RedPointConf:getProName(key)
            if attName ~= "" then
                self.strenList[k][3].visible = true
                local valueTxt = self.strenList[k][4]
                valueTxt.text = value
            end
        end
        local costMid = confData.cost_item[1][1]
        local costAmount = confData.cost_item[1][2]
        local info = {mid = costMid,amount = costAmount,bind = 1}
        GSetItemData(costItem, info, true)
        local myCount = cache.PackCache:getPackDataById(costMid).amount
        local textData = {
                {text = myCount,color = 7},
                {text = "/"..costAmount,color = 7},
        }
        if costAmount > myCount then
            textData[1].color = 14
        end
        self.panel:GetChild("n45").text = mgr.TextMgr:getTextByTable(textData)
        costItem.visible = true
        self.panel:GetChild("n45").visible = true
    else
        costItem.visible = false
        self.panel:GetChild("n45").visible = false
    end
end

function StrengthenView:onClickStrength()
    if self.c1.selectedIndex == 0 then--强化
        local confData = conf.ShenQiConf:getQhDataByLv(self.data.qhLev,self.data.id)
        local nextData = conf.ShenQiConf:getQhDataByLv(self.data.qhLev+1,self.data.id)
        -- printt("强化>>>>>>>>>",confData)
        if nextData then
            local costMid = confData.cost_qhs[1][1]
            local costAmount = confData.cost_qhs[1][2]
            local myCount = self.qhsMap[costMid]
            if myCount >= costAmount then
                proxy.ShenQiProxy:sendMsg(1520102,{shenqiId = self.data.id})
            else
                GComAlter(language.shenqi07)
            end
        else
            GComAlter(language.zuoqi12_1)
        end
    elseif self.c1.selectedIndex == 1 then--附灵
        local confData = conf.ShenQiConf:getFlDataByLv(self.data.flLev,self.data.id)
        local nextData = conf.ShenQiConf:getFlDataByLv(self.data.flLev+1,self.data.id)
        if nextData then
            local costMid = confData.cost_item[1][1]
            local costAmount = confData.cost_item[1][2]
            local myCount = cache.PackCache:getPackDataById(costMid).amount
            if myCount >= costAmount then
                proxy.ShenQiProxy:sendMsg(1520103,{shenqiId = self.data.id})
            else
                GComAlter(language.shenqi09)
            end
        else
            GComAlter(language.zuoqi12_1)
        end
    elseif self.c1.selectedIndex == 2 then--升星
        local confData = conf.ShenQiConf:getSxDataByLv(self.data.sxLev,self.data.id)
        local nextData = conf.ShenQiConf:getSxDataByLv(self.data.sxLev+1,self.data.id)
        printt("下一星级>>>>>>>",nextData)
        if nextData then
            local costMid = confData.cost_item[1][1]
            local costAmount = confData.cost_item[1][2]
            local myCount = cache.PackCache:getPackDataById(costMid).amount
            if myCount >= costAmount then
                proxy.ShenQiProxy:sendMsg(1520104,{shenqiId = self.data.id})
            else
                GComAlter(language.shenqi08)
            end
        else
            GComAlter(language.zuoqi12_1)
        end
    end
end

--强化刷新
function StrengthenView:refreshQh(data)
    self.data.qhLev = data.qhLev
    self.data.power = data.power
    -- self.data.id = data.shenqiId
    self:initStrengthPanel()
end

--广播qhsMap刷新
function StrengthenView:refreshQhsMap(data)
    self.qhsMap = data.qhsMap
end

--升星刷新
function StrengthenView:refreshSx(data)
    self.data.sxLev = data.sxLev
    self.data.power = data.power
    -- self.data.id = data.shenqiId
    self:initShengxingPanel()
end

--附灵刷新
function StrengthenView:refreshFl(data)
    self.data.flLev = data.flLev
    self.data.power = data.power
    -- self.data.id = data.shenqiId
    self:initFulingPanel()
end

--规则
function StrengthenView:onClickGuize()
    GOpenRuleView(1094)
end
return StrengthenView