--沧海镜
--法师类侠客，战斗中会获得x点内伤增加效果，持续x秒，且每次释放大招后，会使自己造成的伤害增加x%，持续x秒，最多叠加x层

---@class Relic_204 : Relic @
---@field super Relic @Relic
local M = class("Relic_204", Relic)

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	--内伤增加效果buf
	self.innerAtkBuf = self:getValue(1)
	--每次释放大招后，会使自己造成的伤害增加x%buff
	self.bigSkillBuf = self:getValue(2)
	self.role_Type = 6
end

function M:gameStart()
	M.super.gameStart(self)
	local data =
	{
		["count"] = "all",
		["camp"] = "friend",
		["pos"] = "not",
		["race"] = "all",
		["roleType"] = self.role_Type,
		["area"] = "all",
	}
	local targets = self.mgr:getTargetData(data)
	if targets == nil then
		return
	end
	for i=1,targets.Count do
		local ply = targets:get(i-1)
		ply.bufMgr:addBufById(self.innerAtkBuf, ply)
	end
end

--技能技术后
function M:skillEnd( player, skillData )
	if player.camp == self.mgr.camp and player.plyData.role_type == self.role_Type and skillData.type == 1 then
		player.bufMgr:addBufById(self.bigSkillBuf, player)
	end
end

return M