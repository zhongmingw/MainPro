
-- Author: 
-- Date: 2017-03-27 10:30:07
--

local TopActive = class("TopActive",import("game.base.Ref"))

local DownLoadId = 1090

function TopActive:ctor(param)
    self.parent = param
    self:initView()
    self:initData()
end

function TopActive:initView()
    -- body
    self.btnlist = {{},{},{}}
    self.btnpos = {} --用于记录位置
    local topPanel1 = self.parent.view:GetChild("n326")
    for i = 0 , 23 do
        local btn = topPanel1:GetChild("n"..i)
        btn.visible = false
        btn.onClick:Add(self.onTopCall,self)
        if i <= 7 then
            table.insert(self.btnlist[1],btn)
        elseif i<= 15 then
            table.insert(self.btnlist[2],btn)
        else
            table.insert(self.btnlist[3],btn)
        end
        --记录坐标
        self.btnpos[i+1] = btn.xy
    end
end

function TopActive:checkConfData(v)
    -- body
    if g_is_banshu then
        if v.id == 1046 then
            v.btnsee = true
            self.seetable[v.id] = v
            table.insert(self.confData,v)
        end
    else
        -- if v.id ~= 1023 then return end 
        -- plog("v.id:",v.id)
        if not g_is_guide or (v.issee and v.issee == 1) then
            v.btnsee = true
            self.seetable[v.id] = v
        else
            table.insert(self.confData,v)
        end
    end
end

function TopActive:initData()
    -- body
    self.touc = {}

    self.teshuid = {}
    self.seetable = {}
    self.confData = {}
    local confdata = conf.ActivityConf:getTopBtn()

    --ios 审核保留
    local _t = {
        -- [1055] = true,
        -- [1023] = true
        [1120] = true, --七天登录
        [1035] = true, --福利大厅
    }

   
    for k , v in pairs(confdata) do
        if g_ios_test  then 
            if _t[v.id] then
                -- plog("走这里走这里", v.id)
                self:checkConfData(v)
            end
            
        else 
            self:checkConfData(v)
        end
    end
end

function TopActive:checkData(v)
    local data = cache.ActivityCache:get5030111()
    -- print(data.acts[1234])
    --print(cache.PlayerCache:getRedPointById(20213))
    if v.id == 1028 
        or v.id == 1102 
        or v.id == 1103 
        or v.id == 1263 
        or v.id == 1271 
        or v.id == 1284 
        or v.id == 1288 
        or v.id == 1294
        or v.id == 1426
        or v.id == 1427
        or v.id == 1428 then
        if mgr.ModuleMgr:CheckView(v.id) then
            if not self:checkKaiFu(v) then
                if self.seetable[v.id] then
                    self.seetable[v.id] = nil 
                end
            end
        end
        self.teshuid[v.id] = true
    elseif v.id == 1092 then
        if mgr.ModuleMgr:CheckView(v.id) then
            if not self:checkAdvance(v) then
                if self.seetable[v.id] then
                    self.seetable[v.id] = nil
                end
            end
        end
        self.teshuid[v.id] = true
    elseif v.id == 1054 then
        --再充献礼检测
        self:check1054()
        self.teshuid[v.id] = true
    elseif v.redid then --活动红点开启判断
        self:checkActive()
        self.teshuid[v.id] = true
    elseif v.id == 1108 then--幸运进阶日 --屏蔽
        -- if mgr.ModuleMgr:CheckView(v.id) then
        --     self:checkLuckyAdvance(v)
        --     self.teshuid[v.id] = true
        -- end
    elseif v.id == 1111 then--夏日活动
        -- v.btnsee = false
        -- self.seetable[1111] = nil
        -- -- self:checkSummerAct(v)
        -- self.teshuid[v.id] = true
        self:checkSummerAct(v)
        self.teshuid[v.id] = true
    elseif v.id == 1113 then--活跃红包
        local data = cache.ActivityCache:get5030111()
        if data and data.acts[1037] and data.acts[1037] == 1 and mgr.ModuleMgr:CheckView(v.id) then
            v.btnsee = true
            self.seetable[1113] = v 
        else
            v.btnsee = false
            self.seetable[1113] = nil 
        end
        self.teshuid[v.id] = true
    elseif v.id == 1115 then
        local data = cache.ActivityCache:get5030111()
        if data and data.acts[1042] and data.acts[1042] == 1 and mgr.ModuleMgr:CheckView(v.id) then
            v.btnsee = true
            self.seetable[1115] = v 
        else
            v.btnsee = false
            self.seetable[1115] = nil 
        end
        self.teshuid[v.id] = true
    elseif v.id == 1121 then
        local data = cache.ActivityCache:get5030111()
        if data and data.acts[1046] and data.acts[1046] == 1 and mgr.ModuleMgr:CheckView(v.id) then
            v.btnsee = true
            self.seetable[1121] = v 
        else
            v.btnsee = false
            self.seetable[1121] = nil 
        end
        self.teshuid[v.id] = true
    elseif v.id == 1122 then
        local data = cache.ActivityCache:get5030111()
        if data and data.acts[1047] and data.acts[1047] == 1 and mgr.ModuleMgr:CheckView(v.id) then
            v.btnsee = true
            self.seetable[1122] = v 
        else
            v.btnsee = false
            self.seetable[1122] = nil 
        end
        self.teshuid[v.id] = true
    elseif v.id == 1141 then
        local var = cache.PlayerCache:getAttribute(50118)
        -- print("0000000000000000",var)
        if var > 0 then
            v.btnsee = true
            self.seetable[1141] = v
        else
            v.btnsee = false
            self.seetable[1141] = nil 
        end
        self.teshuid[v.id] = true
    elseif v.id == 1150 then
        local data = cache.ActivityCache:get5030111()
        local act = data and data.acts[1054] or 0
        if act == 1 and mgr.ModuleMgr:CheckView(v.id) then
            v.btnsee = true
            self.seetable[v.id] = v
        else
            v.btnsee = false
            self.seetable[v.id] = nil   
        end
        self.teshuid[v.id] = true
    elseif v.id == 1160 or v.id == 1232 then --EVE 幸运云购
        local data = cache.ActivityCache:get5030111()
        local act = data and data.acts[3017] or 0
        if v.id == 1232 then
            act = data and data.acts[3054] or 0
        end
        if act == 1 and mgr.ModuleMgr:CheckView(v.id) then
            v.btnsee = true
            self.seetable[v.id] = v
        else
            v.btnsee = false
            self.seetable[v.id] = nil 
        end
    elseif v.id == 1161 then
        self:checkChristmas(v)
        self.teshuid[v.id] = true
    elseif v.id == 1164 then --元旦活动
        self:checkYd(v)
        self.teshuid[v.id] = true
    elseif v.id == 1168 then --魅力沙滩
        local var = cache.PlayerCache:getRedPointById(20158)
        -- print("0000000000000000",var)
        if var > 0 and mgr.ModuleMgr:CheckView(v.id) then
            v.btnsee = true
            self.seetable[1168] = v
        else
            v.btnsee = false
            self.seetable[1168] = nil 
        end
        self.teshuid[v.id] = true
    elseif v.id == 1327 then --天晶洞窟
        local var = cache.PlayerCache:getRedPointById(20202)
        -- print("天晶洞窟0000000000000000",var)
        if var > 0 and mgr.ModuleMgr:CheckView(v.id) then
            v.btnsee = true
            self.seetable[1327] = v
        else
            v.btnsee = false
            self.seetable[1327] = nil 
        end
        self.teshuid[v.id] = true
    elseif v.id == 1170 then
        self:checkWeek(v)
        self.teshuid[v.id] = true
    elseif v.id == 1180 then --腊八活动
        self:checkLaba(v)
        self.teshuid[v.id] = true
    elseif v.id == 1187 then --腊八消费排行
        local data = cache.ActivityCache:get5030111()
        local act = data and data.acts[1067] or 0
        if act == 1 and mgr.ModuleMgr:CheckView(v.id) then
            v.btnsee = true
            self.seetable[v.id] = v
        else
            v.btnsee = false
            self.seetable[v.id] = nil 
        end
    elseif v.id == 1190 or v.id == 1233 then --转盘
        local data = cache.ActivityCache:get5030111()

        local act = data and data.acts[3018] or 0
        if v.id == 1233 then
            act = data and data.acts[3055] or 0
        end
        if act == 1 and mgr.ModuleMgr:CheckView(v.id) then
            v.btnsee = true
            self.seetable[v.id] = v
        else
            v.btnsee = false
            self.seetable[v.id] = nil 
        end
    elseif v.id == 1205 then --情人节活动
        self:checkValentine(v)
        self.teshuid[v.id] = true
    elseif v.id == 1207 then --情人节抽奖
        local data = cache.ActivityCache:get5030111()

        local act = data and data.acts[1069] or 0
        if act == 1 and mgr.ModuleMgr:CheckView(v.id) then
            v.btnsee = true
            self.seetable[v.id] = v
        else
            v.btnsee = false
            self.seetable[v.id] = nil 
        end
    elseif v.id == 1201 then --春节活动
        local data = cache.ActivityCache:get5030111()

        local act = data and data.acts[3047] or 0
        if act == 1 and mgr.ModuleMgr:CheckView(v.id) then
            v.btnsee = true
            self.seetable[v.id] = v
        else
            v.btnsee = false
            self.seetable[v.id] = nil 
        end
    elseif v.id == 1208 then--活跃元宵
        self:checkLantern(v)
        self.teshuid[v.id] = true
    elseif v.id == 1195 then  --小年活动
        local data = cache.ActivityCache:get5030111()
        local act = data and data.acts[3045] or 0
        if act == 1 and mgr.ModuleMgr:CheckView(v.id) then
            v.btnsee = true
            self.seetable[v.id] = v
        else
            v.btnsee = false
            self.seetable[v.id] = nil 
        end    
    elseif  v.id == 1234 or v.id == 1260 then--开服好运灵签
        local data = cache.ActivityCache:get5030111()
         if (data.acts[1084] and data.acts[1084] == 1) 
             or (data.acts[3064] and data.acts[3064] == 1) then  
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            v.btnsee = false
            self.seetable[v.id] = nil 
        end
    elseif  v.id == 1237 then--夺宝奇兵
        local data = cache.ActivityCache:get5030111()
        local act = data and data.acts[1088] or 0
        if act == 1 and mgr.ModuleMgr:CheckView(v.id) then
            v.btnsee = true
            self.seetable[v.id] = v
        else
            v.btnsee = false
            self.seetable[v.id] = nil 
        end       
    elseif  v.id == 1235 or v.id == 1236 then--超值返还
        local data = cache.ActivityCache:get5030111()
        if (data.acts[1101] and data.acts[1101] == 1) 
             or (data.acts[1102] and data.acts[1102] == 1) then  
            -- v.btnsee = true
            -- self.seetable[v.id] = v
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            v.btnsee = false
            self.seetable[v.id] = nil 
        end       
    elseif v.id == 1243 or v.id == 1244 then--超值返还2
        local data = cache.ActivityCache:get5030111()
        if (data.acts[1103] and data.acts[1104] == 1) 
             or (data.acts[1103] and data.acts[1104] == 1) then  
            -- v.btnsee = true
            -- self.seetable[v.id] = v
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            v.btnsee = false
            self.seetable[v.id] = nil 
        end   

    elseif  v.id == 1241 then--鲜花榜
        local data = cache.ActivityCache:get5030111()
        if (data.acts[1089] and data.acts[1089] == 1) or
            (data.acts[1090] and data.acts[1090] == 1) then
           
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif  v.id == 1335 then--魅力榜
        local data = cache.ActivityCache:get5030111()
        if (data.acts[5003] and data.acts[5003] == 1) then
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif  v.id == 1354 then--全服鲜花榜
        local data = cache.ActivityCache:get5030111()
        if (data.acts[5011] and data.acts[5011] == 1) then
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif  v.id == 1248 then--合服折扣礼包
        local data = cache.ActivityCache:get5030111()
        if (data.acts[1093] and data.acts[1093] == 1) then
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif  v.id == 1249 or v.id == 1250 then--神器排行&神器寻宝返还
        local data = cache.ActivityCache:get5030111()
        if --[[(data.acts[1091] and data.acts[1091] == 1) or]]
            (data.acts[1092] and data.acts[1092] == 1)or
            (data.acts[1106] and data.acts[1106] == 1) then
            -- v.btnsee = true
            -- self.seetable[v.id] = v
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif  v.id == 1245 then--世界杯
        local data = cache.ActivityCache:get5030111()
        if data.acts[3058] and data.acts[3058] == 1 then 
            -- v.btnsee = true
            -- self.seetable[v.id] = v
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif  v.id == 1251 then--充值翻牌
        local data = cache.ActivityCache:get5030111()
        if data.acts[1105] and data.acts[1105] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif  v.id == 1252 then--合服返利
        local endTime  = cache.PlayerCache:getRedPointById(30154)
        local nowTime =mgr.NetMgr:getServerTime()
        local leftTime = endTime-nowTime
        if leftTime > 0 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif  v.id == 1253 then--充值返利
        local data = cache.ActivityCache:get5030111()
        if data.acts[3060] and data.acts[3060] == 1 then
            -- print("返利活动》》》") 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif  v.id == 1255 or v.id == 1261 then--山盟海誓
        local data = cache.ActivityCache:get5030111()
        if (data.acts[3061] and data.acts[3061] == 1)or(data.acts[1107] and data.acts[1107] == 1) then
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif  v.id == 1257 or v.id == 1262 then--三生三世
        local data = cache.ActivityCache:get5030111()
        if (data.acts[3062] and data.acts[3062] == 1)or(data.acts[1108] and data.acts[1108] == 1) then
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif  v.id == 1258 then--射门好礼
        local data = cache.ActivityCache:get5030111()
        if (data.acts[3063] and data.acts[3063] == 1)or(data.acts[1109] and data.acts[1109] == 1) then
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end 
    elseif v.id == 1259 then--合服基金
        local data = cache.ActivityCache:get5030111()
        if data.acts[1111] and data.acts[1111] == 1 or 
         data.acts[1115] and data.acts[1115] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif v.id == 1256 then--神炉炼宝
        local data = cache.ActivityCache:get5030111()
        if data.acts[1110] and data.acts[1110] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif v.id == 1264 then--摇钱树
        local data = cache.ActivityCache:get5030111()
        if data.acts[1112] and data.acts[1112] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif v.id == 1268 then--寻仙探宝
        local data = cache.ActivityCache:get5030111()
        if data.acts[3066] and data.acts[3066] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif v.id == 1269 or v.id == 1270 then--剑灵寻宝排行

        local data = cache.ActivityCache:get5030111()
        if (data.acts[3067] and data.acts[3067] == 1) or
         (data.acts[5001] and data.acts[5001] == 1) then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif v.id == 1273 then --充值回馈
        local data = cache.ActivityCache:get5030111()
        if (data.acts[3068] and data.acts[3068] == 1) and mgr.ModuleMgr:CheckView(v.id) then
            v.btnsee = true
            self.seetable[v.id] = v
        else
            v.btnsee = false
            self.seetable[v.id] = nil
        end
    elseif v.id == 1274 then--神器认主
        local data = cache.ActivityCache:get5030111()
        if data.acts[3069] and data.acts[3069] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif v.id == 1275 then--法老秘宝
        local data = cache.ActivityCache:get5030111()
        if data.acts[3070] and data.acts[3070] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif v.id == 1282 then--寻宝排行
        local data = cache.ActivityCache:get5030111()
        if data.acts[5002] and data.acts[5002] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        -- elseif data.acts[3072] and data.acts[3072] == 1 then 
        --     --如果寻宝排行未开启 入口该为寻宝返回
        --     local cc = SysConf:getModuleById:getActiveById(1283)
        --     if mgr.ModuleMgr:CheckView(cc.id) then
        --         cc.btnsee = true
        --         self.seetable[1283] = cc
        --     else
        --         cc.btnsee = false
        --         self.seetable[cc.id] = nil 
        --     end
        else
            self.seetable[v.id] = nil
        end
    elseif v.id == 1276 then
        local data = cache.ActivityCache:get5030111()
        -- print("充值豪礼>>>>>>>>>>>>>>",data.acts[3073])
        if data.acts[3073] and data.acts[3073] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif v.id == 1277 then--机甲剑神
        local data = cache.ActivityCache:get5030111()
        -- print("机甲剑神>>>>>>>>>>>",data.acts[3075],data.acts[1116])
        if data.acts[3075] and data.acts[3075] == 1 then
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end 
    elseif v.id == 1480 then--开服机甲来袭
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1116] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif v.id == 1285 then--单笔豪礼
        local data = cache.ActivityCache:get5030111()
        --print("data.acts[3076] == 1",data.acts[3076] == 1,mgr.ModuleMgr:CheckView(v.id))
        if data.acts and data.acts[3076] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif v.id == 1281 then--恶魔时装
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[3074] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif v.id == 1288 or v.id == 1289 then--神臂擎天
        local data = cache.ActivityCache:get5030111()
        if  (data.acts[3077] and data.acts[3077] == 1) or
            (data.acts[5004] and data.acts[5004] == 1) then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif v.id == 1290 then
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1117] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif v.id == 1291 then
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[3078] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif v.id == 1292 then -- 消费兑换
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[3079] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end    
    elseif v.id == 1293 then--连冲特惠
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1119] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif v.id == 1295 then--累充值特惠
        local data = cache.ActivityCache:get5030111()
        --print("检测 1295",data.acts[1118])
        if data.acts and data.acts[1118] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif v.id == 1298 then--狂欢大乐购
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1133] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif v.id == 1299 then--猴王除妖
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[3080] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
	elseif v.id == 1300 then--摇钱树
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1132] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif v.id == 1302 then--疯狂返利
        local data = cache.ActivityCache:get5030111()
       -- print("1302  ,",data.acts[1134])
        if data.acts and data.acts[1134] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif v.id == 1303 then--冲战达人
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[3081] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif v.id == 1305 then--超值单笔
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[3082] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end   
    elseif v.id == 1280 then--仙侣PK
        local data = cache.ActivityCache:get5030111()
        if (data.acts and data.acts[1114] == 1) or 
         (data.acts and data.acts[1135] == 1) then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end   
    elseif v.id == 1351 then--仙侣PK全服
        local data = cache.ActivityCache:get5030111()
        if (data.acts and data.acts[5009] == 1) or 
         (data.acts and data.acts[5010] == 1) then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end   
    elseif v.id == 1306 then--充值抽抽乐
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[3083] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif v.id == 1307 then--百发百中
        local data = cache.ActivityCache:get5030111()
        -- print("百发百中活动>>>>>>>>>>>>",data.acts[3084])
        if data.acts and data.acts[3084] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end  
    elseif v.id == 1308 then--跨服充值榜
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[5005] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end 
    elseif v.id == 1311 or  v.id == 1312 then--仙童大比拼or 洞房返还
        local data = cache.ActivityCache:get5030111()
        if (data.acts[5006] and data.acts[5006] == 1) or
            (data.acts[3085] and data.acts[3085] == 1)  then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end  
    elseif v.id == 1314 then--刮刮乐
        local data = cache.ActivityCache:get5030111()
        if data.acts[3071] and data.acts[3071] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end    
   elseif v.id == 1315 then--聚宝盆
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[3086] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end 
    elseif v.id == 1316 then--顶部按钮月卡
        local var = cache.PlayerCache:getRedPointById(20200)
        if var == 1 then--已拥有月卡
            v.btnsee = false
            self.seetable[v.id] = nil 
        else
            v.btnsee = true
            self.seetable[v.id] = v
        end
    elseif v.id == 1318 then--秘境淘宝
        local data = cache.ActivityCache:get5030111()
        --print("data.acts[3087]",data.acts[3087])
        if data.acts and data.acts[3087] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end 
    elseif v.id == 1321 then--连消特惠
        local data = cache.ActivityCache:get5030111()
        --print("data.acts[3087]",data.acts[3087])
        if data.acts and data.acts[1137] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end 
    elseif v.id == 1322 then--今日累充
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[3088] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end 
    elseif v.id == 1323 then--天命卜卦
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[3089] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif v.id == 1326 then--步步高升
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1138] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif v.id == 1328 then--老师请点名
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[3090] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif v.id == 1329 then--限时连冲
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1140] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif v.id == 1331 then--
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[3092] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end 
    elseif v.id == 1330 then--
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[3091] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end 
    elseif v.id == 1332 then--灵虚宝藏
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1139] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end 
    elseif v.id == 1333 then--双倍返回
        local data = cache.ActivityCache:get5030111()
        --print("data.acts[1141]",data.acts[1141])
        if data.acts and data.acts[1141] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end 
    elseif v.id == 1338 then--我要转转
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1142] == 1 then
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end 
	elseif v.id == 1339 then--祈福灵泉
        local data = cache.ActivityCache:get5030111()
        --print("data.acts[1141]",data.acts[1141])
        if data.acts and data.acts[1143] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end 
    elseif 1340 == v.id then --寻宝排行
        local data = cache.ActivityCache:get5030111()
        --print("data.acts[3095]",data.acts[3095])
        if data.acts and data.acts[3095] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end 
    elseif 1342 == v.id then --元宝兑换
        local data = cache.ActivityCache:get5030111()
        --print("data.acts[1145]",data.acts[1145],mgr.ModuleMgr:CheckView(v.id))
        if data.acts and data.acts[1145] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif 1346 == v.id then --仙装排行
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[5008] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end  
    elseif 1334 == v.id then --悠讯
        local data = cache.ActivityCache:get5030111()
        -- print("data.acts[1146]",data.acts[1146],g_var.yx_game_param)
        if  g_var.yx_game_param and data.acts and data.acts[1146] == 1 then 
            local packId = tonumber(g_var.packId)
            -- print("1111111111111",packId)
            if mgr.ModuleMgr:CheckView(v.id) and packId ~= 7073 and packId ~= 6074 then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end 
    elseif 1347 == v.id then --神兽排行
        local data = cache.ActivityCache:get5030111()
        --print("data.acts[5007]",data.acts[5007],g_var.yx_game_param)
        if data.acts and data.acts[5007] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end 
    elseif 1350 == v.id then --中秋活动
        local data = cache.ActivityCache:get5030111()
        --print("data.acts[5007]",data.acts[1147])
        if  (data.acts[1148] and data.acts[1148] == 1) or
            (data.acts[1149] and data.acts[1149] == 1) or
            (data.acts[1150] and data.acts[1150] == 1) or
            (data.acts[1151] and data.acts[1151] == 1) or
            (data.acts[1152] and data.acts[1152] == 1) or
            (data.acts[1153] and data.acts[1153] == 1)  then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif 1352 == v.id then --中秋豪礼
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1147] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif 1355 == v.id then--国庆活动
        local data = cache.ActivityCache:get5030111()
        if  (data.acts[1157] and data.acts[1157] == 1) or
            (data.acts[1158] and data.acts[1158] == 1) or
            (data.acts[1159] and data.acts[1159] == 1) or
            (data.acts[1160] and data.acts[1160] == 1) or
            (data.acts[1161] and data.acts[1161] == 1) or
            (data.acts[3051] and data.acts[3051] == 1) then
            --(data.acts[1058] and data.acts[1058] == 1) then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif 1356 == v.id then--全民备战
        local data = cache.ActivityCache:get5030111()
        if  (data.acts[1154] and data.acts[1154] == 1) or
            (data.acts[1155] and data.acts[1155] == 1) or 
            (data.acts[1156] and data.acts[1156] == 1) then
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif 1357 == v.id then --圣印排行
        local data = cache.ActivityCache:get5030111()
        if (data.acts and data.acts[5012] == 1) then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif 1359 == v.id then --圣印返还
        local data = cache.ActivityCache:get5030111()
        if (data.acts and data.acts[1163] == 1 )  then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif 1361 == v.id then -- 珍稀乾坤
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1164] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif v.id == 1363 or v.id == 1364 then -- 剑神寻宝         
        local data = cache.ActivityCache:get5030111()
        if (data.acts[5013] and data.acts[5013] == 1) or
         (data.acts[1166] and data.acts[1166] == 1) then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif 1367 == v.id then -- 烟花庆典
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1167] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif 1368 == v.id then -- 累计消费
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1168] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end   
    elseif 1366 == v.id then -- 幸运鉴宝
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1169] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif 1374 == v.id then -- 万圣节累计充值
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1170] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif 1375 == v.id then -- 捣蛋南瓜田
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1171] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif 1376 == v.id then -- 双色球
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1175] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end 
    elseif 1400 == v.id then -- 天天返利
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1179] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif 1401 == v.id then --感恩活动
        local data = cache.ActivityCache:get5030111()
        --print("data.acts[5007]",data.acts[1147])
        if  (data.acts[1181] and data.acts[1181] == 1) or
            (data.acts[1182] and data.acts[1182] == 1) or
            (data.acts[1183] and data.acts[1183] == 1) then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end 
     elseif 1420 == v.id then --冬至
        local data = cache.ActivityCache:get5030111()
        --print("data.acts[5007]",data.acts[1147])
        if  (data.acts[1196] and data.acts[1196] == 1) or
            (data.acts[1197] and data.acts[1197] == 1) or
            (data.acts[1198] and data.acts[1198] == 1) then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end  
     elseif 1411 == v.id then --双十二
        local data = cache.ActivityCache:get5030111()
        --print("data.acts[5007]",data.acts[1147])
        if  (data.acts[1193] and data.acts[1193] == 1) or
            (data.acts[1194] and data.acts[1194] == 1) or
            (data.acts[1195] and data.acts[1195] == 1) then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end  
    elseif v.id == 1369 then --万圣狂欢
        self:checkWSKH(v)
        self.teshuid[v.id] = true 
    elseif v.id == 1373 then--降妖除魔
        local endTime =cache.PlayerCache:getRedPointById(20208)
        --持续时间
        local duringTime = conf.WSJConf:getValue("wsj_act_time")
        --活动进入时间，超过时间后无法再进
        local lastTime = conf.WSJConf:getValue("wsj_limit_in_time")
        local openTime = endTime - duringTime
        local severTime = mgr.NetMgr:getServerTime()
        if severTime >= openTime  and severTime <= (openTime+lastTime) then
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            v.btnsee = false
            self.seetable[v.id] = nil 
        end
    elseif 1379 == v.id then -- 脱单领称号
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[3097] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif 1382 == v.id then -- 情侣充值排行
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[5014] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif 1380 == v.id then -- 真假雪人
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1176] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif 1381 == v.id then -- 满减活动
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1177] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif 1399 == v.id then -- 水果
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1180] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif v.id >= 1385 and v.id <= 1397 then
        local ActId = {
            [1385] = 1023,--坐骑进阶大比拼
            [1386] = 1001,--仙羽进阶大比拼
            [1387] = 1002,--神兵进阶大比拼
            [1388] = 1003,--仙器进阶大比拼
            [1389] = 1004,--法宝进阶大比拼
            [1390] = 1005,--伙伴仙羽进阶大比拼
            [1391] = 1006,--伙伴神兵进阶大比拼
            [1392] = 1007,--伙伴仙器进阶大比拼
            [1393] = 1008,--伙伴法宝进阶大比拼
            [1394] = 1091,--神器排行
            [1395] = 1041,--等级排行
            [1396] = 1075,--宠物排行
            [1397] = 1051,--装备排行
        }
        self:checkBtnSeeByActId(v,ActId[v.id])
    elseif v.id == 1383 or v.id == 1384 then--奇门遁甲
        local data = cache.ActivityCache:get5030111()
        if (data.acts[5015] and data.acts[5015] == 1) or
         (data.acts[1178] and data.acts[1178] == 1) then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif 1403 == v.id then -- 幸运锦鲤
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1184] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif 1404 == v.id then -- 天降礼包
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1185] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif v.id == 1406 then----月末狂欢（双倍充值）
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[3098] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end 
    elseif 1409 == v.id then -- 帝魂召唤
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1192] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif 1407 == v.id then -- 帝魂任务
        local isFinish = cache.DiHunCache:getDiHunTaskFinish()--任务奖励全部领取
        local dhInfo = cache.DiHunCache:getDiHunInfoByType(1)--固定雷神
        if dhInfo and  dhInfo.star ~= -1 and isFinish then--已激活且任务奖励全部领取
            v.btnsee = false
            self.seetable[v.id] = nil 
        else
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        end
    elseif v.id == 1413 then --2018圣诞活动
        self:checkShengDan(v)
        self.teshuid[v.id] = true 
    elseif 1418 == v.id then -- 圣诞累充福利(2018)
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1201] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif 1419 == v.id then -- 许愿圣诞树(2018)
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1207] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
     elseif 1423 == v.id then -- 冬至抽奖
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1199] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif 1424 == v.id then -- 冬至连充活动
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1200] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif 1425 == v.id then -- 冬至饺宴
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1208] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif 1430 == v.id then -- 元旦祈福(2018)
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1212] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif v.id == 1431 then --2018元旦
        self:checkYuanDan(v)
        self.teshuid[v.id] = true 
    elseif 1435 == v.id then -- 元旦转盘(2018)
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1213] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif 1436 == v.id then -- 记忆花灯
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1208] == 1 then 
            local var = cache.PlayerCache:getRedPointById(20214) or 0
            if mgr.ModuleMgr:CheckView(v.id) and var > 0 then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif v.id == 1439 or v.id == 1440 then--奇兵降临
        local data = cache.ActivityCache:get5030111()
        if (data.acts[1216] and data.acts[1216] == 1) or
         (data.acts[5016] and data.acts[5016] == 1) then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif v.id == 1446 then--腊八消费（2019）
        local data = cache.ActivityCache:get5030111()
        if (data.acts[1220] and data.acts[1220]==1) then
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end 
    elseif v.id == 1458 then--冰雪节
        local data = cache.ActivityCache:get5030111()
        if (data.acts[1224] and data.acts[1224]==1) or
           (data.acts[1225] and data.acts[1225]==1) or
           (data.acts[1226] and data.acts[1226]==1) or
           (data.acts[1227] and data.acts[1227]==1) then
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end 
    elseif v.id == 1457 then--消费抽抽乐
        local data = cache.ActivityCache:get5030111()
        if (data.acts[1228] and data.acts[1228]==1) then
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end 
     elseif 1449 == v.id then--腊八活动
        local data = cache.ActivityCache:get5030111()
        if  (data.acts[1217] and data.acts[1217] == 1) or
            (data.acts[1218] and data.acts[1218] == 1) or
            (data.acts[1219] and data.acts[1219] == 1) then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
     elseif 1447 == v.id then -- 腊八累抽
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1221] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif 1451 == v.id then--小年活动
        local data = cache.ActivityCache:get5030111()
        if  (data.acts[1229] and data.acts[1229] == 1) or
            (data.acts[1230] and data.acts[1230] == 1) or
            (data.acts[1231] and data.acts[1231] == 1) or
            (data.acts[1232] and data.acts[1232] == 1)  then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif 1459 == v.id then -- 小年祭灶
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1233] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    elseif 1460 == v.id then -- 小年豪礼
        local data = cache.ActivityCache:get5030111()
        if data.acts and data.acts[1234] == 1 then 
            if mgr.ModuleMgr:CheckView(v.id) then
                v.btnsee = true
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil 
            end
        else
            self.seetable[v.id] = nil
        end
    else
        if mgr.ModuleMgr:CheckView(v.id) then
            v.btnsee = true
            self.seetable[v.id] = v
        end    
    end
end

function TopActive:checkBtnSeeByActId(v,actId)
    local data = cache.ActivityCache:get5030111()
    if data.acts and data.acts[actId] == 1 then 
        if mgr.ModuleMgr:CheckView(v.id) then
            v.btnsee = true
            self.seetable[v.id] = v
        else
            v.btnsee = false
            self.seetable[v.id] = nil 
        end
    else
        self.seetable[v.id] = nil
    end
end

function TopActive:getDataById(id)
    -- body

    if id then
        for i,j in pairs(self.confData) do
            if j.id == id then
                return j
            end
        end
    end

    return nil 
end

function TopActive:check1104(param,sign)
    -- body
    local v = self:getDataById(1104)
    if not v then
        return
    end

    if param then
        if mgr.ModuleMgr:CheckView(v.id) and cache.PlayerCache:getRedPointById(30101) == 1 then
            --功能开启了
            local time1104 = UPlayerPrefs.GetString(g_var.accountId .. "1104")
            local flag = true
            local over1104 = UPlayerPrefs.GetString(g_var.accountId .. "over1104")
            if not over1104 or over1104 == "" then
                if time1104 and time1104~="" then
                    local pass = mgr.NetMgr:getServerTime() - tonumber(time1104)
                    if pass >= 20*60 then
                        --超时了
                        flag = false
                    end
                else
                    -- proxy.ActivityProxy:sendMsg(1050403, {reqType = 2})
                    UPlayerPrefs.SetString(g_var.accountId.."1104", mgr.NetMgr:getServerTime().."")
                end
            else
                flag = false
            end
            v.btnsee = flag
            if flag then
                self.seetable[v.id] = v
            else
                v.btnsee = false
                self.seetable[v.id] = nil
            end
        end 
    else
        v.btnsee = false
        self.seetable[v.id] = nil
    end

    if sign then
        self:initBtn()
    end
end

function TopActive:check1054()
    -- body
    local v = self:getDataById(1054)
    if not v then
        return
    end

    v.btnsee = true
        --三档分别显示不同图标
    self.seetable[v.id] = v
    if not GGetFirstChargeState(1) then
        v.icon = "zhujiemian_146"
    elseif not GGetFirstChargeState(2) then
        v.icon = "zhujiemian_148"
    elseif not GGetFirstChargeState(3) then
        v.icon = "zhujiemian_147"
    -- elseif not GGetFirstChargeState(4) then --EVE 注释原因：后三档配置已被删除
    --     v.icon = "zhujiemian_201"
    -- elseif not GGetFirstChargeState(5) then
    --     v.icon = "zhujiemian_201"
    -- elseif not GGetFirstChargeState(6) then
    --     v.icon = "zhujiemian_201"
    elseif GGetFirstChargeState(3) then
        v.btnsee = false
        self.seetable[v.id] = nil
    end

    self:initBtn()
end

function TopActive:checkLuckyAdvance(param)
    local data = cache.ActivityCache:get5030111()
    if not data then
        return false
    end
    local flag = false
    local confData = conf.ActivityConf:getActiveByTimetype(5)
    local actId = nil
    for k ,v in pairs(confData) do
        if v.activity_pos and v.activity_pos == 3 and data.acts[v.id] == 1 then --这个活动开启了
            flag = true
            actId = v.id
            break
        end
    end
    if flag then
        param.btnsee = true
        self.seetable[param.id] = param
        -- if actId == 1108 then
        --     param.icon = "zhujiemian_167"
        -- else
        local var = data.openDay%9
        if var == 0 then var = 9 end
        --print("开服天数",data.openDay,var)
            param.icon = language.kaifu50[var]
        -- end
    else
        param.btnsee = false
        self.seetable[param.id] = nil
    end
    return flag
end

function TopActive:checkOpen()
    -- body
    if not g_is_guide or g_is_banshu  then
        self:initBtn()
        return
    end
   
    for k ,v in pairs(self.confData) do
        self:checkData(v)
    end

    self:initBtn()
end
--检测分包下载是否要有红点
function TopActive:checkRedGift()
    if g_is_banshu then
        return
    end

    local function refresh(visible)
        for _,btn in pairs(self.btnlist) do
            for k,v in pairs(btn) do
                local data = v.data
                if data then
                    local id = data.id
                    if id == DownLoadId then
                        v:GetChild("n4").visible = visible
                        return
                    end
                end
            end
        end
    end

    if mgr.DownloadMgr.isArleayDownload then--分包资源已下载
        if cache.PlayerCache:getDownloadGift() then--还未领取礼包
            refresh(true)
        else
            self:checkBackDown()
        end
    else
        refresh(false)
    end
end
--隐藏分包下载按钮
function TopActive:checkBackDown()
    -- body
    if self.seetable[DownLoadId] then
        self.seetable[DownLoadId] = nil
        self:initBtn()
    end
end

--检测活动
function TopActive:checkActive(id)
    -- body
    if g_is_banshu then
        return
    end
    for k,v in pairs(self.confData) do
        if v.redid then
            -- if v.id == 1373 then
            --     print("111111111",v.id,mgr.ModuleMgr:CheckView(v.id))
            -- end
            if mgr.ModuleMgr:CheckView(v.id) then
                local var 
                if id and id == v.id then
                    var = false
                else
                    var = true
                end
                if v.id == 1053 then --送首充特殊处理   
                    -- print("送首充特殊处理",cache.PlayerCache:getAttribute(30104))
                    if cache.PlayerCache:getAttribute(30104) == 1 then
                        v.btnsee = var
                        self.seetable[v.id] = v
                    else
                        self.seetable[v.id] = nil
                    end
                elseif v.id == 1054 then --再充献礼
                    --换地方了
                elseif v.id == 1057 then --每日一元
                    -- print("每日一元",cache.PlayerCache:getAttribute(30103))
                    if cache.PlayerCache:getAttribute(30103) == 1 then
                        v.btnsee = var
                        self.seetable[v.id] = v
                    else
                        self.seetable[v.id] = nil
                    end
                elseif v.id == 1060 then --元宝复制
                    if cache.PlayerCache:getRedPointById(30101) == 1 then
                        v.btnsee = true
                        self.seetable[v.id] = v

                        --特别的 隐藏任务 
                        --self:check1104(true)
                    else
                        self.seetable[v.id] = nil 

                        --特别的 隐藏任务 
                        --self:check1104(true)  
                    end
                    
                elseif v.id == 1120 then --7天登陆
                    if cache.PlayerCache:getRedPointById(30117) and cache.PlayerCache:getRedPointById(30117) == 1 then
                        v.btnsee = var
                        self.seetable[v.id] = v
                    else
                        self.seetable[v.id] = nil
                    end
                elseif v.id == 1058 then --百倍礼包
                    local data = cache.ActivityCache:get5030111()
                    if data.acts[1027] and data.acts[1027] == 1 then
                        v.btnsee = var
                        self.seetable[v.id] = v
                    else
                        self.seetable[v.id] = nil
                    end
                elseif v.id == 1155 then --寻宝活动
                    local data = cache.ActivityCache:get5030111()
                    if (data.acts[3032] and data.acts[3032] == 1) 
                        or (data.acts[3033] and data.acts[3033] == 1) 
                        or (data.acts[3040] and data.acts[3040] == 1)  
                        or (data.acts[3056] and data.acts[3056] == 1) 
                        or (data.acts[3057] and data.acts[3057] == 1) then
                        v.btnsee = var
                        self.seetable[v.id] = v
                    else
                        self.seetable[v.id] = nil
                    end
                elseif v.id == 1059 then --投资计划
                    if cache.PlayerCache:getAttribute(30105) and cache.PlayerCache:getAttribute(30105) ~= 0 then
                        v.btnsee = var
                        self.seetable[v.id] = v
                    else
                        self.seetable[v.id] = nil
                    end
                elseif v.id == 1114 then
                    --plog(cache.PlayerCache:getRedPointById(v.redid),"v.redid",v.redid)
                    if cache.PlayerCache:getRedPointById(v.redid)>0 then
                        v.btnsee = var
                        self.seetable[v.id] = v
                    else
                        self.seetable[v.id] = nil
                    end
                elseif v.id == 1056 then --每日首充
                    -- if cache.PlayerCache:getRedPointById(v.redid)>0 then
                        v.btnsee = var
                        self.seetable[v.id] = v
                    -- else
                    --     self.seetable[v.id] = nil
                    -- end
                elseif v.id == 1152 then  --EVE 天书奖励领完，入口消失
                    local redVal = cache.PlayerCache:getRedPointById(30127)
                    --print("TTTTTTTTTTTTTTT", redVal)
                    --
                    if mgr.XinShouMgr.guiddata and mgr.XinShouMgr.guiddata.guideid == 1146 then
                        var = false
                    end

                    if redVal == 1 then 
                        self.seetable[v.id] = nil 
                    else
                        v.btnsee = var
                        self.seetable[v.id] = v
                    end
                elseif v.id == 1228 or v.id == 1229 or v.id == 1230 or v.id == 1231 or v.id == 1296 or v.id == 1297 then
                    if cache.PlayerCache:getRedPointById(v.redid) > 0 then
                        -- print("充值消费活动",v.id,v.redid)
                        v.btnsee = var
                        self.seetable[v.id] = v
                    else
                        self.seetable[v.id] = nil
                    end
                
                -- elseif v.id == 1253 then
                --     if cache.PlayerCache:getRedPointById(v.redid) > 0 then
                --         v.btnsee = var
                --         self.seetable[v.id] = v
                --     else
                --         self.seetable[v.id] = nil
                --     end
                elseif v.id == 1316 then--顶部按钮月卡
                    local temp = cache.PlayerCache:getRedPointById(20200)
                    if temp ~= 1 then--没有月卡
                        v.btnsee = var
                        self.seetable[v.id] = v
                    else
                        self.seetable[v.id] = nil
                    end
                elseif 1166 == v.id then--雪地大战
                    local data = cache.ActivityCache:get5030111()
                    local var = cache.PlayerCache:getRedPointById(50120)
                    if (data.acts[1058] and data.acts[1058] == 1) and var > 0 then
                        v.btnsee = true
                        self.seetable[v.id] = v
                    else
                        self.seetable[v.id] = nil
                    end
                elseif 1211 == v.id then--答题
                    local data = cache.ActivityCache:get5030111()
                    local var = cache.PlayerCache:getRedPointById(20166)
                    --print("主界面答题按钮>>>>>>>>>",data.acts[3051],var)
                    if (data.acts[3051] and data.acts[3051] == 1) and var > 0 then
                        v.btnsee = true
                        self.seetable[v.id] = v
                    else
                        self.seetable[v.id] = nil
                    end
                elseif 1373 == v.id then--降妖除魔特殊处理
                    local endTime =cache.PlayerCache:getRedPointById(20208)
                    --持续时间
                    local duringTime = conf.WSJConf:getValue("wsj_act_time")
                    --活动进入时间，超过时间后无法再进
                    local lastTime = conf.WSJConf:getValue("wsj_limit_in_time")
                    local openTime = endTime - duringTime
                    local severTime = mgr.NetMgr:getServerTime()
                    -- print("降妖除魔~~~~~~~~~~~~服务器时间",severTime,"开启时间",openTime,"持续时间",(openTime+lastTime))
                    --提前3秒开， 提前5秒结束
                    if severTime >= (openTime - 3)  and severTime <= (openTime+lastTime-5) then
                        if mgr.ModuleMgr:CheckView(v.id) then
                            v.btnsee = true
                            self.seetable[v.id] = v
                        else
                            v.btnsee = false
                            self.seetable[v.id] = nil 
                        end
                    else
                        v.btnsee = false
                        self.seetable[v.id] = nil 
                    end
                elseif 1405 == v.id then--个人答题活动
                    local var = cache.PlayerCache:getRedPointById(20210)
                    -- print("0000000000000000",var)
                    if var > 0 and mgr.ModuleMgr:CheckView(v.id) then
                        v.btnsee = true
                        self.seetable[v.id] = v
                    else
                        v.btnsee = false
                        self.seetable[v.id] = nil 
                    end
                end
            else
                self.seetable[v.id] = nil
            end
        end
    end
    self:initBtn()
end

--检测开服
function TopActive:checkKaiFu(param)
    -- body
    if g_is_banshu then
        return
    end

    local data = cache.ActivityCache:get5030111()
    if not data then
        return false
    end
    local flag = false

    if param.id == 1028 then
        local confData = conf.ActivityConf:getActiveByTimetype(1)
        local confDataOfSevenDay = conf.ActivityConf:getActiveByTimetype(7)  
        for k,v in pairs(confDataOfSevenDay) do
            if v.id == 1049 then 
                table.insert(confData,v)
            end 
        end

        for k ,v in pairs(confData) do
            if v.activity_pos and v.activity_pos == 1 and data.acts[v.id] == 1 then --这个活动开启了
                flag = true
                break
            end
        end
    elseif param.id == 1102 then
        --plog("data.acts[1019]",data.acts[1019])
        -- if data.acts[1019] == 1 then
        --     flag = true
        -- end
        flag = false--屏蔽婚礼排行
    elseif param.id == 1103 then
        local confData = conf.ActivityConf:getActiveByActPos(4)
        for k ,v in pairs(confData) do
            if data and data.acts[v.id] == 1 then --这个活动开启了
                flag = true
                break
            end
        end
    elseif param.id == 1263 then--合服活动入口
        local confData = conf.ActivityConf:getHefuActData()
        for k ,v in pairs(confData) do
            local var = cache.PlayerCache:getRedPointById(v.redid)
            if data.acts[v.act_id] and data.acts[v.act_id] == 1 or (var and var > 0) then --这个活动开启了
                flag = true
                break
            end
        end
    elseif param.id == 1271 then--开服活动入口
        local confData = conf.ActivityConf:getKaifuActData()
        for k ,v in pairs(confData) do
            local var = cache.PlayerCache:getRedPointById(v.redid)
            if (data.acts[v.act_id] and data.acts[v.act_id] == 1) or (var and var > 0) then --这个活动开启了
                flag = true
                break
            end
        end
    elseif param.id == 1284 then--精彩活动入口
        local confData = conf.ActivityConf:getJingCaiActData()
        for k ,v in pairs(confData) do
            local var = cache.PlayerCache:getRedPointById(v.redid)
            if (data.acts[v.act_id] and data.acts[v.act_id] == 1) or (var and var > 0) then --这个活动开启了
                flag = true
                break
            end
        end
    elseif param.id == 1294 then--
        if data.acts and data.acts[1076] == 1 or data.acts[1077] == 1 then 
            flag = true
        end
    elseif param.id == 1426 then--圣诞庆典(2018)
        local confData = conf.ShengDanConf:getShengDanItem()
        for k ,v in pairs(confData) do
            local var = cache.PlayerCache:getRedPointById(v.redid)
            if (data.acts[v.act_id] and data.acts[v.act_id] == 1) or (var and var > 0) then --这个活动开启了
                flag = true
                break
            end
        end
    elseif param.id == 1427 then--冬至(2018)
        local confData = conf.DongZhiConf:getDongZhiItem()
        for k ,v in pairs(confData) do
            local var = cache.PlayerCache:getRedPointById(v.redid)
            if (data.acts[v.act_id] and data.acts[v.act_id] == 1) or (var and var > 0) then --这个活动开启了
                flag = true
                break
            end
        end
    elseif param.id == 1428 then--活动中心
        local confData = conf.ActivityConf:gethdzxItem()
        for k ,v in pairs(confData) do
            local var = cache.PlayerCache:getRedPointById(v.redid)
            if (data.acts[v.act_id] and data.acts[v.act_id] == 1) or (var and var > 0) then --这个活动开启了
                flag = true
                break
            end
        end
    end
    if flag then
        param.btnsee = true
        self.seetable[param.id] = param     
    end

    return flag
end

--进阶活动列表
function TopActive:checkAdvance( param )
    if g_is_banshu then
        return
    end

    local data = cache.ActivityCache:get5030111()
    if not data then
        return false
    end
    local confData = conf.ActivityConf:getActiveList()

    local flag = false
    for k ,v in pairs(confData) do
        if v.activity_pos and v.activity_pos == 2 and data.acts[v.id] == 1 then --这个活动开启了
            print("开服进阶活动开启了")
            flag = true
            break
        end
    end
    -- flag = false --强制屏蔽该入口
    if flag then
        param.btnsee = true
        print("开服进阶活动>>>>>>>>",data.openDay)
        param.icon = language.kaifu50[data.openDay]
        self.seetable[1092] = param     
    end

    return flag
end

--检测夏日活动
function TopActive:checkSummerAct(param)
    if g_is_banshu then
        return
    end

    local data = cache.ActivityCache:get5030111()
    if not data then
        return false
    end

    local flag = false
    if data.acts[1038] == 1 then
        flag = true
    end
    -- print("夏日活动开启",flag)
    if flag and mgr.ModuleMgr:CheckView(param.id) then
        param.btnsee = true
        self.seetable[1111] = param
    else
        param.btnsee = false
        self.seetable[1111] = nil
    end

    return flag
end

--检测圣诞活动
function TopActive:checkChristmas(param)
    local data = cache.ActivityCache:get5030111()
    if not data then
        return false
    end
    local flag = false
    local confData = conf.ActivityConf:getChristmasList()
    for k ,v in pairs(confData) do
        if data.acts[v.id] == 1 then --这个活动开启了
            flag = true
            break
        end
    end
    -- print("圣诞活动",flag)
    if flag and mgr.ModuleMgr:CheckView(param.id) then
        param.btnsee = true
        self.seetable[1161] = param
    else
        param.btnsee = false
        self.seetable[1161] = nil
    end

    return flag
end
--检测元旦活动
function TopActive:checkYd(param)
    return self:checkActiveOpen(param,conf.ActivityConf:getYdActList(),1164)
end
--周末狂欢
function TopActive:checkWeek(param)
    return self:checkActiveOpen(param,conf.ActivityConf:getWeekActList(),1170)
end
--检测腊八活动
function TopActive:checkLaba(param)
    return self:checkActiveOpen(param,conf.ActivityConf:getLabaActList(),1180)
end
--检测情人节活动
function TopActive:checkValentine(param)
    return self:checkActiveOpen(param, conf.ActivityConf:getValentineActList(),1205)
end
--检测元宵活动
function TopActive:checkLantern(param)
    return self:checkActiveOpen(param, conf.ActivityConf:getLanternActList(),1208)
end

function TopActive:checkTurntable(param)
    return self:checkActiveOpen(param,conf.ActivityConf:getTurntableActList(),param.id)
end
--检测万圣狂欢
function TopActive:checkWSKH(param )
    return self:checkActiveOpen(param,conf.ActivityConf:getWSJActList(),1369)
end
--检测圣诞
function TopActive:checkShengDan(param )
    return self:checkActiveOpen(param,conf.ActivityConf:getShengDanActList(),1413)
end
--检测元旦2018
function TopActive:checkYuanDan(param )
    return self:checkActiveOpen(param,conf.ActivityConf:getYuanDanActList(),1431)
end


--检测活动开关
function TopActive:checkActiveOpen(param,confData,moduleId)
    local data = cache.ActivityCache:get5030111()
    if not data then
        return false
    end
    local flag = false
    for k ,v in pairs(confData) do
        if data.acts[v.id] == 1 then --这个活动开启了
            -- print("v.id",v.id)
            flag = true
            break
        end
    end  
    -- print("标志",flag, mgr.ModuleMgr:CheckView(param.id),param.id)
    if flag and mgr.ModuleMgr:CheckView(param.id) then
        param.btnsee = true
        self.seetable[moduleId] = param
    else
        param.btnsee = false
        self.seetable[moduleId] = nil
    end
    return flag
end

--检测某一条任务完成的时候
function TopActive:chenkOpenById(id,flag)
    -- body
    if g_is_banshu then
        return
    end

    for k ,v in pairs(self.confData) do
        if not self.teshuid[v.id] then
            --不是特别处理的id
            if not self.seetable[v.id] then 
                --按钮不存在的时候
                if mgr.ModuleMgr:CheckView(v.id,id) then
                    v.btnsee = flag
                    self.seetable[v.id] = v 
                end
            elseif self.seetable[v.id] and not self.seetable[v.id].btnsee then
                --按钮存在 并且不可见的时候
                if mgr.ModuleMgr:CheckView(v.id,id) then
                    v.btnsee = flag
                    self.seetable[v.id] = v
                end
            end
        end

        -- if not v.redid and v.id ~=1028 and v.id ~=1092 and v.id ~= 1102 then
        --     if not self.seetable[v.id] then
        --         if mgr.ModuleMgr:CheckView(v.id,id) then
        --             v.btnsee = flag
        --             self.seetable[v.id] = v 
        --         end
        --     elseif self.seetable[v.id] and not self.seetable[v.id].btnsee then
        --         if mgr.ModuleMgr:CheckView(v.id,id) then
        --             v.btnsee = flag
        --             self.seetable[v.id] = v
        --         end
        --     end
        -- end
    end
    self:initBtn()
end


function TopActive:initBydata(btn,data,i)
    if not btn then
        return
    end
    btn.data = data
    if g_ios_test then
        if data.id == 1120 or data.id == 1035 then--七天登录或者福利大厅
            btn.icon = UIPackage.GetItemURL(UICommonResIos ,data.icon)
        end
    elseif data.id == 1334 then--悠讯特权
        if g_var.yx_game_param and g_var.yx_game_param ~= "" then
            local confData = conf.YouXunConf:getPrivilegeConf(g_var.packId)
            if confData then
                btn.icon = UIPackage.GetItemURL("main" ,confData.icon)
            else
                btn.icon = UIPackage.GetItemURL("main" ,"zhujiemian_357")
            end
        end
    else
        if data.id == 1241 then
            local info = cache.ActivityCache:get5030111()
            if (info.acts[1089] and info.acts[1089] == 1) or (info.acts[1090] and info.acts[1090] == 1) then
                btn.icon = UIPackage.GetItemURL("main" ,"zhujiemian_279")
            elseif (info.acts[5003] and info.acts[5003] == 1) then
                btn.icon = UIPackage.GetItemURL("main" ,"zhujiemian_332")
            end
        else
            local actData = cache.ActivityCache:get5030111()
            local mulActList = actData.mulActList--多开活动列表
            local icon = nil
            for k,v in pairs(mulActList) do
                local mulAct = conf.ActivityConf:getMulActById(v)
                if mulAct and mulAct.module_id and mulAct.module_id == data.id then
                    icon = mulAct.main_icon
                    break
                end
            end

            if icon then
                btn.icon = UIPackage.GetItemURL("main" ,icon)
            else
                btn.icon = UIPackage.GetItemURL("main" ,data.icon)
            end
        end
    end
    btn.visible = data.btnsee
    --btn.xy = self.btnpos[i]
    if self.touc[data.id] then
        btn:GetChild("n3").visible = false
    else
        if data.iseffect and data.iseffect == 1  then
            btn:GetChild("n3").visible = true
        else
            btn:GetChild("n3").visible = false
        end  
    end


end


function TopActive:onTimer()
    -- body
    if not self.btnlist then
        return
    end
    for k ,v in pairs(self.btnlist) do
        for i,btn in pairs(v) do 
            local lab = btn:GetChild("n8")
            local bgImg = btn:GetChild("n9")
            lab.text = ""
            lab.visible = true   --EVE 
            bgImg.visible = false
            if btn.data and btn.data.id and tonumber(btn.data.id) == 1104 then
                local time1104 = UPlayerPrefs.GetString(g_var.accountId.."1104")
                if time1104 and time1104 ~="" then
                    local pass = mgr.NetMgr:getServerTime() - tonumber(time1104)
                    local var =  20*60
                    lab.text = GTotimeString3(var - pass)
                    if pass >= var then
                        self.seetable[btn.data.id].btnsee = false
                        self.seetable[btn.data.id] = nil
                        self:initBtn()
                        break
                    end
                end
            elseif btn.data and btn.data.id and tonumber(btn.data.id) == 1273 then
                local overTime = cache.PlayerCache:getRedPointById(30159)
                local var =  overTime - mgr.NetMgr:getServerTime()
                --print(var,"var")
                if var <= 0 then
                    self.seetable[btn.data.id].btnsee = false
                    self.seetable[btn.data.id] = nil
                    self:initBtn()
                else
                    lab.text = GTotimeString(var)
                end
            elseif btn.data and btn.data.id and tonumber(btn.data.id) == 1168 then
                local netTime = mgr.NetMgr:getServerTime()
                local overTime = cache.PlayerCache:getRedPointById(20158)
                local actData = conf.ActivityShowConf:getActDataById(1168)
                local curTime = actData.proceed_time[2] - actData.proceed_time[1]
                local startTime = overTime - curTime - 1
                -- print("当前时间 开启时间",netTime,startTime,overTime)
                if overTime > 0 and netTime < overTime and startTime <= netTime then
                    lab.text = GTotimeString3(overTime - netTime)
                else
                    self.seetable[btn.data.id].btnsee = false
                    self.seetable[btn.data.id] = nil
                    self:initBtn()
                end
            elseif btn.data and btn.data.id and tonumber(btn.data.id) == 1405 then
                local netTime = mgr.NetMgr:getServerTime()
                local overTime = cache.PlayerCache:getRedPointById(20210)
                local actData = conf.ActivityShowConf:getActDataById(1405)
                local curTime = actData.proceed_time[2] - actData.proceed_time[1]
                local startTime = overTime - curTime - 1
                -- print("当前时间 开启时间",netTime,startTime,overTime)
                if overTime > 0 and netTime < overTime and startTime <= netTime then
                    lab.text = GTotimeString3(overTime - netTime)
                else
                    self.seetable[btn.data.id].btnsee = false
                    self.seetable[btn.data.id] = nil
                    self:initBtn()
                end
            elseif btn.data and btn.data.id and tonumber(btn.data.id) == 1327 then
                local netTime = mgr.NetMgr:getServerTime()
                local overTime = cache.PlayerCache:getRedPointById(20202)
                local actData = conf.ActivityShowConf:getActDataById(1327)
                local curTime = actData.proceed_time[2] - actData.proceed_time[1]
                local startTime = overTime - curTime - 1
                -- print("当前时间 开启时间",netTime,startTime,overTime)
                if overTime > 0 and netTime < overTime and startTime <= netTime then
                    lab.text = GTotimeString3(overTime - netTime)
                else
                    self.seetable[btn.data.id].btnsee = false
                    self.seetable[btn.data.id] = nil
                    self:initBtn()
                end
            elseif btn.data and btn.data.id and tonumber(btn.data.id) == 1141 then
                local netTime = mgr.NetMgr:getServerTime()
                local overTime = cache.PlayerCache:getAttribute(50118)
                local confData = conf.MarryConf:getValue("wedding_banquet_time")
                local curTime = confData[1][2] - confData[1][1]
                local startTime = overTime - curTime
                if overTime > 0 and startTime > netTime and startTime - netTime > 0 then
                    lab.text = GTotimeString3(startTime - netTime)
                elseif overTime > 0 and netTime > overTime then
                    self.seetable[btn.data.id].btnsee = false
                    self.seetable[btn.data.id] = nil
                    self:initBtn()
                else
                    lab.text = language.marryiage53
                end
            elseif btn.data and btn.data.id and tonumber(btn.data.id) == 1053 then
                local confdata=conf.VipChargeConf:getVipAwardById(1)
                local time=GgetOnLineTime()
                if confdata.online_time - time > 0 then
                    lab.text = GTotimeString3(confdata.online_time - time)
                else
                    lab.text = ""
                    bgImg.visible = false
                end
            elseif btn.data and btn.data.id and (tonumber(btn.data.id) == 1228 
                                or tonumber(btn.data.id) == 1229 or tonumber(btn.data.id) == 1230 
                                or tonumber(btn.data.id) == 1231 or tonumber(btn.data.id) == 1296
                                or tonumber(btn.data.id) == 1297) then
                local t = {
                    [1228] = 30142,
                    [1229] = 30143,
                    [1230] = 30144,
                    [1231] = 30145,
                    [1296] = 30164,
                    [1297] = 30165,
                }
                local endTime = cache.PlayerCache:getRedPointById(t[tonumber(btn.data.id)])
                local netTime = mgr.NetMgr:getServerTime()
                local var = endTime - netTime
                if var > 0 then
                    lab.text = GTotimeString(var)
                    bgImg.visible = true
                else
                    lab.text = ""
                    bgImg.visible = false
                end
            elseif btn.data and btn.data.id and tonumber(btn.data.id) == 1253 then--充值返利bxp
                local  endTime = cache.PlayerCache:getRedPointById(30156)
                local nowTime = mgr.NetMgr:getServerTime()
                if (endTime - nowTime) > 0 then
                    lab.text = GTotimeString(endTime - nowTime)
                else
                    lab.text = ""
                    bgImg.visible = false
                end
            elseif btn.data and btn.data.id and tonumber(btn.data.id) == 1264 then--摇钱树
                local endTime = cache.PlayerCache:getRedPointById(20186)
                local nowTime = mgr.NetMgr:getServerTime()
                if (endTime - nowTime) > 0 then
                    lab.text = GTotimeString(endTime - nowTime)
                else
                    lab.text = ""
                    bgImg.visible = false
                end
            elseif btn.data and btn.data.id and tonumber(btn.data.id) == 1302 then--疯狂返利2018/8/4
                local endTime = cache.PlayerCache:getRedPointById(30167)
                local nowTime = mgr.NetMgr:getServerTime()
                if (endTime - nowTime) > 0 then
                    lab.text = GTotimeString(endTime - nowTime)
                else
                    lab.text = ""
                    bgImg.visible = false
                end
            elseif btn.data and btn.data.id and tonumber(btn.data.id) == 1333 then--双倍返利
                local endTime = cache.PlayerCache:getRedPointById(30177)
                local nowTime = mgr.NetMgr:getServerTime()
                if (endTime - nowTime) > 0 then
                    bgImg.visible = true
                    lab.text = GTotimeString(endTime - nowTime)
                else
                    lab.text = ""
                    bgImg.visible = false

                    self.seetable[btn.data.id].btnsee = false
                    self.seetable[btn.data.id] = nil
                    self:initBtn()
                end
            elseif btn.data and btn.data.id and tonumber(btn.data.id) == 1166 then--雪地大战
                local endTime = cache.PlayerCache:getRedPointById(50120)
                local nowTime = mgr.NetMgr:getServerTime()
                if (endTime - nowTime) > 0 then
                    bgImg.visible = true
                    lab.text = GTotimeString(endTime - nowTime)
                else
                    cache.PlayerCache:setRedpoint(50120,0)
                    lab.text = ""
                    bgImg.visible = false

                    self.seetable[btn.data.id].btnsee = false
                    self.seetable[btn.data.id] = nil
                    self:initBtn()
                end
            elseif btn.data and btn.data.id and tonumber(btn.data.id) == 1211 then--答题
                local endTime = cache.PlayerCache:getRedPointById(20166)
                local nowTime = mgr.NetMgr:getServerTime()
                if (endTime - nowTime) > 0 then
                    bgImg.visible = true
                    lab.text = GTotimeString(endTime - nowTime)
                else
                    cache.PlayerCache:setRedpoint(20166,0)
                    lab.text = ""
                    bgImg.visible = false

                    self.seetable[btn.data.id].btnsee = false
                    self.seetable[btn.data.id] = nil
                    self:initBtn()
                end
           elseif btn.data and btn.data.id and tonumber(btn.data.id) == 1376 then -- 双色球
                local endTime = cache.PlayerCache:getRedPointById(30225)
                local nowTime = mgr.NetMgr:getServerTime()
                if (endTime - nowTime) > 0 then
                    bgImg.visible = true
                    lab.text = GTotimeString(endTime - nowTime)
                else
                    cache.PlayerCache:setRedpoint(30225,0)
                    lab.text = ""
                    bgImg.visible = false

                    self.seetable[btn.data.id].btnsee = false
                    self.seetable[btn.data.id] = nil
                    self:initBtn()
                end
            elseif btn.data and btn.data.id and tonumber(btn.data.id) == 1407 then -- 帝魂任务
                local endTime = cache.PlayerCache:getRedPointById(30234)
                local nowTime = mgr.NetMgr:getServerTime()
                if (endTime - nowTime) > 0 then
                    bgImg.visible = true
                    lab.text = GTotimeString(endTime - nowTime)
                else
                    local _time = conf.DiHunConf:getValue("dh_task_time")
                    cache.PlayerCache:setRedpoint(30234,endTime +_time)
                    -- lab.text = ""
                    -- bgImg.visible = false
                    -- self.seetable[btn.data.id].btnsee = false
                    -- self.seetable[btn.data.id] = nil
                    self:initBtn()
                end
            else
                lab.text = ""
                bgImg.visible = false
            end
        end
    end
end

function TopActive:initBtn()
    -- body
     --检测完成设置按钮
    local pairs = pairs
    for k ,v in pairs(self.btnlist) do
        for i , j in pairs(v) do
            j.visible = false
            j.data = nil 
        end
    end

    local t = {}
    for k , v in pairs(self.seetable) do
        --print("k",k,v.id)
        table.insert(t,v)
    end 
    --活动提示的排序表--排序最大的才显示提示
    self.hintSort = {}
    for k,v in pairs(t) do--可见的顶部按钮
        if v.hint_sort then
            table.insert(self.hintSort,v.hint_sort)
        end
    end
    table.sort(self.hintSort)
    --plog(table.nums(self.seetable),"self.seetable")
    --设置各个按钮
    table.sort(t,function(a,b)
        -- body
        if a.pos == b.pos then
            return a.sort < b.sort
        else
            return a.pos < b.pos
        end
    end)
    self.isOpenHint = false
    local index = {1,1,1}
    for k ,v in pairs(t) do
        if index[v.pos] <= #self.btnlist[v.pos] then
            local btn = self.btnlist[v.pos][index[v.pos]]
            local i = (v.pos-1)*8 + index[v.pos]
            self:initBydata(btn,v,i)
           
            self:openActiveTitle(btn,v)

            index[v.pos] = index[v.pos] + 1
        else
            local i = 16 + index[3]
            local btn = self.btnlist[3][index[3]]
            self:initBydata(btn,v,i)
            self:openActiveTitle(btn,v)
           
            index[3] = index[3] + 1
        end
    end 
    self:setRedPoint()
    -- mgr.TimerMgr:addTimer(0.5, 1, function()
    --     -- self:openActiveTitle(t)
    -- end)
    
end
--bxp 2018/7/1 新活动需要增加提示
function TopActive:openActiveTitle(btn,data)
    if not btn or not data then return end
    if mgr.SceneMgr:getFirstFlag2() then
        local hintGroup = btn:GetChild("n12")
        hintGroup.visible = false
        local hintBgIcon = btn:GetChild("n10")
        local hintTitleIcon = btn:GetChild("n11")
        local t1 = btn:GetTransition("t1")
      
        -- if data.ishint and data.ishint == 1 and data.hint_sort and  data.hint_sort == self.hintSort[#self.hintSort] then--排序最大的才显示提示
        if data.ishint and data.ishint == 1 and data.hint_sort and  data.hint_sort == math.max(unpack(self.hintSort)) then--排序最大的才显示提示
            local isActOpen = false
            local var = 0
            local actData = cache.ActivityCache:get5030111()
            local openActId
            if data.actid then
                for _,v in pairs(data.actid) do
                    if actData.acts[v] and actData.acts[v] == 1 then 
                        isActOpen = true
                        openActId = v
                        break
                    end
                end
            elseif data.hint_open_redid then
                var = cache.PlayerCache:getRedPointById(data.hint_open_redid)
            end
            if not self.isOpenHint then
                if isActOpen or (var > 0) then
                    local isMulAct = false
                    local mulActConf
                    for _,mulActId in pairs(actData.mulActList) do
                        local mulAct = conf.ActivityConf:getMulActById(mulActId)
                        if mulAct and mulAct.active_id and openActId and mulAct.active_id == openActId then
                            isMulAct = true
                            mulActConf  = mulAct
                        end
                    end
                    self.isOpenHint = true
                    hintGroup.visible = true
                    if isMulAct and mulActConf and mulActConf.act_hint_title and mulActConf.act_hint_bg then--是多开的活动
                        hintBgIcon.url = UIPackage.GetItemURL("main" ,mulActConf.act_hint_bg)
                        hintTitleIcon.url = UIPackage.GetItemURL("main" ,mulActConf.act_hint_title)
                    else
                        hintBgIcon.url = UIPackage.GetItemURL("main" ,data.act_hint_bg)
                        hintTitleIcon.url = UIPackage.GetItemURL("main" ,data.act_hint_title)
                    end
                    self.parent:addTimer(10, 1, function ()
                        hintGroup.visible = false
                        mgr.SceneMgr:setFirstFlag2(false)
                    end)
                end
            end
        end
    end
        

            -- local data = cache.ActivityCache:get5030111()
            -- if (data.acts[5001] and data.acts[5001] == 1 ) then --剑灵出世排行
            --     if mgr.ModuleMgr:CheckView(1269) then
            --         local param = {id = 1269}
            --         mgr.ViewMgr:openView2(ViewName.GuideWSSB, param)
            --     end
            -- elseif (data.acts[3067] and data.acts[3067] == 1 )then --剑灵出世寻宝返还
            --     if mgr.ModuleMgr:CheckView(1270) then
            --         local param = {id = 1270}
            --         mgr.ViewMgr:openView2(ViewName.GuideWSSB, param)
            --     end
            -- elseif (data.acts[3066] and data.acts[3066] == 1 ) then --寻仙探宝
            --     if mgr.ModuleMgr:CheckView(1268) then
            --         local param = {id = 1268}
            --         mgr.ViewMgr:openView2(ViewName.GuideWSSB, param)
            --     end
            -- elseif cache.PlayerCache:getRedPointById(30156) > 0 then--超值返利
            --     if mgr.ModuleMgr:CheckView(1253) then
            --         local param = {id = 1253}
            --         mgr.ViewMgr:openView2(ViewName.GuideWSSB, param)
            --     end
            -- elseif (data.acts[1089] and data.acts[1089] == 1 )or ( data.acts[1090] and data.acts[1090] == 1 ) or (data.acts[5003] and data.acts[5003] == 1 ) then --鲜花榜
            --     if mgr.ModuleMgr:CheckView(1241) then
            --         local param = {id = 1241}
            --         mgr.ViewMgr:openView2(ViewName.GuideWSSB, param)
            --     end
            -- elseif (data.acts[1134] and data.acts[1134] == 1 ) then--疯狂返利2018/08/04
            --     if mgr.ModuleMgr:CheckView(1302) then
            --         local param = {id = 1302}
            --         mgr.ViewMgr:openView2(ViewName.GuideWSSB, param)
            --     end
            -- elseif --[[(data.acts[1106] and data.acts[1106] == 1 ) or]] (data.acts[1092] and data.acts[1092] == 1)then --神器排行
            --     if mgr.ModuleMgr:CheckView(1249) then
            --         local param = {id = 1249}
            --         mgr.ViewMgr:openView2(ViewName.GuideWSSB, param)
            --     end
            -- elseif (data.acts[1112] and data.acts[1112] == 1)then --摇钱树
            --     if mgr.ModuleMgr:CheckView(1264) then
            --         local param = {id = 1264}
            --         mgr.ViewMgr:openView2(ViewName.GuideWSSB, param)
            --     end
            -- elseif (data.acts[3058] and data.acts[3058] == 1 ) or (data.acts[3059] and data.acts[3059] == 1)then --世界杯
            --     if mgr.ModuleMgr:CheckView(1245) then
            --         local param = {id = 1245}
            --         mgr.ViewMgr:openView2(ViewName.GuideWSSB, param)
            --     end
            -- elseif (data.acts[1141] and data.acts[1141] == 1 )then 
            --     if mgr.ModuleMgr:CheckView(1333) then
            --         local param = {id = 1333}
            --         mgr.ViewMgr:openView2(ViewName.GuideWSSB, param)
            --     end
            -- end
        -- mgr.SceneMgr:setFirstFlag2(false)
end

function TopActive:addEffect()
    -- body

    -- for i = 6 , 8 do
    --     local item = self.btnlist[i]
    --     --plog("item",item)
    --     local node = item:GetChild("n5")
    --     local effect = self.parent:addEffect(4020104,node)
    --     effect.LocalPosition = Vector3(node.actualWidth/2,-node.actualHeight/2,500)
    -- end
end

--设置按钮是否可见，并且重新设定位置
function TopActive:setVisible()
    -- body
end


function TopActive:onTopCall(context)
    -- body
    local data = context.sender.data
    
    if not self.touc[data.id] then
        self.touc[data.id] = true
        context.sender:GetChild("n3").visible = false
    end
    if data.id == 1054 then
        if not GGetFirstChargeState(1) then
            GOpenView({id = data.id ,index = 0})
        elseif not GGetFirstChargeState(2) then 
            GOpenView({id = data.id ,index = 1})
        elseif not GGetFirstChargeState(3) then
            GOpenView({id = data.id ,index = 2})
        else
            GOpenView({id = data.id ,index = 0})
        end
    else
        -- print("点击的id",data.id)
        GOpenView({id = data.id})
    end
end

function TopActive:setRedPoint()
    if g_is_banshu then
        return
    end
    -- print("30247>>>>>>>>>>",cache.PlayerCache:getRedPointById(30247))

    for _,btn in pairs(self.btnlist) do
        for k,v in pairs(btn) do
            local data = v.data      
            if data then
                local id = data.id
                local redNum = 0
                if id ~= DownLoadId then
                    if id == 1053 then--在线送首充
                        if g_ios_test then    --EVE 屏蔽送首充
                            break
                        end

                        local confdata=conf.VipChargeConf:getVipAwardById(1)
                        local lv = cache.PlayerCache:getRoleLevel()
                        if lv >= 30 and cache.PlayerCache:getAttribute(30104) == 1 then
                            redNum = 1
                        end
                    elseif id == 1046 then --战场
                        --问鼎战
                        redNum = redNum + cache.WenDingCache:getWendingRedPoint()
                        --仙盟战
                        redNum = redNum + cache.PlayerCache:getRedPointById(attConst.A20133)
                        -- redNum = redNum + cache.PlayerCache:getRedPointById(attConst.A20154)
                        --仙魔战
                        redNum = redNum + cache.XianMoCache:getXianMoRedPoint()
                        --皇陵
                        redNum = redNum + cache.HuanglingCache:getHuanglingRedPoint()
                        --竞技场
                        redNum = redNum + cache.PlayerCache:getRedPointById(50109)
                        --排位赛
                        local t = {attConst.A50121,attConst.A50122,attConst.A50123,attConst.A50124,attConst.A50125,attConst.A50126,attConst.A50127}
                        for _,pwsRedid in pairs(t) do
                            redNum = redNum + cache.PlayerCache:getRedPointById(pwsRedid)
                        end
                        --城战
                        local t = {attConst.A20168,attConst.A20169,attConst.A20204,attConst.A20205}
                        for _,cityRed in pairs(t) do
                            redNum = redNum + cache.PlayerCache:getRedPointById(cityRed)
                        end

                        redNum = redNum +  cache.PlayerCache:getRedPointById(attConst.A50133)
                    elseif id == 1103 then--特惠抢购
                        local confdata = conf.ActivityConf:getTopBtnDataById(id)
                        local data = cache.ActivityCache:get5030111()
                        if data and data.acts[1035] == 1 then --这个活动开启了
                            redNum = redNum + cache.PlayerCache:getRedPointById(attConst.A30109)
                        end   
                    elseif id == 1035 then --EVE 等级礼包
                        -- print("hongdian", redNum,cache.PlayerCache:getRedPointById(20127))
                        if cache.PlayerCache:getRedPointById(20127) ~= 0 then 
                            redNum = redNum + cache.PlayerCache:getRedPointById(20127)
                        end    

                        local confdata = conf.ActivityConf:getTopBtnDataById(id)
                        if confdata.getRedid then
                            for k,v in pairs(confdata.getRedid) do
                                redNum = redNum + cache.PlayerCache:getRedPointById(v)
                                if redNum > 0 then break end
                            end
                        end
                    elseif id == 1290 then--趣味挖矿
                        if cache.PlayerCache:getRedPointById(30160) ~= 0 then 
                            redNum = redNum + cache.PlayerCache:getRedPointById(30160)
                        end
                        local confData = conf.ActivityConf:getConversionList()
                        local flag = false
                        for k,v in pairs(confData) do
                            local mid = v.cost_item[1]
                            local num = v.cost_item[2]
                            local amount = cache.PackCache:getPackDataById(mid).amount
                            if amount >= num then
                                flag = true
                            end
                        end
                        if flag then
                            redNum = redNum + 1
                        end
                    elseif id == 1284 then--精彩活动特殊处理
                        local confdata = conf.ActivityConf:getTopBtnDataById(id)
                        if confdata.getRedid then
                            for k,v in pairs(confdata.getRedid) do
                                local cc = conf.RedPointConf:getDataById(v)
                                if cc and cc.checkmoduleid  then
                                    if mgr.ModuleMgr:CheckView(cc.checkmoduleid) then
                                        redNum = redNum + cache.PlayerCache:getRedPointById(v)
                                    end
                                else
                                    redNum = redNum + cache.PlayerCache:getRedPointById(v)
                                end
                                --redNum = redNum + cache.PlayerCache:getRedPointById(v)
                                if redNum > 0 then break end
                            end
                            local data = cache.ActivityCache:get5030111()
                            if data.acts and data.acts[1117] == 1 then--挖矿活动>>>>转移到精彩活动里面了
                                local confData = conf.ActivityConf:getConversionList()
                                local flag = false
                                for k,v in pairs(confData) do
                                    local mid = v.cost_item[1]
                                    local num = v.cost_item[2]
                                    local amount = cache.PackCache:getPackDataById(mid).amount
                                    if amount >= num then
                                        flag = true
                                    end
                                end
                                if flag then
                                    redNum = redNum + 1
                                end
                            end
                        end
                    elseif id == 1355 then--国庆活动处理
                        local confdata = conf.ActivityConf:getTopBtnDataById(id)
                        if confdata.getRedid then
                            for k,redid in pairs(confdata.getRedid) do
                                local cc = cache.PlayerCache:getRedPointById(redid)
                                redNum = redNum + cc
                            end
                        end
                        local var1 = cache.PlayerCache:getRedPointById(50120)
                        local var2 = cache.PlayerCache:getRedPointById(20166)
                        if var1 > 0 then
                            redNum = redNum + 1
                        end
                        if var2 > 0 then
                            redNum = redNum + 1
                        end
                    elseif id == 1458 then--冰雪节活动
                        local confdata = conf.ActivityConf:getTopBtnDataById(id)
                        if confdata.getRedid then
                            for k,redid in pairs(confdata.getRedid) do
                                local cc = cache.PlayerCache:getRedPointById(redid)
                                redNum = redNum + cc
                            end
                        end
                        local var1 = cache.PlayerCache:getRedPointById(50120)
                        if var1 > 0 then
                            redNum = redNum + 1
                        end
                    elseif id == 1334 then--悠讯特权红点
                        local confData = conf.YouXunConf:getPrivilegeConf(g_var.packId)
                        if g_var.yx_game_param and g_var.yx_game_param ~= "" then
                            if not confData then
								confData = conf.YouXunConf:getPrivilegeConf(1001)
                            end
							for k,tabId in pairs(confData.tab_id) do
								local confD = conf.YouXunConf:getNowListData(tabId)
								for _,rId in pairs(confD.redid) do
									local var = cache.PlayerCache:getRedPointById(rId)
									if var >= 999 then
										var = 0
									end
									redNum = redNum + var
									if redNum > 0 then break end
								end
							end
                        end
                    elseif id == 1369 then--万圣狂欢
                        local confdata = conf.ActivityConf:getTopBtnDataById(id)
                        if confdata.getRedid then
                            for k,redid in pairs(confdata.getRedid) do
                                local cc = cache.PlayerCache:getRedPointById(redid)
                                redNum = redNum + cc
                            end
                        end
                        local endTime =cache.PlayerCache:getRedPointById(20208)
                        --持续时间
                        local duringTime = conf.WSJConf:getValue("wsj_act_time")
                        --活动进入时间，超过时间后无法再进
                        local lastTime = conf.WSJConf:getValue("wsj_limit_in_time")
                        local openTime = endTime - duringTime
                        local severTime = mgr.NetMgr:getServerTime()
                        if severTime >= openTime  and severTime <= (openTime+lastTime) then
                            redNum = redNum + 1
                        end
                    elseif id == 1373 then--降妖除魔有出口就要有红点
                        redNum = redNum + 1
                    else
                        local confdata = conf.ActivityConf:getTopBtnDataById(id)
                        if confdata.getRedid then

                            -- if confdata.id == 1155 then --寻宝
                            --     for k,v in pairs(confdata.getRedid) do
                            --         if v == 30125 then --装备寻宝红点
                            --             if mgr.ModuleMgr:CheckSeeView(1155) then --装备寻宝
                            --                 redNum = redNum + cache.PlayerCache:getRedPointById(v)
                            --                 if redNum > 0 then break end
                            --             end
                            --         elseif v == 30128 then 
                            --             if mgr.ModuleMgr:CheckSeeView(1163) then --进阶寻宝
                            --                 redNum = redNum + cache.PlayerCache:getRedPointById(v)
                            --                 if redNum > 0 then break end
                            --             end
                            --         elseif v == 30135 then 
                            --             if mgr.ModuleMgr:CheckSeeView(1193) then --宠物寻宝
                            --                 redNum = redNum + cache.PlayerCache:getRedPointById(v)
                            --                 if redNum > 0 then break end
                            --             end
                            --         elseif v == 10259 then 
                            --             if mgr.ModuleMgr:CheckSeeView(1217) then --符文寻宝
                            --                 redNum = redNum + cache.PlayerCache:getRedPointById(v)
                            --                 if redNum > 0 then break end
                            --             end
                            --         end
                            --     end 
                            -- else
                                for k,v in pairs(confdata.getRedid) do
                                    local cc = conf.RedPointConf:getDataById(v)
                                    local nn = cache.PlayerCache:getRedPointById(v)
                                    if nn == 999 then
                                        nn = 0
                                    end
                                    if cc and cc.checkmoduleid  then
                                        if mgr.ModuleMgr:CheckView(cc.checkmoduleid) then
                                            redNum = redNum + nn
                                        end
                                    else
                                        redNum = redNum + nn
                                    end
                                    --redNum = redNum + cache.PlayerCache:getRedPointById(v)
                                    if redNum > 0 then break end
                                end
                            -- end
                        end                     
                    end
                    --顶部按钮假显示红点（点击按钮打开界面后置零）
                    if id == 1428 or id == 1263 or id == 1284 or id == 1271 then--活动中心、合服活动、精彩活动、开服活动
                        redNum = redNum + cache.PlayerCache:getActFakeRed(id)
                    end
                    self:setRedVisible(v,redNum)
                else
                    self:checkRedGift()
                end
            else
                self:setRedVisible(v,0)
            end
        end
    end
end
--红点显示
function TopActive:setRedVisible(btn,redNum)
    if g_is_banshu then
        return
    end
    
    local red = btn:GetChild("n4")
    if redNum > 0 then
        red.visible = true
    else
        red.visible = false
    end
end

return TopActive