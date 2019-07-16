--
-- Author: 
-- Date: 2018-12-12 22:13:40
--

local DongZhiLianChong = class("DongZhiLianChong", base.BaseView)

function DongZhiLianChong:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
end

function DongZhiLianChong:initView()
         local closeBtn = self.view:GetChild("n0"):GetChild("n6")
    self:setCloseBtn(closeBtn)
     self.lastTime = self.view:GetChild("n12")
     self.curText = self.view:GetChild("n11")

    self.listview = self.view:GetChild("n15") 
    self.listview.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
     self.confData =  conf.DongZhiConf:getDongZhiLianChong()
end

function DongZhiLianChong:setData(data)
    printt(data)
    self.data = data
    if data.items then
        GOpenAlert3(data.items,true)
    end
    self.gotSigns ={}
    self.num = {}
    for k,v in pairs(data.gotSigns) do

        self.gotSigns[k] = {v= v}
        table.insert(self.num, v)
    end

    self.curText.text = self.data.rechargeSum
    self.listview.numItems = #self.confData
  
    self:releaseTimer()
    self.time = self.data.leftTime
     if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
end

function DongZhiLianChong:cellData(index, obj)
   local data  = self.confData[index + 1]
    local curday  = (#self.num or 0) + 1

   local  data1 = data.items
   local  Text  = obj:GetChild("n6")
   local c1 = obj:GetController("c1")
   if self.gotSigns[data.id] then
        c1.selectedIndex = 2 --已领取
   else

        if data.quota <= self.data.rechargeSum and curday == data.days and self.data.got == 0 then
            c1.selectedIndex = 0 --可领取
        else
            c1.selectedIndex = 1 --不可领取
        end
   end--
   local list = obj:GetChild("n7")
   list.itemRenderer = function(index,obj)
      
        local item = data1[index+1]
 
        local itemData  =  {mid = item[1],amount = item[2],bind = item [3]}
        GSetItemData(obj, itemData, true)
   end
   list.numItems = #data1
   local dataday  = self:numberToString(data.days)
   Text.text = string.format(language.dz08,dataday,data.quota)
   local btn = obj:GetChild("n13")
    btn:GetChild("red").visible = false
   if c1.selectedIndex == 0 then
        btn:GetChild("red").visible = true
   end
   btn.data = {cid = data.id,objBtn=  obj , state = c1.selectedIndex}
    btn.onClick:Add(self.onGet,self)

end

function DongZhiLianChong:onGet(context)
   local data = context.sender.data
   
   if data.state == 1 then
        GComAlter(language.dz09)
   else

        proxy.ActivityProxy:send(1030667,{reqType =1 ,cid = data.cid})
   end
end

function DongZhiLianChong:onTimer()
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



function DongZhiLianChong:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

function  DongZhiLianChong:numberToString(szNum)
    ---阿拉伯数字转中文大写
    local szChMoney = ""
    local iLen = 0
    local iNum = 0
    local iAddZero = 0
    local hzUnit = {"", "十", "百", "千", "万", "十", "百", "千", "亿","十", "百", "千", "万", "十", "百", "千"}
    local hzNum = {"零", "一", "二", "三", "四", "五", "六", "七", "八", "九"}
    if nil == tonumber(szNum) then
        return tostring(szNum)
    end
    iLen =string.len(szNum)
    if iLen > 10 or iLen == 0 or tonumber(szNum) < 0 then
        return tostring(szNum)
    end
    for i = 1, iLen  do
        iNum = string.sub(szNum,i,i)
        if iNum == 0 and i ~= iLen then
            iAddZero = iAddZero + 1
        else
            if iAddZero > 0 then
            szChMoney = szChMoney..hzNum[1]
        end
            szChMoney = szChMoney..hzNum[iNum + 1] --//转换为相应的数字
            iAddZero = 0
        end
        if (iAddZero < 4) and (0 == (iLen - i) % 4 or 0 ~= tonumber(iNum)) then
            szChMoney = szChMoney..hzUnit[iLen-i+1]
        end
    end
    local function removeZero(num)
        --去掉末尾多余的 零
        num = tostring(num)
        local szLen = string.len(num)
        local zero_num = 0
        for i = szLen, 1, -3 do
            szNum = string.sub(num,i-2,i)
            if szNum == hzNum[1] then
                zero_num = zero_num + 1
            else
                break
            end
        end
        num = string.sub(num, 1,szLen - zero_num * 3)
        szNum = string.sub(num, 1,6)
        --- 开头的 "一十" 转成 "十" , 贴近人的读法
        if szNum == hzNum[2]..hzUnit[2] then
            num = string.sub(num, 4, string.len(num))
        end
        return num
    end
    return removeZero(szChMoney)
end
return DongZhiLianChong