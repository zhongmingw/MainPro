--
-- Author: Your Name
-- Date: 2018-06-28 11:44:55
--
local TypeTable = {
    [1] = {[1] = "shenqi_002",[2] = "shenqi_012",open = 0,id = 1},
    [2] = {[1] = "shenqi_003",[2] = "shenqi_013",open = 0,id = 2},
    [3] = {[1] = "shenqi_004",[2] = "shenqi_014",open = 0,id = 3},
    [4] = {[1] = "shenqi_051",[2] = "shenqi_052",open = 0,id = 4},
}
local QHSIcon = {
    [1] = "221071124",
    [2] = "221071125",
    [3] = "221071192",
    [4] = "221071820",
}

local ShenQiPanel = class("ShenQiPanel",import("game.base.Ref"))

function ShenQiPanel:ctor(parent)
    self.parent = parent
    self.view = parent.view:GetChild("n15")
    self:initView()
end


function ShenQiPanel:initView()
    self.listView = self.view:GetChild("n11")

    self.shenqiPanel = self.view:GetChild("n15")
    self.modelPanel = self.shenqiPanel:GetChild("n40")
    self.lockEff = self.shenqiPanel:GetChild("n41")
    --激活按钮
    self.jihuoBtn = self.view:GetChild("n6")
    self.jihuoBtn.onClick:Add(self.onClickJihuo,self)
    --分解按钮
    self.fenjieBtn = self.view:GetChild("n7")
    self.fenjieBtn.onClick:Add(self.onClickFenjie,self)
    --附灵按钮
    self.fulingBtn = self.view:GetChild("n8")
    self.fulingBtn.data = 1
    self.fulingBtn.onClick:Add(self.onClickStrength,self)
    --强化按钮
    self.qhBtn = self.view:GetChild("n9")
    self.qhBtn.data = 0
    self.qhBtn.onClick:Add(self.onClickStrength,self)
    --升星按钮
    self.sxBtn = self.shenqiPanel:GetChild("n37")
    self.sxBtn.data = 2
    self.sxBtn.onClick:Add(self.onClickStrength,self)

    --星级Item
    self.starBg = self.shenqiPanel:GetChild("n38")
    self.starItem = self.shenqiPanel:GetChild("n9")
    self.starConTrl = self.starItem:GetController("c1")
    self.starConTrl.selectedIndex = 0
    --锁图标
    self.lockIcon = self.shenqiPanel:GetChild("n10")
    self.DecTxt = self.view:GetChild("n12")
    self.DecItem = self.view:GetChild("n13")
    self.DecNum = self.view:GetChild("n14")
    self.DecTxt.visible = false
    self.DecItem.visible = false
    self.DecNum.visible = false
    --
    --强化属性列表
    self.qhAttrList = {}
    for i=1,4 do
        local nameTxt = self.shenqiPanel:GetChild("n"..(18+i))
        local valueTxt = self.shenqiPanel:GetChild("n"..(22+i))
        table.insert(self.qhAttrList,{nameTxt,valueTxt})
    end
    --附灵属性列表
    self.flAttrList = {}
    for i=1,4 do
        local nameTxt = self.shenqiPanel:GetChild("n"..(27+i))
        local valueTxt = self.shenqiPanel:GetChild("n"..(31+i))
        table.insert(self.flAttrList,{nameTxt,valueTxt})
    end
    --附灵上限属性列表
    self.flsxAttrList = {}
    for i=1,4 do
        local valueTxt = self.shenqiPanel:GetChild("n"..(41+i))
        table.insert(self.flsxAttrList,valueTxt)
    end
    --强化资源
    self.costList = {}
    for i=1,4 do
        local costPanel = self.view:GetChild("n"..(i+1))
        table.insert(self.costList,costPanel)
    end
end
--属性加成设置
function ShenQiPanel:initAttr(qhData,flData)
    for k,v in pairs(self.qhAttrList) do
        v[1].text = ""
        v[2].text = ""
    end
    for k,v in pairs(self.flAttrList) do
        v[1].text = ""
        v[2].text = ""
    end
    for k,v in pairs(self.flsxAttrList) do
        v.text = ""
    end
    local qhLev,flLev = self:getShenQiLvById(self.id)
    local flConf = conf.ShenQiConf:getFlDataByLv(flLev,self.id)
    if flConf.sx_id then--附灵上限属性
        local sxConf = conf.ShenQiConf:getFlDataById(flConf.sx_id)
        local flsxData = GConfDataSort(sxConf)--附灵上限属性
        for k,v in pairs(flsxData) do
            local key = v[1]
            local value = v[2]
            local valueTxt = self.flsxAttrList[k]
            local attName = conf.RedPointConf:getProName(key)
            if attName ~= "" then
                local str = "("..value..")"
                valueTxt.text = mgr.TextMgr:getTextColorStr(str,1)
            end
        end
    end
    --强化属性
    for k,v in pairs(qhData) do
        local key = v[1]
        local value = v[2]
        local decTxt = self.qhAttrList[k][1]
        local valueTxt = self.qhAttrList[k][2]
        local attName = conf.RedPointConf:getProName(key)
        if attName ~= "" then
            decTxt.text = mgr.TextMgr:getTextColorStr(attName .. ":", 1)
            valueTxt.text = mgr.TextMgr:getTextColorStr(value,1)
            if qhLev == 0 then
                decTxt.text = mgr.TextMgr:getTextColorStr(attName .. ":", 16)
                valueTxt.text = mgr.TextMgr:getTextColorStr(value,16)
            end
        end
    end
    --附灵属性
    for k,v in pairs(flData) do
        local key = v[1]
        local value = GProPrecnt(key,v[2])
        local decTxt = self.flAttrList[k][1]
        local valueTxt = self.flAttrList[k][2]
        local attName = conf.RedPointConf:getProName(key)
        if attName ~= "" then
            decTxt.text = mgr.TextMgr:getTextColorStr(attName .. ":", 1)
            valueTxt.text = mgr.TextMgr:getTextColorStr(value,1)
            if flLev == 0 then
                decTxt.text = mgr.TextMgr:getTextColorStr(attName .. ":", 16)
                valueTxt.text = mgr.TextMgr:getTextColorStr(value..language.shenqi05,16)
            end
        end
    end
end

--播放解锁特效
function ShenQiPanel:playLockEff()
    -- self.lockEff
    self.lock = self.parent:addEffect(4020157,self.lockEff)
    self.lock.Scale = Vector3.New(55,55,55)
    -- self.lock.LocalPosition = Vector3.New(confData.pos[1],confData.pos[2],confData.pos[3])
end

function ShenQiPanel:initData()
    -- self.isFirst = true
end

--设置侧边列表
function ShenQiPanel:setListViewData()
    self.listView.numItems = 0
    local flag = true
    local num = 0
    self.index = 1
    for k,v in pairs(self.typeTable) do
        local url = UIPackage.GetItemURL("shenqi" , "TabItem1")
        local obj = self.listView:AddItemFromPool(url)
        self:titleCellData(v, obj)

        if v.open == 1 then
            -- printt("self.shenqiInfos>>>>>>>>>",self.shenqiInfos)
            for k,sqData in pairs(self.shenqiInfos) do
                if math.floor(sqData.id/100) == v.id then
                    local url = UIPackage.GetItemURL("shenqi" , "TabItem2")
                    local obj = self.listView:AddItemFromPool(url)
                    local _t = clone(sqData)
                    num = num + 1
                    if flag then
                        if self:getRedPointById(_t.id)>0 then
                            flag = false
                            self.index = num
                        end
                    end
                    self:cellData(_t, obj)
                end
            end 
        end
    end
end

--大标题页签
function ShenQiPanel:titleCellData(data,obj)
    local bgImg = obj:GetChild("n0")
    local titleImg = obj:GetChild("n1")
    local c1 = obj:GetController("c1")
    bgImg.url = UIPackage.GetItemURL("shenqi" , data[1])
    titleImg.url = UIPackage.GetItemURL("shenqi" , data[2])
    if data.open == 1 then
        c1.selectedIndex = 1
    else
        c1.selectedIndex = 0
    end
    obj.data = data
    -- obj.onClick:Clear()
    obj.onClick:Add(self.onClickTitleCell,self)
end

--小标题页签
function ShenQiPanel:cellData(data,obj)
    local confData = conf.ShenQiConf:getShenQiDataById(data.id)
    local qhData = conf.ShenQiConf:getQhDataByLv(data.qhLev,data.id)
    local nameTxt = obj:GetChild("n2")
    local sourceTxt = obj:GetChild("n3")
    local jihuoTxt = obj:GetChild("n4")
    local redImg = obj:GetChild("red")
    nameTxt.text = confData.name
    if self:getRedPointById(data.id)>0 then
        redImg.visible = true
    else
        redImg.visible = false
    end
    if data.qhLev == 0 then
        if qhData.up_con == 1 then--手动激活
            jihuoTxt.text = language.shenqi01
        elseif qhData.up_con == 2 then--前一个神器达到xx级
            local leftId = data.id - 1
            local leftConf = conf.ShenQiConf:getShenQiDataById(leftId)
            jihuoTxt.text = string.format(language.shenqi02,leftConf.name,qhData.con_value)
        else--道具激活
            local mId = qhData.cost_item[1][1]
            local itemName = conf.ItemConf:getName(mId)
            jihuoTxt.text = string.format(language.shenqi03,itemName)
        end
        jihuoTxt.visible = true
        sourceTxt.visible = false
    else
        -- printt("当前战力>>>>>>>>>>>>>>>>",data)
        sourceTxt.text = language.sell37 .. ":" .. (data.power or 0)
        sourceTxt.visible = true
        jihuoTxt.visible = false
    end
    if data.id == self.id then
        obj.selected = true
    else
        obj.selected = false
    end
    obj.data = data
    obj.onClick:Add(self.onClickShenQiCell,self)
end

function ShenQiPanel:onClickShenQiCell(context)
    local data = context.sender.data
    self.id =data.id
    if self.id then
        -- self.isFirst = true
        self:initShenQiPanel()
    end
end

function ShenQiPanel:onClickTitleCell(context)
    local cell = context.sender
    local data = cell.data
    for k,v in pairs(self.typeTable) do
        if data.id == v.id then
            if v.open == 0 then--关
                self.typeTable[k].open = 1
            else
                self.typeTable[k].open = 0
            end
        else
            self.typeTable[k].open = 0
        end
    end
    self.tabIndex = data.id
    self:setListViewData()
    -- print("大标题页签>>>>>>>>>>>",self.tabIndex,self.typeTable[self.tabIndex].open)
    -- print("红点选择index>>>>>>>>>>>",self.index,self.index+self.tabIndex-1)
    if self.typeTable[self.tabIndex].open == 1 then
        self.listView:ScrollToView(self.tabIndex,false)
        self.listView:AddSelection(self.index+self.tabIndex-1,true)
        self.id = self.tabIndex*100 + self.index
        self:initShenQiPanel()
    end
end

function ShenQiPanel:setData(data)
    self.shenqiInfos = data.shenqiInfos
    self.qhsMap = data.qhsMap
    --神器按照id排序
    table.sort(self.shenqiInfos,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    self.typeTable = clone(TypeTable)

    self:initQhsTxt()
    self:initPresentShenQi()
    self.index = self.id%100
    self.tabIndex = math.floor(self.id/100)
    self.typeTable[self.tabIndex].open = 1
    self:setListViewData()
    if self.typeTable[self.tabIndex].open == 1 then
        self.listView:ScrollToView(self.tabIndex,false)
        self.listView:AddSelection(self.index+self.tabIndex-1,true)
        self.id = self.tabIndex*100 + self.index
        self:initShenQiPanel()
    end
end

--强化石txt初始化
function ShenQiPanel:initQhsTxt()
    if not self.qhsMap then
        return
    end
    for k,v in pairs(self.costList) do
        local txt = v:GetChild("n2")
        txt.text = self.qhsMap[k]
        local icon = v:GetChild("n1")
        icon.url = UIPackage.GetItemURL("_icons" , QHSIcon[k])
    end
end

-- --分解刷新强化石数量
-- function ShenQiPanel:refreshQhsMap(data)
--     for k,v in pairs(self.qhsMap) do
--         if data[k] then
--             self.qhsMap[k] = self.qhsMap[k] + data[k]
--         end
--     end
--     self:initQhsTxt()
-- end
--强化刷新强化石数量
function ShenQiPanel:refreshQhsMap2(data)
    -- printt("强化刷新强化石数量>>>>>>>>",data.qhsMap)
    for k,v in pairs(self.qhsMap) do
        if data.qhsMap[k] then
            self.qhsMap[k] = data.qhsMap[k]
        end
    end
    self:initQhsTxt()
    self:setBtnRed(self.id)
    self:setListViewData()
end

--当前神器红点情况
function ShenQiPanel:getRedPointById(id)
    local qhLev,flLev,sxLev = self:getShenQiLvById(id)
    self.qhRedNum = 0--强化红点
    self.sxRedNum = 0--升星红点
    self.flRedNum = 0--附灵红点
    self.fjRedNum = 0--分解红点
    local qhConf = conf.ShenQiConf:getQhDataByLv(qhLev,id)
    local nextQhConf = conf.ShenQiConf:getQhDataByLv(qhLev+1,id)
    if qhLev == 0 then--激活
    --强化红点
        if qhConf.up_con == 1 then--手动激活
            self.qhRedNum = self.qhRedNum + 1
            -- print("强化红点>>>>>>>>>",qhLev,id)
        elseif qhConf.up_con == 2 then--前一个神器达到xx等级
            local leftId = id - 1
            local leftQhLev = self:getShenQiLvById(leftId)
            if leftQhLev >= qhConf.con_value then
                self.qhRedNum = self.qhRedNum + 1
                -- print("强化红点0000")
            end
        elseif qhConf.up_con == 3 then--消耗道具激活
            local flag = true
            for k,v in pairs(qhConf.cost_item) do
                local costData = cache.PackCache:getPackDataById(v[1],true)
                if costData.amount < v[2] then
                    flag = false
                    break
                end
            end
            if flag then
                self.qhRedNum = self.qhRedNum + 1
                -- print("强化红点1111")
            end
        end
    else
        if nextQhConf then
            if qhConf.cost_qhs and qhLev > 0 then
                local flag = true
                for k,v in pairs(qhConf.cost_qhs) do
                    if self.qhsMap[v[1]] < v[2] then
                        flag = false
                        break
                    end
                end
                if flag then
                    -- print("强化红点2222")
                    self.qhRedNum = self.qhRedNum + 1
                end
            end
        end
        --附灵红点
        local flConf = conf.ShenQiConf:getFlDataByLv(flLev,id)
        local nextFlConf = conf.ShenQiConf:getFlDataByLv(flLev+1,id)
        if nextFlConf then
            if flConf.cost_item then--激活
                local flag = true
                for k,v in pairs(flConf.cost_item) do
                    local costData = cache.PackCache:getPackDataById(v[1],true)
                    if costData.amount < v[2] then
                        flag = false
                        break
                    end
                end
                if flag then
                    self.flRedNum = self.flRedNum + 1
                end
            end
        end
        --升星红点
        local sxConf = conf.ShenQiConf:getSxDataByLv(sxLev,id)
        local nextSxConf = conf.ShenQiConf:getSxDataByLv(sxLev+1,id)
        if nextSxConf then
            if sxConf.cost_item then--激活
                local flag = true
                for k,v in pairs(sxConf.cost_item) do
                    local costData = cache.PackCache:getPackDataById(v[1],true)
                    if costData.amount < v[2] then
                        flag = false
                        break
                    end
                end
                if flag then
                    self.sxRedNum = self.sxRedNum + 1
                end
            end
        end
    end
    cache.ShenQiCache:setRedNum(self.qhRedNum+self.sxRedNum+self.flRedNum)
    return (self.qhRedNum+self.sxRedNum+self.flRedNum)
end

--根据红点值初始化当前选择
function ShenQiPanel:initPresentShenQi()
    local flag = false
    local id = 101
    for k,v in pairs(self.shenqiInfos) do
        if self:getRedPointById(v.id) > 0 then
            flag = true
            id = v.id
            break
        end
    end
    self.id = id
    self:initShenQiPanel()
end

--根据神器id返回当前神器的强化等级、附灵等级和升星等级
function ShenQiPanel:getShenQiLvById(id)
    local qhLev = 0
    local flLev = 0
    local sxLev = 0
    -- print("self.id>>>>>>>>>>>>>>",self.id)
    for k,v in pairs(self.shenqiInfos) do
        if id == v.id then
            qhLev = v.qhLev
            flLev = v.flLev
            sxLev = v.sxLev
            break
        end
    end
    return qhLev,flLev,sxLev
end

--设置神器属性
function ShenQiPanel:initShenQiPanel()
    local qhLev,flLev,sxLev = self:getShenQiLvById(self.id)
    if qhLev == 0 then
        self.jihuoBtn.visible = true
        self.qhBtn.visible = false
        self.sxBtn.visible = false
        self.starItem.visible = false
        self.starBg.visible = false
        self.lockIcon.visible = true
        self.fenjieBtn.visible = false
        self.fulingBtn.visible = false
        self.qhBtn.visible = false
        self.DecTxt.visible = true
        self.DecItem.visible = false
        self.DecNum.visible = false
        local qhDataConf = conf.ShenQiConf:getQhDataByLv(qhLev,self.id)
        local flag = false
        if qhDataConf.up_con == 1 then--手动激活
            self.DecTxt.text = language.shenqi01
            flag = true
        elseif qhDataConf.up_con == 2 then--前一个神器达到xx级
            local leftId = self.id - 1
            local leftQhLev = self:getShenQiLvById(leftId)
            local leftConf = conf.ShenQiConf:getShenQiDataById(leftId)
            -- print("上一个等级>>>>>>>>",leftId,leftQhLev,qhDataConf.con_value)
            if leftQhLev >= qhDataConf.con_value then
                flag = true
            end
            self.DecTxt.text = string.format(language.shenqi02,leftConf.name,qhDataConf.con_value)
        else--道具激活
            self.DecTxt.visible = false
            self.DecItem.visible = true
            self.DecNum.visible = true
            local mId = qhDataConf.cost_item[1][1]
            local needAmount = qhDataConf.cost_item[1][2]
            local itemData = cache.PackCache:getPackDataById(mId,true)
            if itemData.amount >= needAmount then
                flag = true
            end
            local textData = {
                    {text = itemData.amount,color = 7},
                    {text = "/"..needAmount,color = 7},
            }
            if needAmount > itemData.amount then
                textData[1].color = 14
            end
            self.DecNum.text = mgr.TextMgr:getTextByTable(textData)
            local info = {mid = mId,amount = 0,bind = 0}
            GSetItemData(self.DecItem, info, true)
        end
        -- print("是否可激活>>>>>>>>>>>>>>",flag)
        if flag then--激活按钮
            self.jihuoBtn.grayed = false
            self.jihuoBtn.touchable = true
        else
            self.jihuoBtn.grayed = true
            self.jihuoBtn.touchable = false
        end
    else
        self.sxBtn.visible = true
        self.starItem.visible = true
        self.starBg.visible = true
        self.qhBtn.visible = true
        self.jihuoBtn.visible = false
        self.lockIcon.visible = false
        self.fenjieBtn.visible = true
        self.fulingBtn.visible = true
        self.qhBtn.visible = true
        self.DecTxt.visible = false
        self.DecItem.visible = false
        self.DecNum.visible = false
    end
    local nameTxt = self.shenqiPanel:GetChild("n12")
    local lvTxt = self.shenqiPanel:GetChild("n11")
    local confData = conf.ShenQiConf:getShenQiDataById(self.id)
    nameTxt.text = confData.name
    lvTxt.text = "." .. qhLev
    local modelId = confData.modelId--self.modelPanel
    self.shenqi = self.parent:addEffect(modelId,self.modelPanel)
    self.shenqi.Scale = Vector3.New(confData.scale,confData.scale,confData.scale)
    self.shenqi.LocalPosition = Vector3.New(confData.pos[1],confData.pos[2],confData.pos[3])
    --0级时 属性显示1级的 字体置灰
    if qhLev == 0 then qhLev = 1 end
    if flLev == 0 then flLev = 1 end
    local qhConf = conf.ShenQiConf:getQhDataByLv(qhLev,self.id)
    local qhData = GConfDataSort(qhConf)--强化属性
    local flConf = conf.ShenQiConf:getFlDataByLv(flLev,self.id)
    local flData = GConfDataSort(flConf)--附灵属性
    self:refreshSx(sxLev)--星级设置
    -- printt(string.format("%d当前强化属性>>>>>>>>>>",self.id),qhData)
    self:initAttr(qhData,flData)
    --各个按钮红点设置
    self:setBtnRed(self.id)
end

function ShenQiPanel:setBtnRed(id)
    -- self.qhRedNum = 0--强化红点
    -- self.sxRedNum = 0--升星红点
    -- self.flRedNum = 0--附灵红点
    -- self.fjRedNum = 0--分解红点
    self:getRedPointById(id)
    if self.qhRedNum > 0 then
        self.qhBtn:GetChild("red").visible = true
    else
        self.qhBtn:GetChild("red").visible = false
    end
    if self.sxRedNum > 0 then
        self.sxBtn:GetChild("red").visible = true
    else
        self.sxBtn:GetChild("red").visible = false
    end
    if self.flRedNum > 0 then
        self.fulingBtn:GetChild("red").visible = true
    else
        self.fulingBtn:GetChild("red").visible = false
    end
    self.fjRedNum = cache.ShenQiCache:getFenJieRed()
    if self.fjRedNum > 0 then
        self.fenjieBtn:GetChild("red").visible = true
    else
        self.fenjieBtn:GetChild("red").visible = false
    end
end

--星级刷新
function ShenQiPanel:refreshSx(sxLev)
    local sxConf = conf.ShenQiConf:getSxDataByLv(sxLev,self.id)
    -- print("当前星级>>>>>>>>",self.starConTrl.selectedIndex,self.isFirst)
    -- if sxConf and self.isFirst and sxConf.star ~= 0 then
    if sxConf.star ~= 0 then
        self.starConTrl.selectedIndex = sxConf.star + 10
    else
        self.starConTrl.selectedIndex = sxConf.star
    end
        -- self.isFirst = false
    -- else
        -- self.starConTrl.selectedIndex = sxConf.star
    -- end
end

--强化刷新
function ShenQiPanel:refreshPanel(data)
    for k,v in pairs(self.shenqiInfos) do
        if v.id == data.shenqiId then
            if data.qhLev then
                self.shenqiInfos[k].qhLev = data.qhLev
            elseif data.flLev then
                self.shenqiInfos[k].flLev = data.flLev
            elseif data.sxLev then
                self.shenqiInfos[k].sxLev = data.sxLev
            end
            break
        end
    end
    if data.qhLev == 1 then
        self:playLockEff()
    end
    -- printt("强化刷新>>>>>>>data.power",self.shenqiInfos)
    self.id = data.shenqiId
    self:initShenQiPanel()
end

--广播战力刷新
function ShenQiPanel:refreshPower(data)
    for k,power in pairs(data.powers) do
        for k2,v in pairs(self.shenqiInfos) do
            if v.id == k then
                -- print("广播战力刷新",k,v)
                self.shenqiInfos[k2].power = power
            end
        end
    end
    self:initShenQiPanel()
    self:setListViewData()
end

--激活按钮
function ShenQiPanel:onClickJihuo()
    proxy.ShenQiProxy:sendMsg(1520102,{shenqiId = self.id})
end

--分解界面
function ShenQiPanel:onClickFenjie()
    mgr.ViewMgr:openView2(ViewName.ShenQiFenjie, self.qhsMap)
end

--强化附灵升星界面
function ShenQiPanel:onClickStrength(context)
    local index = context.sender.data
    local info = {}
    for k,v in pairs(self.shenqiInfos) do
        if self.id == v.id then
            info = v
        end
    end
    if info.qhLev == 0 then
        GComAlter(language.shenqi04)
        return
    end
    mgr.ViewMgr:openView2(ViewName.StrengthenView, {index = index,info = info,qhsMap = self.qhsMap})
end

return ShenQiPanel