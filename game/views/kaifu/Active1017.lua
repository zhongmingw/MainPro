
--
-- Author: 
-- Date: 2017-03-29 21:02:07
--

local Active1017 = class("Active1017",import("game.base.Ref"))

function Active1017:ctor(param)
    self.view = param
    self:initView()
end

function Active1017:initView()
    -- body
    self.listView = self.view:GetChild("n2")
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
end
function Active1017:onTimer()
    -- body
end

function Active1017:getDataById(id)
    -- body
    for k ,v in pairs(self.data.openTaskInfos) do
        if v.taskId == id then
            return v 
        end
    end
    local t = {
        taskId = id ,
        process = 0,
        taskStatus = 1,
    }
    return t 
end

function Active1017:celldata(index,obj)
    -- body
    local data = self.confData[index+1]
    local cachedata = self:getDataById(data.id)

    local lab = obj:GetChild("n4")
    lab.text = index + 1

    local labdec = obj:GetChild("n6")
    local str = {
        {text = data.name.."(",color = 6}
    }
    local t = {text = cachedata.process}
    if cachedata.process < data.finish_value then
        t.color = 14
    else
        t.color = 7
    end
    table.insert(str,t)
    table.insert(str,{text = "/"..data.finish_value..")",color = 6})
    labdec.text = mgr.TextMgr:getTextByTable(str)

    --奖励
    for i = 1 , 2 do
        local itemObj =  obj:GetChild("n"..i)
        if data.awards and data.awards[i] then
            itemObj.visible = true
            local t = {mid = data.awards[i][1],amount = data.awards[i][2]
            ,bind = data.awards[i][3]}
            GSetItemData(itemObj,t,true)
        else
            itemObj.visible = false
        end
    end


    local btn = obj:GetChild("n3")
    btn.onClick:Add(self.onget,self)
    btn.data = data

    local c1 = obj:GetController("c1")
    c1.selectedIndex = cachedata.taskStatus - 1
end

function Active1017:onget(context)
    local data = context.sender.data
    local cachedata = self:getDataById(data.id)
    if cachedata.taskStatus == 1 then
        GComAlter(language.kaifu09)
        return
    elseif cachedata.taskStatus == 3 then
        return
    end
    local param = {reqType = 1 ,taskId = data.id }
    proxy.ActivityProxy:sendMsg(1030117,param)
end

function Active1017:setCurId(id)
    -- body
    self.id = id 
    --按天数获取配置
    --self.condata = conf.ActivityConf:getOpenTask()
end

function Active1017:setOpenDay( day )
    -- body
    self.openday = day
end

function Active1017:add5030117(data)
    -- body
    self.data = data

    self.confData = conf.ActivityConf:getOpenTask(self.openday)

    table.sort(self.confData,function(a,b)
        -- body
        local ta = self:getDataById(a.id)
        local tb = self:getDataById(b.id)

        local astatue = ta.taskStatus
        local bstatue = tb.taskStatus

        if astatue == 2 then
            astatue = 0
        end

        if bstatue == 2 then
            bstatue = 0
        end


        if astatue == bstatue then
            return a.id < b.id 
        else
            return astatue < bstatue
        end
    end)


    self.listView.numItems = #self.confData

end


return Active1017