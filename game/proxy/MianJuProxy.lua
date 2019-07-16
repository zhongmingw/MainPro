--
-- Author: 
-- Date: 2018-12-03 12:35:06
--

local MianJuProxy = class("MianJuProxy", base.BaseProxy)

function MianJuProxy:init()
    self:add(5630101,self.add5630101)-- 请求面具信息
     self:add(5630102,self.add5630102)--请求面具升级
    self:add(5630103,self.add5630103)--请求使用成长丹
    self:add(5630104,self.add5630104)-- 请求面具升星
    self:add(5630105,self.add5630105)-- 请求幻化
    self:add(5630106,self.add5630106)-- 请求附魔
    self:add(8240207,self.add8240207)-- 面具系统战力广播


end

function MianJuProxy:sendMsg(msgId, param)
    self.param = param
    self:send(msgId,param)
end



--请求面具信息
function MianJuProxy:add5630101(data)
    if data.status == 0 then
      
        cache.MianJuCache:setData(data)
        local view = mgr.ViewMgr:get(ViewName.ShenQiView)
        if view then
            view:setMianJuData(data)
        end
       
    else
        GComErrorMsg(data.status)
    end
end

--请求使用成长丹
function MianJuProxy:add5630103(data)
    if data.status == 0 then
        cache.MianJuCache:refreshGrowInfo(data)
        local view = mgr.ViewMgr:get(ViewName.ShenQiView)
        if view and view.MianJuPanel then
            view.MianJuPanel:returnChengZhangDan(data)
        end
       
    else
        GComErrorMsg(data.status)
    end
end


--请求面具升级
function MianJuProxy:add5630102(data)
    if data.status == 0 then
        printt("面具升级返回",data)
        cache.MianJuCache:refreshMianJuLvData(data)
        local view = mgr.ViewMgr:get(ViewName.ShenQiView)

        if view and view.MianJuPanel then
            view.MianJuPanel:updateMianJuLevel(data)
        end

    else
        GComErrorMsg(data.status)
    end
end

--请求面具升星
function MianJuProxy:add5630104(data)
    if data.status == 0 then
        cache.MianJuCache:refreshMianJuData(data.maskInfo)
        local view1 = mgr.ViewMgr:get(ViewName.ShenQiView) -- 更新原界面数据
        if view1 and view1.MianJuPanel then
            view1.MianJuPanel:addMsgCallBack(data)
        end
        local view2 = mgr.ViewMgr:get(ViewName.MianJuShengXinAndFuMoView) -- 更新升星界面
        if view2 then
            view2:refreshStartView()
        end

    else
        GComErrorMsg(data.status)
    end
end

--请求面具幻化
function MianJuProxy:add5630105(data)
    if data.status == 0 then -- 
        local view = mgr.ViewMgr:get(ViewName.ShenQiView)
        if view and view.MianJuPanel then
            print("面具幻化")
            view.MianJuPanel:addMsgCallBack(data)
            view.MianJuPanel:updateAllList(view.MianJuPanel.index)
        --     local data = view.MianJuPanel.MianJusubData
        --     for k,v in pairs(data) do
        --         print(k,v)
        --     end
        end

    else
        GComErrorMsg(data.status)
    end
end


--请求面具附魔
function MianJuProxy:add5630106(data)
    if data.status == 0 then -- 
        local data1 = cache.MianJuCache:getMianJuChooseData() --更新附魔界面数据
      
        
        data1.fmLevel = data.maskInfo.fmLevel
        data1.elements = data.maskInfo.elements
        data1.power = data.maskInfo.power
  
        cache.MianJuCache:setMianJuChooseData(data1)
        cache.MianJuCache:refreshMianJuData(data.maskInfo)
        local view = mgr.ViewMgr:get(ViewName.ShenQiView)
        if view and view.MianJuPanel then
            view.MianJuPanel:returnFuMo(data)
            -- print("附魔返回")
        end
         local view = mgr.ViewMgr:get(ViewName.MianJuShengXinAndFuMoView)
        if view  then
            view:refreshFumoView()
        end

    else
        GComErrorMsg(data.status)
    end
end

--面具战力广播
function MianJuProxy:add8240207(data)
    print("面具战力广播")
      local view = mgr.ViewMgr:get(ViewName.ShenQiView)
        if view and view.MianJuPanel then
            for k,v in pairs(data.typePower) do
                view.MianJuPanel.power[k] = v
             local chooseData = cache.MianJuCache:getMianJuChooseData()
            end
            for k,v in pairs(view.MianJuPanel.maskSunInfos) do
                for k1,v1 in pairs(data.maskPower) do
                    if k1 == v.id then
                        v.power = v1
                    end
                    if chooseData and chooseData.id == k1 then
                        chooseData.power = v1
                        cache.MianJuCache:setMianJuChooseData(chooseData)
                    end
                end
            end
       
            view.MianJuPanel:RefreshPower()
           
        end
end

-- --请求面具升星
-- function MianJuProxy:add5630104(data)
--     if data.status == 0 then -- 
--         local view = mgr.ViewMgr:get(ViewName.MianJuShengXinAndFuMoView)
--         if view  then
--             local data1 = cache.MianJuCache:getMianJuChooseData() --更新升星界面数据
--             data1.starNum = data.maskInfo.starNum
--             data1.power = data.maskInfo.power
          
--             cache.MianJuCache:setMianJuChooseData(data1)
--             view:refreshStartView()
--         end

--     else
--         GComErrorMsg(data.status)
--     end
-- end

return MianJuProxy