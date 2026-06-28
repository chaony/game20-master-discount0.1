--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-03-10 14:48:58
]]

--迷宫人物巡逻逻辑
---@class AIStatePatrol_Player_MiGong : AIStatePatrol_Player @
---@field super AIStatePatrol_Player @AIStatePatrol_Player
local M = class("AIStatePatrol_Player_MiGong",Battle.AIStatePatrol_Player)

--进入移动状态
function M:enter()
	M.super.enter(self)
	if self.player.followTarget ~= nil then
		self.player.aiEngine:changeState("move")
	end
end

--更新移动状态
function M:update(dt)
	M.super.update(self,dt)
end

--没有敌人的时候的处理
--由父类调用
function M:noEnemy(dt)

end

--退出当前状态
function M:exit()
	M.super.exit(self)
end


return M