--
-- Author: 
-- Date: 2017-04-06 20:26:37
--

local ArenaRank = class("ArenaRank", base.BaseView)

function ArenaRank:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function ArenaRank:initData(data)
    -- body
    self.data = data
end

function ArenaRank:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n2")
    btnClose.onClick:Add(self.onCloseView,self)

    self.c1 = self.view:GetController("c1")

    local btnGet = self.view:GetChild("n9")
    btnGet.onClick:Add(self.ongetCall,self)
    self.btnGet = btnGet

    local btnGuize = self.view:GetChild("n10")
    btnGuize.onClick:Add(self.onGuize,self)

    self.listView = self.view:GetChild("n4")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0

    self:initDec()
end

function ArenaRank:initDec()
    -- body
    local dec = self.view:GetChild("n3")
    dec.text = language.kaifu32

    local dec = self.view:GetChild("n8")
    dec.text = language.kaifu36

    local dec = self.view:GetChild("n17")
    dec.text = language.kaifu33

    local dec = self.view:GetChild("n18")
    dec.text = language.kaifu34

    local dec = self.view:GetChild("n19")
    dec.text = language.kaifu35

    local dec = self.view:GetChild("n16")
    dec.text = language.kaifu37
    --EVE 奖励类型LOGO  
    local moneyType = self.view:GetChild("n11")
    moneyType.url =ResPath.iconRes("gonggongsucai_120") --UIPackage.GetItemURL("_icons","gonggongsucai_120")
    --EVE END
    --奖励数量
    self.money = self.view:GetChild("n12")
    self.money.text = 0
    --当前排名
    self.rank =  self.view:GetChild("n13")
    self.rank.text = ""

    self.playername = self.view:GetChild("n14")
    self.playername.text = ""

    self.power = self.view:GetChild("n15")
    self.power.text = 0
    --EVE 添加奖励绑元显示
    local bybLogo = self.view:GetChild("n24")
    bybLogo.url =ResPath.iconRes("gonggongsucai_108")   

    self.bybNum = self.view:GetChild("n25") 
    self.bybNum.text = 999999
    --EVE END
end

function ArenaRank:celldata(index, obj)
    -- body
    if index +1 == self.listView.numItems then
        if self.listdata.page ~= self.listdata.maxPage then
            proxy.ArenaProxy:send(1310103,{page=self.listdata.page+1})
        end
    end

    local data = self.listdata.rankings[index+1]
    --排名
    local labrank = obj:GetChild("n2")
    labrank.text = data.rank
    local c1 = obj:GetController("c1")
    if data.rank <= 3 and data.rank>0 then
        c1.selectedIndex = data.rank - 1 
    else
        c1.selectedIndex = 3
    end
    --
    labname = obj:GetChild("n3")
    labname.text = data.roleName

    local btnSee = obj:GetChild("n5") 
    btnSee.data = data
    btnSee.onClick:Add(self.onSee,self)

    local labpower = obj:GetChild("n4") 
    labpower.text = data.power

    local btnfight = obj:GetChild("n6") 
    btnfight.data = data
    btnfight.onClick:Add(self.onFight,self)

    if data.rank > 5 then
        btnfight.visible = false
    else
        if data.roleId == cache.PlayerCache:getRoleId() then
            btnfight.visible = false
        else
            btnfight.visible = true
        end
    end
end

function ArenaRank:setData(data_)
    

    if self.data.rank > 3 then
        self.c1.selectedIndex = 0
        self.rank.text = self.data.rank
    else
        self.c1.selectedIndex = self.data.rank
        self.rank.text = ""
    end

    local str = string.split(cache.PlayerCache:getRoleName(),".")
    if #str == 2 then
        self.playername.text = str[2]
    else
        self.playername.text = cache.PlayerCache:getRoleName()
    end

    self.power.text = cache.PlayerCache:getRolePower()

    self.condata = conf.ArenaConf:getRewardByRank(self.data.rank)
    if self.condata then
        self.money.text = self.condata.items[1][2]
        self.bybNum.text = self.condata.items[2][2]
    else
        self.money.text = 0
        self.bybNum.text = 0
    end
    --是否领取
    if self.data.awardSign == 1 then
        self.btnGet.visible = false
    else
        self.btnGet.visible = true 
    end
end
--领取
function ArenaRank:ongetCall()
    -- body
    if not self.data then
        return
    end

    if not self.condata then
        GComAlter(language.kaifu42)
        return
    end

    if self.data.awardSign == 1 then
        return
    end

    local param = {cfgId = self.condata.id}
    proxy.ArenaProxy:send(1310104,param)
end
--查看
function ArenaRank:onSee(context)
    -- body
    local data = context.sender.data
    local param = {}
    param.roleId =data.roleId
    GSeePlayerInfo(param)
end
--挑战
function ArenaRank:onFight(context)
    -- body
    if self.data.rank > 100 then
        GComAlter(language.kaifu43)
        return
    end
    local data = context.sender.data
    local function callback() --发送挑战信息
        -- body
        cache.ArenaCache:setOtherRoleId(data.roleId)
        cache.ArenaCache:setArenaFight(true)
        proxy.ArenaProxy:send(1310105,{rank = data.rank })
    end

    if cache.PlayerCache:getRolePower()<data.power then
         local param = {}
        param.richtext = language.kaifu40
        param.type = 2
        param.sure = callback
        GComAlter(param)
    else
        callback()
    end
end

function ArenaRank:onGuize()
    -- body
    GOpenRuleView(1030)
end

function ArenaRank:onCloseView()
    -- body
    self:closeView()
end

function ArenaRank:add5310103(data)
    -- body
    if not self.listdata then
        self.listdata = {}
        if not self.listdata.rankings then --避免错误而已
            self.listdata.rankings = {}
        end
    end
    self.listdata.page = data.page
    self.listdata.maxPage = data.maxPage
    if data.page <= 1 then
        self.listdata.rankings = data.rankings

    else
        for k, v in pairs(data.rankings) do
            table.insert(self.listdata.rankings,v)
        end
    end
    self.listView.numItems = #self.listdata.rankings
end

function ArenaRank:add5310104(data)
    -- body
    self.data.awardSign = data.awardSign

    self:setData()
    GOpenAlert3(data.items)
end

return ArenaRank