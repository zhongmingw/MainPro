--
-- Author: 
-- Date: 2017-04-17 19:41:13
--
local ActivityCache = class("ActivityCache",base.BaseCache)
--[[

--]]
function ActivityCache:init()
    self.data5030121 = {}
    self.data5030123 = {}
    self.data5030122 = {} --EVE 隐藏任务奖励缓存
    self.onLineAwardsNum = 0
    self.summerPhus = 0
    --祝福时间
    self.isZhuFu = {
        [30119] = false,
        [30120] = false,
        [30121] = false,
        [30122] = false,
        [30123] = false,
    }
    self.wkAlertFlag = true--趣味挖矿是否有购买弹窗
end

--祝福时间
function ActivityCache:setIsZhuFu(key,var)
    -- body
    self.isZhuFu[key] = var
end

function ActivityCache:getIsZhuFu(key)
    -- body
    return self.isZhuFu[key]
end

--抽奖活动弹框推送标识
function ActivityCache:setSummerPush(num)
    self.summerPhus = num
end

function ActivityCache:getSummerPush()
    return self.summerPhus
end

--每日首充奖励
function ActivityCache:set5030121(data)
    -- body
    self.data5030121 = data
end

function ActivityCache:get5030121()
    -- body
    return self.data5030121
end

--首充领取列表
function ActivityCache:set5030123(data)
    -- body
    self.data5030123 = data
end
--获取首充列表某个充值档次的领取情况 step档次1.2.3
function ActivityCache:get5030123(step)
    -- body
    local bol = false
    for k,v in pairs(self.data5030123) do
        if v == step then
            bol = true
        end
    end
    return bol
end

function ActivityCache:isGet5030121(id)
    -- body
    if not self.data5030121 or not self.data5030121.ItemStatus then
        return false
    end
    --已经领取
    if 2 == self.data5030121.ItemStatus[id] then
        return true
    end
    return false
end
---开服活动
function ActivityCache:set5030111(data)
    self.data5030111 = data
    self:setOnlineAward()
end
--开服天数转第几天循环（第10天-第一天）
function ActivityCache:getLoopDay()
    if self.data5030111 then
        local openDay = self.data5030111.openDay
        return (openDay - 1) % 9 + 1
    end
    return 1
end

function ActivityCache:get5030111()
    -- body
    return self.data5030111
end

function ActivityCache:setOnlineAward()
    self.onlineAward = conf.ActivityConf:sortOnlineAward()
end

function ActivityCache:getOnlineAward()
    return self.onlineAward
end


--缓存离线奖励之前的角色等级
function ActivityCache:setOfflineLevel(lv)
    -- body
    self.offLineLevel = lv or cache.PlayerCache:getRoleLevel()
end
function ActivityCache:getOfflineLevel()
    -- body
    return self.offLineLevel
end
--缓存离线奖励之前的
function ActivityCache:setOfflineExp(exp)
    -- body
    self.offLineExp = exp or cache.PlayerCache:getRoleExp()
end
function ActivityCache:getOfflineExp()
    -- body
    return self.offLineExp
end

function ActivityCache:set5030122(data)
    -- body
    self.data5030122 = data
end

function ActivityCache:get5030122(data)
    -- body
    return self.data5030122
end
--寻宝活动提醒框显示  （true提醒）
function ActivityCache:setXunBaoAlert(data)
    -- body
    self.xunBaoAlertType = data
end

function ActivityCache:getXunBaoAlert()
    -- body
    return self.xunBaoAlertType
end
--双倍活动副本信息
function ActivityCache:set5030168(data)
    self.data5030168 = data
end

function ActivityCache:get5030168(id)
    local isFind = false
    if self.data5030168 then
        for k,v in pairs(self.data5030168.doubleModuleList) do
            if v == id then
                isFind = true
                break
            end
        end
    end
    return isFind
end
--腊八活动，飞往主城
function ActivityCache:setLabaFly(flag)
    self.labaFly = flag
end

function ActivityCache:getLabaFly ()
    return self.labaFly 
end
--情人节抽奖不飘道具到背包
function ActivityCache:setValentineRallfe(flag)
    self.delayFly = flag
end
function ActivityCache:getValentineRallfe()
    return self.delayFly 
end 
--小年活动
function ActivityCache:setLunarYearFly(flag)
    self.LunarYearFly = flag
end
function ActivityCache:getLunarYearFly()
    return self.LunarYearFly 
end

--幸运转盘抽奖不飘道具到背包
function ActivityCache:setTurnTable(flag)
    -- body
    self.notFly = flag
end
function ActivityCache:getTurnTable()
    -- body
    return self.notFly
end
--是从鲜花榜进来的
function ActivityCache:setFlowerRankCome(flag)
    self.flowerCome = flag
end
function ActivityCache:getFlowerRankCome()
    return self.flowerCome 
end

--神炉炼宝抽奖不飘道具到背包
function ActivityCache:setSllbChouJiang(flag)
    self.sllbNotFly = flag
end

function ActivityCache:getSllbChouJiang()
    return self.sllbNotFly
end

--趣味挖矿是否有购买弹窗设置
function ActivityCache:setWkAlertFlag(flag)
    self.wkAlertFlag = flag
end

function ActivityCache:getWkAlertFlag()
    return self.wkAlertFlag
end
--天命卜卦
function ActivityCache:setTMBGAlertFlag(flag)
    self.buGuaAlert = flag
end
function ActivityCache:getTMBGAlertFlag()
    return self.buGuaAlert
end

--水果消除
function ActivityCache:setFruitScore(score)
    self.fruitscore = score
end

function ActivityCache:getFruitScore()
     return self.fruitscore or {}
end

--科举答题缓存
function ActivityCache:setCdmhData(data)
    self.cdmhData = data
end

function ActivityCache:getCdmhData()
    return self.cdmhData
end

function ActivityCache:updateCdmhData(data)
    if self.cdmhData then
        self.cdmhData.curQuestionNum = data.curQuestionNum
        self.cdmhData.myScore = data.myScore
        self.cdmhData.ranking = data.ranking
        self.cdmhData.exp = data.exp
    end
end

function ActivityCache:updateRankData(data)
    if self.cdmhData then
        self.cdmhData.scoreRankings = data.scoreRankings
    end
end

--双十二优惠券缓存
function ActivityCache:setYhjData(data)
    self.yhjData = data
end

function ActivityCache:getYhjData()
    return self.yhjData or 0
end

--双十二购物车缓存
function ActivityCache:setGwcData(data)

    self.gwcData = data
end

function ActivityCache:getGwcData()
    
    return self.gwcData or {}
end

--冬至记忆饺宴缓存
function ActivityCache:setJyjyData(data)

    self.JyjyData = data
end

function ActivityCache:getJyjyData()
    
    return self.JyjyData or {}
end

function ActivityCache:setDanMuIsOpen(flag)
    self.isOpenDanMu = flag
end

function ActivityCache:getDanMuOpen()
    return self.isOpenDanMu
end

function ActivityCache:setBingXueFillAmount(data)
    self.bxFillAmount = data
end

function ActivityCache:getBingXueFillAmount()
    return self.bxFillAmount
end

return ActivityCache