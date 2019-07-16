--[[--
  相关计算
]]

local GMath = {}

--获取两点间的距离
function GMath.distance(a, b)
    return Vector3.Distance(a, b)
end

--获取主角前方的距离点
function GMath.roleFrontDistance(dis)
    local role = UnityObjMgr.Role
    local p = role.MapPosition + role.Direction * dis
    return p
end

--获取方向的距离点
function GMath.dirDistance( a, b, d)
    local dir = (b - a).normalized
    local p = a + dir * d
    return p
end

function GMath.dirDistanceB(a,b,d)
    local dir = (b-a).normalized
    local p = b + dir*d
    return p
end

function GMath.restPosition(point)
    local x = point.x
    local y = point.z
    local vx = x - x%30 + 15
    local vy = y - y%30 + 15
    local vec = Vector3.New(vx,gRolePoz,vy)
    if UnityMap:CheckCanWalk(vec) then
        return vec
    end
end

return GMath