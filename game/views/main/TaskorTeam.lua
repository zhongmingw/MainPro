--
-- Author: 
-- Date: 2017-03-14 16:09:42
--
local MainTask = import(".MainTask") --只有主任务
local TaskInfoIn = import(".TaskInfoInMain") --主界面任务提示
local TeamInfo = import(".TeamInfo") --主界面队伍

local TaskorTeam = class("TaskorTeam",import("game.base.Ref"))

function TaskorTeam:ctor(param)
    self.parent = param
    self:initView()
end

function TaskorTeam:initView()
    -- body
    --便于直接隐藏 整个任务相关或者 组对信息
    self.info = {
        {},
        {},
    } 
    --
    self.c1 = self.parent.view:GetController("c1")
    self.c1.onChanged:Add(self.onController1,self)

    self.c2 = self.parent.view:GetController("c2")
    self.c2.onChanged:Add(self.onController2,self)

    self.c3 = self.parent.view:GetController("c3")

    local btnTaskJiantou = self.parent.view:GetChild("n224")
    btnTaskJiantou.onClick:Add(self.onBtnTaskJiantou,self) 

    --背景
    -- local img = self.parent.view:GetChild("n202")
    -- table.insert(self.info[1],{obj = img,x = img.x})
    -- table.insert(self.info[2],{obj = img,x = img.x})
    --
    self.mainTaskItem = self.parent.view:GetChild("n225")
    table.insert(self.info[1],{obj = self.mainTaskItem,x = self.mainTaskItem.x})

    self.taskItem = self.parent.view:GetChild("n208") 
    table.insert(self.info[1],{obj = self.taskItem,x = self.taskItem.x})

    self.levelList = self.parent.view:GetChild("n311")
    table.insert(self.info[1],{obj = self.levelList,x = self.levelList.x})

    local track = self.parent.view:GetChild("n359")
    table.insert(self.info[1],{obj = track,x = track.x})
    table.insert(self.info[2],{obj = track,x = track.x})
    
    self.teamItem = self.parent.view:GetChild("n209")
    table.insert(self.info[1],{obj = self.teamItem,x = self.teamItem.x})
    table.insert(self.info[2],{obj = self.teamItem,x = self.teamItem.x})
    
    self.zhangChangTrack = self.parent.view:GetChild("n666")
    table.insert(self.info[1],{obj = self.zhangChangTrack,x = self.zhangChangTrack.x})
    table.insert(self.info[2],{obj = self.zhangChangTrack,x = self.zhangChangTrack.x})
    
    self.taskBtn = self.parent.view:GetChild("n207")
    table.insert(self.info[1],{obj = self.taskBtn,x = self.taskBtn.x})

    local btn2 = self.parent.view:GetChild("n206")
    -- btn2.title = "组\n队"
    table.insert(self.info[1],{obj = btn2,x = btn2.x})

    local team = self.parent.view:GetChild("n382")
    table.insert(self.info[1],{obj = team,x = team.x})
    table.insert(self.info[2],{obj = team,x = team.x})

    local team = self.parent.view:GetChild("n383")
    table.insert(self.info[1],{obj = team,x = team.x})
    table.insert(self.info[2],{obj = team,x = team.x})

    local team = self.parent.view:GetChild("n384")
    table.insert(self.info[1],{obj = team,x = team.x})
    table.insert(self.info[2],{obj = team,x = team.x})

    local team = self.parent.view:GetChild("n394")
    team.visible = false
    self.itemjjj = team
    table.insert(self.info[1],{obj = team,x = team.x})
    self.itemObj = self.parent.view:GetChild("n390")
    self.itemObj.onClick:Add(self.onLevelItemCall,self)
    self.title = self.parent.view:GetChild("n393")
    
    self.taskText = self.taskBtn:GetChild("title")
    -- self.taskIcon = self.taskBtn:GetChild("icon")
    -- self.joinBtn = self.parent.view:GetChild("n289")
    -- self.joinBtn.onClick:Add(self.onClickTeam,self)
    -- self.teamBtn = self.parent.view:GetChild("n290")
    -- self.teamBtn.onClick:Add(self.onClickJoin,self)
    --self:onController1()
end

function TaskorTeam:setSelect(index)
    -- body
    if not index then
        index = 1
    end

    if index == self.c1.selectedIndex then
        self:onController1()
    else
        self.c1.selectedIndex = index
    end
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:isLevel(sId) then
        -- self.joinBtn.visible = true
        -- self.teamBtn.visible = true
        if not self.isInitLevel then
            self:initLevelpanel()
            self.taskBtn.icon = UIItemRes.main07[2]
            self.taskBtn.selectedIcon = UIItemRes.main07[1]
        end
        self.isInitLevel = true
        self.parent.view:GetChild("n359").visible = true
        local quitBtn = self.parent.view:GetChild("n359"):GetChild("n312")
        quitBtn.onClick:Add(self.onClickQuitLevel,self)
        --离开按钮显示
    else
        if not g_ios_test then
            self.taskBtn.icon = UIItemRes.main02[1]
            self.taskBtn.selectedIcon = UIItemRes.main02[2]
        end
        self.parent.view:GetChild("n359").visible = false
        --改变背景框大小
        --self.parent.view:GetChild("n202").height = 164
        self.isInitLevel = false
        self:releaseTimer()
        -- self.joinBtn.visible = false
        -- self.teamBtn.visible = false
    end
end

function TaskorTeam:onController1()
    self:setItemMsg()
    if self.c1.selectedIndex == 0 then
        self.mainTaskItem.visible = false
        self.taskItem.visible = false
        self.zhangChangTrack.visible = false
        if not self.teamInfo then
            self.teamInfo = TeamInfo.new(self.teamItem)
        end
        local sId = cache.PlayerCache:getSId()
        if mgr.FubenMgr:isLevel(sId) then
            local isNotTeam = cache.TeamCache:getIsNotTeam()
            if isNotTeam then
                if not mgr.FubenMgr:checkScene() then
                    self.teamInfo:clear()
                end
                -- self.joinBtn.visible = true
                -- self.teamBtn.visible = true
            else
                self.teamInfo:setData()
                -- self.joinBtn.visible = false
                -- self.teamBtn.visible = false
            end
        else
            self.teamInfo:setData()
            -- self.joinBtn.visible = false
            -- self.teamBtn.visible = false
        end
    else
        local view = mgr.ViewMgr:get(ViewName.MainView)
        view:setTeamBtnVisible(false)
        local sId = cache.PlayerCache:getSId()
        if mgr.FubenMgr:isLevel(sId) then
            if self.levelList.visible == false then
                proxy.FubenProxy:send(1025104)
            end
            self.levelList.visible = true
            self.taskItem.visible = false
            self.mainTaskItem.visible = false
        elseif mgr.FubenMgr:isHuangLing(sId) then
            self.taskItem.visible = false
            self.zhangChangTrack.visible = true
        elseif mgr.FubenMgr:checkScene() then
            self.mainTaskItem.visible = false
            self.levelList.visible = false
            self.taskItem.visible = false
        else
            self.levelList.visible = false
            self.taskItem.visible = true
            -- self.taskText.text = language.main01
            -- self.taskIcon.url = UIItemRes.main02[1]
            --plog("cache.TaskCache:isOnlyMain()",cache.TaskCache:isOnlyMain())
            if cache.TaskCache:isOnlyMain() then
                self.mainTaskItem.visible = true
                self.taskItem.visible = false

                if not self.MainTask then
                    self.MainTask = MainTask.new(self.mainTaskItem)
                end
                self.MainTask:setData()
            else
                self.mainTaskItem.visible = false
                self.taskItem.visible = true

                if not self.TaskInfoIn then
                    self.TaskInfoIn = TaskInfoIn.new(self.taskItem)
                end
                self.TaskInfoIn:setData()
            end
            local sId = cache.PlayerCache:getSId()
            if mgr.FubenMgr:isFlameScene(sId) then--仙盟驻地 隐藏
                self.taskItem.visible = false
            end
        end
    end
end

function TaskorTeam:setTaskList()
    if self.TaskInfoIn then
        self.TaskInfoIn:setData()
    end
end
--等级礼包获取
function TaskorTeam:setItemMsg()
    -- body
    if g_ios_test then
        self.itemjjj.visible = false 
        return
    end
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:checkScene() or mgr.FubenMgr:isFlameScene(sId) then
        self.itemjjj.visible = false 
        return
    end
    local level = cache.PlayerCache:getRoleLevel()
    local sysConf = conf.SysConf:getValue("overlevel")
    if not sysConf then
        self.itemjjj.visible = false
        return
    else      
        --EVE 等级上限限制取消
        if level >= sysConf[1] then

        else
            self.itemjjj.visible = false
            return
        end       
    end
    --
    local var = cache.PlayerCache:getRedPointById(attConst.A30130)
    if not var or var == 1 then
        self.itemjjj.visible = false
        return
    end

    --local
    local var = cache.PlayerCache:getRedPointById(attConst.A20153)
    
    if not var or var == 0 then
        --全部领取完成
        self.itemjjj.visible = false
        return
    end

    -- --EVE 红点：20127， 推送剩余可领取次数，为0则领取完毕 
    -- local var2 = cache.PlayerCache:getRedPointById(attConst.A20127)
    -- if not var2 or var2 == 0 then
    --     --全部领取完成
    --     self.itemjjj.visible = false
    --     return
    -- end

    --print(var,var,"var")
    local confdata = conf.ActivityConf:getgetGradePackageDataByid(var)
    if not confdata then
        print("返回数据丢失配置",var)
        return
    end
    
    local _t ={}  
    _t.amount = confdata.icon[2]
    _t.mid = confdata.icon[1]
    _t.bind = confdata.icon[3]
    GSetItemData(self.itemObj,_t,false)
    --
    if  level >= confdata.lev then
        self.title.text = language.gonggong107
    else
        local sss = string.format(language.gonggong108,confdata.lev)
        self.title.text =sss -- mgr.TextMgr:getTextColorStr(sss,14) 
    end

    self.itemjjj.visible = true
end

function TaskorTeam:onLevelItemCall()
    -- body
    GOpenView({id = 1136})
end

--如果升级了刷新一下列表
function TaskorTeam:setLevelTask(oldLv)
    -- body
    --副本的时候不检测
    if mgr.FubenMgr:checkScene() then
        return 
    end

    self:setItemMsg()

    if self.c1.selectedIndex == 1 and (self.taskItem.visible or self.mainTaskItem.visible) then
        local data=cache.TaskCache:getData()--任务信息
        if data and #data > 0 then
            local confData = conf.TaskConf:getTaskById(data[1].taskId)
            if confData.type == 1 and confData.trigger_lev and  oldLv< confData.trigger_lev  then
                if cache.PlayerCache:getRoleLevel()>=confData.trigger_lev then
                    self:onController1() 
                end
            end
        end        
    end
end

function TaskorTeam:onController2()
    -- body
    local width = self.parent.view:GetChild("n208").actualWidth
    if self.c3.selectedIndex == 2 then
        --width = self.parent.view:GetChild("n266").actualWidth + 10
    end
    if self.c2.selectedIndex == 0 then -- 箭头向左
        for k ,v in pairs(self.info[1]) do 
            v.obj:TweenMoveX(v.x,0.3)
        end
    else -- 箭头向右
        for k , v in pairs(self.info[1]) do
            v.obj:TweenMoveX(v.x-width-self.taskBtn.width-200,0.25)  --EVE 添加"-20",原因：皇陵UI没完全缩回去
        end
    end
end

function TaskorTeam:onBtnTaskJiantou()
    -- body
    if self.c2.selectedIndex == 0 then
        self.c2.selectedIndex = 1
    else
        self.c2.selectedIndex = 0
    end
end

function TaskorTeam:gotoWar()
    if mgr.FubenMgr:checkScene() then
        if self.c2.selectedIndex == 1 then
            self.c2.selectedIndex = 0
        end
    end
end
------------------------------练级谷----------------------------------
function TaskorTeam:initLevelpanel()
    self.levelList.numItems = 0
    local url1 = UIPackage.GetItemURL("main" , "TaskItem1")
    local obj = self.levelList:AddItemFromPool(url1)
    local url2 = UIPackage.GetItemURL("main" , "TaskItem2")
    local obj = self.levelList:AddItemFromPool(url2)
    local url3 = UIPackage.GetItemURL("main" , "TaskItem3")
    local obj = self.levelList:AddItemFromPool(url3)
    local url4 = UIPackage.GetItemURL("main" , "TaskItem4")
    local obj = self.levelList:AddItemFromPool(url4)
    -- local url5 = UIPackage.GetItemURL("main" , "TaskItem4")
    -- local obj = self.levelList:AddItemFromPool(url5)
    -- local url6 = UIPackage.GetItemURL("main" , "TaskItem4")
    -- local obj = self.levelList:AddItemFromPool(url6)
    -- local url7 = UIPackage.GetItemURL("main" , "TaskItem5")
    -- local obj = self.levelList:AddItemFromPool(url7)
    -- local url8 = UIPackage.GetItemURL("main" , "TaskItem6")
    -- local obj = self.levelList:AddItemFromPool(url8)
    self.levelList:ScrollToView(0)
end

function TaskorTeam:setLevelData()
    local levelData = cache.FubenCache:getLevelData()
    
    -- self.taskText.text = language.main02
    -- self.taskIcon.url = UIItemRes.main02[2]
    self:setLevelDec()
    self:setLevelAward(levelData.incomeMap)
    self:setTempData()
    -- self.expPlusLeftTime = levelData.expPlusLeftTime
    -- self:setOnefiveData(levelData)
    -- self:setQuitLevel()
end
--当前练级谷几层
function TaskorTeam:setLevelDec()
    if not self.levelList then return end
    local panel = self.levelList:GetChildAt(0)
    if not panel then return end
    local condata = conf.SceneConf:getSceneById(cache.PlayerCache:getSId())
    local text = panel:GetChild("n2")
    if text then
        text.text = condata and condata.name or ""
    end
    local btn = panel:GetChild("n5")
    -- btn.visible = true
    if btn then
        btn.onClick:Add(self.onClickLevelTip,self)
    end
    self:setLevelTime()
end

function TaskorTeam:onClickLevelTip()
    if cache.PlayerCache:VipIsActivate(1) then
        mgr.ViewMgr:openView(ViewName.LevelTipView, function(view)
            view:setData(1)
        end)
    else
        GComAlter(language.vip22)
    end
end
--刷新练级谷时间
function TaskorTeam:setLevelTime()
    self.leftTime = cache.FubenCache:getLevelLeftTime()
    if not self.levelTime then
        --plog("刷新练级谷时间")
        local panel = self.levelList:GetChildAt(0)
        self.levelTime = panel:GetChild("n4")
    end
    if not self.levelTimer then
       -- plog("启动定时器")
        self:onLevelTimer()
        self.levelTimer = self.parent:addTimer(1, -1, handler(self, self.onLevelTimer))
    end
end
--挂机收益
function TaskorTeam:setLevelAward(data)
    self:setLevelTime()
    local panel = self.levelList:GetChildAt(1)
    local awards = GGetLevelAwards(data)
    local listView = panel:GetChild("n16")
    listView.itemRenderer = function(index,obj)
        local awardData = awards[index + 1]

        if awardData.amount > 100000 then  --EVE 特殊处理：练级谷预览面板不显示小数，只取整
            awardData.amount = math.round(awardData.amount/(100000/10))*10000  
        end 

        local itemData = {mid = awardData.mid,amount = awardData.amount,bind = awardData.bind}
        GSetItemData(obj, itemData, true)
    end
    listView.numItems = #awards
end
--特权加成（白银，黄金，钻石）
function TaskorTeam:setTempData()
    local silver = 1
    local gold = 2
    local diamonds = 3
    if self.levelList.numItems < 4 then return end
    local panel1 = self.levelList:GetChildAt(3)--白銀
    local msg1 = panel1:GetChild("n1")
    local msg2 = panel1:GetChild("n3")
    msg1.text = language.fuben51
    msg2.text = language.fuben53
    local desc1 = panel1:GetChild("n6")
    desc1.text = language.vip21[silver]
    local icon = panel1:GetChild("n17")
    icon.url = UIItemRes.temp01[silver]
    local desc2 = panel1:GetChild("n2")
    desc2.x = 60
    local desc3 = panel1:GetChild("n4")
    desc3.x = 60
    local btn = panel1:GetChild("n5")
    btn.onClick:Add(self.onClickGoto,self)
    local expAdd = conf.SysConf:getValue("byxz_exp_add_coef")
    local tqAdd = conf.SysConf:getValue("byxz_tq_add_coef")
    local str1 = mgr.TextMgr:getTextColorStr(expAdd.."%"..language.gonggong10, 7)
    local str2 = mgr.TextMgr:getTextColorStr(tqAdd.."%"..language.gonggong10, 7)
    local str3 = mgr.TextMgr:getTextColorStr(expAdd.."%"..language.gonggong09, 14)
    local str4 = mgr.TextMgr:getTextColorStr(tqAdd.."%"..language.gonggong09, 14)
    local isJh = cache.PlayerCache:VipIsActivate(silver)
    if isJh then
        desc2.text = str1
        desc3.text = str2
        icon.grayed = false
        btn.visible = false
    else
        desc2.text = str3
        desc3.text = str4
        icon.grayed = true
        btn.visible = true
    end

    -- local panel2 = self.levelList:GetChildAt(4)--黄金
    -- local msg1 = panel2:GetChild("n1")
    -- local msg2 = panel2:GetChild("n3")
    -- msg1.text = language.fuben52
    -- msg2.text = ""
    -- local desc1 = panel2:GetChild("n6")
    -- desc1.text = language.vip21[gold]
    -- local icon = panel2:GetChild("n17")
    -- icon.url = UIItemRes.temp01[gold]
    -- local desc2 = panel2:GetChild("n2")
    -- desc2.x = 87
    -- local desc3 = panel2:GetChild("n4")
    -- desc3.x = 87
    -- desc3.text = ""
    -- local btn = panel2:GetChild("n5")
    -- btn.onClick:Add(self.onClickGoto,self)
    -- local isJh = cache.PlayerCache:VipIsActivate(gold)
    -- if isJh then
    --     desc2.text = str1
    --     icon.grayed = false
    --     btn.visible = false
    -- else
    --     desc2.text = str2
    --     icon.grayed = true
    --     btn.visible = true
    -- end
end
--退出练级谷
function TaskorTeam:onClickQuitLevel()
    self:releaseTimer()
    cache.FubenCache:setLevelData(nil)
    mgr.FubenMgr:quitFuben()
end

function TaskorTeam:onClickGoto()
    GOpenView({id = 1050})
end
--1.5倍时间加成
-- function TaskorTeam:setOnefiveData(data)
--     local panel = self.levelList:GetChildAt(4)
--     local desc = panel:GetChild("n6")
--     desc.text = language.fuben50
--     self.timeOnefive = panel:GetChild("n20")
--     local btn = panel:GetChild("n19")
--     btn.onClick:Add(function()
--         mgr.ViewMgr:openView(ViewName.LevelTipView, function(view)
--             view:setData(2)
--         end)
--     end)
-- end

function TaskorTeam:setQuitLevel()
    -- local panel = self.levelList:GetChildAt(5)
    -- local btn = panel:GetChild("n312")
    -- btn.onClick:Add(function()
        --改变背景框大小
        
    -- end)
end

function TaskorTeam:releaseTimer()
    if self.levelTimer then
        self.parent:removeTimer(self.levelTimer)
        self.levelTimer = nil
    end
    self.leftTime = 0
    -- self.expPlusLeftTime = 0
end
--练级谷倒计时
function TaskorTeam:onLevelTimer()
    if self.leftTime <= 0 then
        self:releaseTimer()
        return
    end
    if self.leftTime then
        self.leftTime = self.leftTime - 1
        if self.leftTime <= 0 then
            self.leftTime = 0
        end
        cache.FubenCache:setLevelLeftTime(self.leftTime)
        if self.levelTime then
            self.levelTime.text = GTotimeString(self.leftTime)
        end
    end
    -- self.expPlusLeftTime = self.expPlusLeftTime - 1
    -- if self.expPlusLeftTime <= 0 then
    --     self.expPlusLeftTime = 0
    -- end
    -- cache.FubenCache:setExpPlusLeftTime(self.expPlusLeftTime)
    -- self.timeOnefive.text = GTotimeString(self.expPlusLeftTime)
end

function TaskorTeam:onClickJoin()
    proxy.TeamProxy:send(1300113)
end

function TaskorTeam:onClickTeam()
    mgr.ViewMgr:openView(ViewName.TeamView, function( ... )
    -- body
    end,{index = 1})
end
--跨服组队副本
function TaskorTeam:setKuaFuTeamFuben()
    -- body
    
    
end

function TaskorTeam:refMyTeamData()
    if self.teamInfo then
        self.teamInfo:refMyTeamData()
    end
end


return TaskorTeam