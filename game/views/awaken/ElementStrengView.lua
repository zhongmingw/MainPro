--
-- Author:bxp 
-- Date: 2018-10-30 10:55:54
--元素强化

local table = table
local pairs = pairs
local ElementStrengView = class("ElementStrengView", base.BaseView)

local TiShengStr = UIPackage.GetItemURL("awaken","bamenxitong_019")
local StopStr = UIPackage.GetItemURL("awaken","shengyin_026")
local ProId = {221043533}

function ElementStrengView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function ElementStrengView:initView()
    self:setCloseBtn(self.view:GetChild("n0"):GetChild("n2"))
    local dec1 = self.view:GetChild("n8")
    dec1.text = language.eightgates06[2]

    local dec2 = self.view:GetChild("n15")
    dec2.text = language.eightgates06[3]

    self.c1 = self.view:GetController("c1")
    --元素列表
    self.listView = self.view:GetChild("n2")
    self.listView.itemRenderer = function (index,obj)
        self:cellData(index,obj)
    end
    self.listView.onClickItem:Add(self.onClickSelect,self)

    self.choseItem = self.view:GetChild("n11")

    self.cost = self.view:GetChild("n6")
    --属性列表
    self.attList = self.view:GetChild("n12")
    self.attList.itemRenderer = function (index,obj)
        self:cellAttData(index,obj)
    end

    self.bar = self.view:GetChild("n7")
    --提升
    local btn = self.view:GetChild("n10")
    btn.data = 0
    btn.onClick:Add(self.onLevelUp,self)
    --一键提升
    self.oneKeyBtn = self.view:GetChild("n9")
    self.oneKeyBtn.data = 1
    self.oneKeyBtn.onClick:Add(self.onLevelUp,self)
    self.oneKeyBtn.icon = TiShengStr
    --升阶
    self.stepUpBtn = self.view:GetChild("n17")
    self.stepUpBtn.onClick:Add(self.onStepUpCallBack,self)

    self.stepTitle = self.view:GetChild("n18")
    self.stepTitle.text = ""

    self.view:GetChild("n5").url =ResPath.iconRes(conf.ItemConf:getSrc(ProId[1]))

end

function ElementStrengView:initData(data)
    local mid = data and data.mid 
    self.choseMid = mid
    local data = cache.AwakenCache:getEightGatesData()
    self.info = clone(data.info)
    self.score = cache.AwakenCache:getBMScore()

    --进阶间隔等级
    self.stepLevel = conf.EightGatesConf:getValue("bm_jinjie_level")
    --品质对应进阶上限
    self.stepByColor = conf.EightGatesConf:getValue("bm_jinjie_max")
    --强化上限
    self.strengByColor = conf.EightGatesConf:getValue("bm_stren_max_color")

    self:setEleInfo()
    self.listView.numItems = #self.info
    self:choseCell()
    --正在自动升级
    self.isAutoing = false

end

function ElementStrengView:addMsgCallBack(data)
    self.newLv = data.level

    self.score = data.score
    -- local isLevelUp = self.oldLv ~= self.newLv and true or false
    -- print("self.newLv",self.newLv,self.oldLv,isLevelUp)
    if self.isAutoing then
        self:send()
    end
    self:updateinfo()
    self:choseCell()
end

--更新元素列表信息 
function ElementStrengView:updateinfo(data)
    local data = cache.AwakenCache:getEightGatesData()
    self.info = clone(data.info)
  
    -- printt("更新后",self.info)
    self:setEleInfo()
    self.listView.numItems = #self.info
end

function ElementStrengView:setEleInfo()
    -- print("执行前",os.clock())
    for k,v in pairs(self.info) do
        v.site = k
        if v.state == 2 then
            local confData = conf.ItemConf:getItem(v.eleInfo.mid)
            local subType = confData and confData.sub_type or 1
            local strengInfo = conf.EightGatesConf:getStrengInfo(subType,v.eleInfo.level)
            if not strengInfo then
                print("八门强化表没有类型",subType,"等级",v.eleInfo.level)
                -- return
            end
            local needCost = strengInfo and strengInfo.need_cost or 0
            -- v.redNum = self.score >= needCost and 1 or 0
            if confData then
                local quality = confData.color
                --当前强化等级
                local curStrengLv = v.eleInfo.level
                --当前接
                local curstageLv = confData.stage_lvl
                --下次升阶等级
                local nextStepLv = curstageLv*self.stepLevel
                local maxLvCurColor = 0--当前品质可强化最高等级
                for k,v in pairs(self.strengByColor) do
                    if quality == v[1] then
                        maxLvCurColor = v[2]
                        break
                    end
                end
                -- -- if v.eleInfo.mid == 1311016002 then
                --     print("名称",conf.ItemConf:getName(v.eleInfo.mid))
                --     print("当前强化等级",curStrengLv)
                --     print("下次升阶等级",nextStepLv)
                --     print("当前品质可强化最高等级",maxLvCurColor)
                --     print("当前阶",curstageLv)
                --     print("拥有",self.score)
                --     print("消耗",needCost)
                --     -- printt("listnumber",listnumber)
                --     -- print("num",num)
                --     -- print("v.redNum",v.redNum)
                -- -- end
                if curStrengLv < maxLvCurColor and curStrengLv < nextStepLv and self.score >= needCost then--可强化
                    v.redNum = 1
                else
                    --当前阶
                    local curstageLv =  confData.stage_lvl
                    local flag = false
                    for _,j in pairs(self.stepByColor) do
                        if quality == j[1] and curstageLv < j[2] and curStrengLv == nextStepLv then--还可以再升阶
                            flag = true
                            break
                        end
                    end
                    if flag then
                        local confData = conf.EightGatesConf:getStepCost(curstageLv)
                        local listnumber = {}
                        for _,n in pairs(confData.items) do
                            local _packdata = cache.PackCache:getElementById(n[1])
                            table.insert(listnumber,math.floor(_packdata.amount/n[2]))
                        end
                        local num = math.min(unpack(listnumber))
                        if num > 0 then
                            v.redNum = 1
                        else
                            v.redNum = 0
                        end
                    else
                        v.redNum = 0
                    end
                end
            end             
        else
            v.redNum = 0
        end
    end
    table.sort(self.info,function (a,b)
        if a.state ~= b.state then
            return a.state > b.state
        elseif a.redNum ~= b.redNum then
            return a.redNum > b.redNum
        else
            return a.site < b.site
        end
    end)
    -- printt("self.info",self.info)

    -- print("执行后",os.clock())

end

function ElementStrengView:choseCell()
    if self.choseMid == 0 then
        if self.listView.numItems > 0 then
            local cell = self.listView:GetChildAt(0)
            if cell then
                cell.onClick:Call()
            end
        end
    else
        for k = 1,self.listView.numItems do
            local cell = self.listView:GetChildAt(k - 1)
            if cell then
                local change = cell.data
                local mid = change.mData.eleInfo.mid
                if self.choseMid == mid then--选中boss
                    cell.onClick:Call()
                    break
                end
            end
        end
    end
end


--元素列表
function ElementStrengView:cellData(index,obj)
    local data = self.info[index+1]
    local name = obj:GetChild("title")
    local siteName = obj:GetChild("n7")
    siteName.text = "孔位："..language.eightgates04[data.site]
    
    local lvl = obj:GetChild("n4")
    lvl.text = string.format(language.skill03,data.eleInfo.level)
    
    local redImg = obj:GetChild("red")
    redImg.visible = data.redNum == 1
    
    if data.state == 2 then
        local info = clone(data.eleInfo)
        if info and info.mid ~= 0 then
            name.text = mgr.TextMgr:getQualityStr1(conf.ItemConf:getName(info.mid), conf.ItemConf:getQuality(info.mid))
            info.isquan = true
            info.isArrow = true
            GSetItemData(obj:GetChild("n5"),info,true)
        end 
    else
        name.text = "暂无"
        GSetItemData(obj:GetChild("n5"),{})
    end
    obj.data = {mData = data, index = index}
end



function ElementStrengView:send()
    --是否升级了
    local isLevelUp = self.oldLv ~= self.newLv and true or false
    if self.score >= self.needCost and not isLevelUp then
        proxy.AwakenProxy:send(1610105,{reqType = 0,site = self.site})
        self.oneKeyBtn.icon = StopStr
    else
        self.isAutoing = false
        self.oneKeyBtn.icon = TiShengStr
    end    
end


--选择元素
function ElementStrengView:onClickSelect(context)
    local cell = context.data
    local data = cell.data
    self.choseEleData = data
    -- printt("所选元素",data) 
    self.c1.selectedIndex = 0--强化
    self.oldLv = data.mData.eleInfo.level
    if data.mData.state == 2 then
        self.site = data.mData.site
        local info = clone(data.mData.eleInfo)
        if info and info.mid ~= 0 then
            self.choseMid = info.mid
            info.isquan = true
            info.isArrow = true
            GSetItemData(self.choseItem,info,true)
            --阶
            local curstageLv = conf.ItemConf:getStagelvl(info.mid)
            --当前强化等级
            local curStrengLv = data.mData.eleInfo.level --== 0 and 1 or data.mData.eleInfo.level
            self.curStrengLv = curStrengLv
            local stepColor = 0--可进阶品质
            for k,v in pairs(self.stepByColor) do
                if curstageLv < v[2] then
                    stepColor = v[1]
                    break
                end
            end
            local maxLvCurColor = 0--当前品质可强化最高等级
            local quality = conf.ItemConf:getQuality(info.mid)
            for k,v in pairs(self.strengByColor) do
                if quality == v[1] then
                    maxLvCurColor = v[2]
                    break
                end
            end
            -- print("可进阶品质",stepColor,"当前接",curstageLv)
            --下一次升阶等级
            -- local lv = curStrengLv
            -- if lv == 0 or lv%self.stepLevel == 0 then
            --     lv = lv +1
            -- end
            local nextStepLv = curstageLv*self.stepLevel
            if stepColor > 0 then
                local colorStr = mgr.TextMgr:getQualityStr1(string.format(language.gonggong110[stepColor]),stepColor)
                self.stepTitle.text = string.format(language.eightgates12,nextStepLv,colorStr)
                self.stepUpBtn.grayed = false
                self.stepUpBtn.touchable = true
            else
                self.stepUpBtn.grayed = true
                self.stepUpBtn.touchable = false
                self.stepTitle.text = "已达到最大阶数"
            end
          
            local subType = conf.ItemConf:getSubType(info.mid)
            local strengConf = conf.EightGatesConf:getStrengInfo(subType,curStrengLv)
            local nextStrengConf = conf.EightGatesConf:getStrengInfo(subType,curStrengLv+1) or 
                                    conf.EightGatesConf:getStrengInfo(subType,curStrengLv)
             --所需材料
            self.needCost = strengConf.need_cost or 0
            self.needExp = strengConf.need_exp or 0
            local strColor = tonumber(self.score) >= tonumber(self.needCost) and 7 or 14
            local textData = {
                {text = self.score,color = strColor},
                {text = "/"..self.needCost,color = 7},
            }
            self.cost.text = mgr.TextMgr:getTextByTable(textData)
            --下一级属性
            self.nextAttData = GConfDataSort(nextStrengConf)
            self.attData = GConfDataSort(strengConf)
            self.attList.numItems = #self.attData +1
            -- print("当前强化等级",curStrengLv,"下一次升阶等级",nextStepLv,"强化上限",maxLvCurColor)
            if curStrengLv < nextStepLv and curStrengLv < maxLvCurColor then
                self.c1.selectedIndex = 0--强化
                self.bar.max = tonumber(self.needExp) 
                self.bar.value = data.mData.eleInfo.exp
            else
                self.c1.selectedIndex = 1--进阶
                self.isCanStepUp = conf.ItemConf:getQuality(info.mid) >= stepColor
                self.bar.value = self.bar.max
                self.bar:GetChild("title").text = "MAX"
            end
        end 
    else
        self.site = 0
        GComAlter("该部位还未镶嵌元素")
        GSetItemData(self.choseItem,{})
        self.stepTitle.text = ""
        self.attList.numItems = 0
        self.cost.text = ""
        self.bar.max = 1
        self.bar.value = 0
        self.c1.selectedIndex = 2
        -- cell.selected = false
    end

end
--属性列表
function ElementStrengView:cellAttData(index,obj)
    local dec1 = obj:GetChild("n1")
    local dec2 = obj:GetChild("n2")
    if index == 0 then
        dec1.text = "强化等级："..self.curStrengLv
        dec2.text = self.curStrengLv +1
    else
        local data = self.attData[index]
        local nextData = self.nextAttData[index]
        if data and nextData then
            dec1.text = conf.RedPointConf:getProName(data[1])..":"..GProPrecnt(data[1],math.floor(data[2]))
            dec2.text = conf.RedPointConf:getProName(nextData[1])..":"..GProPrecnt(nextData[1],math.floor(nextData[2]))
        end
    end
end

--强化
function ElementStrengView:onLevelUp(context)
    local data = context.sender.data
    if self.site == 0 then return end
    local canSend = self.score >= self.needCost
    if canSend then
        if data == 0 then
            self.isAutoing = false
            self.oneKeyBtn.icon = TiShengStr
        elseif data == 1 then--一键
            self.isAutoing = not self.isAutoing
            if self.isAutoing then
                self.oneKeyBtn.icon = StopStr
            else
                self.oneKeyBtn.icon = TiShengStr
            end
        end
        proxy.AwakenProxy:send(1610105,{reqType = 0,site = self.site})
    else
        GComAlter("材料不足")
    end
end
--升阶
function ElementStrengView:onStepUpCallBack()
    if not self.isCanStepUp then
        GComAlter(language.eightgates13)
    else
        if self.choseEleData then
            mgr.ViewMgr:openView2(ViewName.ElemetStepUpView,{choseEleData = self.choseEleData})
            self:closeView()
        end
    end

end

return ElementStrengView