--
-- Author: 
-- Date: 2017-07-22 11:49:50
--

local MarryFubenDekaron = class("MarryFubenDekaron", base.BaseView)

function MarryFubenDekaron:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function MarryFubenDekaron:initView()
    self.view:GetChild("n4").text = language.fuben18.."："
    self.view:GetChild("n6").text = language.kuafu67
    self.passText = self.view:GetChild("n5")
    self.timeText = self.view:GetChild("n7")
    self.listView = self.view:GetChild("n11")
    self.expDesc = self.view:GetChild("n12")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    local getBtn1 = self.view:GetChild("n13")
    getBtn1.data = 1
    getBtn1.onClick:Add(self.onClickGet,self)
    local getBtn2 = self.view:GetChild("n14")
    getBtn2.data = 2
    getBtn2.onClick:Add(self.onClickGet,self)
    self.consts = conf.MarryConf:getValue("qingyuan_double_got_cost")--双倍领取
    self.view:GetChild("n15").url = UIItemRes.moneyIcons[self.consts[2]]
    self.constsText = self.view:GetChild("n16")
end
--[[1   
int32
变量名：passBo  说明：已通关xx波
2   
int32
变量名：passSec 说明：用时
3   
array<SimpleItemInfo>
变量名：items   说明：获得
4   
int8
变量名：jnrAdd  说明：1:纪念日加成]]
function MarryFubenDekaron:initData(data)
    local passBo = data.passBo
    self.passBo = passBo
    local passId = Fuben.marry * 1000 + 1
    local confData = conf.FubenConf:getPassDatabyId(passId)
    local normalDrops = confData and confData.normal_drop or {}
    self.awards = {}
    for i=1,passBo do
        local award = normalDrops[i]
        if award then
            local isFind = false
            for k,v in pairs(self.awards) do
                if v.mid == award.mid then
                    v[2] = v[2] + 1
                    isFind = true
                end
            end
            if not isFind then
                table.insert(self.awards, award)
            end
        end
    end
    self.listView.numItems = #self.awards
    self.passText.text = passBo..language.tips06
    self.timeText.text = GTotimeString(data.passSec)
    if data.jnrAdd <= 0 then
        self.expDesc.visible = false
    else
        self.expDesc.visible = true
        self.expDesc.text = language.kuafu68.."100%"
    end
    self.constsText.text = math.ceil(self.consts[1] * passBo / 100)
end

function MarryFubenDekaron:cellData(index, obj)
    local award = self.awards[index + 1]
    local itemData = {mid = award[1],amount = award[2],bind = award[3]}
    GSetItemData(obj, itemData)
end

function MarryFubenDekaron:onClickGet(context)
    local btn = context.sender
    if self.passBo > 0 then
        proxy.MarryProxy:send(1027104,{reqType = btn.data})
    else
        GComAlter(language.kuafu71)
        mgr.FubenMgr:quitFuben()
    end
    self:closeView()
end

return MarryFubenDekaron