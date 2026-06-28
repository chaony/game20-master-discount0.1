local M = class("MasterApprenticeFindPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self.m_tab_index = self.m_params.index or 1
	self:getData("mentorship_info")
end

function M:onEnter()
	self:initData()
end

function M:initData(data)
	if data then
		self.m_data = data
	end
	if 	self.m_data then
		self.m_status = self.m_data.status -- 0: 未开启, 1: 徒弟期间 2: 师父期间
		self.m_desc = self.m_data.desc or "" -- 宣言
		self.m_flag = self.m_data.flag --  1: (找师父 or 找徒弟) 0: (不找师父 or 不找徒弟)
		self.m_recommend = self.m_data.recommend --推荐列表 m_
		self.m_apply = self.m_data.apply --申请列表 
	end
end

function M:setTabIndex(index)
	self.m_tab_index = index
end

function M:getStageName(id)
	local stage_tab = ConfigManager:getCfgByName("stage")
	if id == 0 then
		id = 1001
	end
	local stage_data = stage_tab[id]
	return stage_data
end

function M:getApplyTitleText(sort)
	if sort == 1 then
		return "master_apprentice_str_0010"
	elseif sort == 2 then
		return "master_apprentice_str_0011"
	elseif sort == 3 then
		return "master_apprentice_str_0012"
	end
end

function M:getDesc()
	if self.m_status == 1 then
		return Language:getTextByKey("master_apprentice_str_0037")
	else
		return Language:getTextByKey("master_apprentice_str_0036")
	end
end

function M:getDesc2()
	if self.m_status == 1 then
		return Language:getTextByKey("master_apprentice_str_0036")
	else
		return Language:getTextByKey("master_apprentice_str_0037")
	end
end

--
function M:disposeApply(id)
	if id then
		for k,v in pairs(self.m_apply) do
			if v.uid == id then
				table.remove( self.m_apply, k)
				break
			end
		end
	else
		self.m_apply = {}
	end
end

return M
