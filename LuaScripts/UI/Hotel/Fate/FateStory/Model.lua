local M = class("FateStoryModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_cur_hero_id = self.m_params.hero
	self.m_cur_stage = self.m_params.cur_stage
	self.m_stages = self.m_params.list_stage
	self.m_cur_dare_num = self.m_params.times
	self.m_dare_num_max = self.m_params.times_max
	--确定当前关卡索引
	self.m_cur_stage_index = 0
	if self.m_cur_stage <= 0 then
		return
	end
	for k, v in pairs(self.m_stages) do
		if self.m_cur_stage == v.id then
			self.m_cur_stage_index = k
			break
		end
	end
end

return M