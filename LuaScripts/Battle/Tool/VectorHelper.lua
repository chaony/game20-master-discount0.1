--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-02-19 14:50:47
]]

---@class VectorHelper @
local M = class("VectorHelper")

--让目标对象 target 旋转角度 angle 之后得到的向量
function M:GetRotateAngleVec(target, angle)
    local result = Quaternion.MulVec3(Quaternion.Euler(angle.x, angle.y, angle.z), target);
    return result
end

return M