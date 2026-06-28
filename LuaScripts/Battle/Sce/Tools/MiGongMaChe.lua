--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-02-17 19:45:55
]]


---@class MiGongMaChe @
local M = class("MiGongMaChe")

M.player = nil
function M:init(player)
    self.player = player
    if self.player.animator ~= nil then
       self.player.animator:changeState("idle")
    end
end


function M:PlayRun(name)
    if self.player.animator ~= nil then
       self.player.animator:changeState(name)
    end
end

--更新
function M:update(dt,unsdt)


end


return M

