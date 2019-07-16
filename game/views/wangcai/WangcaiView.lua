--旺财
local WangcaiView = class("WangcaiView",base.BaseView)

function WangcaiView:ctor()
    -- body
    self.super.ctor(self)
    self.type = 1
    self.uiClear = UICacheType.cacheTime
end

function WangcaiView:initData(data)
    -- body
    local window2 = self.view:GetChild("n0")
    GSetMoneyPanel(window2,self:viewName())
    local closeBtn = window2:GetChild("btn_close")
    closeBtn.onClick:Add(self.onClickClose,self)
    --星级
    self.xingxing = self.view:GetChild("n327")
    self.controllerC1 = self.view:GetController("c1")
    --招财10次
    self.selectTenBtn = self.view:GetChild("n335")
    self.selectTenBtn.onChanged:Add(self.onClickCheck,self)
    local shadeBtn = self.view:GetChild("n336")
    shadeBtn.onClick:Add(self.changeSelected,self)
    self.attList = {} --属性加成
    for i=268,275 do
        local text = self.view:GetChild("n"..i)
        text.text = ""
        table.insert(self.attList,text)
    end
    self.dogList = {{state = 1,id = 1}} 
    self.level = 0
    self.exp = 0
    self.time = 0 --铜钱计时
    self.byb_time = 0 --绑元计时
    self.dogNum = 1 --旺财数量
    self.isFirstIn = true
    self:addTimer(1, -1, handler(self,self.timeTick))

    self.is10 = true

    self.super.initData()
end

function WangcaiView:onClickCheck()
    -- body
    -- print("招财10次选择",self.selectTenBtn.selected)
end

function WangcaiView:changeSelected()
    if self.selectTenBtn.selected then
        self.selectTenBtn.selected = false
    else
        self.selectTenBtn.selected = true
    end
end

function WangcaiView:timeTick()
    -- body
    local confData = conf.WangcaiConf:getEarningsData(self.dogNum)
    if self.time >= confData.time then
        self.time = 0
        self.exp = self.exp + confData.exp
        --旺财铜钱buff加成
        local rate = mgr.BuffMgr:isWangcai()
        self.tqCount = (self.tqCount + confData.got_tq)>confData.tq_max and confData.tq_max or (self.tqCount + confData.got_tq*(1+rate))
        -- self.ybCount = (self.ybCount + confData.got_byb)>confData.byb_max and confData.byb_max or (self.ybCount + confData.got_byb)
        self:initAttribute()
        self:initWangcai()
    else
        self.time = self.time + 1
    end
    if self.byb_time >= confData.byb_time then
        self.byb_time = 0
        -- local confData = conf.WangcaiConf:getEarningsData(self.dogNum)
        self.exp = self.exp + confData.exp
        -- self.tqCount = (self.tqCount + confData.got_tq)>confData.tq_max and confData.tq_max or (self.tqCount + confData.got_tq)
        self.ybCount = (self.ybCount + confData.got_byb)>confData.byb_max and confData.byb_max or (self.ybCount + confData.got_byb)
        self:initAttribute()
        self:initWangcai()
    else
        self.byb_time = self.byb_time + 1
    end
end

--设置属性
function WangcaiView:initAttribute()
    -- body
    for k,v in pairs(self.attList) do
        v.text = ""
    end
    local attrData = conf.WangcaiConf:getAttData(self.level)
    local lvlUpBtn = self.view:GetChild("n265")
    lvlUpBtn.onClick:Add(self.onClicklevelUp,self)
    local expBar = self.view:GetChild("n111")
    local ExpTxt = self.view:GetChild("n280")
    local stageIcon = self.view:GetChild("n301")
    local nameTxt = self.view:GetChild("n302")
    expBar.value = self.exp
    lvlUpBtn:GetChild("red").visible = false
    if attrData then
        local data = GConfDataSort(attrData)
        for k,v in pairs(data) do
            local key = v[1]
            local value = v[2]
            local decTxt = self.attList[k]
            local attName = conf.RedPointConf:getProName(key)
            decTxt.text = attName.." "..value
        end
        if not attrData.star then attrData.star = 0 end
        if attrData.star and attrData.star ~= 0 and self.is10 then
            self.xingxing:GetController("c1").selectedIndex = attrData.star +10
        else
            self.xingxing:GetController("c1").selectedIndex = attrData.star or 0
        end

        local powerTxt = self.view:GetChild("n277")
        powerTxt.text = attrData.power or 0
        local step = attrData.step or 1
        stageIcon.url = UIPackage.GetItemURL("_imgfonts" , "huoban_0"..string.format("%02d",step))
        nameTxt.text = attrData.name
        local nextAttrData = conf.WangcaiConf:getAttData(self.level+1)
        -- if attrData.star == 10 and nextAttrData and nextAttrData.need_exp <= self.exp then
        --     proxy.WangcaiProxy:sendMsg(1320103)
        -- end
        if nextAttrData then
            expBar.max = nextAttrData.need_exp
            local textData = {
                {text=self.exp.."",color = 14},
                {text="/",color = 7},
                {text=nextAttrData.need_exp.."",color = 7},
            }
            if self.exp >= nextAttrData.need_exp then
                lvlUpBtn:GetChild("red").visible = true
                textData = {
                    {text=self.exp.."",color = 7},
                    {text="/",color = 7},
                    {text=nextAttrData.need_exp.."",color = 7},
                }
            end
            ExpTxt.text = mgr.TextMgr:getTextByTable(textData)
            lvlUpBtn.visible = true
            self.view:GetChild("n318").visible = false
        else
            local textData = {
                {text=self.exp.."",color = 7},
                {text="/",color = 7},
                {text=attrData.need_exp.."",color = 7},
            }
            expBar.max = attrData.need_exp
            ExpTxt.text = mgr.TextMgr:getTextByTable(textData)
            lvlUpBtn.visible = false
            self.view:GetChild("n318").visible = true
        end
    end
end

--设置旺财
function WangcaiView:initWangcai()
    -- body
    local numBar = self.view:GetChild("n286")
    numBar.value = self.dogNum
    numBar.max = 5
    for i=1,5 do
        if i <= self.dogNum then
            self.view:GetChild("n2"..(86+i)).grayed = false
        else
            self.view:GetChild("n2"..(86+i)).grayed = true
        end
        local data = conf.WangcaiConf:getEarningsData(i)
        if data then
            local item = self.view:GetChild("n29"..(i+2))
            local titleTxt = item:GetChild("n2")
            titleTxt.text = string.format(language.wangcai01,(data.got_tq*(60/data.time)))
        end
    end
    local confData = conf.WangcaiConf:getEarningsData(self.dogNum)
    if confData then
        local tqTxt = self.view:GetChild("n313")
        local ybTxt = self.view:GetChild("n314")
        tqTxt.text = self.tqCount .. "/" .. confData.tq_max
        ybTxt.text = self.ybCount .. "/" .. confData.byb_max
    end
    --领取收益按钮
    local getEarningsBtn = self.view:GetChild("n307")
    getEarningsBtn.onClick:Add(self.onClickGet,self)
    if self.tqCount > confData.tq_max/10 or self.ybCount > confData.byb_max/10 then
        getEarningsBtn:GetChild("red").visible = true
    else
        getEarningsBtn:GetChild("red").visible = false
    end
    --设置不同特权按钮位置
    if self.isFirstIn then
        for i=1,5 do
            if i ~= 1 then
                local num = self.dogList[i].id
                local btnTurnTo = self.view:GetChild("n30"..(num+1))
                btnTurnTo:GetChild("title").text = language.wangcai08[num]
                btnTurnTo.visible = true
                btnTurnTo.x = self.view:GetChild("n2"..(86+i)).x-11
                btnTurnTo.data = self.dogList[i].id
                btnTurnTo.onClick:Add(self.onClickTurnTo,self)
                if self.dogList[i].state == 1 then
                    btnTurnTo.visible = false
                end
            end
            
            if self.dogList[i].state == 1 then
                local node = self.view:GetChild("n32"..i)
                local modelObj = self:addModel(3080199,node)
                modelObj:setScale(90)
                modelObj:setRotationXYZ(0,language.wangcai06[i],0)
                modelObj:setPosition(language.wangcai07[i][1], language.wangcai07[i][2], language.wangcai07[i][3])
            end
        end
        self.isFirstIn = false
    end
    local decTxt = self.view:GetChild("n309")
    local maxData = conf.WangcaiConf:getEarningsData(5)
    local minData = conf.WangcaiConf:getEarningsData(1)
    local multiple1 = math.floor(maxData.got_tq/minData.got_tq)-1
    local multiple2 = math.floor(maxData.exp/minData.exp)-1
    decTxt.text = string.format(language.wangcai05,multiple1,multiple2)
end

--跳转按钮
function WangcaiView:onClickTurnTo( context )
    -- body
    local cell = context.sender
    local id = cell.data
    if id == 2 then
        if self.isFirstCz ~= 1 then
            GOpenView({id = 1042})
            self:closeView()
        end
    else
        if not cache.PlayerCache:VipIsActivate(id-2) then
            GOpenView({id = 1050})
            self:closeView()
        end
    end
end

function WangcaiView:setData(data)
    -- body
    -- printt(data)
    self.data = data
    self.level = data.level
    self.exp = data.exp
    self.tqCount = data.tqCount
    self.ybCount = data.ybCount
    --设置旺财列表状态 state=1为旺财生效 0为不生效
    self.dogList = {{state = 1,id = 1}} 
    self.isFirstCz = data.isFirstCz
    if self.isFirstCz == 1 then
        table.insert(self.dogList,{state = 1,id = 2})
    else
        table.insert(self.dogList,{state = 0,id = 2})
    end
    for i=1,3 do
        if cache.PlayerCache:VipIsActivate(i) then
            table.insert(self.dogList,{state = 1,id = i+2})
        else
            table.insert(self.dogList,{state = 0,id = i+2})
        end
    end
    local num = 0
    for k,v in pairs(self.dogList) do
        if v.state == 1 then
            num = num + 1
        end
    end
    self.dogNum = num
    table.sort(self.dogList,function(a,b)
        if a.state ~= b.state then
            return a.state > b.state
        else
            if a.id ~= b.id then
                return a.id < b.id
            end
        end
    end)
    local confData = conf.WangcaiConf:getEarningsData(self.dogNum)
    self.time = (mgr.NetMgr:getServerTime() - data.lastUpdateTime)%confData.time
    self.byb_time = (mgr.NetMgr:getServerTime() - data.lastByUpdateTime)%confData.byb_time
    self:initAttribute()
    self:initWangcai()

    --疯狂招财设置
    local costData = conf.WangcaiConf:getCrazyCost()
    self.crazyNeed = self.view:GetChild("n333")
    self.crazyBtn = self.view:GetChild("n330")
    local moneyLogo = self.view:GetChild("n337") --EVE 疯狂招财用元宝还是绑元

    self.totalCount = conf.WangcaiConf:getCrazyTimes(self.dogNum)
    -- print("当前次数",data.zcCount)
    self.czTimes = data.zcCount+1 > #costData and #costData or data.zcCount+1
    -- if data.zcCount >= self.totalCount and self.totalCount ~= 0 then
        -- self.crazyBtn.grayed = true
        -- self.view:GetChild("n331").grayed = true
        -- self.crazyBtn.touchable = false
    -- else
        self.crazyBtn.grayed = false
        self.view:GetChild("n331").grayed = false
        self.crazyBtn.touchable = true
    -- end
    if self.totalCount == 0 then
        self.view:GetChild("n329").text = language.wangcai09
    else
        if self.totalCount - data.zcCount < 0 then
            self.view:GetChild("n329").text = 0
        else
            self.view:GetChild("n329").text = self.totalCount - data.zcCount
        end
    end
    self.crazyNeed.text = costData[self.czTimes]

    --EVE 疯狂招财耗费的货币logo显示
    local curBindGold = cache.PlayerCache:getTypeMoney(MoneyType.bindGold)
    self.curBindGold = curBindGold
    if curBindGold ~= 0 then 
        --绑元存在，显示绑元LOGO
        moneyLogo.url = UIItemRes.moneyIcons[MoneyType.bindGold]
    else
        --绑元不足，显示元宝LOGO
        moneyLogo.url = UIItemRes.moneyIcons[MoneyType.gold]
    end 
    --EVE END

    self.crazyBtn.data = {costData = costData}
    self.crazyBtn.onClick:Add(self.onClickCrazy,self)
    if costData[self.czTimes] <= 0 then
        self.crazyBtn:GetChild("n3").visible = true
    else
        self.crazyBtn:GetChild("n3").visible = false
    end
end

--EVE 消耗绑元的警告
function WangcaiView:setNotice(crazyCount,Complement)
        -- print("消耗元宝~：") 
        if self.notTips then 
            proxy.WangcaiProxy:sendMsg(1320102,{reqType = 1,zcTimes = crazyCount})
            return 
        end

        local param = {}
        param.type = 8

        if Complement then
            param.richtext = string.format(language.wangcai13, Complement) 
        end

        param.richtext1 = language.wangcai14
        param.sureIcon = UIItemRes.imagefons01
        param.sure = function(flag) --注意这个加flag的用法
            self.notTips = flag
            proxy.WangcaiProxy:sendMsg(1320102,{reqType = 1,zcTimes = crazyCount})
        end
        GComAlter(param) 
end

function WangcaiView:onClickCrazy(context)
    local tempData = context.sender.data
    local costData = tempData.costData

    local moneyYb = cache.PlayerCache:getTypeMoney(MoneyType.gold)
    local moneyBy = self.curBindGold

    if self.data.zcCount >= self.totalCount and self.totalCount ~= 0 then
        local isFirstCharge = cache.PlayerCache:getAttribute(10324)
        local param = {}
        param.type = 2
        if isFirstCharge > 0 then
            param.richtext = language.wangcai11
            param.sure = function()
                GOpenView({id = 1063})
            end
        else
            param.richtext = language.wangcai12
            param.sure = function()
                GOpenView({id = 1042})
            end
        end
        param.cancel = function()
            
        end
        GComAlter(param)
    else   
        if not self.selectTenBtn.selected then--单次招财

            --EVE 单次招财
            -- if alertData == 1 then --元宝
            --     if moneyYb >= costData[self.czTimes] then
            --         self:setNotice(alertData,1)
            --     else
            --         GComAlter(language.gonggong18)
            --     end
            -- else --绑元
            --     proxy.WangcaiProxy:sendMsg(1320102,{reqType = 1,zcTimes = 1})
            -- end

            if moneyBy > 0 and moneyBy < costData[self.czTimes] then --需要用元宝补足时，才有警告提示
                local complement = costData[self.czTimes] - moneyBy
                self:setNotice(1, complement)
            else
                proxy.WangcaiProxy:sendMsg(1320102,{reqType = 1,zcTimes = 1})
            end
            --EVE END

        else--勾选招财10次            
            local leftTimes = 1
            local cost = 0

            --print("当前次数",self.czTimes)
            if self.dogNum < 5 then--旺财数量少于5只
                leftTimes = self.totalCount - self.data.zcCount
                leftTimes = leftTimes > 10 and 10 or leftTimes
            else
                leftTimes = 10
            end

            for i=1,leftTimes do
                local t = self.czTimes+i > #costData and #costData or self.czTimes+i-1

                --EVE 10次招财
                -- if alertData == 1 then  --EVE 元宝次数
                --     if moneyYb < (cost + costData[t]) then
                --         leftTimes = i-1
                --         break
                --     end
                -- else    --EVE 绑元次数
                --     if moneyBy < (cost + costData[t]) then
                --         leftTimes = i-1
                --         break
                --     end
                -- end

                if moneyYb == 0 or moneyBy == 0 then  --不需要补足时
                    if moneyYb == 0 then --元宝为0，全用绑元招财时计算招财次数
                        if moneyBy < (cost + costData[t]) then
                            leftTimes = i-1
                            break
                        end
                    else  --绑元为0，全用元宝招财时计算招财次数
                        if moneyYb < (cost + costData[t]) then
                            leftTimes = i-1
                            break
                        end
                    end
                else --需要补足时

                    if (moneyYb + moneyBy) < (cost + costData[t]) then 
                        leftTimes = i-1
                        break
                    end     
                end
                --EVE END

                cost = cost + costData[t]
            end

        
            --EVE 注释原因：十次招财弹窗取消
            -- local param = {}
            -- param.type = 2
            -- param.sure = function()
            --     --print("元宝数量",extraYb)
            --     if moneyYb < cost then
            --         GComAlter(language.gonggong18)
            --     else
            --         proxy.WangcaiProxy:sendMsg(1320102,{reqType = 1,zcTimes = leftTimes})
            --     end
            -- end

            -- local textData = {
            --                         {text = language.wangcai10[1],color = 6},
            --                         {text = string.format(language.wangcai10[2],cost),color = 7},
            --                         {text = string.format(language.wangcai10[3],leftTimes),color = 6},
            --                     }
            -- param.richtext = mgr.TextMgr:getTextByTable(textData)

            -- if leftTimes == 0 then            
            --     -- GComAlter(language.gonggong18)             
            -- else      
            --     --EVE 直接招财
            --     self:setNotice(alertData,leftTimes)

            --     -- GComAlter(param) 
            -- end

            --EVE 策划的变态需求，只有需要花费元宝补足的时候弹窗
            if leftTimes == 0 then 
                if moneyYb == 0 or moneyBy == 0 then  --只用元宝或者只用绑元时
                    if moneyYb == 0 then --只用绑元
                        GComAlter(language.wangcai15)
                    else --只用元宝时
                        GComAlter(language.gonggong18)
                    end 
                else --混合使用时
                    GComAlter(language.gonggong18)
                end 
            else
                if moneyYb == 0 or moneyBy == 0 then 
                    proxy.WangcaiProxy:sendMsg(1320102,{reqType = 1,zcTimes = leftTimes})
                else
                    local finalCost = cost - moneyBy
                    if finalCost <= 0 then 
                        proxy.WangcaiProxy:sendMsg(1320102,{reqType = 1,zcTimes = leftTimes})
                        -- print("AAAAAAAAAA", finalCost, cost, moneyBy)
                    else
                        -- print("AAAAAAAAAA", finalCost, cost, moneyBy)
                        self:setNotice(leftTimes, finalCost)
                    end              
                end
            end 
            --EVE END
        end
    end
end

--进阶按钮
function WangcaiView:onClicklevelUp( context )
    -- body
    local nextAttrData = conf.WangcaiConf:getAttData(self.level+1)
    if nextAttrData then
        if self.exp >= nextAttrData.need_exp then
            proxy.WangcaiProxy:sendMsg(1320103)
        else
            GComAlter(language.wangcai02)
        end
    else
        GComAlter(language.wangcai03)
    end
end

--进阶刷新
function WangcaiView:updateJinjie(data)
    -- body
    self.level = data.curLevel
    self.exp = data.curExp
    self.is10 = false
    self:initAttribute()
    mgr.SoundMgr:playSound(Audios[2])
end

--领取收益
function WangcaiView:onClickGet( context )
    -- body
    if self.tqCount > 0 or self.ybCount > 0 then
        proxy.WangcaiProxy:sendMsg(1320102,{reqType = 0})
    else
        GComAlter(language.wangcai04)
    end
end
--领取收益后刷新
function WangcaiView:updateEarnings( data )
    -- body
    self.tqCount = 0
    self.ybCount = 0
    GOpenAlert3(data.items)
    self:initWangcai()
end


function WangcaiView:onClickClose()
    -- body
    self:closeView()
end

return WangcaiView