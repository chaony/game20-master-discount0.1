--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-03-10 14:49:57
]]

--迷宫人物逻辑
---@class AIStateMove_Player_MiGong : AIStateMove_Player @
---@field super AIStateMove_Player @AIStateMove_Player
local M = class("AIStateMove_Player_MiGong",Battle.AIStateMove_Player)

--进入移动状态
function M:enter()
	M.super.enter(self)
end


--更新移动状态
function M:update(dt)
	M.super.update(self,dt)
end


function M:noEnemy(dt)
						
end


--退出当前状态
function M:exit()
	M.super.exit(self)
end

return M