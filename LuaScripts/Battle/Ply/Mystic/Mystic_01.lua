-- 催心掌，五雷真决，八段锦

--每次普攻削弱敌方攻击力2%，暴击值3，攻击力最多削弱40%，暴击值最多削弱90，并且在每次普攻的同时恢复自身2%的血量，削弱时间叠加到战斗结束（如果3秒之再受到普攻效果就叠加，多个侠客装备也会叠加）；

---@class Mystic_01 : Mystic
---@field super Mystic
local M = class("Mystic_01", Mystic)

function M:init(mgr, mysticCfg, mysticBufCfg)
	M.super.init(self, mgr, mysticCfg, mysticBufCfg)

	self.addBuff1 = self:getParam(1, 0)	--Buff[] 给目标加debuff
	self.addBuff2 = self:getParam(2, 0)	--Buff[] 给自己加buff
end

---@param ply PlayerModel
---@param skill SkillDataConfig
function M:skillStart(ply, skill)
	if skill.type == 2 then	-- 普攻
		self.player.bufMgr:addBufById(self.addBuff2, self.player)
	end
end

function M:attackOver(victim, killer, wantdata, attackData)
	if attackData.skillConfig and attackData.skillConfig.type == 2 then
		victim.bufMgr:addBufById(self.addBuff1, self.player)
	end
end

return M