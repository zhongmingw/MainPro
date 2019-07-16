--
-- Author: wx
-- Date: 2017-01-17 17:28:36
-- 新手任务
-- Remarks：EVE 颜色14(红)已被修改为颜色5(白)

local MainTask = class("MainTask",import("game.base.Ref"))

function MainTask:ctor(param)
    self.view = param
    self:initView()
end

function MainTask:initView()
    -- body
    self.name = self.view:GetChild("n0")
    self.name.text = ""

    self.progressbar = self.view:GetChild("n1")
    self.progressbar.value = 0
    self.progressbar.max = 0

    --self.progressbarText =  self.view:GetChild("n10")
    --self.progressbarText.text = ""

    self.dec = self.view:GetChild("n4")
    self.dec.text = ""

    self.condtion = self.view:GetChild("n6") 
    self.condtion.text = ""

    local btnGoon = self.view:GetChild("n7") 
    btnGoon.onClick:Add(self.onBtnGoon,self)

    local btnTitle = self.view:GetChild("n9")
    btnTitle.text = language.task07

    local shap = self.view:GetChild("n10") 
    shap.onClick:Add(self.onBtnGoon,self)
    if g_ios_test then
        self.view:GetChild("n12").url = UIItemRes.iosMainIossh.."zhujiemian_185"--任务
    end
end

function MainTask:setData()
    -- body
    self.data = cache.TaskCache:getData()--任务信息
    if not self.data or not next(self.data) then
        return
    end

    local confData = conf.TaskConf:getTaskById(self.data[1].taskId)
    self.name.text = confData.name or ""

    self.dec.text = confData.dec or ""
    
    self.progressbar.value = confData.cur_step-1
    self.progressbar.max = confData.all_step

    if confData.conditions then 
        local str = ""
        for k , v in pairs(confData.conditions) do
            local desc = confData.desc[k]
            --plog("desc=",desc)
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
                                    ss[2] = string.format(ss[2],cache.TaskCache:getextMap(self.data[1].taskId,v[1]))
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
                                ss[2] = string.format(ss[2],cache.TaskCache:getextMap(self.data[1].taskId,v[1]))
                                if tonumber(ss[2])<tonumber(v[2]) then
                                    table.insert(param,{color = 5,text = ss[2]})
                                else
                                    table.insert(param,{color = ss[1],text = ss[2]})
                                end
    
                            elseif 1==confData.task_type then --找npc
                                local npcConf = conf.NpcConf:getNpcById(v[1])
                                ss[2] = string.format(ss[2],npcConf.name)
                                table.insert(param,{color = ss[1],text = ss[2]})
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
        self.condtion.text = str
    else
        self.condtion.text = ""
    end


    --死怪物检测--or 4 == confData.task_type
    -- if  2 == confData.task_type  then
    --     if confData.conditions then
    --         mgr.TaskMgr:isfinish(confData)
    --     end
    -- end
end

function MainTask:onBtnGoon(context)
    -- body
    if not mgr.FubenMgr:checkScen3() then
        return
    end
    --if Time.getTime() - (self.lastTime or 0) < 2 then 
        --GComAlter(language.team66 )
     --   return
    --end

    

    self.lastTime = Time.getTime()

    mgr.TaskMgr:setCurTaskId(self.data[1].taskId)
    mgr.TaskMgr.mState = 2 --设置任务标识
    mgr.TaskMgr:resumeTask() 
end

return MainTask