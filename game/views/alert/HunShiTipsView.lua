--
-- Author: 
-- Date: 2018-11-27 19:03:30
--魂饰

local HunShiTipsView = class("EquipTipsView", base.BaseView)

function HunShiTipsView:ctor()
    HunShiTipsView.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
    self.isBlack = true 
end

function HunShiTipsView:initView()
    self.leftpanel = self.view:GetChild("n0")
    self.oldxy = self.leftpanel.xy
    self.rightpanel = self.view:GetChild("n1")

    self.leftpanel.visible = false
    self.rightpanel.visible = false
    self.leftxy = {
        self.leftpanel:GetChild("n44").xy,
        self.leftpanel:GetChild("n48").xy,
        self.leftpanel:GetChild("n45").xy,
    }
    self.rightxy = {
        self.rightpanel:GetChild("n50").xy,
        self.rightpanel:GetChild("n56").xy,
        self.rightpanel:GetChild("n51").xy,
    }
    self:setCloseBtn(self.blackView)

end

function HunShiTipsView:initData()
    -- body
    self.leftpanel:GetChild("n44").xy = self.leftxy[1]
    self.leftpanel:GetChild("n48").xy = self.leftxy[2]
    self.leftpanel:GetChild("n45").xy = self.leftxy[3]

    self.rightpanel:GetChild("n50").xy = self.rightxy[1]
    self.rightpanel:GetChild("n56").xy = self.rightxy[2]
    self.rightpanel:GetChild("n51").xy = self.rightxy[3]
    self.maxLvByColor = conf.DiHunConf:getValue("dh_stren_max_color")
end
function HunShiTipsView:setData(data)
    if not data then
        self:closeView()
        return
    end
    if not data.index then
        data.index = 0
    end
    self.leftpanel.visible = false
    self.rightpanel.visible = false
    local confData = conf.ItemConf:getItem(data.mid)
    --魂饰类型
    self.subType = confData.sub_type
    --魂饰部位
    self.part = confData.part

    self.data = data
   
    local view = mgr.ViewMgr:get(ViewName.DiHunPack)
    if view then
        self.packInfo = cache.PackCache:getDiHunDataByIndex(data.index)
    else
        self.packInfo = nil
    end
    self.dhInfo = cache.DiHunCache:getDiHunInfoByType(self.subType)
    self.leftInfo = nil
    for k,v in pairs(self.dhInfo.partInfo) do
        if v.part == self.part and v.item.mid ~= 0 then
            local t = clone(v)
            t.mid = v.item.mid 
            self.leftInfo = t
        end
    end
    local leftLv = self.leftInfo and  self.leftInfo.strenLevel and  self.leftInfo.strenLevel or 0
    self.strenLev = data.strenLevel or leftLv
    if data.index == 0 then
        self.index = 1--只是道具显示
    else
        if self.packInfo then
            self.index = 2 --穿戴
            if self.leftInfo then
                self.index = 3--更换
            end
        else
            --选择的是穿在身上的
            self.leftInfo = data
            self.index = 4 --强化
        end
    end
    -- print("self.index",self.index)

    if self.index == 1 then
        if self.leftInfo then
            self:initLeft(self.leftInfo)
            self:initRight(self.data)
            self.leftpanel.xy = self.oldxy
        else
            self:initLeft(self.data)
            self.leftpanel:Center()
        end
    elseif self.index == 2 then
        self:initLeft(self.data)
        self.leftpanel:Center()
    elseif self.index == 3 then
        self.leftpanel.xy = self.oldxy
        self:initLeft(self.leftInfo)
        self:initRight(self.data)
    elseif self.index == 4 then
        self:initLeft(self.leftInfo)
        self.leftpanel:Center()
    end

end

function HunShiTipsView:initLeft(data)
    self.leftmid = data.mid
    self.leftpanel.visible = true
    --道具icon
    local itemObj = self.leftpanel:GetChild("n19")
    local t = clone(data)
    -- t.isquan = true
    GSetItemData(itemObj,t)

    local confData = conf.ItemConf:getItem(data.mid)
    --名字
    local name = self.leftpanel:GetChild("n24")
    name.text = mgr.TextMgr:getColorNameByMid(data.mid)
    --部位
    local partName = self.leftpanel:GetChild("n25") 
    --最大强化等级
    self.leftMaxLv = 0
    for k,v in pairs(self.maxLvByColor) do
        if v[1] == confData.color then
            self.leftMaxLv = v[2]
        end
    end
    partName.text = "最大强化等级："..self.leftMaxLv
    --强化等级
    local strenLevTxt = self.leftpanel:GetChild("n49")
    local strenLev = math.min(self.strenLev,self.leftMaxLv)
    strenLevTxt.text = mgr.TextMgr:getTextColorStr("强化等级：".. strenLev,7)
    --绑定
    local isbind = self.leftpanel:GetChild("n26") 
    isbind.text = ""
    --阶数
    local equipDesc1 = self.leftpanel:GetChild("n27")
    equipDesc1.text = "装备位置："..confData.part_name or ""
    --装备等级
    local level = self.leftpanel:GetChild("n50")
    local t = conf.DiHunConf:getDiHunInfoByType(confData.sub_type)
    level.text = "帝魂："..t.name

    local need = self.leftpanel:GetChild("n28")
    need.text =  ""
    --基础评分
    local power = self.leftpanel:GetChild("n18")
    power.text = 0
    --综合评分
    local power1 = self.leftpanel:GetChild("n54")
    power1.text = 0
    --已装备icon
    local isWear = self.leftpanel:GetChild("n4")
    if self.index == 3 or self.index == 4 then
        isWear.visible = true
    else
        isWear.visible = false
    end
    --属性
    local listView = self.leftpanel:GetChild("n41")
    local score,score1 = self:setListMsg(listView,data)
    power.text = math.floor(score)
    power1.text = math.floor(score + score1) 
    --仓库令
    self.leftpanel:GetChild("n56").visible = false
    self.leftpanel:GetChild("n55").text = ""
    --获取途径
    local listView1 = self.leftpanel:GetChild("n47")
    self:setGetWayList(listView1,confData)

    self:setBtnSeeinfo(1)
end

function HunShiTipsView:initRight(data)
    self.rightmid = data.mid
    self.rightpanel.visible = true
    --道具icon
    local itemObj = self.rightpanel:GetChild("n19")
    local t = clone(data)
    -- t.isquan = true
    GSetItemData(itemObj,t)

    local confData = conf.ItemConf:getItem(data.mid)

    --名字
    local name = self.rightpanel:GetChild("n24")
    name.text = mgr.TextMgr:getColorNameByMid(data.mid)
    --部位
    local partName = self.rightpanel:GetChild("n25") 
    --最大强化等级
    local rightMaxLv = 0
    for k,v in pairs(self.maxLvByColor) do
        if v[1] == confData.color then
            rightMaxLv = v[2]
        end
    end
    partName.text = "最大强化等级："..rightMaxLv
    --绑定
    local isbind = self.rightpanel:GetChild("n26") 
    isbind.text = ""
    --阶数
    local equipDesc1 = self.rightpanel:GetChild("n27")
    equipDesc1.text = "装备位置："..confData.part_name or ""

      --强化等级
    local strenLevTxt = self.rightpanel:GetChild("n58")
    local strenLev = math.min(self.strenLev,rightMaxLv)

    strenLevTxt.text = mgr.TextMgr:getTextColorStr("强化等级：".. strenLev,7)
    --装备等级
    local level = self.rightpanel:GetChild("n57")
    local t = conf.DiHunConf:getDiHunInfoByType(confData.sub_type)
    level.text = "帝魂："..t.name

    local need = self.rightpanel:GetChild("n28")
    need.text =  ""
    --基础评分
    local power = self.rightpanel:GetChild("n18")
    power.text = 0
    --综合评分
    local power1 = self.rightpanel:GetChild("n62")
    power1.text = 0
    local isWear = self.rightpanel:GetChild("n4")
    isWear.visible = false
       --属性
    local listView = self.rightpanel:GetChild("n47")
    local score,score1 = self:setListMsg(listView,data)

    power.text = math.floor(score)
    power1.text = math.floor(score + score1)

    local listView1 = self.rightpanel:GetChild("n55")
    self:setGetWayList(listView1,confData)

    self.rightpanel:GetChild("n64").visible = false
    self.rightpanel:GetChild("n63").text = ""

    local isWear = self.leftpanel:GetChild("n4")
    isWear.visible = true
    
    --装备对比
    self:setEquipContrast()

    self:setBtnSeeinfo(2)

end
function HunShiTipsView:setEquipContrast()
    local text1 = self.rightpanel:GetChild("n41")
    local text2 = self.rightpanel:GetChild("n42")
    local text3 = self.rightpanel:GetChild("n53")

    local text4 = self.rightpanel:GetChild("n43")
    local text5 = self.rightpanel:GetChild("n44")
    local text6 = self.rightpanel:GetChild("n54")

    text1.text = ""
    text2.text = ""
    text3.text = ""
    text4.text = ""
    text5.text = ""
    text6.text = ""

    local confdataright = conf.ItemConf:getItem(self.rightmid)
    local confdataleft = conf.ItemConf:getItem(self.leftmid)

    local attiData1 = conf.ItemArriConf:getItemAtt(self.rightmid )
    local attiData2 = conf.ItemArriConf:getItemAtt(self.leftmid)
    local num = 0
    local function getText(num)
        if num < 0 then
            return mgr.TextMgr:getTextColorStr(num, 14)
        elseif num > 0 then
            return mgr.TextMgr:getTextColorStr("+"..num, 7)
        else
            return ""
        end
    end
    local t = GConfDataSort(attiData1)
    for k,v in pairs(t) do
        num = num + 1
        local att2 = attiData2 and attiData2["att_"..v[1]] or 0
        if num == 1 then
            text1.text = conf.RedPointConf:getProName(v[1])
            text4.text = getText(v[2] - att2)
        elseif num == 2 then
            text2.text = conf.RedPointConf:getProName(v[1])
            text5.text = getText(v[2] - att2)
        elseif num == 3 then
            text3.text = conf.RedPointConf:getProName(v[1])
            text6.text = getText(v[2] - att2)
        end
    end
end

function HunShiTipsView:setListMsg(listView,data)
    listView.numItems = 0
    local attiData = conf.ItemArriConf:getItemAtt(data.mid)
    --魂饰属性
    local baseAttData = GConfDataSort(attiData)
    local url = UIPackage.GetItemURL("alert" , "baseAttiItem")
    local baseitem = listView:AddItemFromPool(url)
 
    local score = 0--基础评分
    local str = ""
    local strengStr = ""
    for k,v in pairs(baseAttData) do
        local str1 = conf.RedPointConf:getProName(v[1]).." "..GProPrecnt(v[1],math.floor(v[2]))
        if k ~= #baseAttData then
            str1 = str1.."\n"
            -- text = text.." ".."\n"
        end
        str = str..str1
        score = score + mgr.ItemMgr:baseAttScore(v[1],v[2])--基础评分
    end
    baseitem:GetChild("n0").text = language.equip02[11]
    baseitem:GetChild("n8").text = str
    baseitem:GetChild("n1").text = ""
    
    --分解获得
    local url = UIPackage.GetItemURL("alert" , "Component6")
    local baseitem = listView:AddItemFromPool(url)

    local spltData = conf.DiHunConf:getSplitExp(data.mid)
    if not spltData then
        print("帝魂配置sy_split缺少",data.mid)
    else
        local partnerNum = spltData.items[1][2]
        baseitem:GetChild("n0").text = language.equip02[10]--分解获得
        baseitem:GetChild("n1").url =  ResPath.iconRes(tostring(conf.ItemConf:getSrc(spltData.items[1][1])))
        baseitem:GetChild("n2").text = partnerNum
    end
    
    local  synScore = 0
    return score,synScore
end

--获取途径
function HunShiTipsView:setGetWayList(listView1,confData)
    listView1.itemRenderer = function(index,obj)
        local info = confData.formview[index + 1]
        local id = info[1]
        local childIndex = info[2]
        local data = conf.SysConf:getModuleById(id)
        local lab = obj:GetChild("n1")
        lab.text = data.desc
        local btn = obj:GetChild("n0")
        if id == 9998 then--运营活动
            btn.visible = false
        else
            btn.visible = true
        end
        btn.data = {id = id,childIndex = childIndex}
        btn.onClick:Add(self.onBtnGo,self)
    end
    listView1.numItems = confData.formview and #confData.formview or 0 
end

function HunShiTipsView:onBtnGo(context)
    local data = context.sender.data
    local param = {id = data.id,childIndex = data.childIndex}
    GOpenView(param)
end


function HunShiTipsView:setBtnSeeinfo(way)
    local btn1 
    local btn2 
    local btn3
    local c1  
    local p1 --蓝底
    if way == 1 then--左侧面板
        btn1 = self.leftpanel:GetChild("n44")--穿戴
        btn2 = self.leftpanel:GetChild("n48")--吞噬
        btn3 = self.leftpanel:GetChild("n45")--丢弃
        c1 = self.leftpanel:GetController("c1")
        p1 = self.leftpanel:GetChild("n42")
        xylist=  self.leftxy
    else
        btn1 = self.rightpanel:GetChild("n50")
        btn2 = self.rightpanel:GetChild("n56")
        btn3 = self.rightpanel:GetChild("n51")
        c1 = self.rightpanel:GetController("c1")
        p1 = self.rightpanel:GetChild("n48")
        xylist=  self.rightxy
    end
    
    btn1.onClick:Clear()
    btn1.onClick:Add(self.onWearEquip,self)
    btn2.onClick:Clear()
    btn3.onClick:Clear()

    btn2.title = language.shengyin02[2]--分解
    btn2.onClick:Clear()
    btn2.onClick:Add(self.onTunshi,self)
    btn3.visible = false
    if self.index == 1 then--只是查看
        c1.selectedIndex = 0
    elseif self.index == 2 then--穿戴
        c1.selectedIndex = 1
        btn1.title = language.shengyin02[1]
        btn1.visible = true
        btn2.visible = true
        btn3.visible = false
    elseif self.index == 3 then--更换
        c1.selectedIndex = 1
        btn1.visible = true
        btn2.visible = true
        btn3.visible = false
        btn1.title = language.shengyin02[4]
    elseif self.index == 4 then--脱
        c1.selectedIndex = 1
        btn1.visible = true
        btn1.title = language.eightgates02[5]
        btn2.visible = true
        btn2.title = language.shengyin02[4]
        btn2.onClick:Clear()
        btn2.onClick:Add(self.onOpenPack,self)
        btn3.visible = false
    end

    local count =  (btn1.visible and 1 or 0) +(btn2.visible and 1 or 0)+(btn3.visible and 1 or 0)
    if count == 3 then
        p1.height = 158
    elseif count == 2 then
        p1.height = 115
    else
        p1.height = 74
    end

    local t = {}
    table.insert(t,btn1)
    table.insert(t,btn2)
    table.insert(t,btn3)

    local number = 1
    for k ,v in pairs(t) do
        if v.visible then
            v.xy = xylist[number]
            number = number + 1
        end
    end

end

function HunShiTipsView:onWearEquip(context)
    local btn = context.sender
    local param = {}
    param.indexs = {}
    if self.index == 1 then
        return --看
    elseif self.index == 2 then--穿
        if self.dhInfo.star == -1 then
            GComAlter(language.dihun07)
            return
        end
        param.type = self.subType
        param.partInfos = {self.part}
        table.insert(param.indexs,self.data.index)
    elseif self.index == 3 then--换
        param.type = self.subType
        param.partInfos = {self.part}
        table.insert(param.indexs,self.data.index)
        local rightColor = conf.ItemConf:getQuality(self.rightmid)
        local leftColor = conf.ItemConf:getQuality(self.leftmid)
        if rightColor < leftColor then
            local str1 = mgr.TextMgr:getQualityStr1( language.gonggong110[leftColor],leftColor )
            local str2 = mgr.TextMgr:getQualityStr1( language.gonggong110[rightColor],rightColor )
            local mData = {}
            mData.type = 21
            mData.richtext = string.format(language.dihun03,str1,str2)
            mData.sure = function ()
                proxy.DiHunProxy:sendMsg(1620104,param)
                self:closeView()
            end
            GComAlter(mData)
            return
        end
    elseif self.index == 4 then--强化
        local mData = {}
        mData.mid = self.data.mid
        mData.subType = self.subType
        mData.part = self.part
        mData.lv = math.min(self.strenLev ,self.leftMaxLv)
        mgr.ViewMgr:openView2(ViewName.HunShiStrengView,mData)
        self:closeView()
        return
    end
    proxy.DiHunProxy:sendMsg(1620104,param)
    self:closeView()
end
--吞噬
function HunShiTipsView:onTunshi()
    local data = {}
    table.insert(data,self.data.index)
    proxy.DiHunProxy:sendMsg(1620106,{indexs = data})
    self:closeView()
end

function HunShiTipsView:onOpenPack()
    local view = mgr.ViewMgr:get(ViewName.DiHunPack)
    if not view then
        mgr.ViewMgr:openView2(ViewName.DiHunPack,{subType = self.subType})
    end
    self:closeView()
end

return HunShiTipsView