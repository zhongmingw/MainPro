--
-- Author: 
-- Date: 2017-04-07 17:52:26
--

local Arena = class("Arena", import("game.base.Ref"))

function Arena:ctor(param)
    self.parent = param
    self.view = param.view:GetChild("n42")
    self.imgPath = nil
    self:initView()
end

function Arena:initView()
    -- body
    --排名玩家
    self.playerlist = {}
    for i = 6 , 9 do
        local item = self.view:GetChild("n"..i)
        item.visible = false
        if i < 9 then
            item.onClick:Add(self.onPlayCall,self)
        end

        table.insert(self.playerlist,item)
    end
    --扫荡按钮
    local btnSaoDang = self.view:GetChild("n10")
    self.view:GetChild("n33").text = language.arena01
    btnSaoDang.onClick:Add(self.onSaodang,self)
    --加次数
    local btnAdd = self.view:GetChild("n11")
    btnAdd.onClick:Add(self.onPlus,self)
    --是否显示仙羽
    self.checkbtn = self.view:GetChild("n12")
    self.checkbtn.onClick:Add(self.onCheck,self)
    --荣誉商店跳转
    local btnShop = self.view:GetChild("n13")
    btnShop.onClick:Add(self.onShop,self)
    --排行版
    local btnRank = self.view:GetChild("n14")
    btnRank.onClick:Add(self.onRank,self)
    --时间
    local btnJantou = self.view:GetChild("n15") 
    btnJantou.visible = false  --删除cd隐藏箭头
    --btnJantou.onClick:Add(self.onShiJian,self)
    --钻石vip 无cd
    self.btnJantou = btnJantou
    --换
    local btnChange = self.view:GetChild("n16") 
    btnChange.onClick:Add(self.onChange,self)

    self.bg = self.view:GetChild("n35")
    --self:updateBgImg()
    --
    self:initDec()

    if g_is_banshu then
        btnRank.visible = false
        btnShop.visible = false
    end 

    --EVE 奖励类型LOGO
    --local tempPanel = self.view:GetChild("n42")
    local moneyType01 = self.view:GetChild("n17")
    local moneyType02 = self.view:GetChild("n18")
    moneyType01.url = ResPath.iconRes("gonggongsucai_120")--UIPackage.GetItemURL("_icons","gonggongsucai_120")
    moneyType02.url = ResPath.iconRes("gonggongsucai_120") --UIPackage.GetItemURL("_icons","gonggongsucai_120")
    --EVE END

    --EVE 竞技场面板显示奖励绑元
    self.bybLogo1 = self.view:GetChild("n37")
    self.bybLogo2 = self.view:GetChild("n38")
    self.bybLogo1.url =ResPath.iconRes("gonggongsucai_108")   
    self.bybLogo2.url =ResPath.iconRes("gonggongsucai_108")

    self.bybNum1 = self.view:GetChild("n39") 
    self.bybNum2 = self.view:GetChild("n40") 
    self.bybNum1.text = 999999
    self.bybNum2.text = 123321
    --EVE END
end

function Arena:updateBgImg()
    if self.bg.url and self.bg.url ~= "" then
        return
    end
    -- if self.imgPath then
    --     UnityResMgr:UnloadAssetBundle(self.imgPath, true)
    --     self.bg.url = nil
    -- end
    self.imgPath = UIItemRes.zhanchang.."jingjichang_019"
    --self.bg.url = self.imgPath
    self.parent:setLoaderUrl(self.bg,self.imgPath)
end

function Arena:initDec()
    -- body

    local dec = self.view:GetChild("n21") 
    dec.text = language.arena03

    local dec = self.view:GetChild("n22") 
    dec.text = language.arena04

    local dec = self.view:GetChild("n23") 
    dec.text = language.arena05

    local dec = self.view:GetChild("n24") 
    dec.text = language.arena06
    self.nextdec = dec

    self.nexticon = self.view:GetChild("n18")   

    local dec = self.view:GetChild("n27") 
    dec.text = language.arena07

    local dec = self.view:GetChild("n28") 
    dec.text = language.arena08

    local dec = self.view:GetChild("n29") 
    dec.text = language.arena09

    --当前奖励
    self.curReward = self.view:GetChild("n25") 
    self.curReward.text = 0
    --下阶段奖励
    self.nextReward = self.view:GetChild("n26") 
    self.nextReward.text = 0
    --挑战次数
    self.count = self.view:GetChild("n30") 
    self.count.text = 0
    --战力
    self.power = self.view:GetChild("n31") 
    self.power.text = 0
    --排名
    self.rank = self.view:GetChild("n32") 
    self.rank.text = 0
end

function Arena:setData(data_)

end

function Arena:onSaodang()
    -- body
    if not self.data then
        return
    end
    --判定有没有玩家
    if #self.data.arenaRoles == 0 then
        return
    end


    -- if self.data.leftColdTime>0 and self.data.coldToZero == 1 and not cache.PlayerCache:VipIsActivate(3) then
    --     GComAlter(language.arena28)
    --     return
    -- end  

    if self.data.leftChallengeCount <= 0 then
        if cache.PlayerCache:VipIsActivate(3) then
            local var = conf.ArenaConf:getValue("day_challege_count_buy_max")
            if self.data.dayChallengeCountBuy >= var then
                GComAlter(language.arena29)
            else
                self:onPlus()
            end
        else
            GComAlter(language.arena29)
        end
        return
    end

    --发送扫荡消息
    mgr.ViewMgr:openView(ViewName.Alert13,function(view)
        -- body
        view:setData(self.data)
    end)
end

function Arena:onPlus()
    -- body--加次数
    if not self.data then
        return
    end

    local vip = cache.PlayerCache:VipIsActivate(3) 
    if not vip then
        if g_ios_test then    --EVE 屏蔽处理，提示字符更改
            GComAlter(language.gonggong76)
        else
            GComAlter(language.arena10)
        end
        return
    end

    local var = conf.ArenaConf:getValue("day_challege_count_buy_max")
    if self.data.dayChallengeCountBuy >= var then
        GComAlter(language.arena12)
        return
    end

    mgr.ViewMgr:openView(ViewName.Alert13,function(view)
        -- body
        view:setDataArenaBuy(self.data)
    end)

end

function Arena:onCheck()
    -- body 是否显示仙羽
    self:initRank()
end

function Arena:onShop(  )
    -- body 荣誉商店跳转
    GOpenView({id = 1045})
end

function Arena:onShiJian()
    -- body时间箭头
    if not self.data then
        return
    end
    local vip = cache.PlayerCache:VipIsActivate(3)
    if vip then --砖石vip 是不需要cd的
        return 
    end

    if self.data.leftColdTime > 0 then
        local param = {}
        local t = clone(language.arena19)
        local var = conf.ArenaConf:getValue("clear_cold_cd_cost")
        local money = math.ceil(self.data.leftColdTime/60)*var
        t[2].text = string.format(t[2].text,money)
        param.richtext = mgr.TextMgr:getTextByTable(t)
        param.sure = function()
            -- body
            proxy.ArenaProxy:send(1310202)
        end
        param.type = 2
        GComAlter(param)
    else
        
        GComAlter(language.arena27)
    end
end
--重新随机
function Arena:onChange()
    -- body
    if not self.data then
        return
    end
    if self.oldtime then
        local var = conf.ArenaConf:getValue("refresh_cd")
        if mgr.NetMgr:getServerTime() - self.oldtime < var then
            GComAlter(string.format(language.kaifu41,var))
            return
        end
    end
    self.oldtime = mgr.NetMgr:getServerTime()
    proxy.ArenaProxy:send(1310102)
end

function Arena:onRank()
    -- body
    if not self.data then
        return
    end

    mgr.ViewMgr:openView(ViewName.ArenaRank,function(view)
        -- body
        proxy.ArenaProxy:send(1310103,{page = 1})
        view:setData()
    end, self.data)
end

function Arena:onPlayCall(context)
    -- body
    if not self.data then
        return
    end
    local data = context.sender.data
    if not data then
        return
    end

    if self.data.leftChallengeCount <= 0 then
        local vip = cache.PlayerCache:VipIsActivate(3)
        if not vip then
            if g_ios_test then    --EVE 屏蔽处理，提示字符更改
                GComAlter(language.gonggong76)
            else            
                GComAlter(language.arena11)
            end
        else
            local var = conf.ArenaConf:getValue("day_challege_count_buy_max")
            if self.data.dayChallengeCountBuy >= var then
                GComAlter(language.arena29)
                return
            end

            self:onPlus()
        end
        return
    end

    local function callback()
        -- body
        --发送挑战信息
        cache.ArenaCache:setOtherRoleId(data.roleId)
        cache.ArenaCache:setArenaFight(true)
        proxy.ArenaProxy:send(1310105,{rank = data.rank })
    end
    --printt(self.parent.guidedata)
    if self.parent.isGuide and self.parent.guidedata and self.parent.guidedata.guideid == 1069 then
        plog("还在引导中")
        cache.ArenaCache:setGuide(self.parent.isGuide)
        callback()
        return
    end

    if data.power > cache.PlayerCache:getRolePower() then --玩家战力超过自己
        local param = {}
        param.richtext = language.kaifu40
        param.type = 2
        param.sure = callback
        GComAlter(param)
    else
        callback()
    end
end


--设置玩家信息
function Arena:initRank()
    -- body
    if not self.data then
        return
    end

    local seexianyu = self.checkbtn.selected 
    for i = #self.data.arenaRoles + 1 , 4 do
        self.playerlist[i].visible = false
    end

    for k ,v in pairs(self.data.arenaRoles) do
        if k > 4 then
            break
        end
        local item = self.playerlist[k]
        item.visible = true

        item.data = v 

        local name = item:GetChild("n3")
        name.text = v.roleName

        local rank = item:GetChild("n2")
        rank.text = string.format(language.kaifu39,v.rank)

        local power = item:GetChild("n5")
        power.text = v.power

        local panel = item:GetChild("n1")
        if not panel.data then
            panel.data = self.parent:addModel(v[1],panel)
            panel.data:setPosition(panel.actualWidth/2,-panel.actualHeight-155,500)
            panel.data:setScale(150)
           -- panel.data:setRotationXYZ(0,130,0)
        end 
        --printt(v.skins)
        if seexianyu then
            panel.data:setSkins(v.skins[1],v.skins[2],v.skins[3])
        else
            panel.data:setSkins(v.skins[1],v.skins[2],0)
        end
		
		local _temp = GGetMsgByRoleIcon(v.roleIcon)
        panel.data:setRotation(RoleSexModel[_temp.sex].angle) 
    end
end
--玩家自己的信息
function Arena:initRoleMsg()
    self:updateBgImg()

    -- if cache.PlayerCache:VipIsActivate(3) then   --删除cd 隐藏箭头
    --     self.btnJantou.visible = false
    -- else
    --      self.btnJantou.visible = true  
    -- end

    self.power.text = cache.PlayerCache:getRolePower()
    self.rank.text = self.data.rank
    self.count.text = self.data.leftChallengeCount
    --改变一下红点数量
    if self.data.coldToZero == 1 and self.data.leftColdTime > 0 then
        mgr.GuiMgr:redpointByVar(50109,0)--竞技场cd期间
    else
        mgr.GuiMgr:redpointByVar(50109,self.data.leftChallengeCount)
    end
    --奖励
    local condata = conf.ArenaConf:getRewardByRank(self.data.rank)
    if self.data.rank == 1 then
        self.nextReward.visible = false
        self.nextdec.visible = false
        self.nexticon.visible = false
        self.bybLogo2.visible = false
        self.bybNum2.visible = false
    else
        self.nextReward.visible = true
        self.nextdec.visible = true
        self.nexticon.visible = true
        self.bybLogo2.visible = true
        self.bybNum2.visible = true
    end

    if condata then
        self.curReward.text = condata.items[1][2]
        self.bybNum1.text = condata.items[2][2]     --EVE 当前奖励绑元数量
        local nextconf = conf.ArenaConf:getRewardByRank(condata.rank_begin-1)
        if nextconf then
            self.nextReward.text = nextconf.items[1][2]
            self.bybNum2.text = nextconf.items[2][2]   --EVE 下阶段奖励绑元数量
        else --顶级
            self.nextReward.text = condata.items[1][2]
            self.bybNum2.text = condata.items[2][2]     --EVE 顶级绑元奖励数量
        end
    else
        self.curReward.text = 0 
        self.bybNum1.text = 0     --EVE 排名不够，不奖励绑元
        local nextconf = conf.ArenaConf:getMaxRankReward()
        self.nextReward.text = nextconf.items[1][2]
        self.bybNum2.text = nextconf.items[2][2]    --EVE 排名不够，下阶段奖励绑元数量
    end
end

function Arena:add5310101(data)
    self.data = data
    self:initRank()
    self:initRoleMsg()
    if self.timer then
        self.parent:removeTimer(self.timer)
    end
end
function Arena:add5310102( data )
    -- body
    self.data.arenaRoles = data.arenaRoles
    self:initRank()
end

function Arena:add5310201( data)
    -- body
    self.data.leftChallengeCount = data.leftChallengeCount
    self.data.dayChallengeCountBuy = data.dayChallengeCountBuy

    self:initRoleMsg()
end

function Arena:add5310202()
    -- body
    self.data.leftColdTime = 0
end

function Arena:clear()
    self.bg.url = ""
end


return Arena