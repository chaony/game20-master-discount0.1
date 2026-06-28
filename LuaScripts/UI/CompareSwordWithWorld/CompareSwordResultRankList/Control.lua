local M = class("CompareSwordResultRankListControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
	if msg == 99999 then 
		self:closeView()
	elseif msg == "race" then
		self:switchNode(1)
		self.m_view:refreshUI()
	elseif msg == "type" then
		self:switchNode(2)
		self.m_view:refreshUI()
	elseif msg == "load_rank" then 
		self:requestLoadRank()
	end
end

function M:switchNode(type)
	if type == 1 then --天
		local function netCallback(response)
			if self.m_view then
				self.m_model.type_count[self.m_model.m_race_type][self.m_model.m_type_type] = response.count
				self.m_model.jinji_rank_list[self.m_model.m_type_type] = {}
				self.m_model.jifen_rank_list[self.m_model.m_type_type] = {}
				self.m_model:insertRankData(response)
				--self.m_view:switchNode(self.m_model.m_sel_tab_index)
				self.m_view:refreshUI()
			end
		end
		local params = {}
		params.start = 1
		params.stop = 10
		params.typ = self.m_model.m_type_type -- 
		if self.m_model.m_race_type == 2 then
			params.round_stage = self.m_model.round_stage
		end
		local net = self.m_model.m_race_type == 1 and "full_service_point_race_ranks" or "full_service_top_rank_info"
		self.m_model:getNetData(net, params, netCallback)
	else --地
		local function netCallback(response)
			if self.m_view then
				self.m_model.type_count[self.m_model.m_race_type][self.m_model.m_type_type] = response.count
				self.m_model.jinji_rank_list[self.m_model.m_type_type] = {}
				self.m_model.jifen_rank_list[self.m_model.m_type_type] = {}
				self.m_model:insertRankData(response)
				--self.m_view:switchNode(self.m_model.m_sel_tab_index)
				self.m_view:refreshUI()
			end
		end
		local params = {}
		params.start = 1
		params.stop = 10
		params.typ = self.m_model.m_type_type -- 
		if self.m_model.m_race_type == 2 then
			params.round_stage = self.m_model.round_stage
		end
		local net = self.m_model.m_race_type == 1 and "full_service_point_race_ranks" or "full_service_top_rank_info"
		self.m_model:getNetData(net, params, netCallback)
	end
end

function M:requestLoadRank()
	local start_pos, end_pos = self.m_model:getLoadIndex()
	if start_pos > 0 then
		local function netCallback(response)
			if self.m_view then
				self.m_mail_load = true
				self.m_model.type_count[self.m_model.m_race_type][self.m_model.m_type_type] = response.count
				self.m_model:insertRankData(response)
				--self.m_view:switchNode(self.m_model.m_sel_tab_index)
				self.m_view:refreshUI()
			end
		end
		local params = {}
		params.start = start_pos
		params.stop = end_pos
		params.typ = self.m_model.m_type_type -- 
		local net = self.m_model.m_race_type == 1 and "full_service_point_race_ranks" or "full_service_top_rank_info"
		self.m_model:getNetData(net, params, netCallback)
	end
end

function M:destroy()

	M.super.destroy(self)
end


return M