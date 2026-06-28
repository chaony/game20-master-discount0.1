--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-02-18 09:53:57
]]

--挂机玩家的攻击
---@class AIStatePatrol_Player_TianJi : AIStatePatrol_Player @
---@field super AIStatePatrol_Player @AIStatePatrol_Player
local M = class("AIStatePatrol_Player_TianJi",Battle.AIStatePatrol_Player)

--进入状态
function M:enter()
	M.super.enter(self)
end

--更新状态
function M:update(dt)
	--Logger.log( self.player.plyType.." 无敌人 进入到 移动状态 ")
	if self.player.camp == 1 then
		--场景导航 不是空
		if self.player.plyMgr.scene ~= nil then
			--我要追的点
			local point = self.player.plyMgr.scene:getPathPosition(self.player.index,self.player.tianjilou_move_index);
			if point ~= nil then
				--我和要追的点的距离
				self.player.aiEngine:changeState("move")
			end 
		end
	end	
end


--退出当前状态
function M:exit()
	M.super.exit(self)
end


return M