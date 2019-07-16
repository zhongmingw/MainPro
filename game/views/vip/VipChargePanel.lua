local VipChargePanel = class("VipChargePanel", import("game.base.Ref"))

local MAXVIP = 13

function VipChargePanel:ctor(mParent)
    -- body
    self.parent = mParent
    self:initView()
end

function VipChargePanel:initView()
    -- body
    self.view = self.parent.view:GetChild("n44")
    self.listView = self.view:GetChild("n32")
    local btnPrivilege = self.view:GetChild("n29")
    btnPrivilege.onClick:Add(self.onClickPrivilege, self)
    --首冲活动倒计时
    self.lastTimeTxt = self.view:GetChild("n30")
    self.islastTime = true
    self:updateChongzhi()
    self:initChargeList()

    if g_ios_test then   
        btnPrivilege.visible = false --EVE 屏蔽VIP福利按钮
        self.lastTimeTxt.scaleX = 0 --屏蔽充值界面活动倒计时
        self.lastTimeTxt.scaleY = 0
    end 
end

function VipChargePanel:onClickPrivilege()
    -- body
    self.parent.controllerC1.selectedIndex = 1
end

function VipChargePanel:setData()
    -- body
    self.data = cache.VipChargeCache:getRechargeList()
    table.sort( self.data.czItemList, function(a,b) 
        if a.itemId ~= b.itemId then
            return a.itemId < b.itemId
        end
    end)
    local vipDec = self.view:GetChild("n28")
    local vipLvTxt = self.view:GetChild("n20") --当前vip
    local nextVipLvTxt = self.view:GetChild("n21") --下一级vip
    local vipExpBar = self.view:GetChild("n14") --当前vip经验进度条  
    local vipLv = cache.PlayerCache:getVipLv()
    local vipStars = cache.PlayerCache:getVipStars()
    local nextVipLv = vipLv + 1
    vipLvTxt.text = vipLv
    nextVipLvTxt.text = nextVipLv
    nextVipLvTxt.visible = true

    local vipExp = cache.PlayerCache:getVipExp()
    local id = vipLv*1000+1
    local vipAttConf = conf.VipChargeConf:getVipAttrDataById(id)
    local nextConf = {}
    local nextVipLvExp = 0
    local nextId = (vipLv+1)*1000 +1
    if vipLv >= MAXVIP then
        nextId = vipLv*1000 +10
    end
    nextConf = conf.VipChargeConf:getVipAttrDataById(nextId)
    nextVipLvExp = nextConf.vip_exp
    vipExpBar.value = vipExp
    vipExpBar.max = nextVipLvExp

    if vipLv == MAXVIP then
        nextVipLvTxt.visible = false
        vipDec.visible =false
        self.view:GetChild("n18").visible =false
    elseif vipLv >=1 then
        vipDec.text = string.format(language.vip13,nextVipLvExp-vipExp,nextVipLv)
        if nextVipLvExp-vipExp <= 0 then
            vipDec.text = language.vip34
        end
    -- elseif vipLv == 1 then
    --     vipExpBar:GetChild("title").text = ""
    --     vipDec.text = language.vip08
    elseif vipLv == 0 then
        vipExpBar:GetChild("title").text = ""
        vipDec.text = language.vip09
    end
    if tonumber(g_var.channelId) == 72 then
        self.listView.numItems = #self.data.czItemList - 2
    else
        self.listView.numItems = #self.data.czItemList
    end
end

--初始化充值列表
function VipChargePanel:initChargeList()
    -- body
    self.listView.numItems = 0
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
end

function VipChargePanel:celldata( index,obj )
    -- body
    local CzItemInfo = self.data.czItemList[index+1]
    if not CzItemInfo then
        return 0
    end
    local rmb = obj:GetChild("n4")
    rmb.text = CzItemInfo.rmb
    local moneyYb = obj:GetChild("n7")
    moneyYb.text = CzItemInfo.moneyYb
    local dec = obj:GetChild("n5")
    local dec2 = obj:GetChild("n14")
    dec2.visible = false
    dec2.y = 120
    local id = 1001+index
    local chargeConf = conf.VipChargeConf:getChargeListData(id)
    obj.onClick:Clear()
    local iconUrl = UIPackage.GetItemURL("vip" , ""..chargeConf.img)
    obj:GetChild("icon").url = iconUrl
    if chargeConf.rmb then
        obj.onClick:Add(self.GoToCharge,self)
        obj.data = {price=CzItemInfo.rmb}
    end
    
    if chargeConf.ext_award_by and chargeConf.ext_award_by ~= 0 then
        local str = string.format(language.vip04,chargeConf.ext_award_by)
        dec.text = str
    end
    dec.visible = false
    if chargeConf.awards then
        local str2 = string.format(language.vip05,chargeConf.awards[1][2])
        dec2.text = str2
        dec2.visible = true
    end
    if CzItemInfo.isFirst == 1 or self.islastTime then
        dec.visible = false
        dec2.y = 140
    else
        dec.visible = true
        dec2.y = 120
    end
    if CzItemInfo.todayFirstCz == 1 then
        dec2.visible = false
    end
    if not chargeConf.rmb then
        dec.visible = false
        moneyYb.visible = false
        rmb.visible = false
        dec2.y = 140
        obj:GetChild("n6").visible = false
        obj:GetChild("n2").visible = false
    end
    if not chargeConf.ext_award_by or chargeConf.ext_award_by == 0 then
        dec.visible = false
    end
    if dec.visible and dec2.visible then
        obj:GetChild("icon").y = 45
    else
        obj:GetChild("icon").y = 60
    end
end
function VipChargePanel:setFirstChargeActTime(lastTime)
    -- body
    self.lastTimeTxt.text = language.vip07 .. self:formatTime(lastTime,1)
    if lastTime <=0 then
        self.islastTime = true
        -- self.listView.numItems = 0
        -- self:updateChongzhi()
        self.lastTimeTxt.text = ""--language.vip07 ..language.vip11
        return
    else
        self.islastTime = false
    end
end
function VipChargePanel:formatTime(timeValue,type_) --type_==1时显示带天数的时间
    -- body
    local allhours = math.floor(timeValue/3600)
    local day = math.floor(allhours/24)
    local hour = math.floor(allhours%24)
    local min = math.floor(timeValue%3600/60)
    local ses = timeValue%3600%60
    if type_ == 1 then
        local str = "%d天%02d时%02d分%02d秒"
        return string.format(str,day,hour,min,ses)
    else
        local str = "%02d:%02d"
        return string.format(str,min,ses)
    end
end
function VipChargePanel:GoToCharge(context)
    -- body
    --GComAlter(language.vip14)
    --plog("前往充值,充值暂未开放")
    local data = context.sender.data
    mgr.SDKMgr:pay(data)
end
--请求充值列表
function VipChargePanel:updateChongzhi(  )
    -- body
    --充值成功重新请求 刷新列表
    -- print("刷新充值列表")
    proxy.VipChargeProxy:sendRechargeList()
end


return VipChargePanel