--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-02-18 09:49:30
]]

---@class AIStateMove_Player_TianJi : AIStateMove_Player @
---@field super AIStateMove_Player @AIStateMove_Player
local M = class("AIStateMove_Player_TianJi",Battle.AIStateMove_Player)

--进入移动状态
function M:enter()
	M.super.enter(self)
	self.player:lockEnemy(nil);
end


--更新移动状态
function M:update(dt)
	M.super.update(self,dt)
	if self.player.camp == 1 then
		local point = self.player.plyMgr.scene:getPathPosition(self.player.index, self.player.tianjilou_move_index)
		if point ~= nil then
			--我和要追的点的距离
			local distance = GlobalTools:Distance3D(point, self.player.position)
			if distance > GlobalTools:ToFix2(1) then
				local dir = GlobalTools:Dir3D(point, self.player.position)
				--玩家移动
				self.player:move_no_coillder(dir,dt)
				dir.y = 0;
				--self.player:rotaTo(dir,dt)
			else
				
				self.player.tianjilou_move_index = self.player.tianjilou_move_index + 1;
			end
		else
			--切换到巡逻
			self.player.aiEngine:changeState("patrol")
		end
	end		
end

function M:noEnemy(dt)
	--没有找到敌人
	--场景导航不是空
	--只有英雄会走这个逻辑
	--敌人不走 
	--挂机AI中独有的逻辑
							
end


--退出当前状态
function M:exit()
	M.super.exit(self)
end


return M