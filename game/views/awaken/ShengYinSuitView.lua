--
-- Author: 
-- Date: 2018-09-14 10:26:27
--

local ShengYinSuitView = class("ShengYinSuitView", base.BaseView)

function ShengYinSuitView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
    self.isBlack = true
end

function ShengYinSuitView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)

    self.suitList = self.view:GetChild("n7")
    self.suitList.itemRenderer = function (index,obj)
        self:cellData(index,obj)
    end
    self.suitList.onClickItem:Add(self.choseSuit,self)
    self.suitList:SetVirtual()

    self.attList = self.view:GetChild("n20")
    self.attList.itemRenderer = function (index,obj)
        self:cellAttData(index,obj)
    end
    
    --获得圣印
    local getBtn = self.view:GetChild("n27")
    getBtn.onClick:Add(self.onGetShengYin,self)
    --套装积分
    self.suitScore = self.view:GetChild("n26")

    self.suitCom = {}
    for i=1,11 do
        local btn = self.view:GetChild("n8"):GetChild("n"..i)
        btn.data = i
        btn.onClick:Add(self.onBtnCallBack,self)
        table.insert(self.suitCom,btn)
    end
end

function ShengYinSuitView:initData()
    self.suitData = conf.ShengYinConf:getSuitData()
    
    -- printt(#self.suitData,self.suitData)
    
    self.shengYinItems = conf.ItemConf:getShengYinItems()
    
    self.suitList.numItems = #self.suitData

    --选择第一个cell
    self:choseFirstCell()

end

function ShengYinSuitView:choseFirstCell()
    for k = 1,#self.suitData do
        local cell = self.suitList:GetChildAt(k - 1)
        if cell then
            cell.onClick:Call()
            break
        end
    end
end

function ShengYinSuitView:setData(data)
    
end

function ShengYinSuitView:cellData(index,obj)
    local data = self.suitData[index+1]
    local name = obj:GetChild("title")
    local num = obj:GetChild("n4")
    local color = data[1].color
    local str = data[1] and data[1].name and data[1].name or ""
    name.text = mgr.TextMgr:getQualityStr1("["..str.."]",color)
    --套装总件数
    local suitNum = data[#data].dress_num
    --套装激活件数
    local extType = data[1] and math.floor(data[1].id /1000) 
    -- print(extType)
    local actNum = GGetActShengYinSuitByExtType(extType)
    num.text = actNum.."/"..suitNum
    obj.data = {data = data,extType = extType,index = index,actNum = actNum}
end
--选择套装
function ShengYinSuitView:choseSuit(context)
    local cell = context.data
    local data = cell.data
    -- printt("所选套装",data)
    local attData = data.data
    local extType = data.extType
    local shengYinItem = self:getItemsByExtType(extType)
    self.suitItem = {}
    for k,v in pairs(shengYinItem) do
        self.suitItem[v.part] = v
    end
    -- printt("套装装备",suiItem)
    self:setPartMsg(self.suiItem)

    self.attData = self.suitData[data.index+1]
    -- printt("属性",self.attData)
    self.allScore = 0
    self.actNum = data.actNum
    self.attList.numItems = #self.attData

    self.suitScore.text = self.allScore

end

function ShengYinSuitView:getItemsByExtType(extType)
    local item = {}
    for k,v in pairs(self.shengYinItems) do
        if v.ext_type and v.ext_type == extType then
            table.insert(item,v)
        end
    end
    return item
end
--设置部位信息
function ShengYinSuitView:setPartMsg()
    for k,v in pairs(self.suitCom) do
        local frame = v:GetChild("n1")
        local icon = v:GetChild("n2")
        local effectPanel = v:GetChild("n3")
        -- if v.data == 11 then
        --     frame.visible = false
        -- end
        frame.url = UIItemRes.shengyin02[v.data]
        local info = self.suitItem[v.data]
        if info then
            local confData = conf.ItemConf:getItem(info.id)
            icon.url = confData.src and ResPath.iconRes(confData.src) or nil
            if confData.shengyin_movie then
                effectPanel.url = UIPackage.GetItemURL("_movie" , "MovieShengYin"..confData.shengyin_movie)
            end
            if v.data == 11 then
                effectPanel.url = UIPackage.GetItemURL("_movie" , "MovieShengYin11")
            end
        else
            icon.url = nil
            effectPanel.url = nil
        end
    end
end
--部位点击
function ShengYinSuitView:onBtnCallBack(context)
    local btn = context.sender 
    local data = btn.data 
    local t = self.suitItem[data]
    local partInfo = cache.AwakenCache:getShengYinPartInfo()
    local info = clone(t)
    if info then
        if next(partInfo) ~= nil then
            for k , v in pairs(partInfo) do
                local confdata = conf.ItemConf:getItem(t.id)
                if v.part == confdata.part then
                    info.level = v.strenLev--该部位的强化等级
                    break
                end
            end
        else
            info.level = 0
        end
        info.mid = t.id
        info.isquan = true
        info.isArrow = true
        GSeeLocalItem(info)
    end 
end

function ShengYinSuitView:cellAttData(index,obj)
    local data = self.attData[index+1]
    local detialAtt = GConfDataSort(data)
    obj:GetChild("n0").text = "["..data.dress_num.."件]"
    local colorStr = self.actNum >= tonumber(data.dress_num) and "[color=#0B8109]" or "[color=#44403D]"
    local str = ""
    local score = 0
    for k,v in pairs(detialAtt) do
        local str2 = colorStr..conf.RedPointConf:getProName(v[1]).."+"..GProPrecnt(v[1],math.floor(v[2])).."[/color]"
        if k ~= #detialAtt then
            str2 = str2 .. "\n"
        end
        str = str ..str2
        score = score + mgr.ItemMgr:baseAttScore(v[1],v[2])--基础评分
    end
    obj:GetChild("n8").text = colorStr.."评分 "..score.."[/color]".."\n"..str
    self.allScore = self.allScore + score
end

function ShengYinSuitView:onGetShengYin()
    GOpenView({id = 1348})
end

return ShengYinSuitView