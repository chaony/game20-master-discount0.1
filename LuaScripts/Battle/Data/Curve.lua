--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-03-18 21:04:43
]]

--曲线
---@class Curve @
local M = class("Curve")


function M:setData( out_data )
    self.data = out_data;
end

--定点数
--lerpTime 在 0 ~ 10000之间的 lerp系数
function M:Evaluate( lerpTime )
    --0 ~ 1000
    local key = GlobalTools:Mul( lerpTime, GlobalTools.base1000 );
    key = GlobalTools:ToFloat(key);
    key = math.floor(key);
    return self.data[key];
end

return M;