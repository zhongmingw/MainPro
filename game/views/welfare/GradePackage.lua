--
-- Author: EVE
-- Date: 2017-05-23 14:42:10
--

local GradePackage = class("GradePackage", import("game.base.Ref"))

function GradePackage:ctor(mParent,panelObj)
    self.mParent = mParent
    self.panelObj = panelObj
    self:initPanel()
end

function GradePackage:initPanel()
    --list 第一级列表
    self.listView = self.panelObj:GetChild("n3")
    self:initListView()
end

function GradePackage:initListView()
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
    self.listView.numItems = 0
end

function GradePackage:celldata(index, obj)
    local data = self.tempData[index+1]
    local itemList = obj:GetChild("n8")
    GSetAwards(itemList,data.items)

    local needGrade = obj:GetChild("n4")
    needGrade.text = string.format(language.welfare23, data.lev) --需求等级

    --剩余份数
    local needGrade = obj:GetChild("n9") 

    if data.count > 10000 then   --隐藏前三档的数量显示
        needGrade.text = ""
    else       
        if table.nums(self.num) ~= 0 then
            local uesdData = self.num[data.id] or 0
            if uesdData then 
                local temp = data.count - uesdData
                if temp < 0 then 
                    temp = 0
                end
                needGrade.text = string.format(language.welfare37, temp) 
            else
                needGrade.text = string.format(language.welfare37, data.count)
            end
        else
            needGrade.text = string.format(language.welfare37, data.count)
        end 
    end 


    --领取状态 0已领取 1领取 2未达成 3已错过
    local c1 = obj:GetController("c1")
    local curLevel = cache.PlayerCache:getRoleLevel()
    c1.selectedIndex = 3 

    local temp = 0
    if self.num and self.num[data.id] then 
        temp = self.num[data.id]
    else
        temp = 0
    end
    -- print("dddddddddd",data.count,temp,data.lev)
    local temp01 = data.count - temp

    if self.signs[data.id] then --已领取
        c1.selectedIndex = 0
    elseif data.lev > curLevel and temp01 > 0 then     
        c1.selectedIndex = 2 --未达成
    elseif data.lev <= curLevel and temp01 > 0 then  
        c1.selectedIndex = 1 --可领取     
    else
        c1.selectedIndex = 3   --已错过                       
    end
        
    local btnGet = obj:GetChild("n7")
    local data = {id = data.id} 
    btnGet.data = data --按钮的状态 
    btnGet.onClick:Add(self.onClickGet,self)
end

function GradePackage:onClickGet(context)
    local cell = context.sender
    local data = cell.data   
    -- print("领取那个档的奖励",data.id) 
    proxy.ActivityProxy:send(1030140,{cfgId = data.id}) --领取请求

end

function GradePackage:setData(data)
    self.data = data 
    -- print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    -- printt(self.data)
    -- for k , v in pairs(self.data.signs) do
    --     print("ssss",k,v)
    -- end
    -- print("333333",table.nums(self.data.useCounts) )
    -- for k,v in pairs(self.data.useCounts) do
    --     print("aaaaaaa",k,v)
    -- end
    -- print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    self.num = data.useCounts

    self.signs = {}
    for k , v in pairs(self.data.signs) do
        self.signs[v] = k
    end

    --领取弹窗
    if data.items and #data.items>0 then
        GOpenAlert3(data.items)
    end

    --读取配置表
    self.tempData = conf.ActivityConf:getGradePackageData()
    local curLevel = cache.PlayerCache:getRoleLevel()

    if table.nums(self.num) ~= 0 then 
        for k,v in pairs(self.tempData) do
            local temp = 0
            if self.num and self.num[v.id] then 
                temp = self.num[v.id]
            else
                temp = 0
            end
            -- print("cccccccccc",v.count,temp,v.lev)
            local temp01 = v.count - temp

            if self.signs[v.id] then 
                self.tempData[k].sign = 3 --已领取
            elseif v.lev <= curLevel and temp01 > 0 then
                self.tempData[k].sign = 1 --可领取
            elseif v.lev > curLevel and temp01 > 0 then 
                self.tempData[k].sign = 2 --未达成          
            else
                self.tempData[k].sign = 4 --已错过
            end       
        end
        table.sort(self.tempData,function(a,b)
            if a.sign ~= b.sign then
                return a.sign < b.sign
            elseif a.lev ~= b.lev then
                return a.lev < b.lev
            end
        end)
    end 

    self.listView.numItems = #self.tempData
    self.listView:ScrollToView(0)
end

function GradePackage:setVisible(visible)
    self.panelObj.visible = visible   
end

function GradePackage:sendMsg()
    -- 发送请求
    proxy.ActivityProxy:send(1030140,{cfgId = 0})
    -- plog("等级礼包请求发送~~~~~~~~~~~~~~~~~~~~~~~")
end

return GradePackage   