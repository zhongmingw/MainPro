--
-- Author: yr
-- Date: 2017-03-03 16:52:02
--

local HttpMgr = class("HttpMgr")

function HttpMgr:ctor()
    self.httpList = {}
end

--请求服务器，获取版本数据
--url=请求链接， delay=请求时间超过则重新链接，
--loop=-1失败后继续链接，>0继续链接次数。func=成功/失败回调
function HttpMgr:http(url, delay, loop, func)
    local t = os.time()
    local www = WWW.New(url)
    table.insert(self.httpList, {http=www, markTime=t, delay=delay, loop=loop, url=url, func=func})

    if not self.timer then
        self.timer = mgr.TimerMgr:addTimer(0.05, -1, function()
            self:update()
        end, "HttpMgr")
    end
end

function HttpMgr:update()
    local len = #self.httpList
    for i=len, 1, -1 do
        local info = self.httpList[i]
        local www = info.http
        local delay = info.delay
        local loop = info.loop
        local markTime = info.markTime
        local url = info.url
        local func = info.func
        if os.time() - markTime > delay or (www.error and www.error~="") then  --失败
            www:Dispose()
            if loop == -1 or loop > 0 then
                www = WWW.New(url)
                info.http = www
                info.markTime = os.time()
                if loop > 0 then
                    info.loop = info.loop - 1
                end
            else
                if func then
                    func("fail", data)
                end
                table.remove(self.httpList, i)
            end
            return
        end
        if www.isDone then  --连接成功
            local data = ""
            if www.text and www.text ~= "" then
                data = json.decode(www.text)
            end
            if func then
                func("success", data)
            end
            www:Dispose()
            table.remove(self.httpList, i)
        end
    end
    if len == 0 and self.timer then
        mgr.TimerMgr:removeTimer(self.timer)
        self.timer = nil
    end
end

-- 登录成功之后保存当前登录账号
-- 升级之后也需要提交等级数据
function HttpMgr:RecordAccSer(data)
    local url_param = "account_id="..g_var.accountId.."&server_id=".. g_var.serverId.."&role_name="
    url_param = url_param .."&channel_id="..g_var.channelId.."&level="..cache.PlayerCache:getRoleLevel()
    local urlSign = GameUtil.Md5String(url_param)
    local url = g_var.record_account_url.."?"..url_param.."&sign="..GameUtil.Md5String(urlSign.."tf2017~#&~@E!gjxy")
    -- print("RecordAccSer:",url)
    self:http(url, 1, 1, nil)
end

--充值返利连接
function HttpMgr:chargeBack()
    --充值返利
    if g_var.chargeBack ~= 0 then
        local param = "account_id="..g_var.accountId.."&role_id="..cache.PlayerCache:getRoleId()
        param = param.."&server_id=".. g_var.serverId.."&server_info="..g_var.socketAddress..":"..g_var.socketPort
        local urlSign = GameUtil.Md5String(param)
        local url = g_var.charge_back_url.."?"..param.."&sign="..GameUtil.Md5String(urlSign.."tf2017~#&~@E!gjxy")
        print("充值返利：", url)
        self:http(url, 1, 1, nil)
        g_var.chargeBack = 0
    end
end

--请求服务器列表
function HttpMgr:requestServerList(inputText,page,callback)
    local curPage = page or 1
    local url = g_var.server_list_url
    --作弊使用
    if g_var.platform_id_bt ~= 0 then
        url = g_var.server_list_url_bt.."?c="..g_var.platform_id_bt
    end
    --当前为版署状态
    if g_is_banshu == true then 
        url = g_var.server_list_url .."?c=98"--98是版署服
    end
    if not page then 
        url = url.."&t=1".."&a="..g_var.accountId
    else
        url = url.."&t=2".."&p="..curPage.."&a="..g_var.accountId
    end
    --渠道id
    local cId = g_var.channelId or 0
    if g_var.channel_bt and g_var.channel_bt ~= 0 then
        cId = g_var.channel_bt
    end
    --包ID
    local arr = string.split(g_var.pack_version, ".")
    local tpid = arr[2]
    url = url.."&packid="..tpid.."&child="..cId.."&tims="..os.time()

    print("请求服务器列表地址："..url)
    self:http(url,5,-1,function(state, data)
        if callback then
            callback(data)
        end
    end)
end



return HttpMgr