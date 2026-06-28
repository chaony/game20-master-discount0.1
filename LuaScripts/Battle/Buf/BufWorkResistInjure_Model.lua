--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-02-14 15:38:51
]]

--为队友抵挡伤害
---@class BufWorkResistInjure : BufWork_Model @
---@field super BufWork_Model @BufWork_Model
local M = class("BufWorkResistInjure", BufWork_Model)

return M