--
-- Author: 
-- Date: 2018-09-14 22:34:20
--

local ShengHunView = class("ShengHunView", base.BaseView)

function ShengHunView:ctor()
    self.super.ctor(self)
    self.isBlack = true
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
end

function ShengHunView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)

    self.listView = self.view:GetChild("n12")
    self.listView.itemRenderer = function (index,obj)
        self:cellData(index, obj)
    end
    self.listView:SetVirtual()
end

function ShengHunView:initData()
    self:setData()
end

function ShengHunView:setData()
    self.shInfos = cache.AwakenCache:getShenghunInfo()
    self.shData = conf.ShengYinConf:getShengHunData()
    self.listView.numItems = #self.shData
    self.canSend = true
end

function ShengHunView:cellData(index,obj)
    local data = self.shData[index+1]
    local item = obj:GetChild("n7"):GetChild("n7")
    local num = obj:GetChild("n7"):GetChild("n13")
    local bar = obj:GetChild("n8")
    local attTxt = obj:GetChild("n9")
    local useBtn = obj:GetChild("n10")
    local lvHint = obj:GetChild("n11")
    local c1 = obj:GetController("c1")

    local itemInfo = {}
    itemInfo.mid = data.id
    itemInfo.amount = 1
    itemInfo.bind = 0
    GSetItemData(item, itemInfo, true)

    local haveShengHun = cache.PackCache:getPackDataById(data.id).amount
    local color = haveShengHun >= tonumber(data.cost) and 10 or 14
    local textData = {
        {text = haveShengHun,color = color},
        {text = "/"..data.cost,color = 10},
    }
    num.text = mgr.TextMgr:getTextByTable(textData)

    local max = 0
    local nextLv
    local roleLv = cache.PlayerCache:getRoleLevel()
    local flag = false
    table.sort(data.use_max, function (a,b)
        return a[1] > b[1]
    end)
    -- printt(data.use_max)
    for k,v in pairs(data.use_max) do
        if roleLv >= v[1] then
            max = v[2]
            nextLv = data.use_max[k-1] and data.use_max[k-1][1]
            -- flag = true
            -- print(data.use_max[k-1][1])
            break
        end
    end
    if nextLv then
        lvHint.text = string.format(language.shengyin07,nextLv)
    else
        max =  data.use_max[1][2]
        lvHint.text = ""
    end



    -- if not flag then
    --     max =  data.use_max[#data.use_max][2]
    --     lvHint.text = ""
    -- else
    --     lvHint.text = string.format(language.shengyin07,nextLv)
    -- end
    bar.max = max
    bar.value = self.shInfos[data.id] and self.shInfos[data.id] or 0
    c1.selectedIndex = haveShengHun >= data.cost and 0 or 1
    if bar.value == max then
        c1.selectedIndex = 1
    end
    local attiData = conf.ItemArriConf:getItemAtt(data.id)
    local t = GConfDataSort(attiData)
    local baseAtt = {}
    local shengYinAtt = {}
    for k,v in pairs(t) do
        if tonumber(v[1]) < 500 then
            table.insert(baseAtt,v)
        else
            table.insert(shengYinAtt,v)
        end
    end
    local str = ""
    for k,v in pairs(baseAtt) do
        local str1 = conf.RedPointConf:getProName(v[1]).." [color=#0B8109]+"..tonumber(GProPrecnt(v[1],math.floor(v[2])))*bar.value.."[/color]"
        str = str.."  "..str1
    end
    local str2 = ""
    for k,v in pairs(shengYinAtt) do
        local str3 = conf.RedPointConf:getProName(v[1]).." [color=#0B8109]+"..tonumber(string.sub(GProPrecnt(v[1],math.floor(v[2])),1,-2))*bar.value.."%[/color]"
        str2 = str2..str3
    end
    attTxt.text = str.."\n"..str2

    local cacheData = cache.PackCache:getPackDataById(data.id)
    useBtn.data = {index = cacheData.index,amount = data.cost ,value = tonumber(bar.value),max = max }
    useBtn.onClick:Add(self.onClickGetBtn,self)

end

function ShengHunView:onClickGetBtn(context)
    local data = context.sender.data
    local value  = data.value
    local max = data.max
    if self.canSend then
        if value < max then
            self.canSend = false
            local data = context.sender.data
            local param = {}
            param.index = data.index
            param.amount = data.amount
            param.ext_arg = 0
            -- printt("使用道具",param)
            proxy.PackProxy:sendUsePro(param)
        else
            GComAlter(language.team66)
        end
    else
        GComAlter(language.team66)
    end
end


return ShengHunView