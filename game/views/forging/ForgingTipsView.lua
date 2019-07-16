--
-- Author: ohf
-- Date: 2017-02-10 14:41:22
--
--锻造各弹窗
local ForgingTipsView = class("ForgingTipsView", base.BaseView)

function ForgingTipsView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function ForgingTipsView:initView()
    self.cameoPanel1 = self.view:GetChild("n6")--宝石选择
    self.cameoPanel2 = self.view:GetChild("n10")--宝石升级或者卸下
    self.attPanel1 = self.view:GetChild("n20")
    self.suitPanel1 = self.view:GetChild("n40")
    self.attTipPanel = self.view:GetChild("n81")--tips属性  单独部位强化，，宝石
    self.attTipPanel2 = self.view:GetChild("n99")--升星tips属性
    self.blackView.onClick:Add(self.onClickClose,self)
end

function ForgingTipsView:clear()
    self.cameoPanel1.visible = false
    self.cameoPanel2.visible = false
    self.attPanel1.visible = false
    self.suitPanel1.visible = false
    self.attTipPanel.visible = false
    self.attTipPanel2.visible = false
end

function ForgingTipsView:setForgData(data)
    self.forgData = data
end
--data 1强化tip 2升星 3升星套装 4宝石 5宝石卸下 6 宝石总属性 7宝石套装 8升星tip 9强化总属性
function ForgingTipsView:setData(index,data)
    self.mData = data
    self.mIndex = index
    self:clear()
    if index == 1 then
        self.attTipPanel.visible = true
        self:initTipPanel()
    elseif index == 2 then
        self.attPanel1.visible = true
        self:initStarAtt()
    elseif index == 3 then
        self.suitPanel1.visible = true
        self:initStarSuit()
    elseif index == 4 then
        self.cameoPanel1.visible = true
        self.cameoPanel1.x = data.pos.x
        self.cameoPanel1.y = data.pos.y
        self:initCameoList()
    elseif index == 5 then
        self.cameoPanel2.visible = true
        self.cameoPanel2.x = data.pos.x
        self.cameoPanel2.y = data.pos.y
        self:initCamoBtn()
    elseif index == 6 then
        self.attPanel1.visible = true
        self:initCameoAtt()
    elseif index == 7 then
        self.suitPanel1.visible = true
        self:initCameoSuit()
    elseif index == 8 then
        self.attTipPanel2.visible = true
        self:initTipPanel2()
    elseif index == 9 then
        self.attPanel1.visible = true
        self:initStengAtt()
    end
end
--预览宝石
function ForgingTipsView:initCameoList()
    table.sort(self.mData.camoList,function(a,b)
        return a.mid > b.mid
    end)
    local listView = self.view:GetChild("n5")
    listView.itemRenderer = function(index,cell)
        local data = self.mData.camoList[index + 1]
        cell.data = data
        local itemObj = cell:GetChild("n1")
        GSetItemData(itemObj, data)
        local name = cell:GetChild("n2")
        name.text = conf.ItemConf:getName(data.mid)
    end
    listView.onClickItem:Add(self.onClickCameoItem,self)
    local numItems = #self.mData.camoList
    listView.numItems = numItems
end

function ForgingTipsView:onClickCameoItem(context)
    local cell = context.data
    local itemData = cell.data
    local mid = itemData.mid
    proxy.ForgingProxy:send(1100104,{reqType = 1,part = self.mData.part,hole = self.mData.hole,itemId = mid})
    self:onClickClose()
end

function ForgingTipsView:initCamoBtn()
    local panel = self.view:GetChild("n7")
    local btn1 = self.view:GetChild("n8")
    -- upBtn.onClick:Add(self.onClickUpCameo,self)
    local btn2 = self.view:GetChild("n9")
    local btn3 = self.view:GetChild("n111")
    btn1.visible = false
    btn2.visible = false
    btn3.visible = false
    btn1.onClick:Clear()
    btn2.onClick:Clear()
    btn3.onClick:Clear()
    -- unloadBtn.onClick:Add(self.onClickUnloadCameo,self)
    local iType = self.mData.type or 1
    if iType == 1 then--只可卸下
        btn1.visible = true
        btn1.title = language.pack09
        btn1.onClick:Add(self.onClickUnloadCameo,self)
        panel.height = 58
    elseif iType == 2 then--升级+卸下
        btn1.visible = true
        btn1.title = language.pack38
        btn1.onClick:Add(self.onClickUpCameo,self)
        btn2.visible = true
        btn2.title = language.pack09
        btn2.onClick:Add(self.onClickUnloadCameo,self)
        panel.height = 101
    elseif iType == 3 then--替换+卸下
        btn1.visible = true
        btn1.title = language.pack37
        btn1.onClick:Add(self.onClickReplace,self)
        btn2.visible = true
        btn2.title = language.pack09
        btn2.onClick:Add(self.onClickUnloadCameo,self)
        panel.height = 101
    elseif iType == 4 then--替换+升级+卸下 
        btn1.visible = true
        btn1.title = language.pack37
        btn1.onClick:Add(self.onClickReplace,self)
        btn2.visible = true
        btn2.title = language.pack38
        btn2.onClick:Add(self.onClickUpCameo,self)
        btn3.visible = true
        btn3.title = language.pack09
        btn3.onClick:Add(self.onClickUnloadCameo,self)
        panel.height = 142
    end
end
--替换宝石
function ForgingTipsView:onClickReplace()
    local camoList = {}
    for k,v in pairs(self.mData.camoList) do
        if v.mid > self.mData.itemId then
            table.insert(camoList, v)
        end
    end
    table.sort(camoList,function(a,b)
        return a.mid > b.mid
    end)
    local cameoData = {pos = self.mData.pos2, part = self.mData.part,camoList = camoList,hole = self.mData.hole}
    self:onClickClose()
    mgr.ViewMgr:openView(ViewName.ForgingTipsView, function(view)
        view:setData(4,cameoData)
    end)
end
--升级宝石
function ForgingTipsView:onClickUpCameo()
    proxy.ForgingProxy:send(1100104,{reqType = 3,part = self.mData.part,hole = self.mData.hole,itemId = self.mData.itemId})
    self:onClickClose()
end
--卸下宝石
function ForgingTipsView:onClickUnloadCameo()
    proxy.ForgingProxy:send(1100104,{reqType = 2,part = self.mData.part,hole = self.mData.hole,itemId = 0})
    self:onClickClose()
end

--强化总属性
function ForgingTipsView:initStengAtt()
    local img = self.view:GetChild("n18")
    img.url = UIItemRes.strengFont
    local data = self:getForgStreng()
    for k,v in pairs(language.forging1) do
        local attText = self.view:GetChild("n2"..k)
        attText.text = conf.RedPointConf:getProName(v).." "..data["att_"..v]     --language.jueseprops[v].." "..data["att_"..v]
    end
end

--强化总属性
function ForgingTipsView:getForgStreng()
    local data = self.forgData or cache.PackCache:getForgData()
    local attList = {}
    for k,v in pairs(data) do
        local confData = conf.ForgingConf:getStrenAttData(v.strenLev,v.part)
        table.insert(attList, confData)
    end

    local attData = {}
    for k,id in pairs(language.forging1) do
        local att = 0
        for k,v in pairs(attList) do
            if not v["att_"..id] then
                v["att_"..id] = 0
            end
            att = v["att_"..id] + att
        end
        attData["att_"..id] = att
    end
    return attData
end

--升星总属性
function ForgingTipsView:initStarAtt()
    local img = self.view:GetChild("n18")
    img.url = UIItemRes.starFont
    local data = self:getForgStar()
    for k,v in pairs(language.forging1) do
        local attText = self.view:GetChild("n2"..k)
        attText.text = conf.RedPointConf:getProName(v).." "..data["att_"..v]     --language.jueseprops[v].." "..data["att_"..v]
    end
end

--升星总属性
function ForgingTipsView:getForgStar()
    local data = self.forgData or cache.PackCache:getForgData()
    local attList = {}
    for k,v in pairs(data) do
        local confData = conf.ForgingConf:getStarData(v.part,v.starLev)
        table.insert(attList, confData)
    end

    local attData = {}
    for k,id in pairs(language.forging1) do
        local att = 0
        for k,v in pairs(attList) do
            if not v["att_"..id] then
                v["att_"..id] = 0
            end
            att = v["att_"..id] + att
        end
        attData["att_"..id] = att
    end
    return attData
end

--宝石总属性
function ForgingTipsView:initCameoAtt()
    local img = self.view:GetChild("n18")
    img.url = UIItemRes.cameoFont
    local data = self:getCamoAtt()
    for k,v in pairs(language.forging1) do
        local attText = self.view:GetChild("n2"..k)
        attText.text = conf.RedPointConf:getProName(v).." "..data["att_"..v]
    end
end

--宝石总属性
function ForgingTipsView:getCamoAtt()
    local data = self.forgData or cache.PackCache:getForgData()
    local attList = {}
    for _,v in pairs(data) do
        for k,id in pairs(v.gemMap) do
            if id > 0 then
                local confData = clone(conf.ItemArriConf:getItemAtt(id))
                table.insert(attList, confData)
            end
        end
    end
    -- printt(attList)
    local attData = {}
    for k,id in pairs(language.forging1) do
        local att = 0
        for k,v in pairs(attList) do
            if not v["att_"..id] then
                v["att_"..id] = 0
            end
            att = v["att_"..id] + att
        end
        attData["att_"..id] = att
    end
    return attData
end
--升星套装
function ForgingTipsView:initStarSuit()
    local title = self.view:GetChild("n39")
    title.url = UIItemRes.starSuit
    self:initSuitAtt()
    self.desc1.text = string.format(language.forging12, 0)
    self.desc2.text = string.format(language.forging12, 0)
    self.numMax1.text = "0/0"
    self.numMax2.text = "0/0"
end
--宝石套装
function ForgingTipsView:initCameoSuit()
    local title = self.view:GetChild("n39")
    title.url = UIItemRes.cameoSuit
    self:initSuitAtt()
    self.desc1.text = string.format(language.forging13, 0, 6)
    self.desc2.text = string.format(language.forging13, 0, 6)
    self.numMax1.text = "0/0"
    self.numMax2.text = "0/0"
end

function ForgingTipsView:initSuitAtt()
    self.desc1 = self.view:GetChild("n41")
    self.jhText1 = self.view:GetChild("n42")--当前激活
    self.numMax1 = self.view:GetChild("n49")
    
    self.attiListView1 = self.view:GetChild("n112")
    self.attiListView1:SetVirtual()
    self.attiListView1.itemRenderer = function(index,obj)
        self:cellAttiData1(index, obj)
    end
    --下一等级
    self.desc2 = self.view:GetChild("n43")
    self.jhText2 = self.view:GetChild("n44")--下一级激活
    self.numMax2 = self.view:GetChild("n50")
    
    self.attiListView2 = self.view:GetChild("n113")
    self.attiListView2:SetVirtual()
    self.attiListView2.itemRenderer = function(index,obj)
        self:cellAttiData2(index, obj)
    end
end

function ForgingTipsView:cellAttiData1(index,cell)
    local data = self.suitAttiData[index + 1]
    cell:GetChild("n1").text = conf.RedPointConf:getProName(data[1]).." "..data[2]
end
function ForgingTipsView:cellAttiData2(index,cell)
    local data = self.suitNextAttiData[index + 1]
    cell:GetChild("n1").text = conf.RedPointConf:getProName(data[1]).." "..data[2]
end

--设置套装属性（宝石 or升星）
function ForgingTipsView:setSuitData(data)
    local suitData = nil--当前
    local suitNextData = nil--下一级
    if self.mIndex == 3 then--升星套装
        local suits = conf.ForgingConf:getAllStarEffect()
        local id = self:getSuitId(data.activeStarSuits,suits)
        suitData = conf.ForgingConf:getStarEffect(id)
        suitNextData = conf.ForgingConf:getStarEffect(id + 1)
        if suitData then
            self.desc1.text = string.format(language.forging12, suitData.star)
        else
            self.desc1.text = string.format(language.forging12, suitNextData.star)
        end
        if suitNextData then--下一级
            self.desc2.text = string.format(language.forging12, suitNextData.star)
        end
        local curStarLv = cache.PackCache:getNumbyStar(suitData.star)--获得该级别的升星部位数量
        self.numMax1.text = curStarLv.."/"..suitData.star
        if curStarLv >= suitData.star then--是否激活
            self.jhText1.text = mgr.TextMgr:getTextColorStr(language.gonggong10,7)
        else
            self.jhText1.text = mgr.TextMgr:getTextColorStr(language.gonggong09,14)
        end
        if suitNextData then
            local nextStarLv = cache.PackCache:getNumbyStar(suitNextData.star)
            self.numMax2.text = nextStarLv.."/"..suitNextData.star
            if nextStarLv >= suitNextData.star then--是否激活
                self.jhText2.text = mgr.TextMgr:getTextColorStr(language.gonggong10,7)
            else
                self.jhText2.text = mgr.TextMgr:getTextColorStr(language.gonggong09,14)
            end
        end
    elseif self.mIndex == 7 then--宝石套装
        local suits = conf.ForgingConf:getAllCamoEffect()
        local id = self:getSuitId(data.activeGemSuits,suits)
        suitData = conf.ForgingConf:getCameoEffect(id)
        suitNextData = conf.ForgingConf:getCameoEffect(id + 1)
        if suitData then
            self.desc1.text = string.format(language.forging13, suitData.gem_lev)
        else
            self.desc1.text = string.format(language.forging13, suitNextData.gem_lev)
        end
        if suitNextData then
            self.desc2.text = string.format(language.forging13, suitNextData.gem_lev)
        end
        -- local curLen = #data.activeGemSuits
        -- local nextLvl = curLen + 1
        -- local len = #conf.ForgingConf:getAllCamoEffect()
        -- if nextLvl > len then
        --     nextLvl = len
        -- end
        local curLvl = cache.PackCache:getAllGemlv()--获得该级别的宝石数量
        self.numMax1.text = curLvl.."/"..suitData.gem_lev
        if curLvl >= suitData.gem_lev then--是否激活
            self.jhText1.text = mgr.TextMgr:getTextColorStr(language.gonggong10,7)
        else
            self.jhText1.text = mgr.TextMgr:getTextColorStr(language.gonggong09,14)
        end
        if suitNextData then
            local nextLvl = cache.PackCache:getAllGemlv()
            self.numMax2.text = nextLvl.."/"..suitNextData.gem_lev
            if nextLvl >= suitNextData.gem_lev then--是否激活
                self.jhText2.text = mgr.TextMgr:getTextColorStr(language.gonggong10,7)
            else
                self.jhText2.text = mgr.TextMgr:getTextColorStr(language.gonggong09,14)
            end
        end
    end
    --属性
    if suitData then        
        local t = GConfDataSort(suitData)
        self.suitAttiData = t
        self.attiListView1.numItems = #t
    else
        local t = GConfDataSort(suitNextData)
        self.suitAttiData = t
        self.attiListView1.numItems = #t
    end
    --下一等级
    if suitNextData then
        local t = GConfDataSort(suitNextData)
        self.suitNextAttiData = t
        self.attiListView2.numItems = #t
    end
end

function ForgingTipsView:getSuitId(data,suits)
    local id = 1000
    local dataLen = #data
    local suitsLen = #suits
    if dataLen == 0 then
        return id + 1
    end
    if dataLen == suitsLen then
         return id + dataLen - 1
    end
    for k,v in pairs(data) do
        if v and v > id then
            id = v
        end
    end
    
    return id
end
--强化tip
function ForgingTipsView:initTipPanel()
    local lev = self.mData.strenLev--等级
    local levStr = string.format(language.forging24,self.mData.strenLev)
    local maxLv = conf.ForgingConf:getStrengMaxLv()
    local part = self.mData.part
    local partName = language.equip06[part]
    local tipDec = self.view:GetChild("n74")
    tipDec.text = language.forging20
    local partText = self.view:GetChild("n69")
    partText.text = string.format(language.forging23,partName)
    local levText = self.view:GetChild("n70")
    levText.text = levStr

    local playLv = cache.PlayerCache:getRoleLevel()--玩家等级
    if playLv < maxLv and playLv >= lev then
        tipDec.visible = true
    else
        tipDec.visible = false
    end
    for i=1,3 do
      local attDec = self.view:GetChild("n7"..i)
      if i == 3 then
        attDec.text = string.format(language.forging27[i],maxLv)
      else
        attDec.text = language.forging27[i]
      end
    end
    --各级属性
    local function callback(data,obj)
        if data then
            for k,v in pairs(data) do
                if string.find(k,"att_") then
                    local strList = string.split(k,'_')
                    local attId = tonumber(strList[2])
                    obj.text = conf.RedPointConf:getProName(attId).."+"..v
                    break
                end
            end
        else
            obj.text = language.talent18
        end
    end

    local attText1 = self.view:GetChild("n78")--本级属性
    local attText2 = self.view:GetChild("n79")--下一级属性
    local attText3 = self.view:GetChild("n80")--满级属性
    local data1 = conf.ForgingConf:getStrenAttData(lev,part)
    local data2 = conf.ForgingConf:getStrenAttData(lev + 1,part)
    local data3 = conf.ForgingConf:getStrenAttData(maxLv,part)
    if self.mIndex == 8 then--升星属性
        data2 = conf.ForgingConf:getStarData(part,lev + 1)
        data1 = conf.ForgingConf:getStarData(part,lev)
        data3 = conf.ForgingConf:getStarData(part,maxLv)
    end
    callback(data1,attText1)
    callback(data2,attText2)
    callback(data3,attText3)
end
--升星tip
function ForgingTipsView:initTipPanel2()
    local tipDec = self.view:GetChild("n92")
    tipDec.text = language.forging21
    local part = self.mData.part
    local starLev = self.mData.starLev
    local levStr = string.format(language.forging25,self.mData.starLev)
    local partName = language.equip06[part]
    local maxLv = conf.ForgingConf:getStarMaxLv(part)
    local partText = self.view:GetChild("n87")
    partText.text = string.format(language.forging23,partName)
    local levText = self.view:GetChild("n88")
    levText.text = levStr
    for i=1,3 do
      local attDec = self.view:GetChild("n11"..i)
      if i == 3 then
        attDec.text = string.format(language.forging27[i],maxLv)
      else
        attDec.text = language.forging27[i]
      end
    end
    --当前属性
    local curAtts = {}
    for i=96,98 do
        local att = self.view:GetChild("n"..i)
        table.insert(curAtts, att)
    end
    --下级属性
    local nextAtts = {}
    for i=102,104 do
        local att = self.view:GetChild("n"..i)
        table.insert(nextAtts, att)
    end
    --最大属性
    local maxAtts = {}
    for i=105,107 do
        local att = self.view:GetChild("n"..i)
        table.insert(maxAtts, att)
    end
    
    self:setStarTipsData(part,starLev,maxLv,curAtts,nextAtts,maxAtts)
end
--升星tip属性
function ForgingTipsView:setStarTipsData(part,starLev,maxLv,curAtts,nextAtts,maxAtts)
    local confData1 = conf.ForgingConf:getStarData(part,starLev)--当前属性
    local confData2 = conf.ForgingConf:getStarData(part,starLev + 1)--下级属性
    if starLev >= maxLv then
        confData2 = conf.ForgingConf:getStarData(part,maxLv)--下级属性
    end
    local confData3 = conf.ForgingConf:getStarData(part,maxLv)--满级属性
    --当前属性
    if confData1 then
        local t = GConfDataSort(confData1)
        if #t <= 0 then--没有属性的情况
            local t2 = GConfDataSort(confData2)
            for k,v in pairs(t2) do
                if k == 1 then
                    curAtts[k].text = conf.RedPointConf:getProName(v[1]).." 0"
                elseif k == 2 then
                    curAtts[k].text = conf.RedPointConf:getProName(v[1]).." 0"
                elseif k == 3 then
                    curAtts[k].text = conf.RedPointConf:getProName(v[1]).." 0"
                end
            end
        else
            for k,v in pairs(t) do
                if k == 1 then
                    curAtts[k].text = conf.RedPointConf:getProName(v[1]).." "..v[2]
                elseif k == 2 then
                    curAtts[k].text = conf.RedPointConf:getProName(v[1]).." "..v[2]
                elseif k == 3 then
                    curAtts[k].text = conf.RedPointConf:getProName(v[1]).." "..v[2]
                end
            end
        end
    end
    --下级属性
    if confData2 then
        local t = GConfDataSort(confData2)
        for k,v in pairs(t) do
            if k == 1 then
                nextAtts[k].text = conf.RedPointConf:getProName(v[1]).." "..v[2]
            elseif k == 2 then
                nextAtts[k].text = conf.RedPointConf:getProName(v[1]).." "..v[2]
            elseif k == 3 then
                nextAtts[k].text = conf.RedPointConf:getProName(v[1]).." "..v[2]
            end
        end
    end
    --满级属性
    if confData3 then
        local t = GConfDataSort(confData3)
        for k,v in pairs(t) do
            if k == 1 then
                maxAtts[k].text = conf.RedPointConf:getProName(v[1]).." "..v[2]
            elseif k == 2 then
                maxAtts[k].text = conf.RedPointConf:getProName(v[1]).." "..v[2]
            elseif k == 3 then
                maxAtts[k].text = conf.RedPointConf:getProName(v[1]).." "..v[2]
            end
        end
    end
end

function ForgingTipsView:onClickClose()
    self.forgData = nil
    self:closeView()
end

return ForgingTipsView