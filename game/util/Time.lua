--
-- Author: yr
-- Date: 2017-06-01 17:25:25
--

local Time = {}
local socket = require "socket"

function Time.getTime()
    return socket.gettime()
end

return Time