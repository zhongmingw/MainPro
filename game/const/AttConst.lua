--[[
    属性定义
--]]

local attConst = {}
--潜力点
attConst.A504 = 504
--当前血量
attConst.A104 = 104
--最大血量
attConst.A105 = 105
--邮件红点
attConst.A10201 = 10201
--修仙红点
attConst.A10204 = 10204
--在线奖励
attConst.A20111= 20111
--离线经验
attConst.A20114 = 20114
--资源找回
attConst.A20113 = 20113
--签到奖励
attConst.A20112 = 20112
--vip礼包
attConst.A20115 = 20115
--仙尊福利
attConst.A20116 = 20116
--等级礼包
attConst.A20127 = 20127
--等级特卖
attConst.A20128 = 20128

--进阶副本红点
attConst.A50101 = 50101
--vip副本红点
attConst.A50102 = 50102
--铜钱副本红点
attConst.A50103 = 50103
--剧情副本红点
attConst.A50104 = 50104
--经验副本红点
attConst.A50105 = 50105
--爬塔副本红点
attConst.A50106 = 50106
--练级谷红点
attConst.A50107 = 50107
--每日福利红点
attConst.A20115 = 20115
--仙尊卡红点
attConst.A20116 = 20116
--开服任务红点
attConst.A20117 = 20117
--开服投资计划红点
attConst.A20118 = 20118
--等级投资计划红点
attConst.A20119 = 20119
--在线送首充领取标识  1:未领取
attConst.A30104 = 30104
--投资计划 活动结束 0 都关闭 1:只开等级 2 都开
attConst.A30105 = 30105
--30天登陆结束红点
attConst.A30106 = 30106
--7天登陆结束红点
attConst.A30117 = 30117
--个人boss红点
attConst.A20136 = 20136

--影卫红点
attConst.A10217 = 10217
--剑神红点
attConst.A10218 = 10218
--强化红点
attConst.A10229 = 10229
--升星红点
attConst.A10230 = 10230
--宝石红点
attConst.A10231 = 10231
--打造红点
attConst.A10232 = 10232
--合成红点
attConst.A10233 = 10233
--好友列表
attConst.A10234 = 10234
--套装红点
attConst.A10235 = 10235
--称号红点
attConst.A10236 = 10236
--时装红点
attConst.A10237 = 10237
--世界红包红点
attConst.A10238 = 10238
--仙盟红包红点
attConst.A10239 = 10239
--成就红点
attConst.A10203 = 10203
--伙伴红点
attConst.A10211 = 10211
--修仙升级红点
attConst.A10245 = 10245

attConst.A10224 = 10224 --旺财
attConst.A10225 = 10225 --拍卖下架物品
attConst.A10226 = 10226 --拍卖成功可领取
attConst.A20120 = 20120-- 30天登陆
attConst.A20121 = 20121--元宝复制
attConst.A20122 = 20122--每日一元
attConst.A20123 = 20123 -- 再充献礼
attConst.A20124 = 20124--每日首充
attConst.A20125 = 20125--每日累充
attConst.A20118 = 20118--开服投资计划
attConst.A20119 = 20119--等级投资计划
attConst.A10301 = 10301--人物改名次数
attConst.A10202 = 10202--红包总红点
attConst.A20137 = 20137--离线挂机抢夺次数红点

attConst.packAging = 10101--道具时效
attConst.packNum = 10104--   已开启背包格子数量
attConst.packTime = 10105--   上一次开启背包的时间
attConst.wareNum = 10106--  已开启仓库格子数量
attConst.wareTime = 10107--   上一次开启仓库的时间
attConst.packSec = 10109--背包格子累計秒數
attConst.wareSec = 10110--仓库格子累計秒數
attConst.limitPack = 10111--临时背包开始时间
attConst.A20129 = 20129-- 在线福利在线时间
attConst.A20130 = 20130-- 在线福利已領取的獎勵
attConst.A20131 = 20131--问鼎结束红点
attConst.A20132 = 20132--皇陵结束红点
attConst.A20133 = 20133--仙盟结束红点
attConst.A20134 = 20134--世界boss
attConst.A20141 = 20141--双修结束红点
attConst.A10240 = 10240--坐骑当前经验值
attConst.A10241 = 10241--坐骑等级
attConst.A10242 = 10242--坐骑在线时间
attConst.A10316 = 10316--练级谷剩余时间
attConst.A10243 = 10243--坐骑当前在线时间
attConst.A10322 = 10322--是否首次登陆
attConst.A10323 = 10323--跨服开启红点
attConst.A30109 = 30109--特惠抢购红点
attConst.A10247 = 10247--y姻缘树红点
attConst.A30111 = 30111--0元购是否开启红点
attConst.A20142 = 20142--仙魔战活动开启时间
attConst.A20143 = 20143--浪漫姻缘活动开启时间
attConst.A20146 = 20146--三界争霸活动开启时间
attConst.A20147 = 20147--宝树活动红点
attConst.A20148 = 20148--7天登陆活动红点
attConst.A20149 = 20149--点石成金活动红点
attConst.A10248 = 10248--剑神套装红点
attConst.A10249 = 10249--野外三倍刷怪红点
attConst.A50113 = 50113--秘境修炼
attConst.A50114 = 50114--幻境镇妖
attConst.A50115 = 50115--单人守塔\
attConst.A50116 = 50116--剑神守护
attConst.A10250 = 10250--装备套装红点
attConst.A10251 = 10251--BOSS喂养红点
attConst.A50117 = 50117--跨服组队次数红点
attConst.A20153 = 20153--等级礼包领取
attConst.A20154 = 20154--仙盟争霸可领取
attConst.A30124 = 30124--天书活动可领取
attConst.A30125 = 30125--寻宝活动红点
attConst.A30128 = 30128--进阶寻宝活动红点
attConst.A30129 = 30129--铸星寻宝活动红点
attConst.A30130 = 30130--等级礼包结束红点
attConst.A20156 = 20156--圣诞登陆领取奖励红点
attConst.A20157 = 20157--圣诞袜上交红点
attConst.A10325 = 10325 --创号天数
attConst.A10253 = 10253--元旦登录豪礼
attConst.A50120 = 50120--元旦雪战红点
attConst.A20159 = 20159--周末登录豪礼红点
attConst.A30132 = 30132--腊八登录红点
attConst.A30133 = 30133--活跃腊八红点
attConst.A30134 = 30134--腊八有礼红点
attConst.A10255 = 10255--宠物红点
attConst.A30135 = 30135--宠物寻宝红点
attConst.A30136 = 30136--情侣跨年红点
attConst.A30137 = 30137--情人节活跃红点
attConst.A20161 = 20161--情人节登录红点
attConst.A20164 = 20164--天降红包红点
attConst.A20162 = 20162--春节登录领取红点
attConst.A30139 = 30139--活跃元宵红点
attConst.A20163 = 20163--元宵登录豪礼
attConst.A20166 = 20166--猜灯谜红点
attConst.A10257 = 10257--符文镶嵌红点
attConst.A50121 = 50121--排位赛入口红点
attConst.A50122 = 50122--组队排位赛竞猜红点
attConst.A50123 = 50123--季后赛排位竞猜红点
attConst.A10259 = 10259--符文寻宝红点
attConst.A50124 = 50124--单人排位赛进阶奖励红点
attConst.A50125 = 50125--组队排位赛进阶奖励红点
attConst.A50126 = 50126--单人场次奖励红点
attConst.A50127 = 50127--组队场次奖励红点
attConst.A20167 = 20167--Boss战斗信息
attConst.A30140 = 30140--五色塔开启红点
attConst.A20168 = 20168--跨服城战开启红点
attConst.A20169 = 20169--跨服城战每日奖励领取红点
attConst.A30141 = 30141--仙盟科技红点
attConst.A10326 = 10326--宣言追求者 1:有

attConst.A30149 = 30149--神器寻宝红点
attConst.A30150 = 30150--洪荒寻宝红点
attConst.A30157 = 30157--剑灵寻宝红点

attConst.A30152 = 30152--鲜花榜活动剩余时间（开服）
attConst.A30153 = 30153--鲜花榜活动剩余时间（限时）
attConst.A20178 = 20178--世界杯兑换红点
attConst.A20179 = 20179--神器强化换红点
attConst.A20180 = 20180--神器升星换红点
attConst.A20181 = 20181--神器附灵换红点
attConst.A20187 = 20187--开服物品投资红点
attConst.A10327 = 10327--平台ID
attConst.A50131 = 50131--帝王将相仙位被抢提示红点
attConst.A20204 = 20204--跨服城战连胜分配红点
attConst.A20205 = 20205--跨服城战终结红点
attConst.A30181 = 30181--仙装寻宝红点
attConst.A10265 = 10265--神兽系统红点
attConst.A50133 = 50133 
attConst.A30216 = 30216--圣印寻宝红点
attConst.A30218 = 30218--剑神装备寻宝红点
attConst.A10266 = 10266--头饰红点
attConst.A10267 = 10267--时装藏品红点

attConst.A10268 = 10268--面具成长丹红点
attConst.A10269 = 10269--面具升级红点
attConst.A10270 = 10270--面具升星红点
attConst.A10271 = 10271--面具附魔红点
attConst.A30251 = 30251--奇兵寻宝活动红点
attConst.A30256 = 30256--鸿蒙寻宝活动红点
attConst.A50135 = 50135--生肖试炼红点

attConst.A30258 = 30258--冰雪节登陆红点
attConst.A30259 = 30259--冰雪节任务
attConst.A30260 = 30260--冰雪节兑换
attConst.A30261 = 30261--冰雪节消费抽抽乐

return attConst;