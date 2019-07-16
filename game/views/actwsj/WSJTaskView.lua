--
-- Author: 
-- Date: 2018-10-24 11:43:38
--

local WSJTaskView = class("WSJTaskView", base.BaseView)

function WSJTaskView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true

end

function WSJTaskView:initView()
    self:setCloseBtn(self.view:GetChild("n0"):GetChild("n1"))
    self.model = self.view:GetChild("n2")
    self.bossInfo = self.view:GetChild("n6")

    self.listView = self.view:GetChild("n10")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.numItems = 0

    self.okBtn = self.view:GetChild("n1")
    self.okBtn.onClick:Add(self.onClickOkBtn,self)

end
function WSJTaskView:initData(data)
    self.floor = data.floor
    self:initModel()
    self.curFloorConf = conf.WSJConf:getWSJAwardByFloor(data.floor)
    self.nextFloorConf = conf.WSJConf:getWSJAwardByFloor(data.floor+1)
    if self.nextFloorConf then
        local str = ""
        if self.nextFloorConf.bossid then
            for k,v in pairs(self.nextFloorConf.bossid) do
                local monsterConf = conf.MonsterConf:getInfoById(v)
                str = str..monsterConf.name.."("..monsterConf.level.."级)"
                if k ~= #self.nextFloorConf.bossid then
                    str = str .. "\n"
                end
            end
        end
        self.bossInfo.text = str
        self.listView.numItems = #self.nextFloorConf.fly_awards
        self:refreshInfo()
    end
end

function WSJTaskView:refreshInfo()
    local mid = conf.WSJConf:getValue("wsj_ng_mid")
    local packData = cache.PackCache:getPackDataById(mid)
    self.haveAmount = packData.amount
    self.needAmont = self.curFloorConf.need_next_num
    local color  = tonumber(packData.amount) >= tonumber(self.curFloorConf.need_next_num) and 20 or 0
    local textData = {
            {text = packData.amount,color = color},
            {text = "/"..self.curFloorConf.need_next_num,color = 0},
        }
    self.view:GetChild("n8").text = mgr.TextMgr:getTextByTable(textData)
end

function WSJTaskView:cellData(index,obj)
    local data = self.nextFloorConf.fly_awards[index+1]
    if data then
        local t = {}
        t.mid = data[1]
        t.amount = data[2]
        t.bind = data[3]
        GSetItemData(obj,t,true)
    end
end

function WSJTaskView:initModel()
    local mConf = conf.NpcConf:getNpcById(GNPC.xycm[self.floor])

    local modelObj = self:addModel(mConf.body_id,self.model)
    modelObj:setScale(190)
    modelObj:setRotationXYZ(0,180,0)
    modelObj:setPosition(self.model.actualWidth/2,-self.model.actualHeight-400,800)
end

function WSJTaskView:onClickOkBtn()
    local flag = self.haveAmount >= self.needAmont 
    if flag then
         proxy.WSJProxy:send(1028202,{amount = self.needAmont})
    else
        GComAlter(language.wsj07)
    end
end


return WSJTaskView