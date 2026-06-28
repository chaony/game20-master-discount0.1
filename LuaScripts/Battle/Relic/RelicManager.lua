Relic = require("Battle.Relic.Relic")

---@class RelicManager @遗物管理器
---@field list ListMap<Relic>
local M = class("RelicManager")

M.dataList = nil

M.list = nil

M.plyMgr = nil

M.gaming = false

M.camp = 1

function M:init(plyMgr, camp)
	--遗物表
	self.dataList = ConfigManager:getCfgByName("heirloom");
	--法宝表
	self.treasure_config = ConfigManager:getCfgByName("battle_treasure_config")
	--遗物列表
	self.list = Battle.ListMap.new()
	self.plyMgr = plyMgr
	self.camp = camp
	self.task_list = Battle.ListMap.new()
	--
	self.cur_task = nil;
	self.delayTime = GlobalTools.base0_5;
	self.curDelayTime = self.delayTime;
end


function M:playEffect( task )
	local task_list = self.task_list:get(task.id)
	if task_list == nil then
		task_list = {}
		self.task_list:add(task.id, task_list)
	end
	--加入任务列表
	table.insert(task_list, task)
end


function M:add( id, param )
	--去法宝表里去取法宝配置
	if param == nil then
		local data = self.treasure_config[id]
		if data ~= nil then
			--得到法宝中的 遗物配置id
			local heirloom_item = self.dataList[data.skill_id]
			if heirloom_item ~= nil then
				---@type Relic
				local cur_relic = self.list:get(data.skill_id)
				if cur_relic == nil then
					cur_relic = require("Battle.Relic.Relic".."_"..heirloom_item.group_id).new()
					self.list:add(data.skill_id, cur_relic)
				else
					cur_relic.relicCount = cur_relic.relicCount + 1
				end
				cur_relic:init(self, data, heirloom_item)
				self.list:sort( function(data1, data2)
					return data1 < data2;
				end)
			end
			--if self.list[id] == nil then
			--	local relic = require("Battle.Relic.Relic".."_"..data["group_id"]).new()
			--	self.list[id] = relic
			--else
			--	self.list[id].relicCount = self.list[id].relicCount + 1
			--end
			--self.list[id]:init(self, self.dataList[id])
			--self.list[id].param = param
		end
	else
		local data = self.dataList[id]
		if data ~= nil then
			if self.list:get(id) == nil then
				local relic = require("Battle.Relic.Relic".."_"..data["group_id"]).new()
				self.list:add(id, relic)
			else
				local relic = self.list:get(id)
				relic.relicCount = relic.relicCount + 1
			end
			local cur_relic = self.list:get(id)
			cur_relic:init(self, param, self.dataList[id])
		end
	end
	
end

function M:getTarget(target,count)
	local targets = Battle.List.new()
	local player = self.plyMgr:getPlayers(self.camp):get(0)
	if player ~= nil then
		local data =
		{
			["count"] = "all",
			["camp"] = "all",
			["posIndex"] = "all",
			["priority"] = false,
			["ignoreSummon"] = false,
			["targetNoRepeat"] = false,
			["campRace"] = "not",
			["gender"] = "all",
			["pos"] = "not",
			["profession"] = "all",
			["area"] = "all",
			["areaWidth"] = 0,
			["areaHeight"] = 0,
			["areaAngle"] = 0,
			["areaRadius"] = 0,
			["forceSelect"] = false,
			["selectLast"] = false,
			["isFixPoint"] = false,
			["useSelf"] = false,
			["fixpoint"] = "enemyBackCenter"
		}
		if count ~= nil then
			data["posIndex"] = count
		end
		--无敌人
		if target == "not" then
			targets = Battle.List.new()
		elseif target == "self" then
			--我方全体
			data["camp"] = "friend"
			targets = SelectTargetTool:findPlayerByType(data, player)
		elseif target == "enemy" then
			--敌方全体
			data["camp"] = "enemy"
			targets = SelectTargetTool:findPlayerByType(data, player)
		else
			--id为target的人
			data["camp"] = "friend"
			targets = Battle.List.new()
			local temp = SelectTargetTool:findPlayerByType(data, player)
			for i = 1, temp.Count do
				if temp:get(i - 1):equal(player) == false then
					targets:add(temp:get(i - 1))
				end
			end
		end
	end
	return targets
end


function M:getTargetData(data)
	local targets = nil
	local player = self.plyMgr:getPlayers(self.camp):get(0)
	if player ~= nil then
		if data ~= nil then
			targets = SelectTargetTool:findPlayerByType(data, player)
		end
	end
	
	return targets
end
function M:findById(id)
	return self.list[id]
end

function M:removeById(id)
	if self.list:get(id) ~= nil then
		self.list:get(id):destroy()
	end
	self.list:remove(id)
end

function M:remove(relic)
	if relic ~= nil then
		relic:destroy()
		self.list:removeValue(relic);
		--table.removebyvalue(self.list, relic, true)
	end
end

function M:clear()
	self.list:clear()
	self.task_list:clear()
	self.cur_task = nil
end

function M:gameStart()
	self.gaming = true
	for i = 1, self.list.list.Count do
		local k = self.list.list:get(i-1)
		local v = self.list:get(k)
		v:gameStart()
	end
end


function M:skillStart( player, skillData )
	for i = 1, self.list.list.Count do
		local k = self.list.list:get(i-1)
		local v = self.list:get(k)
		v:skillStart( player, skillData )
	end
end


function M:skillEnd( player, skillData )
	for i = 1, self.list.list.Count do
		local k = self.list.list:get(i-1)
		local v = self.list:get(k)
		v:skillEnd( player, skillData )
	end
end


function M:beforeDead( dead, killer, damage)
	local changeDamage = damage;
	for i = 1, self.list.list.Count do
		local k = self.list.list:get(i-1)
		local v = self.list:get(k)
		changeDamage = v:beforeDead( dead, killer, changeDamage )
	end
	return changeDamage;
end


--玩家死亡
function M:playDead( dead, killer )
	for i = 1, self.list.list.Count do
		local k = self.list.list:get(i-1)
		local v = self.list:get(k)
		v:playDead( dead, killer )
	end
end

--攻击结束
function M:attackOver( beHitPlayer, killer, damage )
	for i = 1, self.list.list.Count do
		local k = self.list.list:get(i-1)
		local v = self.list:get(k)
		v:attackOver( beHitPlayer, killer, damage )
	end
end


function M:spawnFinish()
	for i = 1, self.list.list.Count do
		local k = self.list.list:get(i-1)
		local v = self.list:get(k)
		v:spawnFinish()
	end
end

--临时数据修改（只能处理临时数据）
function M:dataChangeTemp(killer, victim)
	for i = 1, self.list.list.Count do
		local k = self.list.list:get(i-1)
		local v = self.list:get(k)
		v:dataChangeTemp()
	end
end

function M:update(dt, unsdt)
	if self.gaming then
		for i = 1, self.list.list.Count do
			local k = self.list.list:get(i-1)
			local v = self.list:get(k)
			v:update(dt, unsdt)
		end

		if self.task_list.list.Count > 0 then
			if self.cur_task == nil then
				local k = self.task_list.list:get(0)
				self.cur_task = self.task_list:get(k)
				self.task_list:remove(k)
				for i, v in ipairs(self.cur_task) do
					GlobalTools:PlayEffect(v.ply, v.prefabName, v.autoTime, "head")
				end
				self.curDelayTime = self.delayTime;
			else
				if self.curDelayTime > 0 then
					self.curDelayTime = self.curDelayTime - dt
					if self.curDelayTime <= 0 then
						self.cur_task = nil
					end
				end
			end
		end
	end
end

function M:gameover()
	self.gaming = false
	for i = 1, self.list.list.Count do
		local k = self.list.list:get(i-1)
		local v = self.list:get(k)
		v:gameover()
	end
	self:clear()
end

function M:destroy()
	self:gameover()
	for i = 1, self.list.list.Count do
		local k = self.list.list:get(i-1)
		local v = self.list:get(k)
		v:destroy()
	end
	self.task_list:clear()
end
return M
