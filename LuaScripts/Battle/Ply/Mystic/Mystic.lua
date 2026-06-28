---@class Mystic 秘籍基类
---@field mgr MysticManager_Model
---@field player PlayerModel
---@field mysticCfg ConfigMystic
---@field data ConfigMysticBuff
local M = class("Mystic")

---@param mgr MysticManager_Model
---@param mysticCfg ConfigMystic
---@param mysticBufCfg ConfigMysticBuff
function M:init(mgr, mysticCfg, mysticBufCfg)
	self.player = mgr.player
	self.data = mysticBufCfg
	self.mysticCfg = mysticCfg
	self.mgr = mgr
	self.param = self.data.param
	self.condition_param = self.data.condition_param
end

--自己出生
function M:spawn()
	
end

--出生结束
function M:spawnFinish()

end


-- 技能开始
---@param ply PlayerModel
---@param skill SkillDataConfig
function M:skillStart(ply, skill)
end

-- 技能结束
---@param ply PlayerModel
---@param skill SkillDataConfig
function M:skillEnd(ply, skill)
end

-- 攻击结束时
---@param victim PlayerModel
---@param killer PlayerModel
---@param wantdata Battle_BeHitDirectData_WantData
-----@param attackData Battle_AttackData
function M:attackOver(victim, killer, wantdata, attackData)
end

-- 获取参数
function M:getParam(index, default)
	default = default or 0
	return self.param[index] or default
end

-- 获取参数
function M:getConditionParam(index)
	return self.condition_param[index]
end

-- 获取参数
function M:getConditionData(index, key, default)
	local conditions = self:getConditionParam(1)
	if conditions then
		for i, v in ipairs(conditions) do
			if v[1] == key then
				return v[2] or default
			end
		end
	end
	return default
end

function M:destroy()
	self.mysticCfg = nil
	self.data = nil
	self.mgr = nil
	self.param = nil
end

return M