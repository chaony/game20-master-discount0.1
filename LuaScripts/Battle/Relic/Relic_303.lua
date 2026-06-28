--智力型武神，在释放大招后，给予自己加速{x}点，怒气回复{y}点
---@class Relic_303 : Relic @
---@field super Relic @Relic
local M = class("Relic_303", Relic)

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	self.bufId = self:getValue(1)
	self.bufId2 = self:getValue(2)
end

function M:gameStart()
	M.super.gameStart(self)
end

--技能技术后
function M:skillEnd( player, skillData )
	if player.camp == self.mgr.camp and player.plyData.type == self.data.hero_type and skillData.anim_name == "skill3" then
		player.bufMgr:addBufById(self.bufId, player)
		player.bufMgr:addBufById(self.bufId2, player)
		self:playEffect(player)
	end
end

return M