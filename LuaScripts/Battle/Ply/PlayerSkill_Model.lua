---@class PlayerSkill_Model @玩家的技能管理器
---@field player PlayerModel
---@field skill_items Battle_List<PlayerSkillItem>
local M = class("PlayerSkill_Model")

--数据
M.data = nil

--玩家
M.player = nil

--技能item
M.skill_items = nil

--技能数量
M.skillCount = 0

--角色技能数据
M.skillData = nil

--可以使用的技能数组
M.canUseSkillList = nil

--技能初始化
function M:init( player, data, serverData, refresh )
	--数据模型
	--{
	--	 "1":111,
	--	 "5":151
	--},
	--人物model
	self.player = player
	--当前技能的类型 Model or View
	self.type = type;
	--英雄身上所带的技能数据
	self.data = data
	--服务器传来的技能数据
	if serverData ~= nil then
		self.data = serverData
	end
	--技能更新时间
	self.skill_update_time = GlobalTools.base0_2
	--当前技能更新时间
	self.cur_skill_update_time = GlobalTools.base0;
	--刷新技能
	self:refreshSkill( serverData, refresh )
end

--创建技能数据
function M:refreshSkill( serverData, refresh )
	--存放技能数据的
	if self.skill_items == nil then
		self.skill_items = Battle.List.new()
	else
		for i = 1, self.skill_items.Count do
			local skill = self.skill_items:get(i - 1)
			skill:destroy()
		end
		self.skill_items:clear()
	end
	
	for i = 1, 6 do
		local data_item = self.data[tostring(i)] or  self.data[i]
		local itemCls = require("Battle.Ply.PlayerSkillItem")
		local itemIns = itemCls.new()
		if data_item ~= nil then
			if serverData ~= nil then
				itemIns:init(self.player, nil, data_item )
			else
				itemIns:init(self.player, data_item, nil)
			end
			self.skill_items:add( itemIns )
			if refresh == true and itemIns.cur_skill_config ~= nil and itemIns.cur_skill_config.feature ~= nil then
				itemIns.cur_skill_config.feature:initFinish()
			end
		end
	end
	
	--当前可用的技能数据
	if self.canUseSkillList == nil then
		self.canUseSkillList = Battle.List.new()
	else
		self.canUseSkillList:clear()
	end
	--根据优先级排序
	for f = 1,5 do
		for i=self.skill_items.Count,1,-1 do
			--获取到技能item
			local skill_item = self.skill_items:get(i-1)
			if skill_item ~= nil then
				local skillConfig = skill_item:getSkillConfig()
				if skillConfig ~= nil then
					local priority = skillConfig.priority
					if priority == f then
						self.canUseSkillList:add(skill_item)
					end
				end
			end
		end
	end
end

--获取优先级最高的并且 可以使用的技能
function M:getCanUseMostPriority()
	for i=1,self.canUseSkillList.Count,1 do
		--获取到技能item
		local skill_item = self.canUseSkillList:get(i-1)
		if skill_item ~= nil and skill_item:canUse() then
			return skill_item:getSkillConfig()
		end
	end
end

--检测开场技
function M:checkOpening()
	for i = 1, self.skill_items.Count do
		local skill_item = self.skill_items:get(i-1)
		if skill_item ~= nil then
			local config = skill_item.cur_skill_config
			if config ~= nil and config.is_opening == true then
				return true
			end
		end
		
	end
	return false
end


--获取玩家技能
function M:getSkill( skillId )
	return self.skill_items:get(skillId)
end

--通过名字获取技能
---@return PlayerSkillItem
function M:getSkillByName( skill_name )
	for i = 1, self.skill_items.Count do
		local skill_item = self.skill_items:get(i-1)
		if skill_item ~= nil and skill_item.cur_skill_config ~= nil and skill_item.cur_skill_config.anim_name == skill_name then
			return skill_item
		end
	end
	return nil
end

--锁定技能
--skill_list = {"attack1", "skill1"}
function M:lockSkill( skill_list )
	for i = 1, self.skill_items.Count do
		local skill_item = self.skill_items:get(i-1)
		if skill_item ~= nil and skill_item.cur_skill_config ~= nil then
			skill_item.cur_skill_config.lock = table.indexof(skill_list, skill_item.cur_skill_config.anim_name) == false
		end
	end
end

--更新技能
function M:update(dt,unsdt)
	self.cur_skill_update_time = self.cur_skill_update_time + dt;
	if self.cur_skill_update_time > self.skill_update_time then
		--获取当前优先级最高的技能
		for i=1,self.skill_items.Count,1 do
			local skill_item = self.skill_items:get(i - 1)
			if skill_item ~= nil then
				skill_item:update(self.skill_update_time,unsdt)
			end
		end
		self.cur_skill_update_time = self.cur_skill_update_time - self.skill_update_time
	end
end

--作为攻击者的属性临时调整
function M:killerDataChangeTemp(victim, skill)
	for i = 1, self.skill_items.Count do
		local skill_item = self.skill_items:get(i - 1)
		if skill_item ~= nil then
			local config = skill_item.cur_skill_config
			if config ~= nil and config.feature ~= nil then
				config.feature:killerDataChangeTemp(victim, skill)
			end
		end
	end
end

--作为受伤者的属性临时调整
function M:victimDataChangeTemp(killer, skill)
	for i = 1, self.skill_items.Count do
		local skill_item = self.skill_items:get(i - 1)
		if skill_item ~= nil then
			local config = skill_item.cur_skill_config
			if config ~= nil and config.feature ~= nil then
				config.feature:victimDataChangeTemp(killer, skill)
			end
		end
	end
end

--攻击开始处理
function M:beforeAttack(attackData, killer)
	for i = 1, self.skill_items.Count do
		local skill_item = self.skill_items:get(i - 1)
		if skill_item ~= nil then
			local config = skill_item.cur_skill_config
			if config ~= nil and config.feature ~= nil then
				config.feature:beforeAttack(attackData, killer)
			end
		end
	end
end

--攻击开始处理
function M:killerBeforeAttack(attackData, victim)
	for i = 1, self.skill_items.Count do
		local skill_item = self.skill_items:get(i - 1)
		if skill_item ~= nil then
			local config = skill_item.cur_skill_config
			if config ~= nil and config.feature ~= nil then
				config.feature:killerBeforeAttack(attackData, victim)
			end
		end
	end
end


--攻击结束处理
function M:afterAttack(data)
	for i = 1, self.skill_items.Count do
		local skill_item = self.skill_items:get(i - 1)
		if skill_item ~= nil then
			local config = skill_item.cur_skill_config
			if config ~= nil and config.feature ~= nil then
				config.feature:afterAttack(data)
			end
		end
	end
	return data.damage
end

--攻击结束处理
function M:killerAfterAttack(data)
	for i = 1, self.skill_items.Count do
		local skill_item = self.skill_items:get(i - 1)
		if skill_item ~= nil then
			local config = skill_item.cur_skill_config
			if config ~= nil and config.feature ~= nil then
				config.feature:killerAfterAttack(data)
			end
		end
	end
	return data.damage
end

--hit帧开始前
---@param frameData AnimEvtFrame_Model
---@param data Battle_Frame_Data_Event_Hit
function M:hitFrame(frameData, data)
	for i = 1, self.skill_items.Count do
		---@type PlayerSkillItem
		local skill_item = self.skill_items:get(i - 1)
		if skill_item ~= nil then
			local config = skill_item.cur_skill_config
			if config ~= nil and config.feature ~= nil then
				data = config.feature:hitFrame(frameData, data)
			end
		end
	end
	return data
end

--角色出生结束
function M:initFinish()
	for i = 1, self.skill_items.Count do
		local skill_item = self.skill_items:get(i - 1)
		if skill_item ~= nil then
			local config = skill_item.cur_skill_config
			if config ~= nil and config.feature ~= nil then
				config.feature:initFinish()
			end
		end
	end
end

--角色出生结束
function M:spawnFinish()
	for i = 1, self.skill_items.Count do
		local skill_item = self.skill_items:get(i - 1)
		if skill_item ~= nil then
			local config = skill_item.cur_skill_config
			if config ~= nil and config.feature ~= nil then
				config.feature:spawnFinish()
			end
		end
	end
end

--角色死亡
function M:dead(data)
	local canDead = true
	for i = 1, self.skill_items.Count do
		local skill_item = self.skill_items:get(i - 1)
		if skill_item ~= nil then
			local config = skill_item.cur_skill_config
			if config ~= nil and config.feature ~= nil then
				canDead = config.feature:dead(data) and canDead
			end
		end
	end
	return canDead
end

--角色死亡
function M:killPlayer(data)
	for i = 1, self.skill_items.Count do
		local skill_item = self.skill_items:get(i - 1)
		if skill_item ~= nil then
			local config = skill_item.cur_skill_config
			if config ~= nil and config.feature ~= nil then
				config.feature:killPlayer(data)
			end
		end
	end
end

--查找敌人
function M:findPlayer(data)
	local player_data = data
    for i = 1, self.skill_items.Count do
		local skill_item = self.skill_items:get(i - 1)
		if skill_item ~= nil then
			local config = skill_item.cur_skill_config
			if config ~= nil and config.feature ~= nil then
				player_data = config.feature:findPlayer(player_data)
			end
		end
	end
	return player_data
end

--范围hit攻击调整攻击中心点
function M:checkAoeTarget(targetPos)
	local pos = targetPos
	for i = 1, self.skill_items.Count do
		local skill_item = self.skill_items:get(i - 1)
		if skill_item ~= nil then
			local config = skill_item.cur_skill_config
			if config ~= nil and config.feature ~= nil then
				pos = config.feature:checkAoeTarget(pos)
			end
		end
	end
	return pos
end

--技能事件
function M:skillDispatch(data)
	for i = 1, self.skill_items.Count do
		local skill_item = self.skill_items:get(i - 1)
		if skill_item ~= nil then
			local config = skill_item.cur_skill_config
			if config ~= nil and config.feature ~= nil then
				config.feature:skillDispatch(data)
			end
		end
	end
end

--子弹命中
function M:bulletHit(data)
	for i = 1, self.skill_items.Count do
		---@type PlayerSkillItem
		local skill_item = self.skill_items:get(i - 1)
		if skill_item ~= nil then
			local config = skill_item.cur_skill_config
			if config ~= nil and config.feature ~= nil then
				config.feature:bulletHit(data)
			end
		end
	end
end

function M:destroy()
	for i = 1, self.skill_items.Count do
		local skill = self.skill_items:get(i - 1)
		skill:destroy()
	end
	self.skill_items:clear()
end

return M