--
-- Author: ohf
-- Date: 2017-03-27 12:06:05
--
--更新公告
local NoticePanel = class("NoticePanel",import("game.base.Ref"))

function NoticePanel:ctor(mParent,panelObj)
    self.mParent = mParent
    self.panelObj = panelObj
    self:initPanel()
end

function NoticePanel:initPanel()

end

function NoticePanel:setData(data)
    -- body
    local title = data.title
    local content = data.content
    self.panelObj:GetChild("n3").text = title
    local textPanel = self.panelObj:GetChild("n6")
    textPanel:GetChild("n0").text = content
end

function NoticePanel:sendMsg()
    mgr.HttpMgr:http(g_var.gonggao_url, 10, 10, function(state, data)
        self:setData(data)
    end)
end

function NoticePanel:setVisible(visible)
    self.panelObj.visible = visible
end

return NoticePanel