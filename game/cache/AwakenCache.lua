--
-- Author: 
-- Date: 2017-09-21 14:27:36
--
local AwakenCache = class("AwakenCache",base.BaseCache)
--[[

--]]
function AwakenCache:init()

end

function AwakenCache:setAwakenWarData(data)
    self.warData = data
end

function AwakenCache:getAwakenWarData()
    return self.warData
end

function AwakenCache:setAwakenTired(tired)
    if self.warData then
        self.warData.tired = tired
    end
end
--剑神殿时间
function AwakenCache:setAwakenLeftTime(time)
    if self.warData then
        self.warData.leftPlayTime = time
    end
end

function AwakenCache:getAwakenLeftTime()
    return self.warData and self.warData.leftPlayTime or 0
end
--boss列表
function AwakenCache:setBossList(bossList)
    self.bossList = bossList
end

function AwakenCache:getBossList()
    return self.bossList or {}
end

--获取五行装备
function AwakenCache:getEquipByPart(part)
    -- body
    local data = cache.PackCache:getJianLingquipData()
    for k ,v in pairs(data) do
        local confdata = conf.ItemConf:getItem(v.mid)
        if confdata and confdata.part and  confdata.part == part then
            return v 
        end
    end

    return 
end

function AwakenCache:setJianLing(data)
    -- body
    self.partInfos = data
end

function AwakenCache:getJianLingByPart( part )
    -- body
    for k ,v in pairs(self.partInfos) do
        if v.part == part then      
            return v 
        end
    end
    return 
end

--根据部位获取已装备的圣装
function AwakenCache:getShengZhuangEquppedByPart(part)
    local data = cache.PackCache:getShengZhuangEquipData()
    for k,v in pairs(data) do
        local confData = conf.ItemConf:getItem(v.mid)
        if confData and confData.part and confData.part == part then
            return v
        end
    end
    return
end

--根据部位获取已装备的圣印
function AwakenCache:getShengYinEquppedByPart(part)
    local data = cache.PackCache:getShengYinEquipData()
    for k,v in pairs(data) do
        local confData = conf.ItemConf:getItem(v.mid)
        if confData and confData.part and confData.part == part then
            return v
        end
    end
    return
end
--根据圣印id获取已经激活的套装件数
function AwakenCache:getActShengYinSuitByid(id)
    local data = cache.PackCache:getShengYinEquipData()
    local extType = conf.ItemConf:getRedBagType(id)
    local openSuitNum = 0--已激活套装件数
    if extType ~= 0 then--存在套装
        for k,v in pairs(data) do
            local tempExtType = conf.ItemConf:getRedBagType(v.mid)
            if tempExtType == extType then
                openSuitNum = openSuitNum + 1
            end
        end
    end
    return openSuitNum
end


function AwakenCache:setShengYinPartInfo(data)
    self.shengYinPartInfo = data or {}
end
function AwakenCache:getShengYinPartInfo()
    return self.shengYinPartInfo
end

function AwakenCache:updateShengYinPartInfo(data)
    local temp = {data}
    for k,v in pairs(temp) do
        local flag = false
        for i,j in pairs(self.shengYinPartInfo) do
            if v.part == j.part then
                j.strenLev = v.level 
                j.strenExp = v.exp
                flag = true
            end
        end
        if not flag then
            table.insert(self.shengYinPartInfo,{strenLev = v.level,strenExp = v.exp,part = v.part})
        end
    end
end

function AwakenCache:setShengHunInfo(data)
    self.shengHunInfo = data
end
function AwakenCache:getShenghunInfo()
    return self.shengHunInfo
end

function AwakenCache:setSyScore(score)
    self.syScore = score
end
function AwakenCache:getSyScore()
    return self.syScore or 0
end

function AwakenCache:getSZCheck(num)
    if num == 0 then
        return self.getSZCheck1  
    elseif  num == 1 then
        return self.getSZCheck2  
    elseif  num == 2 then
        return self.getSZCheck3 
    end 
end

function AwakenCache:setSZCheck(istrue,num)
     if num == 0 then
        self.getSZCheck1 = istrue
     elseif  num == 1 then
        self.getSZCheck2 = istrue
     elseif  num == 2 then
        self.getSZCheck3 = istrue
     end
end
--根据预览展示来显示所穿戴的模型
function AwakenCache:judgeWhichSZModel()
    if   not self.getSZCheck2 and not self.getSZCheck3 then
        return 0
    elseif self.getSZCheck2 and not self.getSZCheck3 then
        return 1    
    elseif self.getSZCheck3 then
        return 2   
    end
end
--八门元素信息
function AwakenCache:setEightGatesData(data)
    self.eightGatesData = data
end
function AwakenCache:getEightGatesData()
    return self.eightGatesData
end
--八门开启后更新八门空位信息
function AwakenCache:upDateGatesState(data)
    for k,v in pairs(data) do
        for i,j in pairs(self.eightGatesData.info) do
            if k == i then
                j.state = v
            end
        end
    end
end
--选择八门孔位
function AwakenCache:setEightSite(id)
    self.site = id
end

function AwakenCache:getEightSite()
    return self.site
end

function AwakenCache:setBMScore(score)
    self.bmScore = score
end
function AwakenCache:getBMScore()
    return self.bmScore or 0
end
--强化之后更新八门元素信息
function AwakenCache:updateEleInfo(data)
    self.eightGatesData.info[data.site].eleInfo.level = data.level
    self.eightGatesData.info[data.site].eleInfo.exp = data.exp
    -- self.eightGatesData.info[data.site].site = data.site
    local mid = self.eightGatesData.info[data.site].eleInfo.mid
    local equipData = cache.PackCache:getElementEquipData()
    for k,v in pairs(equipData) do
        if mid == v.mid then
            v.level = data.level
            v.exp = data.exp
        end
    end

end

return AwakenCache