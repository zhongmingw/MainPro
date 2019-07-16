--
-- Author: 
-- Date: 2019-01-09 20:14:26
--
local ChunJieConf2019 = class("ChunJieConf2019",base.BaseConf)

function ChunJieConf2019:init()

    self:addConf("cj_showlist")--
    self:addConf("cj_model")--

    self:addConf("cj_login_one")--
    self:addConf("cj_jjgs_task_info")--
    self:addConf("cj_jjgs_task_award")--
    self:addConf("cj_login_two")--
    self:addConf("cj_nnyy_two")--
    self:addConf("cj_exchange_two")--
    self:addConf("cj_login_three")--
    self:addConf("cj_login_four")--
    self:addConf("cj_global")--
    -- self:addConf("cj_model")--
    -- self:addConf("cj_showlist")--
    -- self:addConf("cj_model")--

end
function ChunJieConf2019:getModelData(id)
    return self.cj_model[tostring(id)]
end

function ChunJieConf2019:getShowList(jieduan)
    local data = {}
    for k,v in pairs(self.cj_showlist) do
    print(v.jieduan,jieduan)
        if (v.jieduan == jieduan) or (v.id == 1001) then
            table.insert(data,v)
        end
    end
    printt(data)
    table.sort(data,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    return data
end


--登录有礼1
function ChunJieConf2019:getLoginAwardById1(id)
    return self.cj_login_one[tostring(id)]
end

--登录有礼2
function ChunJieConf2019:getLoginAwardById2(id)
    return self.cj_login_two[tostring(id)]
end

function ChunJieConf2019:getValue(id)
    return self.cj_global[tostring(id)]
end

return ChunJieConf2019