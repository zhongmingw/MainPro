--
-- Author: wx
-- Date: 2017-01-06 20:06:37
-- Remarks：EVE 颜色14(红)已被修改为颜色5(白)

local TaskInfoInMain = class("TaskInfoInMain",import("game.base.Ref"))

function TaskInfoInMain:ctor(param)
    self.view = param
    self:initView()
end

function TaskInfoInMain:initView()
    -- body
    self.view:SetVirtual()
    self.view.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.view.numItems = 0
end
--local data = {ljg = true,text1 = "练级谷",text2 = "超高经验挂机升级"}
function TaskInfoInMain:celldata(index,obj)
    -- body
    --第一条任务服务器信息
    local data = self.data[index+1]
    --任务类型
    --plog("data.taskId",data.taskId)
    if g_ios_test then
        obj:GetChild("n11").url = UIItemRes.iosMainIossh.."zhujiemian_185"--任务
    end
    local isLjg = data and data.ljg 
    if isLjg then
        if g_ios_test then
            obj:GetChild("n2").url = UIItemRes.iosMainIossh02[7]
        else
            obj:GetChild("n2").url = UIItemRes.maintaskinfo[7]
        end
        obj:GetChild("n8").text = data.text1
        obj:GetChild("n9").text = data.text2
        obj:GetChild("n10").visible = false
        obj:GetChild("n14").visible = false
        local btnMsg = obj:GetChild("n11")
        btnMsg.data = 998
        btnMsg.onClick:Add(self.onBtnTaskCallBack,self)
        obj:GetChild("n12").visible = false
        obj:GetChild("n13").visible = false
        obj.height = 50
        return
    end
    local confData = conf.TaskConf:getTaskById(data.taskId)--.task_type
    --printt(confData)


    --对应icon
    local typeIcon = obj:GetChild("n2")
    if typeIcon then  --EVE 添加判断条件，防止此处引用空值
        if g_ios_test then
            typeIcon.url = UIItemRes.iosMainIossh02[confData.type] or UIItemRes.iosMainIossh02[1]
        else
            typeIcon.url = UIItemRes.maintaskinfo[confData.type] or UIItemRes.maintaskinfo[1]
        end
    end 
    --名字
    local taskName = obj:GetChild("n8")

    taskName.text = confData.name or ""
    if confData.type == 4 or confData.type == 5 then --日常 or 帮派任务
        local param = {}
        table.insert(param,{text = taskName.text.."(",color = 1 })
        local var = 0
        local max = 0
        if confData.type == 4 then
            var = cache.TaskCache:getdailyFinishCount()
            max = conf.TaskConf:getValue("daily_finish_max")
        else
            var = cache.TaskCache:getgangFinishCount()
            max = conf.TaskConf:getValue("gang_finish_max")
        end
        var = var + 1
        table.insert(param,{text = var,color = 5 })
        table.insert(param,{text = "/"..max..")",color = 1 })
        taskName.text = mgr.TextMgr:getTextByTable(param)
    end

    --
    local dec = obj:GetChild("n9") 
    local dec2 = obj:GetChild("n12") 
    dec2.text = "" 
    local dec3 = obj:GetChild("n13") 
    dec3.text = "" 
    --dec.text = confData.dec or ""
    --plog(confData.trigger_lev,"confData.trigger_lev")
    local falg = true
    if confData and confData.trigger_lev and cache.PlayerCache:getRoleLevel() < confData.trigger_lev  then 
        local str = string.format(language.mian01,confData.trigger_lev)
        dec.text = mgr.TextMgr:getTextColorStr(str, 5) 
        dec2.text = ""
        -- dec3.text = language.task14
        -- local daydata = cache.TaskCache:getdailyTasks()
        -- if daydata and #daydata ~= 0 then
        --     dec3.text = language.task13
        -- end
        dec3.text = language.task13
        falg = false
        obj.height = 70
    else
        obj.height = 50
        if confData.type == 6 then
            dec.text = confData.desc-- mgr.TextMgr:getTextColorStr(confData.desc, 1)
        elseif confData.conditions then 
            local str = ""
            for k , v in pairs(confData.conditions) do
                local desc = confData.desc[k]
                local t = string.split(desc or "","#")
                local param = {}
                if #t > 1 then
                    for i ,var in pairs(t) do
                        local ss = string.split(var,",")
                        if #ss == 2 then
                            if string.find(ss[2],"%%") then
                                if 2==confData.task_type then --杀怪 手机
                                    if i == 2 then
                                        local npcConf = conf.MonsterConf:getInfoById(v[1])
                                        ss[2] = string.format(ss[2],npcConf.name)
                                        table.insert(param,{color = ss[1],text = ss[2]})
                                    elseif i == 3 then
                                        --plog(ss[2],"sss",cache.TaskCache:getextMap(self.data[1].taskId,v[1]))
                                        --plog("self.data[1].taskId.",data.taskId)
                                        ss[2] = string.format(ss[2],cache.TaskCache:getextMap(data.taskId,v[1]))
                                        if tonumber(ss[2])<tonumber(v[2]) then
                                            table.insert(param,{color = 5,text = ss[2]})
                                        else
                                            table.insert(param,{color = ss[1],text = ss[2]})
                                        end
                                    else
                                        --local 
                                        ss[2] = string.format(ss[2],v[2])
                                        table.insert(param,{color = ss[1],text = ss[2]})
                                    end
                                elseif 3 == confData.task_type then 
                                    ss[2] = string.format(ss[2],cache.TaskCache:getextMap(data.taskId,v[1]))
                                    if tonumber(ss[2])<tonumber(v[2]) then
                                        table.insert(param,{color = 5,text = ss[2]})
                                    else
                                        table.insert(param,{color = ss[1],text = ss[2]})
                                    end
                                elseif 1==confData.task_type or  6==confData.task_type then --找npc
                                    local npcConf = conf.NpcConf:getNpcById(v[1])
                                    ss[2] = string.format(ss[2],npcConf.name)
                                    table.insert(param,{color = ss[1],text = ss[2]})
                                elseif confData.task_type == 5  then
                                    if confData.type == 2 then
                                        --支线任务
                                        --print(ss[2],cache.TaskCache:getextMap(data.taskId,v[1]),v[1])
                                        local count = cache.TaskCache:getextMap(data.taskId,v[1])
                                        ss[2] = string.format(ss[2],count)
                                        if tonumber(count)<tonumber(v[2]) then
                                            table.insert(param,{color = 5,text = ss[2]})
                                        else
                                            table.insert(param,{color = ss[1],text = ss[2]})
                                        end
                                    end
                                end
                            else
                                table.insert(param,{color = ss[1],text = ss[2]})
                            end 
                        end
                    end
                    str = mgr.TextMgr:getTextByTable(param)
                else
                    str = desc or ""
                end 

                if k ~= #confData.conditions then
                    str = str .. "\n"
                end  
            end
            dec.text = str
        else
            dec.text = ""
        end
    end
    --如果是支线任务 检测是否完成
    if confData.type == 2 then
        local flag = true
        for k ,v in pairs(confData.conditions) do
            local var = cache.TaskCache:getextMap(data.taskId,v[1])
            if var < v[2] then
                flag = false
                break
            end
        end

        if flag then
            dec.text = mgr.TextMgr:getTextColorStr(language.task15,10)
        end
    end

    

    local btnPos = obj:GetChild("n10")
    btnPos.data = index  
    btnPos.onClick:Add(self.onBtnMsg,self) 

    local btnPos1 = obj:GetChild("n14")
    btnPos1.data = index  
    btnPos1.onClick:Add(self.onBtnMsg,self)

    local btnPos2 = obj:GetChild("n15")   --EVE 扩大n10和n14的点击范围
    btnPos2.data = index  
    btnPos2.onClick:Add(self.onBtnMsg,self)

    if confData.type == 4 or confData.type == 5 or confData.type == 6 then
        btnPos.visible = falg
        btnPos1.visible = falg
    else
        btnPos.visible = false
        btnPos1.visible = false
    end

    local btnMsg = obj:GetChild("n11")
    btnMsg.data = index
    btnMsg.onClick:Add(self.onBtnTaskCallBack,self)

    obj.data = index --当前点击第几条

    --收集或者杀死怪物检测--or 4 == confData.task_type 
    -- if  2 == confData.task_type then
    --     if confData.conditions then
    --         mgr.TaskMgr:isfinish(confData)
    --     end
    -- end
end

function TaskInfoInMain:onBtnTaskCallBack( context )
    -- body
    --plog("aaaa")
    if not mgr.FubenMgr:checkScen3() then
        return
    end
    --if Time.getTime() - (self.lastTime or 0) < 2 then 
        --GComAlter(language.team66 )
       -- return
    --end
    self.lastTime = Time.getTime()

    local cell = context.sender
    if cell.data == 998 then--练级谷
        GOpenView({id = 1025})
        return
    end
    local index = cell.data + 1
    local data = self.data[index]
    local confData = conf.TaskConf:getTaskById(data.taskId)

    --当主线任务等级不够时，要提示玩家升级，此时点击引导升级，或者其他副本玩法。
    if confData.type == 1 and confData.trigger_lev and cache.PlayerCache:getRoleLevel() < confData.trigger_lev  then
        GGuildeLevel()
        return
    end
   -- print("confData.task_type",confData.task_type,confData.type)
    if confData.type == 2 then
        local flag = true
        for k ,v in pairs(confData.conditions) do
            local var = cache.TaskCache:getextMap(data.taskId,v[1])
            if var < v[2] then
                flag = false
                break
            end
        end

        if flag then
            proxy.TaskProxy:send(1050501,{taskId = data.taskId})
            return
        else
            
            if confData.formview and confData.formview [1] then
                --2018/4/9 特别加秘境任务需求变化
                local param = {id = confData.formview[1],childIndex = confData.formview[2]}           
                GOpenView(param)
                return
            elseif confData.task_type == 4 then
                --如果是支线任务
                mgr.FubenMgr:gotoFubenWar(confData.conditions[1][1])
                return
            end
        end
    end

    if data.taskStatu == 2 then --容错 
       -- plog("任务完成了")
        return
    end

    if confData.type == 6 then --商会任务
        local canget = true
        for k , v in pairs(confData.conditions) do
            local itemData = cache.PackCache:getPackDataById(v[1])
            if v[2]>itemData.amount then --不满足
                canget = false
                break
            end
        end
        if canget then
            self:onSeeReward(data)
        else
            self:onSeeReward(data)
            -- GOpenView({id = 1016}) --帮派仓库 
        end
        return 
    end

   
    if not confData.mapid and confData.type == 1 then 
        plog("当前任务所在的mapId没有配置@策划")
        return 
    end


    mgr.TaskMgr.mCurTaskId = data.taskId
    mgr.TaskMgr.mState = 2
    mgr.TaskMgr:resumeTask()
    --mgr.TaskMgr:setCurTaskId(data.taskId)
    --mgr.TaskMgr:startTask()
    --plog("前往目的地")
end

function TaskInfoInMain:onBtnMsg( context )
    -- body
    context:StopPropagation()

    local cell = context.sender
    local index = cell.data + 1
    local data = self.data[index]
    local confData = conf.TaskConf:getTaskById(data.taskId)

    --plog("onBtnMsg")
    self:onSeeReward(data)
end

function TaskInfoInMain:setData()
    -- body
    self.data ={}
    --任务列表
    for k ,v in pairs(cache.TaskCache:getData()) do
        table.insert(self.data,v)
    end
    if not g_ios_test then   --EVE 屏蔽支线、商会、仙盟任务
        
        --日常任务
        for k ,v in pairs(cache.TaskCache:getdailyTasks()) do
            table.insert(self.data,v)
        end

        

        if not g_is_banshu then
            --帮派任务
            for k ,v in pairs(cache.TaskCache:getgangTasks()) do
                table.insert(self.data,v)
            end
            
            --商会任务
            for k ,v in pairs(cache.TaskCache:getshangHuiTasks()) do
                table.insert(self.data,v)
            end
            local _t = cache.TaskCache:getbranchTasks()
            table.sort(_t, function(a,b)
                -- body
                local cca = conf.TaskConf:getTaskById(a.taskId)
                local ccb = conf.TaskConf:getTaskById(b.taskId)
                local aSort = 999
                local bSort = 999
                if not cca or not ccb then
                    print("任务配置和后端对不上")
                else
                    aSort = cca.sort
                    bSort = ccb.sort
                    --支线任务：可领取的放到仙盟任务下方bxp
                    local ccaCon = clone(cca)
                    for k ,v in pairs(ccaCon.conditions) do
                        local var = cache.TaskCache:getextMap(a.taskId,v[1])
                        if var < v[2] then
                            cca.ccaFlag = 0
                            break
                        else
                            cca.ccaFlag = 1
                        end
                    end
                    local ccbCon = clone(ccb)
                    for k ,v in pairs(ccbCon.conditions) do
                        local var = cache.TaskCache:getextMap(b.taskId,v[1])
                        if var < v[2] then
                            ccb.ccbFlag = 0
                            break
                        else
                            ccb.ccbFlag = 1
                        end
                    end
                end

               
                if cca.ccaFlag == ccb.ccbFlag then
                    if aSort == bSort then
                        return a.taskId < b.taskId
                    else
                        return aSort < bSort
                    end
                else
                    return cca.ccaFlag > ccb.ccbFlag 
                end
            end )
            for k ,v in pairs(_t) do
                table.insert(self.data,v)
            end
        end


    end
    -- --练级谷
    -- local ljgLeftTime = cache.PlayerCache:getAttribute(attConst.A10316) or 0
    -- local ljgLv = conf.SysConf:getValue("lianji_lev")
    -- if ljgLeftTime > 0 and cache.PlayerCache:getRoleLevel() >= ljgLv then
    --     local data = {ljg = true,text1 = language.fuben77,text2 = language.fuben78}
    --     table.insert(self.data,data)
    -- end
    self.view.numItems = #self.data
end

function TaskInfoInMain:onSeeReward(data)
    -- body
    local index = tonumber(string.sub(data.taskId,1,1))
    if index  == 4 or index  == 5 then
        mgr.ViewMgr:openView(ViewName.TaskAwardView, function( view )
            -- body
            --self.rewardview = view
            view:setData(data)
        end)
    elseif index == 6 then
        mgr.ViewMgr:openView2(ViewName.TaskSHView, data)
    end
    
end

return TaskInfoInMain