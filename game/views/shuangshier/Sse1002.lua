--
-- Author: Your Name
-- Date: 2018-09-18 14:32:34
--登录有礼
local Sse1002 = class("Sse1002",import("game.base.Ref"))

function Sse1002:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end

function Sse1002:onTimer()
    -- body
    if not self.data then return end

end

      
-- int8
-- 变量名：reqType 说明：0：显示 1：购买  
-- map<int32,int32>
-- 变量名：buyItem 说明：购买的道具id和数量  
-- int32
-- 变量名：offerId 说明：优惠券道具id（1-？）   
-- array<SimpleItemInfo>   变量名：items   说明：道具   
-- int32
-- 变量名：curDay  说明：当前第几天 从1开始   
-- int32
-- 变量名：actStartTime    说明：活动开始时间 
-- int32
-- 变量名：actEndTime  说明：活动结束时间
function Sse1002:addMsgCallBack(data)

    -- body
    printt("特惠满减",data)
    if data.items then
        GOpenAlert3(data.items,true)

    end
    self.data = data
       --记录已点的
    self.recordChoose = cache.ActivityCache:getGwcData()

    self.confData =  conf.ShuangShiErConf:getTeHuiAwardByDay(self.data.curDay)
    self.timeTxt.text = GToTimeString12(data.actStartTime) .. "-" .. GToTimeString12(data.actEndTime)
    self.listView1.numItems = #self.confData
   
    self:RefeshAllTest()
    self:showImg()
    self.listView2.numItems = #self.recordChoose or 0
end



function Sse1002:initView()
    -- body
    
   

    self.timeTxt = self.view:GetChild("n5")
    self.decTxt = self.view:GetChild("n6")
    self.decTxt.text = language.sse06

    self.listView1 = self.view:GetChild("n15")

    self.listView1.itemRenderer = function (index,obj)
        self:cell1data(index, obj)
    end



    self.listView2 = self.view:GetChild("n32")

    self.listView2.itemRenderer = function (index,obj)
        self:cell1data2(index, obj)
    end
  
    self.isopenCalum = false
 
  
    self.sumText =  self.view:GetChild("n26")
    self.DisText = self.view:GetChild("n29")
    self.XiaDanJianText = self.view:GetChild("n33") -- 下单减文本
    self.YouHuiQuanText = self.view:GetChild("n35") -- 优惠券文本
   

    self.sumPrice = 0 
    self.DisPrice = 0 

    self.edu = conf.ShuangShiErConf:getGlobal("dt_mj")[1]-- 最低额度 
    local btn =  self.view:GetChild("n37")
     btn.onClick:Add(self.XiaDan,self)

     self.gouwuImg = self.view:GetChild("n38")--购物车图
     self.gouwuImg.visible = false
end

function Sse1002:cell1data( index,obj )
    local data = self.confData[index + 1]
    local itemInfo = {mid = data.items[1],amount = 1,bind = data.items[3]}
    GSetItemData(obj:GetChild("n10"),itemInfo,true)
    local tex01 = obj:GetChild("n13")
    local tex02 = obj:GetChild("n12")
    tex01.text = conf.ItemConf:getName(data.items[1])
    tex02.text = data.cost
    local btn = obj:GetChild("n14")
    btn.data = {mid= data.items[1],index = index + 1,quota = data.cost,state = 1,id  = data.id}
    btn.onClick:Add(self.onClickItemAdd,self)


   
end

function Sse1002:cell1data2( index,obj )
    if not self.recordChoose[index + 1] then return end
    local data = self.recordChoose[index + 1]
    local itemInfo = {mid = data.mid,amount = 1,bind = 1}
    GSetItemData(obj:GetChild("n17"),itemInfo,true)
    local tex01 = obj:GetChild("n20")
    local tex02 = obj:GetChild("n19")
    local tex03 = obj:GetChild("n23") --数量文本
    local btn = obj:GetChild("n21")
    btn:RemoveEventListeners()
    -- "<a href=>"..data.num.."</a>"
    tex03.text = data.num
    if data.num <2 then
        btn.icon =  UIItemRes.shaungshier[2] -- 垃圾箱
        btn:SetScale(1,1)
        btn:SetXY(200,24)
    else
        btn.icon =  UIItemRes.shaungshier[1] --减号
        btn:SetScale(0.85,0.85)
        btn:SetXY(191,24)

    end
    btn.data = {index = data.index}
    btn.onClick:Add(self.ongouwuClickItem,self)
    tex03.data = {obj = obj,index = data.index}
    tex03.onChanged:Add(self.onTextChanged,self) --文本内容变化时
 
    tex01.text = conf.ItemConf:getName(data.mid)
    tex02.text = data.quota
    local btn = obj:GetChild("n22") -- 加
    btn:RemoveEventListeners()
    btn.data = {mid= data.mid,index = data.index,quota = data.quota,id = data.id}
    btn.onClick:Add(self.onClickItemAdd,self)
    self.recordChoose[index + 1].itemObj = obj

end

function Sse1002:ongouwuClickItem(context)
    local  data =  context.sender.data

    for k,v in pairs(self.recordChoose) do
        if v.index == data.index then
            v.num = v.num - 1 
            if v.num < 1 then
                table.remove(self.recordChoose,k)
                break
            end
        end
    end
   
    self.listView2.numItems = #self.recordChoose or 0 
    if #self.recordChoose == 0 then
          self.gouwuImg.visible = true
    else
          self.gouwuImg.visible = false
    end
   cache.ActivityCache:setGwcData(self.recordChoose)
 
    self:RefeshAllTest()
end

function Sse1002:onClickItemAdd(context)
    local  data =  context.sender.data
    if #self.recordChoose ~= 0 then
        local ishave = false
        for i,v in ipairs(self.recordChoose) do
            if v.index == data.index then
                if v.num >=999 then
                    return
                end
                v.num =  v.num + 1
                ishave = true
                break
            end
        end
        if not ishave then
            table.insert(self.recordChoose,{mid = data.mid, num = 1,quota = data.quota,index = data.index,id = data.id})
         
        end
    else
        table.insert(self.recordChoose,{mid = data.mid, num = 1,quota = data.quota,index = data.index,id = data.id})
       
    end
    printt(self.recordChoose)
    self.listView2.numItems = #self.recordChoose or 0 
    --更新购物车里面的item
    for k,v in pairs(self.recordChoose) do
        if v.index == data.index then
            if v.itemObj then
                v.itemObj:GetChild("n23").text = v.num
            end
        end
    end
 
    self:RefeshAllTest()
    self:showImg()
      cache.ActivityCache:setGwcData(self.recordChoose)
end

function Sse1002:onTextChanged(context)
    local data= context.sender.data

    for k,v in pairs(self.recordChoose) do
        if v.index == data.index then
            v.num = tonumber(data.obj:GetChild("n23").text) or 0
            local btn = data.obj:GetChild("n21")
            if v.num < 2 then
                btn.icon =  UIItemRes.shaungshier[2] -- 垃圾箱
                btn:SetScale(1,1)
                btn:SetXY(200,24)
            else
                btn.icon =  UIItemRes.shaungshier[1] --减号
                btn:SetScale(0.85,0.85)
                btn:SetXY(191,24)
            end
            break
        end
    end
    self:RefeshAllTest()

end

function Sse1002:onFocusIn(context)
    -- if not self.isopenCalum then
    --     local obj = context.sender.data.obj
    --     local calcum = obj:GetChild("n33")
    --     calcum.visible = true
    -- else
    --     return
    -- end
      
end

function Sse1002:onYouHuiJuanView(context)

      mgr.ViewMgr:openView2(ViewName.TehuiView,{curPrice = self.sumPrice})
end

function Sse1002:RefeshAllTest()

      -- 计算总价和折扣价
    self.sumPrice = 0 
    self.DisPrice = 0 
    for k,v in pairs(self.recordChoose) do
    
        self.sumPrice = self.sumPrice + v.quota*v.num
    end
  


    self.sumText.text = self.sumPrice
    --计算减多少折扣
    local Disdata = conf.ShuangShiErConf:getGlobal("dt_mj")
    local Youhuiquandata = conf.ShuangShiErConf:getGlobal("dt_offer")

    local reduceprice = 0 --减了多少钱
    local reduceYouHuiQuan = 0 --优惠券减去的价格
    local isUp = false --是否减到最高
    local tonext = 0 --到达下一个还差多少钱
    local tonextYb = 0 --到达下一个还差多少钱可减多少元宝
    for k,v in pairs(Disdata) do
        if self.sumPrice >=v[1] then
            reduceprice = v[2]
            if Disdata[k+1] then
                if self.sumPrice >= Disdata[k+1][1] then
                    reduceprice = Disdata[k+1][2]
                else
                    tonext = Disdata[k+1][1] - self.sumPrice
                    tonextYb = Disdata[k+1][2]
             
                    break
                end

            else
                break
            end
        end
    end
    --判断是否满足优惠券
    local iscan = false
    for k,v in pairs(Youhuiquandata) do
        if self.sumPrice >=v[2] then
            iscan = true
        end
    end
    local YouHuiJuandata = cache.ActivityCache:getYhjData() or 0
    if iscan  and YouHuiJuandata ~= 0 then --可以使用并且已选择了优惠券
        reduceYouHuiQuan =  cache.ActivityCache:getYhjData().quota 
        self.YouHuiQuanText.text = mgr.TextMgr:getTextColorStr(string.format(language.sse12,cache.ActivityCache:getYhjData().quota) ,10,"")  
    else
        reduceYouHuiQuan = 0
        self.YouHuiQuanText.text = mgr.TextMgr:getTextColorStr(language.sse11,10,"")

    end
    if reduceprice == Disdata[#Disdata][2] then

        isUp = true
    end
    self.DisPrice = self.sumPrice - reduceprice - reduceYouHuiQuan
    self.DisText.text = self.DisPrice

    --是否达到最低额度
    if self.sumPrice < self.edu[1] then
       self.XiaDanJianText.text = string.format(language.sse07,self.edu[1],self.edu[2]) 
    else
        if isUp  then
           
            self.XiaDanJianText.text = string.format(language.sse09,reduceprice) 
            
        else
            
            self.XiaDanJianText.text = string.format(language.sse08,reduceprice,tonext,tonextYb) 
            
        end
    end

     


    self.YouHuiQuanText.onClickLink:Add(self.onYouHuiJuanView,self)

  
    

end

function Sse1002:XiaDan(context)
     if #self.recordChoose == 0 then
            GComAlter(language.sse14)
            return
    end
    local money = cache.PlayerCache:getTypeMoney(MoneyType.gold)
    if money >= self.DisPrice then
        local buyItem1 = {}
        local buyNum1 = {}
        for k,v in pairs(self.recordChoose) do
            -- buyItem1[v.mid] = v.num
            -- local temp = {v.mid,v.num}
            table.insert(buyItem1,v.id)
            table.insert(buyNum1,v.num)

        end

        local offerId1 
        local YouHuiJuandata = cache.ActivityCache:getYhjData()
        if YouHuiJuandata == 0 then
            proxy.ShuangShiErProxy:sendMsg(1030661,{reqType = 1,buyItem= buyItem1,offerId = 0,buyNum = buyNum1}) -- 没使用优惠券
             self.recordChoose = {}
            cache.ActivityCache:setGwcData(self.recordChoose)
            return
        else
         
            for k,v in pairs(conf.ShuangShiErConf:getGlobal("dt_offer")) do
                print(YouHuiJuandata.quota,v[3])
               if YouHuiJuandata.quota == v[3] then
                    offerId1 = k
                    break
               end
            end
     
            proxy.ShuangShiErProxy:sendMsg(1030661,{reqType = 1,buyItem= buyItem1,offerId = offerId1,buyNum = buyNum1}) -- 使用优惠券
            self.recordChoose = {}
            cache.ActivityCache:setYhjData(nil)
            cache.ActivityCache:setGwcData(self.recordChoose)
        end
    else
        GComAlter(language.gonggong18)
    end
end

function Sse1002:showImg()  -- 显示购物车图片
    if #self.recordChoose == 0 then
        self.gouwuImg.visible = true
    else
        self.gouwuImg.visible = false
    end
end

return Sse1002