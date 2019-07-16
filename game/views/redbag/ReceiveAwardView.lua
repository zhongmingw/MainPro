--
-- Author:
-- Date: 2017-01-19 14:40:55
--
--红包界面
local ReceiveAwardView = class("ReceiveAwardView", base.BaseView)

local currencyUrl = {
    [1] = "ui://zacz9sn2woxld5",--元宝
    [2] = "ui://zacz9sn2woxld6",--绑元
    [3] = "ui://zacz9sn2woxld7",--铜钱
    [4] = "ui://zacz9sn2woxld8",--绑定铜钱
}

function ReceiveAwardView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.uiClear = UICacheType.cacheTime
end
function ReceiveAwardView:initData(data)
    -- body
    if data then
        self:setData(data)
    end
end
function ReceiveAwardView:initView()
    self.mainlist = self.view:GetChild("n9")
    self.mainlist.itemRenderer = function(index,obj)
        self:cellItemData(index, obj)
    end
    self.mainlist.numItems = 0
    
    self.head = self.view:GetChild("n16"):GetChild("n0")
    self.title = self.view:GetChild("n4")
    self.src = self.view:GetChild("n5")
    self.price = self.view:GetChild("n6")
    self.num = self.view:GetChild("n7")
    self.num1 = self.view:GetChild("n8")
    self.img = self.view:GetChild("n14")
    self.img2 = self.view:GetChild("n13")

    -- self.mData = {} 
    self.redBagRecords = {}--红包记录
    local closeBtn = self.view:GetChild("n12")
    closeBtn.onClick:Add(self.onClickClose,self)
end

function ReceiveAwardView:setData(data)
    self.mData = data

    for i=1,#data.redBagRecords do
        local index=(data.page-1)*10+i
        self.redBagRecords[index]=data.redBagRecords[i]
    end
    --printt(self.mData)
    local _type = conf.ItemConf:getType(data.redBagInfo.redBagMid)
    local amount
    local money
    -- print("红包类型",_type)
    if _type == 4 then
        amount = conf.ItemConf:getRedBagAmount(data.redBagInfo.redBagMid)
        money = conf.ItemConf:getRedBagMoney(data.redBagInfo.redBagMid)
        self._type = 2
    else
        local confdata = conf.ItemConf:getArgsItem(data.redBagInfo.redBagMid)
        amount = confdata[1][2]
        money = confdata[1][3]
        self._type = confdata[1][1]
    end
    
    self.title.text= data.redBagInfo.name..language.redbag06

    local confname=conf.ItemConf:getItemCome(data.redBagInfo.redBagMid)
    self.src.text=confname

    
    local t = GGetMsgByRoleIcon(data.redBagInfo.icon,data.redBagInfo.roleId,function(tab)
        if self.head then
            self.head.url = tab.headUrl
        end
    end)
    self.head.url = t.headUrl

    local num=0
    local records = {}
    for k,v in pairs(self.redBagRecords) do
        table.insert(records,v)
    end
    self.redBagRecords = records
    self.mainlist.numItems = #self.redBagRecords
    -- print("红包数量",amount,data.curRecordCount,#self.redBagRecords)
    -- printt(self.redBagRecords)
    num=amount-#self.redBagRecords
    
    local str=""
    if num<=0 then
        str="[/size][/color][color=#FFFFFF][size=18]"..language.redbag04.."[/size][/color]"
    else
        str="[/size][/color][color=#FFFFFF][size=18]"..string.format(language.redbag05,num).."[/size][/color]"
    end

    if data.moneyYb and data.moneyYb>0 then
        self.price.text=data.moneyYb
        self.img.url = currencyUrl[self._type]--UIPackage.GetItemURL("_icon","221051002")
        self.img2.url = currencyUrl[self._type]--UIPackage.GetItemURL("_icon","221051002")
    else
        self.price.text=data.copper
        self.img.url = currencyUrl[self._type]--UIPackage.GetItemURL("_icon","221051003")
        self.img2.url = currencyUrl[self._type]--UIPackage.GetItemURL("_icon","221051003")
    end

    self.num.text ="[color=#F7B71E][size=18]"..amount.."[/size][/color][color=#FFFFFF][size=18]个红包共[/size][/color]"
    self.num1.text ="[color=#F7B71E][size=18]"..money..str
    -- print("剩余数量",money,str)
end

function ReceiveAwardView:getTimeText(time)
    
end
--附件
function ReceiveAwardView:cellItemData(index,cell)
    if index + 1 >= self.mainlist.numItems then
        
        local redbagNum = #self.redBagRecords
        local currPage = self.mData.page
        -- print("最大页数",self.mData.maxPage,currPage)
        if self.mData.maxPage == currPage then 
            --没有下一页了
            --return
        else
            -- print("请求下一页")
            proxy.RedBagProxy:send_1250404({redBagId = self.mData.redBagInfo.redBagId, reqType = 1, page = currPage+1})
        end
    end
    local data={}
    data=self.redBagRecords[index+1]
    if data then
        local head = cell:GetChild("n13"):GetChild("n0")
        local t = GGetMsgByRoleIcon(data.icon,data.roleId,function(tab)
            if head then
                head.url = tab.headUrl
            end
        end)
        head.url = t.headUrl
        local currencyIcon = cell:GetChild("n14")
        -- print("红包类型",self._type,currencyIcon,currencyUrl[self._type])
        currencyIcon.url = currencyUrl[self._type]
        local src = cell:GetChild("n4")
        src.text=data.name
        
        local money = cell:GetChild("n10")
        money.text = data.money

        local flag = cell:GetChild("n3")
        if data.isBest==1 then
            flag.visible=true
        else
            flag.visible=false
        end
    end
end


function ReceiveAwardView:onClickClose()
    -- body
    self.redBagRecords = {}
    self:closeView()
end

return ReceiveAwardView