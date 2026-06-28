--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-01-19 16:09:28
]]

--定点数
---@class FixNum @
local M = class("FixNum")

--装换后的值
M.value = 0


function M:init( value )
    self.value = GlobalTools:ToFix(value)
end

--[[
    @desc: 加法运算
    author:{author}
    time:2020-01-19 16:41:39
    --@fixNum: 
    @return:
]]
function M:add( fixNum )
    self.value = self.value + fixNum.value
end

--[[
    @desc: 减法运算
    author:{author}
    time:2020-01-19 16:42:34
    @return:
]]
function M:sub( fixNum )
    self.value = self.value - fixNum.value
end

--[[
    @desc: 乘法运算
    author:{author}
    time:2020-01-19 16:43:20
    --@fixNum: 
    @return:
]]
function M:mul( fixNum )
    self.value = self.value * fixNum.value
end

--[[
    @desc: 除法运算
    author:{author}
    time:2020-01-19 16:43:20
    --@fixNum: 
    @return:
]]
function M:div( fixNum )
    self.value = self.value / fixNum.value
end


--[[
    @desc: 返回float值
    author:{author}
    time:2020-01-19 16:51:03
    @return:
]]
function M:toFloat()
    return GlobalTools:ToFloat(self.value)
end

return M