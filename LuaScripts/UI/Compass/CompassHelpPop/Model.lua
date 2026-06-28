local M = class("CompassHelpPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.cur_index = self.m_params.cur_index
	self.pool_data = self.m_params.pool_data
	self.data = {}
	self:Probability()
end

function M:Probability()
	local cfg_block = ConfigManager:getCfgByName("roulette_block")
	for kk, vv in pairs(self.pool_data) do
		local key = tonumber(kk)
		local cfg_block_item = cfg_block[self.cur_index][vv.block]
		vv.probability = cfg_block_item.percent_show
		vv.reward_grade = cfg_block_item.reward_grade
		self.data[key] = vv
	end
	local sortFunc = function (v1, v2)
		local reward_grade_1 = cfg_block[self.cur_index][v1.block].reward_grade
		local reward_grade_2 = cfg_block[self.cur_index][v2.block].reward_grade
		if reward_grade_1 == reward_grade_2 then
			return v1.probability < v2.probability
		else
			return reward_grade_1 < reward_grade_2
		end
	end
	table.sort(self.data, sortFunc)
end

function M:destroy()
	M.super.destroy(self)
end

return M
