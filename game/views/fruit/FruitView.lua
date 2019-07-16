--
-- Author: 
-- Date: 2018-11-12 15:13:21
--

local FruitView = class("FruitView", base.BaseView)
local  array = {}
local arraryindex = {}  -- 待消除的位置
local waitTime = 0.5
local currposList = {
    [1] = {xy ={142,230}},[2] = {xy ={291,230}},[3] = {xy ={440,230}},
    [4] = {xy ={142,346}},[5] = {xy ={291,346}},[6] = {xy ={440,346}},
    [7] = {xy ={142,462}},[8] = {xy ={291,462}},[9] = {xy ={440,462}},
}


function FruitView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.openTween = ViewOpenTween.scale
    
end


function FruitView:initView()
   local closeBtn = self.view:GetChild("n53"):GetChild("n9")
   self:setCloseBtn(closeBtn)
   self.panel = self.view:GetChild("n24")
   self.lastTime = self.view:GetChild("n46")
   self.listView1 = self.view:GetChild("n51")
   self.listView1.itemRenderer = function(index,obj)
        self:cellData(index, obj)
   end
   self.listView1.numItems = 3
   self.baoxiangList = {}

   for i =18,22,2 do
        local btn = self.view:GetChild("n"..i)
        btn.data = btn.name
        table.insert(self.baoxiangList,btn)
        btn.onClick:Add(self.lingQu,self)
   end

   self.btnList = {}
   for i = 28,36 do
        local btn = self.view:GetChild("n"..i)
        local id = i-27
        local han,lie =self:getShuZhusort(id)
        self.btnList[id] = {btn = btn,id = id,hanlie = {han,lie},isclear = false}
        btn.data = {index = id }
        btn.onClick:Add(self.clickChange,self)
   end
   local ruleBtn = self.view:GetChild("n43")
   ruleBtn.onClick:Add(self.rule,self)

   local yuanbaoText = self.view:GetChild("n45")
   yuanbaoText.text = conf.ActivityConf:getValue("fruit_cost")[2]

   self.readXiaoChutable = {}

   self.effectList = {} -- 水果宝箱特效
    for i = 54,62 do
        local effect = self.view:GetChild("n"..i)
        -- table.insert(self.effectList,effect)
        self.effectList[i-53] = effect
    end
end



    
-- int8
-- 变量名：reqType 说明：0：显示 1：消除 2：领取宝箱 
-- int32
-- 变量名：cid 说明：消除的类型或领取的id  
-- int8
-- 变量名：ids 说明：消除的位置  
-- array<int32>
-- 变量名：score   说明：积分  
-- int32
-- 变量名：leftTime    说明：活动剩余时间  
-- array<SimpleItemInfo>   变量名：items   说明：奖励  
-- map<int32,int32>
-- 变量名：type    说明：位置对应的类型
function FruitView:setData(data)
    printt("水果消除",data)
    self.data = data
   
    
    if data.reqType == 0 then
        for k,v in pairs(data.type) do
            self.btnList[k].type = v
        end
        for k,v in pairs( self.btnList) do
            -- print( v.btn.name,currposList[k].xy[1],currposList[k].xy[2])
            v.btn:GetChild("icon").url = UIItemRes.shuiguo[v.type]
            v.btn:SetXY(currposList[k].xy[1],currposList[k].xy[2])
            v.btn.touchable = true
        end
        self:Revert()
    elseif data.reqType == 1 then  --消除
        for k,v in pairs(data.ids) do
            print("发送过来",k,v)
        end
          
         for k,v in pairs(self.btnList) do
             v.isclear = false
             v.btn.touchable = false
         end
        for k,v in pairs(self.data.ids) do
            self.btnList[v].isclear = true
            self.btnList[v].btn.visible = false
            -- 4020177  4020213
            self.effect = self:addEffect(4020177, self.effectList[v])
            self.effect.LocalPosition = Vector3.New(50,-50,-100)
            
        end
        self:MoveDown()
    elseif data.reqType == 2 then --领取
        if data.items then
        GOpenAlert3(data.items,true)
        end
    end
    
    self:updateBaoXiangJinDuTiao()
    self:releaseTimer()
    self.time = self.data.leftTime
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
end



function  FruitView:clickChange( context)
    local data = context.sender.data
    local money =  cache.PlayerCache:getTypeMoney(MoneyType.gold)
    local price =conf.ActivityConf:getValue("fruit_cost")[2]
    if money < price then
        GComAlter(language.qmbz07)
        return
    else   
        local btnData = context.sender.data
        local index  = btnData.index
        local typef =  self.btnList[index].type
        self.readXiaoChutable[index] = index
        self:getcalculateList(index,typef)
        local data1 = {}
        for k,v in pairs(self.readXiaoChutable) do
            table.insert(data1, k)
        end
         printt("发送过去",data1)
        proxy.ActivityProxy:send(1030651,{reqType = 1 ,cid = typef,ids = data1,count = 0})

    end

end



function  FruitView:cellData( index,obj )
    local data = conf.ActivityConf:getFruitShowBytype(index + 1)
    local itemlist = obj:GetChild("n49")
    local icon =  obj:GetChild("n50")
    icon.url = UIItemRes.shuiguo[index + 1]
    itemlist.itemRenderer = function(index,cell)
        local itemData = {mid = data[index + 1][1],amount = data[index + 1][2],bind = data[index + 1][3]}
        GSetItemData(cell,itemData,true)  
    end
    itemlist.numItems = #data

end

function  FruitView:lingQu( context )
    local data = context.sender.data
    local data1 = {}
    if data == "n18" then --普通
        data1.index = 1
    elseif data == "n20" then--稀有
        data1.index = 2
    elseif data == "n22" then--珍惜
         data1.index = 3
    end
    -- printt(self.data.score)
    -- print(self.data.score[data1.index] ,data1.index)
    data1.score = self.data.score[data1.index] or 0
    mgr.ViewMgr:openView2(ViewName.ChooseView,data1)
end


function FruitView:onTimer()
    if self.time > 86400 then 
        self.lastTime.text = GTotimeString7(self.time)
    else
        self.lastTime.text = GTotimeString(self.time)
    end
    if self.time <= 0 then
        self:releaseTimer()
        self:closeView()
    end
    self.time = self.time - 1
end

function FruitView:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

function FruitView:rule()
    -- body
    GOpenRuleView(1159)
end

--根据index 返回所在行列
function FruitView:getShuZhusort(index)
    local lie = index % 3
    local han = index/3
    if han <= 1 then
        han = 1
    end
    if (han > 1) and(han <= 2) then
        han = 2
    end
    if han > 2 then
        han = 3
    end
    if lie == 0 then 
        lie = 3
    end
    return han,lie
end

function FruitView:ReturnIndex (han ,lie)  --根据行列返回索引
    return  (han -1)*3 + lie
end

-- 计算返回得到准备消除的位置列表
function FruitView:getcalculateList(index,fruit_type)
    local _han,_lie = self:getShuZhusort(index) -- 得到index 所在行列
    -- print("行：".._han.."咧：".._lie)
    --上面
    local index1 = self:ReturnIndex (_han -1 ,_lie)
    if not self.readXiaoChutable[index1] then 
        -- if 0< index1 and index1 < 10 then
        if _han-1 >= 1 then 
            if self.btnList[index1].type ==  fruit_type then
                self.readXiaoChutable[index1] = index1
                self:getcalculateList(index1,fruit_type)
            end
        end
    end
    
    --下面
    local index2 = self:ReturnIndex (_han +1 ,_lie)
    if not self.readXiaoChutable[index2] then 
        -- if 0< index2 and index2 < 10 then
        if _han+1 <=3 then
            if self.btnList[index2].type ==  fruit_type then
                self.readXiaoChutable[index2] = index2
                self:getcalculateList(index2,fruit_type)
            end
        end
    end
    --左边
    local index3 = self:ReturnIndex (_han ,_lie - 1)
    if not self.readXiaoChutable[index3] then 
        -- if 0< index3  and index3 < 10 then
        if _lie-1 >= 1 then
            if self.btnList[index3].type ==  fruit_type then
                self.readXiaoChutable[index3] = index3
                self:getcalculateList(index3,fruit_type)
            end
        end
     end
    

     --右边
    local index4 = self:ReturnIndex (_han  ,_lie + 1)
    if not self.readXiaoChutable[index4] then 
        -- if 0 < index4  and index4 < 10 then
        if _lie+ 1<= 3 then
            if self.btnList[index4].type ==  fruit_type then
                self.readXiaoChutable[index4] = index4
                self:getcalculateList(index4,fruit_type)
            end
        end
     end
 

end

function FruitView:MoveDown()
    for i=3, 1, -1 do
        local emplty = 0
        for j=3, 1, -1 do
            local index = self:ReturnIndex(j ,i)
            if self.btnList[index].isclear == true then -- 水果清除                
                    -- print("需要移动索引",index)
                emplty = emplty + 1
            else
                self:moveAction(index, emplty)
                -- if emplty ~= 0 then
                -- else 
                -- end
            end
        end
    end
    self:addTimer(waitTime+0.03, 1,function()
            self:Revert()
            print("是否重置了出现是正常，卡顿时候看下有没输出这句话")
            for k,v in pairs(self.btnList) do
                v.btn.touchable = true
            end
    end)
    -- if not self.RevertTime then
    --     self.RevertTime =  self:addTimer(waitTime+0.03, 1,function(  )
    --         self:Revert()
    --         for k,v in pairs(self.btnList) do
    --             v.btn.touchable = true
    --         end
    --         self:removeTimer(self.RevertTime)
    --         self.RevertTime = nil
    --    

    -- end
    
end


function FruitView:moveAction(index,emplty)
    local targetPosY = self.btnList[index].btn.y +116*emplty
    self.btnList[index].btn:TweenMoveY( targetPosY,waitTime)

end

--更新宝箱进度条
function  FruitView:updateBaoXiangJinDuTiao()

    local data =conf.ActivityConf:getValue("fruit_baoxiang_needscore")
    for k,v in pairs(self.baoxiangList) do
        local progress = v:GetChild("n6")
            progress.value = self.data.score[k] or 0
            progress.max =  data[k]
            --播放特效
            local lastScore =  cache.ActivityCache:getFruitScore()[k] or self.data.score[k]
            if self.data.score[k]  then
                if self.data.score[k] > lastScore then
                    local node = v:GetChild("n9")
                    local effect = self:addEffect(4020103,node)
                    effect.LocalPosition = Vector3(node.actualWidth/2,-node.actualHeight/2,0)
                    effect.Scale = Vector3.New(18,18,70)
                end
            end
    end
    cache.ActivityCache:setFruitScore(self.data.score)
end

function FruitView:Revert()
    self.readXiaoChutable = {}
    for k,v in pairs(self.btnList) do
        v.btn.data = {index = k}
        v.btn.visible = true
        v.btn:SetXY(currposList[k].xy[1],currposList[k].xy[2])
        v.type = self.data.type[k]
        v.btn:GetChild("icon").url =  UIItemRes.shuiguo[self.data.type[k]]
        -- print("k:",k,self.data.type[k],"url",v.btn:GetChild("icon").url)
        -- print("v.btn.x:",v.btn.x,"v.btn.y:",v.btn.y,"v.btn.visible",v.btn.visible)
    end
end
return FruitView