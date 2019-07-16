--
-- Author: yr
-- Date: 2017-06-08 15:37:37
--

local DownloadConf = class("DownloadConf",base.BaseConf)

function DownloadConf:ctor()
    self:addConf("back_res")
end

function DownloadConf:getDownloadInfo()
    if not self.info then
        self.info = {}
        for k, v in pairs(self.back_res) do
            self.info[v.index] = v
        end
    end
    return self.info
end


return DownloadConf