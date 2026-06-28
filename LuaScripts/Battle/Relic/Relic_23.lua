--珍藏柜
--每拥有一个稀有或史诗级别的遗物，则己方武魂的生命与防御力+1.5%，最多叠加10%
---@class Relic_23 : Relic @
---@field super Relic @Relic
local M = class("Relic_23", Relic)

--防御和生命增加量
M.value = nil
--最大增加量
M.maxValue = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.value = self:getValue(1)
	self.maxValue = self:getValue(2)
	self.calType = 3
end

function M:gameStart()
	M.super.gameStart(self)
	--稀有或史诗遗物数量
	local count = 0
	for i = 1, self.mgr.list.list.Count do
		local k = self.mgr.list.list:get(i-1)
		local v = self.mgr.list:get(k)
		if v.data.quality >= 5 then
			count = count + 1
		end
	end
	
	local add = GlobalTools:Mul(count, self.value)
	if add > self.maxValue then
		add = self.maxValue
	end
	
	local targets = self.mgr:getTarget("self", "all")
	for i = 1, targets.Count do
		local ply = targets:get(i - 1)
		self:dealWithValue(ply, "def", self.calType, add)
		
		local rate = ply.data:get_hpRate()
		self:dealWithValue(ply, "hp", self.calType, add)
		ply.data:get_hp(GlobalTools:Mul(ply.data:get_hp(), rate))
		
		
	end
end

return M