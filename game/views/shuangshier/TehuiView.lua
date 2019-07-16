--
-- Author: 
-- Date: 2018-12-05 21:51:29
--


local TehuiView = class("TehuiView", base.BaseView)

function TehuiView:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
end

function TehuiView:initView()
    local btn = self.view:GetChild("n4")
    self:setCloseBtn(btn)
    self.listView1 = self.view:GetChild("n17")
    self.listView1.itemRenderer = function (index,obj)
        self:cell1data(index, obj)
    end
    -- self.listView1:SetVirtual()
    self.btn = self.view:GetChild("n1")
    self.btn.onClick:Add(self.onClickGet,self)
    self.confData = conf.ShuangShiErConf:getGlobal("dt_offer")
    self.tex01 = self.view:GetChild("n19")

end

function TehuiView:initData(data)
    self.data = data
    self.data1 = {}
    local packdata = cache.PackCache:getPackData()
    for k,v in pairs(self.confData ) do
        for k1,v1 in pairs(packdata) do
   
            if v[1] == v1.mid then
               table.insert(self.data1, v)
            end
        end
    end
    -- table.sort(self.data1, function(a,b)
    --     return a.id < b.id
    -- end )
   if #self.data1 == 0 then
        self.tex01.visible = true
   else
        self.tex01.visible = false

   end
    self.listView1.numItems = #self.data1 

end


function TehuiView:cell1data(index,obj)
    local  data = self.data1[index + 1]

    local text01 = obj:GetChild("n5")
    local text02 = obj:GetChild("n7")

    text01.text = data[3]
    text02.text = string.format(language.sse10,data[2])
    local packdata = cache.PackCache:getPackData()
    local isHave = false
    for k,v in pairs(packdata) do
        if v.mid == data[1] then
            isHave = true
            break
        end
    end
    if self.data.curPrice >= data[2]  and  isHave then --满减条件
        obj.grayed = false
        -- obj.touchable = true
    else
        obj.grayed = true
        -- obj.touchable = false
    end
    obj.data = {objData= obj,confData = data,indexId = index + 1}
    obj.onClick:Add(self.onClickItem,self)


end

function TehuiView:onClickGet(context)
    local view = mgr.ViewMgr:get(ViewName.ShuangShiErView)
    if view and view.classObj[1002] then
  
        view.classObj[1002]:RefeshAllTest()
    end
    self:closeView()
end

function TehuiView:onClickItem(context)
    local data = context.sender.data
    if data.objData.grayed == true then
        data.objData:GetChild("n8").visible = false
        GComAlter(language.sse17)
    else
        data.objData:GetChild("n8").visible = true

        cache.ActivityCache:setYhjData({index = indexId,quota = data.confData[3] }) 
    end
  
end

return TehuiView