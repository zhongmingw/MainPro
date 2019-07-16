--
-- Author: 
-- Date: 2018-09-13 15:48:00
--

local ShengYinStreng = class("ShengYinStreng", base.BaseView)

local TiShengStr = UIPackage.GetItemURL("awaken","shengyin_020")
local StopStr = UIPackage.GetItemURL("awaken","shengyin_026")

function ShengYinStreng:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
    self.isBlack = true
end

function ShengYinStreng:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    local dec = self.view:GetChild("n14")
    dec.text = language.shengyin04

    self.listView = self.view:GetChild("n3")
    self.listView.itemRenderer = function (index,obj)
        self:cellData(index,obj)
    end
    self.listView.onClickItem:Add(self.choseShengYin,self)
    -- self.listView:SetVirtual()
    self.choseItem = self.view:GetChild("n17")
    self.strenglv = self.view:GetChild("n10")
    self.cost = self.view:GetChild("n8")
    self.attList = self.view:GetChild("n21")
    self.attList.itemRenderer = function (index,obj)
        self:cellAttData(index,obj)
    end
    self.attList:SetVirtual()
    self.bar = self.view:GetChild("n11")
    --提升
    local btn = self.view:GetChild("n16")
    btn.data = 0
    btn.onClick:Add(self.onTiSheng,self)
    --一键提升
    self.oneKeyBtn = self.view:GetChild("n15")
    self.oneKeyBtn.data = 1
    self.oneKeyBtn.onClick:Add(self.onTiSheng,self)
    self.oneKeyBtn.icon = TiShengStr


end

function ShengYinStreng:initData(data)
    --强化满级
    self.isFullLv = false
    self.mData = data
    self.syScore = self.mData.materialNum
    for k,v in pairs(data.equipData) do
        local confData = conf.ItemConf:getItem(v.mid)
        local part = confData.part
        v.part = part
    end
    -- table.sort(data.equipData, function (a,b)
    --     if a.part ~= b.part then
    --         return a.part < b.part
    --     end
    -- end )
    self.partInfo = cache.AwakenCache:getShengYinPartInfo()
    -- printt(self.mData.equipData)
      for k,v in pairs(self.mData.equipData) do
        local confdata = conf.ItemConf:getItem(v.mid)
        local lv = 0
        if self.partInfo and next(self.partInfo)~=nil then
            for i , j in pairs(self.partInfo) do
                if j.part == confdata.part then
                    lv = j.strenLev
                    break
                end
            end
        else
            lv = 0
        end
        
        local color = conf.ItemConf:getQuality(v.mid)
        local limLvColor = 0--品质强化上限
        local colorData = conf.ShengYinConf:getValue("sy_stren_max_color")
        for _,q in pairs(colorData) do
            if q[1] == color then
                limLvColor = q[2]
                break
            end
        end
        v.lv = lv
        v.part = confdata.part

        local strengInfo = conf.ShengYinConf:getStrenInfo(confdata.part,lv)
        if strengInfo.need_cost then
            if self.syScore >= strengInfo.need_cost  and lv < limLvColor then
                v.sort = 1
            else
                v.sort = 2
            end
        end

    end

    table.sort( self.mData.equipData, function ( a,b )
        -- if a.sort and b.sort then
        -- end
        if a.sort and b.sort and  a.sort ~= b.sort then
            return a.sort < b.sort
        elseif a.lv and b.lv and  a.lv ~= b.lv then
            return a.lv < b.lv
        elseif a.part and b.part and  a.part ~= b.part then
            return a.part < b.part
        end
    end )

    -- printt("可强化圣印",data)
    --正在自动升级
    self.isAutoing = false
    --设置部位信息
    self:setPartInfo()
    --每次打开界面选中第一个
    self:choseFirstCell()
end



function ShengYinStreng:setData(data)
    self.newLv = data.level
   

    self.syScore = data.syScore
    
    self.strenglv.text = data.level
    -- local isLevelUp = self.oldLv ~= self.newLv and true or false
    -- print("self.newLv",self.newLv,self.oldLv,isLevelUp)
    if self.isAutoing then
        self:send()
    end
    
    self:setPartInfo()

    for k = 1,#self.mData.equipData do
        local cell = self.listView:GetChildAt(k - 1)
        if cell then
            if cell.selected then
                cell.onClick:Call()
                break
            end
        end
    end

end

function ShengYinStreng:send()
    --是否升级了
    local isLevelUp = self.oldLv ~= self.newLv and true or false
    if self.syScore >= self.needCost and not isLevelUp then
        proxy.AwakenProxy:send(1600105,{reqType = 0,part = self.part})
        self.oneKeyBtn.icon = StopStr
    else
        self.isAutoing = false
        self.oneKeyBtn.icon = TiShengStr
    end
end

function ShengYinStreng:setPartInfo()
    self.partInfo = cache.AwakenCache:getShengYinPartInfo()
    -- printt("强化后部位信息",self.partInfo)
    -- printt("self.mData.equipData",self.mData.equipData)
    -- printt("self.partInfo",self.partInfo)
 
 

    self.listView.numItems = #self.mData.equipData

end

function ShengYinStreng:choseFirstCell()
    for k = 1,#self.mData.equipData do
        local cell = self.listView:GetChildAt(k - 1)
        if cell then
            cell.onClick:Call()
            break
        end
    end
end

function ShengYinStreng:cellData(index,obj )
    local data = self.mData.equipData[index+1]
    if data then
        -- print("?????/",data.lv)
        local color = conf.ItemConf:getQuality(data.mid)
        obj:GetChild("title").text = mgr.TextMgr:getQualityStr1(conf.ItemConf:getName(data.mid), color)
        local lv = 0
        local exp = 0
        local confdata = conf.ItemConf:getItem(data.mid)
        local part = confdata.part
        if next(self.partInfo)~=nil then
            for k , v in pairs(self.partInfo) do
                if v.part == confdata.part then
                    lv = v.strenLev
                    exp = v.strenExp
                    break
                end
            end
        else
            exp = 0
            lv = 0
        end
        obj:GetChild("n4").text = lv.."级"
        local info = clone(data)
        info.index = 0
        info.level = lv
        info.isquan = true
        info.isArrow = true
        GSetItemData(obj:GetChild("n5"),info,true)
        local redImg = obj:GetChild("red")
        redImg.visible = false
        local strengInfo = conf.ShengYinConf:getStrenInfo(part,lv)
        if strengInfo.need_cost then

            redImg.visible = self.syScore >= strengInfo.need_cost and true or false
            
            local limLvColor = 0--品质强化上限
            local colorData = conf.ShengYinConf:getValue("sy_stren_max_color")
            for k,v in pairs(colorData) do
                if v[1] == color then
                    limLvColor = v[2]
                    break
                end
            end
            if lv == limLvColor then
                redImg.visible = false
            end


        else
            redImg.visible = false
        end
        obj.data = {data = data,lv = lv,part = part,exp = exp}
    end
end
--
function ShengYinStreng:choseShengYin(context)
    local cell = context.data
    local data = cell.data
    -- printt("所选圣印",data)
    self.oldLv = data.lv--圣印升级前等级
    self.newLv = nil
    self.strenglv.text = data.lv
    local info = clone(data.data)
        info.index = 0
        info.strenLev = data.lv
        info.isquan = true
        info.isArrow = true
    GSetItemData(self.choseItem,info,true)
    
    self.part = data.part
    local colorData = conf.ShengYinConf:getValue("sy_stren_max_color")
    self.colorMaxLv = 0
    local color = conf.ItemConf:getQuality(info.mid)
    for k,v in pairs(colorData) do
        if v[1] == color then
            self.colorMaxLv = v[2]
            break
        end
    end
    -- print("当前品质",color,"等级上限",self.colorMaxLv)

    local strengInfo = conf.ShengYinConf:getStrenInfo(self.part,data.lv)
    self.attData = GConfDataSort(strengInfo)
    if not strengInfo.need_exp then
       strengInfo =  conf.ShengYinConf:getStrenInfo(self.part,data.lv-1)
    end
    self.bar.max = tonumber(strengInfo.need_exp) 
    self.bar.value = data.exp
    

    local nextStengInfo = conf.ShengYinConf:getStrenInfo(self.part,data.lv+1) or conf.ShengYinConf:getStrenInfo(self.part,data.lv)
    --所需材料
    self.needCost = strengInfo.need_cost
    local color = tonumber(self.syScore) >= tonumber(strengInfo.need_cost) and 7 or 14
    local textData = {
        {text = self.syScore,color = color},
        {text = "/"..strengInfo.need_cost,color = 7},
    }
    self.cost.text = mgr.TextMgr:getTextByTable(textData)

    self.nextAttData = GConfDataSort(nextStengInfo)
    self.attList.numItems = #self.attData
end

function ShengYinStreng:cellAttData(index,obj)
    local data = self.attData[index+1]
    local nextData = self.nextAttData[index+1]
    local dec1 = obj:GetChild("n1")
    local dec2 = obj:GetChild("n2")
    dec1.text = conf.RedPointConf:getProName(data[1])..":"..GProPrecnt(data[1],math.floor(data[2]))
    dec2.text = conf.RedPointConf:getProName(nextData[1])..":"..GProPrecnt(nextData[1],math.floor(nextData[2]))
    -- print("self.newLv",self.newLv,"self.colorMaxLv",self.colorMaxLv,"self.oldLv",self.oldLv,"data[2]",data[2],"nextData[2]",nextData[2])
    if (self.newLv and self.newLv >= self.colorMaxLv) or (self.oldLv >= self.colorMaxLv) or data[2] == nextData[2] then--已满级
        self.newLv = nil
        dec2.text = "已满级"
        self.cost.text = ""
        self.bar.value = self.bar.max
        self.bar:GetChild("title").text = "MAX"
        self.isFullLv = true
    else
        self.isFullLv = false
    end
    -- if (self.newLv and self.newLv == self.colorMaxLv) or self.oldLv == self.colorMaxLv then

    -- end
end


function ShengYinStreng:onTiSheng(context)
    local data = context.sender.data
    local canSend = self.syScore >= self.needCost
    if canSend then
        if self.isFullLv then
            GComAlter(language.shengyin09)
            return
        end
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
        proxy.AwakenProxy:send(1600105,{reqType = 0,part = self.part})
    else
        GComAlter("材料不足")
    end
end



return ShengYinStreng