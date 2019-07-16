--
-- Author: 
-- Date: 2018-11-16 14:21:43
--

local ChooseView = class("ChooseView", base.BaseView)

function ChooseView:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
end

function ChooseView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
   self:setCloseBtn(closeBtn)
   self.listView1 = self.view:GetChild("n7")
   self.listView1.itemRenderer = function(index,obj)
        self:cellData(index, obj)
   end
   self.listView1.numItems = 0
   local  btn1 =  self.view:GetChild("n8")
    btn1.onClick:Add(self.lingQu,self)
    local  addbtn =  self.view:GetChild("n11")
    addbtn.data = 2
    addbtn.onClick:Add(self.updatebtn,self)
    local  reducebtn =  self.view:GetChild("n10")
    reducebtn.data = 1
    reducebtn.onClick:Add(self.updatebtn,self)
    self.tex = self.view:GetChild("n12")
    self. tex.text = 0
    self.tex1 = self.view:GetChild("n3")
    local tex2 = self.view:GetChild("n1")
    tex2.text = string.format(language.fr03)

    self.tex3 = self.view:GetChild("n4")
    
end

function ChooseView:initData(data)
    self.data = data
    local icon = self.view:GetChild("n0"):GetChild("icon")
    icon.url = UIItemRes.shuiguo[data.index+3+3]
    self.itemId = nil
    self.tex.text = 0
    self.tex3.text = string.format(language.fr04,conf.ActivityConf:getValue("fruit_baoxiang_needscore")[data.index])
    self.datashow = conf.ActivityConf:getFruitChooseShowBytypes(data.index)
    self.needScore = conf.ActivityConf:getValue("fruit_baoxiang_needscore")[data.index]
    self.listView1.numItems = #self.datashow
    self.tex1.text = math.floor(self.data.score /self.needScore )
end


function  ChooseView:cellData( index,obj )
    local data = self.datashow[index + 1]
    local item = obj:GetChild("n4")
    item.touchable = false 
    local itemData = {mid = data.items[1],amount = data.items[2],bind = data.items[3]}
    GSetItemData(item,itemData,true)
    obj:GetController("button").selectedIndex = 0
    obj.data = data.id
    obj.onClick:Add(self.choose,self)
end

function  ChooseView:lingQu( context )
    if not self.itemId    then
        GComAlter(language.fr01)
        return
    end
    if  tonumber(self.tex1.text) == 0 then
        GComAlter(language.fr05)
        return
    end
    if tonumber(self.tex.text) == 0 then
          GComAlter(language.fr02)
        return
    end


     -- print(tonumber(self.tex1.text),"数量",self.itemId)
    
    proxy.ActivityProxy:send(1030651,{reqType = 2 ,cid = self.itemId , ids = {},count = tonumber(self.tex.text)})

    self.data.score = self.data.score - tonumber(self.tex.text)*self.needScore
    self.tex1.text = tonumber(self.tex1.text)- tonumber(self.tex.text) >= 0 and tonumber(self.tex1.text)- tonumber(self.tex.text) or 0
end

function  ChooseView:choose( context )
    local data = context.sender.data
    self.itemId = data
end

function  ChooseView:updatebtn( context )
    if not self.itemId then
         GComAlter(language.fr01)
    end
    local data = context.sender.data
    
    if data == 1 then -- +
        if self.data.score >=  self.needScore*(tonumber(self.tex.text)+ 1) then
            self.tex.text = tonumber(self.tex.text)+ 1
            -- self.currentChoosenum = self.currentChoosenum + 1
        else
            GComAlter(language.forging32)
        end 
    elseif data == 2  then
  
        if tonumber(self.tex.text) >= 1  then
            self.tex.text = tonumber(self.tex.text)- 1
            -- self.currentChoosenum = self.currentChoosenum - 1

        end
    end


end

return ChooseView