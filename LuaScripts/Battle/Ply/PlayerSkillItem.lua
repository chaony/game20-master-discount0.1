---@class PlayerSkillItem @单个技能
---@field cur_skill_config SkillDataConfig
local M = class("PlayerSkillItem")

--当前的技能配置
M.skill_configs = nil
--当前的技能等级
M.level = 0
--当前的技能配置
M.cur_skill_config = nil
--初始化
function M:init(player, data, serverData)
	-- 玩家的 第几个技能 1 表示第一个技能
	-- 玩家数据
	self.player = player
	--技能数据
	self.skillData = ConfigManager:getCfgByName("skill_detail");
	if serverData ~= nil then
		self:ConfigServer( serverData )
	else
		self:ConfigLocal( data )
	end
end


function M:ConfigServer( data )
	-- 111
	-- 数据
	self.data = data
	--i = 111  技能id
	--技能定义
	local skillConfig = require("Battle.Ply.SkillDataConfig").new()
	local data = self.skillData[self.data];
	if data ~= nil then
		skillConfig:init(data)
		skillConfig.id = self.data
	else
		Logger.logError( " 技能id = "..tostring( self.data ).." 不存在 ");
	end
	
	skillConfig:setPlayer(self.player)
	self.cur_skill_config = skillConfig
	self.cur_skill_config:conditionInit()
end


function M:ConfigLocal( data )
	-- 	[1]={
	--      level 1
	-- 		{
	-- 			111,
	-- 			1,
	-- 		},
	--      level 2
	-- 		{
	-- 			112,
	-- 			81,
	-- 		},
	--      level 3
	-- 		{
	-- 			113,
	-- 			161,
	-- 		},
	-- 	},
	
	--数据
	self.data = data
	self.skill_configs = Battle.List.new()
	for i,v in ipairs(self.data) do
		--i = 111  技能id
		--v = 1    解锁等级
		--数据模型
		--{
		-- 		111,
		-- 		1,
		-- },
		--技能定义
		local skillConfig = require("Battle.Ply.SkillDataConfig").new()
		local data = self.skillData[v[1]];
		if data ~= nil then
			skillConfig:init(data)
			skillConfig.id = v[1]
		else
			Logger.logError( " 技能id = "..tostring( v[1] ).." 不存在 ");
		end

		--skillConfig.unlock_level = v[2]
		skillConfig:setPlayer(self.player)
		self.skill_configs:add(skillConfig)
	end
	--技能等级
	self.level = self:getSkillLevel()
	if self.level > 0 then
		self.cur_skill_config = self.skill_configs:get(self.level-1)
		if self.cur_skill_config ~= nil then
			self.cur_skill_config:conditionInit()
		end
	end
end


--[[
    @desc: 通过人物等级 计算 技能等级 
    author:{author}
    time:2020-02-22 10:15:59
    @return:
]]
function M:getSkillLevel()
	for i = self.skill_configs.Count, 1, -1 do
		local config = self.skill_configs:get(i-1)
		---紫卡
		---skill3 1级开启等级1，81级开启等级2，161级开启等级3
		---skill1 11级开启等级1，21级开启等级2，101级开启等级3，181级开启等级4
		---skill2 41级开启等级1，121级开启等级2，201级开启等级3
		---skill0 61级开启等级1，141级开启等级2，221级开启等级3
		---attack1 1级开启等级1
		---蓝卡
		---skill3 1级开启等级1，61级开启等级2，121级开启等级3
		---skill1 11级开启等级1，21级开启等级2，81级开启等级3，141级开启等级4
		---skill2 41级开启等级1，101级开启等级2
		---attack1 1级开启等级1
		--if self.player.camp == 1 then
		--	if config.anim_name == "skill3" then
		--		return 1
		--	elseif config.anim_name == "skill1" then
		--		return 0
		--	elseif config.anim_name == "skill1" then
		--		return 0
		--	elseif config.anim_name == "attack1" then
		--		return 1
		--	else
		--		return 0
		--	end
		--else
		--	if config.anim_name == "attack1" then
		--		return 1
		--	else
		--		return 0
		--	end
		--end
		if SceneManager.curScene.isUseConfig == true and self.player.plus_level and self.player.plus_level > 0 and config.unlock_level == 9999 then
			return self.player.plus_level
		end
		
		if config.unlock_level <= self.player.data:get_level() then
			--当前的技能等级
			local level = i
			if level < 1 then
				level = 1
			end
			return level
		end
	end
	return 0
end



--当前技能是否可以使用
function M:canUse()
	if self.cur_skill_config:canUse() then
		return self.cur_skill_config
	end
end

--获取当前的技能配置
function M:getSkillConfig()
	return self.cur_skill_config
end

--更新状态
function M:update(dt,unsdt)
	if self.cur_skill_config ~= nil then
		self.cur_skill_config:update(dt,unsdt)
	end
end

function M:destroy()
	if self.cur_skill_config ~= nil then
		self.cur_skill_config:destroy()
	end
end

return M
