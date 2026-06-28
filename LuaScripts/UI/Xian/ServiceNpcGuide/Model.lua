local M = class("ServiceNpcGuideModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_notices_list_data = self.m_params or {}
end

function M:getNpcGuideTab()
	local new_tab = {}
	local npc_guide_tab =  ConfigManager:getCfgByName("npc_guide")
	for k = 1,table.nums(npc_guide_tab) do
		local c_cfg = npc_guide_tab[k]
		if c_cfg.sort == 1 then
			table.insert( new_tab, k)
		end
	end
	local function sortFunc(id_one, id_two)
		local cfg_1 =  npc_guide_tab[id_one]
		local cfg_2 =  npc_guide_tab[id_two]
		local got_1 = self:getNpcGuideData(id_one)
		local got_2 = self:getNpcGuideData(id_two)
		if got_1 ~= nil and got_2 ~= nil and got_1 ~= got_2 then
			return got_2
		elseif cfg_1.guide_stage == cfg_2.guide_stage then
			return id_one < id_two
		else
			return cfg_1.guide_stage < cfg_2.guide_stage
		end
    end
	table.sort(new_tab,sortFunc)
	return new_tab
end

function M:getNpcGuideData(id)
	local npc_guide_tab =  ConfigManager:getCfgByName("npc_guide")
	local guide_cfg = npc_guide_tab[id]
	local get_bl = false
	for k,v in pairs(UserDataManager.welfare_npc_guide) do
		if v == id then
			get_bl = true
		end
	end
	return get_bl, guide_cfg
end

function M:checkLockSort(id)
	local npc_guide_tab =  ConfigManager:getCfgByName("npc_guide")
	local guide_cfg = npc_guide_tab[id]
	local cur_stage_id = UserDataManager:getCurStage()
	local day = GameUtil:dayCompute()
	return cur_stage_id>=guide_cfg.unlock_condition_param, day>=guide_cfg.unlock_days
end

function M:checkOpenById(id)
	local npc_guide_tab =  ConfigManager:getCfgByName("npc_guide")
	local guide_cfg = npc_guide_tab[id]
	local cur_stage_id = UserDataManager:getCurStage()
	local day = GameUtil:dayCompute()
	if cur_stage_id>=guide_cfg.unlock_condition_param and day>=guide_cfg.unlock_days then
		return true
	end
	return false
end

return M
