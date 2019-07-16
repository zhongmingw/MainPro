local Zq1003 = class("Zq1003",import("game.base.Ref"))

function Zq1003:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end
function Zq1003:onTimer()
    -- body
    if not self.data then return end
end
function Zq1003:addMsgCallBack(data)
   if data.msgId == 5030611 then
        -- GOpenAlert3(data.items)
        self.data = data 
        printt(data)  
        self.dec1.text = "活动时间："..GToTimeString11(self.data.actStartTime).."~"..GToTimeString11(self.data.actEndTime)

    end
end

function Zq1003:initView()

    self.oneTimeCost = conf.ZhongQiuConf:getGlobal("zq_visit_moon_one_cost")[2]
    self.TenTimeCost = conf.ZhongQiuConf:getGlobal("zq_visit_moon_ten_cost")[2]

    self.effectImg = self.view:GetChild("n28")

    self.dec1 = self.view:GetChild("n7")
    self.dec1.text = language.zq04

    local dec2 = self.view:GetChild("n8")
    dec2.text = language.zq02
    self.dec3 = self.view:GetChild("n27")

    local model = self.view:GetChild("n24")
    local modelId = conf.ZhongQiuConf:getGlobal("zq_visit_moon_model")[1]
    local model1 = self.parent:addModel(modelId,model)
    model1:setPosition(40.6,-362.6,695.6)
    model1:setRotationXYZ(358,134.3,0.8)
    model1:setScale(67,67,67)
    self.confdata = conf.ZhongQiuConf:getGlobal("zq_visit_moon_item_show")
    self.listView1 = self.view:GetChild("n17")
    self.listView1.itemRenderer = function(index,obj)
        self:cellBaseData(index, obj)
    end
    self.listView1.numItems = #self.confdata

    self.btn = self.view:GetChild("n18")
    self.btn.title = "拜月一次"
    self.btn.onClick:Add(self.onGet1,self)

    self.btnSelect = self.view:GetChild("n20")
    self.btnSelect.onClick:Add(self.onGet2,self)
    self.btnSelect.onClick:Call()

end

function Zq1003:onGet1(context)
    local money = cache.PlayerCache:getTypeMoney(MoneyType.gold)
    if self.btnSelect.selected == false then
       
        if money >= self.oneTimeCost then
            proxy.ZhongqiuProxy:sendMsg(1030611,{reqType = 1})
            self.effect = self.parent:addEffect(4020171, self.effectImg)
            self.effect.Scale = Vector3.New(100,100,100)
        else
            GGoVipTequan(0)
            --self.parent:closeView()
        end
    else
        
        if money >= self.TenTimeCost then
             proxy.ZhongqiuProxy:sendMsg(1030611,{reqType = 2})
             self.effect = self.parent:addEffect(4020171, self.effectImg)
             self.effect.Scale = Vector3.New(100,100,100)
        else
            GGoVipTequan(0)
            --self.parent:closeView()
        end
        
    end
end

function Zq1003:onGet2(context)
    if self.btnSelect.selected == false then
        self.btn.title = "拜月一次"
        self.dec3.text = self.oneTimeCost
    else
        self.btn.title = "拜月十次"
        self.dec3.text = self.TenTimeCost 
    end 
end

function Zq1003:cellBaseData(index, obj)
    local data = self.confdata[index + 1]
    local itemData = {mid = data[1],amount = data[2],bind = data[3]}
    GSetItemData(obj, itemData, true)
end


return Zq1003