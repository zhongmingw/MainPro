--
-- Author:bxp 
-- Date: 2018-12-03 14:53:30
--抛光

local table = table
local PaoGuangPanel = class("PaoGuangPanel",import("game.base.Ref"))

function PaoGuangPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end
function PaoGuangPanel:initPanel()
 
    self.view = self.mParent.view:GetChild("n20")
    
    self.listView = self.view:GetChild("n15")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView:SetVirtual()
    self.listView.onClickItem:Add(self.onClickItem,self)
    self.gemList = {}
    for i=1,6 do
        local gemItem = self.view:GetChild("n2"):GetChild("n"..i)
        gemItem.onClick:Add(self.onClickGem,self)
        table.insert(self.gemList,gemItem)
    end
    --当前抛光
    self.curPaoGuang = self.view:GetChild("n6")
    self.curAttList = self.view:GetChild("n39")
    --下一级
    self.nextPaoGuang = self.view:GetChild("n10")
    self.nextAttList = self.view:GetChild("n40")

    self.choseGemItem = self.view:GetChild("n2"):GetChild("n7")

    local btn1 = self.view:GetChild("n14")
    btn1.onClick:Add(self.onBtnCallback,self)

    local btn2 = self.view:GetChild("n13")
    btn2.onClick:Add(self.onBtnCallback,self)

    self.materialList = self.view:GetChild("n12")
    self.materialList.itemRenderer = function(index,obj)
        self:cellMaterialData(index, obj)
    end
    self.materialList.numItems = 0

    self.c1 = self.view:GetController("c1")
    self.c2 = self.view:GetController("c2")

    self.hint = self.view:GetChild("n38")

    self.redList = {}

end


function PaoGuangPanel:addMsgCallBack(data)
    self.part = data.part
    self.hole = data.hole
    -- print("返回",data.part,data.hole)
    self:setRedNum()
    self:setListData()

    self:setGemListInfo(data.part)
    self:setAttList(data.part,data.hole)
end

function PaoGuangPanel:setData()
    self:setListData()
    for k = 1,self.listView.numItems do
        local cell = self.listView:GetChildAt(k - 1)
        if cell then
            cell.onClick:Call()
            break
        end
    end
    self.listView:AddSelection(0,false)
end

function PaoGuangPanel:setListData()
    self.forgData = cache.PackCache:getForgData()
    -- printt("装备数据",self.forgData)  
    self:setRedNum()
    self.equipData = {}
    local data = cache.PackCache:getEquipData()
    local _t = clone(data)
    for k,v in pairs(_t) do
        local part = conf.ItemConf:getPart(v.mid)
        local redNum = self.redPart[part]
        v.redNum = redNum
        v.part = part
        table.insert(self.equipData,v)
    end
    table.sort(self.equipData,function (a,b)
        if a.redNum ~= b.redNum then
            return a.redNum > b.redNum
        else
            return a.part < b.part
        end
    end)
    self.listView.numItems = #self.equipData 
end

function PaoGuangPanel:setRedNum()
    local paoGuangLv = conf.ForgingConf:getValue("equip_gem_polish_lev")

    for part,data in pairs(self.forgData) do
        if not self.redList[part] then
            self.redList[part] = {}
        end
        for k,mid in pairs(data.gemMap) do
            self.redList[part][k] = 0
            if mid ~= 0 then
                local gemType = conf.ItemConf:getGemType(mid)
                local gemlvl = conf.ItemConf:getLvl(mid)

                local polishLev = data and data.gemPolish and data.gemPolish[k] and data.gemPolish[k].polishLev or 0
                local id = gemType *1000 + polishLev
                local confData = conf.ForgingConf:getGemPolishById(id)
                local listnumber = {}
                if confData and confData.items and gemlvl >= paoGuangLv then
                    for _,j in pairs(confData.items) do
                        local _packdata = cache.PackCache:getPackDataById(j[1])
                        table.insert(listnumber,math.floor(_packdata.amount/j[2]))
                    end
                    local redNum = math.min(unpack(listnumber))
                    if confData.polish < 100 then
                        self.redList[part][k] = redNum
                    end
                end
            end
        end
    end
    -- printt("红点",self.redList)
    --部位红点
    self.redPart = {}
    for k,v in pairs(self.redList) do
        self.redPart[k] = self:getSumRed(v)
    end
end

function PaoGuangPanel:getSumRed(arr)
    local sum = 0
    for k,v in pairs(arr) do
        sum  = sum +v
    end
    return sum
end

function PaoGuangPanel:cellData(index,obj)
    local name = obj:GetChild("n8")
    local data = self.equipData[index+1]
    if data then
        local confData = conf.ItemConf:getItem(data.mid)
        local part = confData.part
        -- obj:GetChild("red").visible = self:getSumRed(self.redList[part]) > 0
        obj:GetChild("red").visible = data.redNum > 0
        obj.data = part
        local gemInfo = self.forgData[part]
        for i=1,6 do
            local img = obj:GetChild("n"..i)
            if gemInfo.gemMap[i] and gemInfo.gemMap[i] ~= 0 then
                img.grayed = false
            else
                img.grayed = true
            end
        end
        local t = clone(data)
        t.isquan = true
        GSetItemData(obj:GetChild("n9"),t,false)
        name.text = conf.ItemConf:getName(data.mid)
        local redImg = obj:GetChild("red")
    end
end

function PaoGuangPanel:onClickItem(context)
    local cell = context.data
    local data = cell.data
    self.part = data
    self.isEnough = true--默认材料足够
    self:setGemListInfo(self.part,true)
end

--设置选中装备（中间位置）
function PaoGuangPanel:setChoseItem()
    local equipData = cache.PackCache:getEquipByIndex(Pack.equip + self.part)
    if equipData then
        local t = clone(equipData)
        t.isquan = true
        GSetItemData(self.choseGemItem,t)
    else
        GSetItemData(self.choseGemItem,{})
    end
end

--设置宝石信息
function PaoGuangPanel:setGemListInfo(part,isClickItem)
    self:setChoseItem()
    local gemInfo = self.forgData[part]
   
    for k,v in pairs(self.gemList) do
        v.selected = false
        local icon = v:GetChild("n3")
        local lockIcon = v:GetChild("n4")
        local name = v:GetChild("n6")
        local title = v:GetChild("n7")
        local mid = gemInfo.gemMap[k]
        local redImg = v:GetChild("red")
        -- printt("self.redList[part]",self.redList[part])
        redImg.visible = self.redList[part] and self.redList[part][k] and self.redList[part][k] > 0 and true or false
        if mid and mid ~= 0 then 
            local confData = conf.ItemConf:getItem(mid)
            local src = confData.src
            local iconUrl = ResPath.iconRes(tostring(src))
            icon.url = iconUrl
            lockIcon.visible = false
            name.text = confData.name
        else
            name.text = language.forging98
            icon.url = nil
            lockIcon.visible = true
        end
        v.data = {hole = k ,mid = mid}

        --宝石属性
        local gemAtt = gemInfo.gemPolish[v.data.hole]
        --抛光度
        local polish = gemAtt and  gemAtt.polish or 0 
        title.text = string.format(language.forging99,polish).."%"
    end
     --顺时针选择第一个镶嵌的宝石
    if isClickItem then
        self.hole = nil
        for k,v in pairs(self.gemList) do
            if v.data.mid  and v.data.mid ~= 0 then
                self.hole = v.data.hole
                break
            end
        end
    end

    if self.hole then
        self.gemList[self.hole].onClick:Call()

        self.mid = self.gemList[self.hole].data.mid
        self:setAttList(part,self.hole)
    end
end
--点击宝石
function PaoGuangPanel:onClickGem(context)
    local btn = context.sender
    local data = btn.data
    local mid = data.mid
    self.isEnough = true--默认材料足够
    if not mid or mid == 0 then
        btn.selected = false
        GComAlter(language.forging100)
    else
        self.hole = data.hole
        self.mid = mid 
        local lvl = conf.ItemConf:getLvl(mid)
        local paoGuangLv = conf.ForgingConf:getValue("equip_gem_polish_lev")
        if lvl < paoGuangLv then
            self.c2.selectedIndex = 1
            self.hint.text = string.format(language.forging101,paoGuangLv)
        else
            self.c2.selectedIndex = 0
            self:setAttList(self.part,data.hole)
        end
    end    
    if self.hole then
        self.gemList[self.hole].selected = true
    end
end

--设置属性
function PaoGuangPanel:setAttList(part,hole)
    if not part or not hole then
        return 
    end
    local function SetListMsg(attiData ,listView )
        table.sort(attiData,function (a,b)
            return a[1] < b[1]
        end)
        listView.itemRenderer = function (index,obj)
            local data = attiData[index+1]
            local dec1 = obj:GetChild("n0")
            local dec2 = obj:GetChild("n1")
            if data[1] == 100 then--宝石属性，此系统独有
                dec1.text = "宝石属性"
                dec2.text = "+"..tostring(tonumber(data[2])/100).."%"
            else
                dec1.text = conf.RedPointConf:getProName(data[1]).."加成"
                dec2.text = "+"..GProPrecnt(data[1],math.floor(data[2]))
            end
        end
        listView.numItems = #attiData
    end
    local gemInfo = self.forgData[part]
    local gemAtt = gemInfo.gemPolish[hole]
    local mid = gemInfo.gemMap[hole]
    local gemType = conf.ItemConf:getGemType(mid)
    local polishLev = gemAtt and gemAtt.polishLev and gemAtt.polishLev or 0
    local id = gemType *1000 + polishLev
    local curAttConf = conf.ForgingConf:getGemPolishById(id)
    local nextAttConf = conf.ForgingConf:getGemPolishById(id+1)
    local curPol = 0
    local nextPol = 0
    local str1 = ""
    local str2 = ""
    if curAttConf and curAttConf.items then
        self.items = curAttConf.items
        self.materialList.numItems = #curAttConf.items
    else
        self.items = {}
        self.materialList.numItems = 2
    end
    if curAttConf and nextAttConf then
        curPol = curAttConf.polish
        nextPol = nextAttConf.polish
        self.c1.selectedIndex = 0

        local t1 = GConfDataSort(curAttConf)
        table.insert(t1,{100,curAttConf.gem_att})
        SetListMsg(t1,self.curAttList)
        
        local t2 = GConfDataSort(nextAttConf)
        table.insert(t2,{100,nextAttConf.gem_att})
        SetListMsg(t2,self.nextAttList)


    elseif curAttConf and not nextAttConf then
        curPol = curAttConf.polish
        nextPol = curAttConf.polish
        self.c1.selectedIndex = 1

        local t3 = GConfDataSort(curAttConf)
        table.insert(t3,{100,curAttConf.gem_att})
        SetListMsg(t3,self.curAttList)

        self.nextAttList.numItems = 0
    end

    self.curPaoGuang.text = string.format(language.forging105,curPol)
    self.nextPaoGuang.text = string.format(language.forging106,nextPol)
end
--材料list
function PaoGuangPanel:cellMaterialData(index,obj)
    local data = self.items[index+1]
    local tab = obj:GetChild("n1")
    local listC1 = obj:GetController("c1")
    if data then
        listC1.selectedIndex = 0
        local t = {}
        t.mid = data[1]
        t.amount = 1
        t.isquan = true
        GSetItemData(obj:GetChild("n0"), t, true)
        local packData = cache.PackCache:getPackDataById(data[1])
        local color = tonumber(packData.amount) >= tonumber(data[2]) and 10 or 14
        local textData = {
            {text = packData.amount,color = color},
            {text = "/"..data[2],color = 10},
        }
        if tonumber(packData.amount) < tonumber(data[2]) then
            self.isEnough  = false
        end
        tab.text =  mgr.TextMgr:getTextByTable(textData)
    else
        listC1.selectedIndex = 1
    end
end

function PaoGuangPanel:onBtnCallback(context)
    -- print("self.mid",self.mid,"孔",self.hole,"部位",self.part,"道具足够",self.isEnough)
    local btn = context.sender
    if btn.name == "n13" then--抛光
        if not self.mid or self.mid == 0 then
            GComAlter(language.forging100)
        elseif not self.hole then
            GComAlter(language.forging104)
        elseif not self.part then
            --没有部位
        else
            if not self.isEnough then
                GComAlter(language.forging102)
            else
                if self.c1.selectedIndex == 1 then
                    GComAlter(language.forging103)
                else
                    proxy.ForgingProxy:send(1100117,{part = self.part,hole = self.hole})
                end
            end

        end
    elseif btn.name == "n14" then
        mgr.ViewMgr:openView2(ViewName.SeeGemPaoguang)
    end
end

function PaoGuangPanel:clear()
    self.part = nil
    self.hole = nil
end


return PaoGuangPanel