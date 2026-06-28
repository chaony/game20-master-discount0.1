---@class SummonManager @宠物管理器
---@field player PlayerModel	召唤者
---@field summonList Battle_List<Summon_Model>	召唤列表
local M = class("SummonManager")

--连线数组
M.summonList = nil

M.maxNum = 1000

--我的管理者
M.player = nil
--初始化
---@param player PlayerModel
function M:init(player)
	self.maxNum = 1000
	self.player = player
	self.summonList = Battle.List.new()
end

--加入一个宠物
function M:add(data, skill)
	local summon = require("Battle.Summon.Summon_Model").new()
	summon:init(self.player, data, skill)
	self.summonList:add(summon)
	if self.summonList.Count > self.maxNum then
		local item = self.summonList:get(0)
		self.summonList:removeAt(0)
		item:destroy()
	end
end

--移除连线
---@param summon Summon_Model
function M:remove(summon)
	self.summonList:remove(summon)
	summon:destroy()
end

--清除所有子弹
function M:clear()
	for i = 1,self.summonList.Count do
		self.summonList:get(i-1):destroy()
	end
	self.summonList:clear()
end

function M:update(dt)
	if self.summonList.Count > 0 then
		for i=self.summonList.Count,1,-1 do
			self.summonList:get(i-1):update(dt)
		end
	end
end

function M:destroy()
	self:clear()
end

return M