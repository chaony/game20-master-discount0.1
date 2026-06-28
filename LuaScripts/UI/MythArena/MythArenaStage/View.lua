local M = class("MythArenaStageView",LikeOO.OOPopBase)

M.m_uiName = "MythArena/MythArenaStage"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
	self.m_stage_slider = self:findSlider("stage_slider")
	self:setTextByLanKey("close_title_text", "wlsh_text_0004")
	self:setTextByLanKey("go_btn_text", "new_str_0866")
	self:setTextByLanKey("reward_btn_text", "new_str_0373")
	self:refreshUI()
	if self.m_model.m_pop_data > 0 then
		self:updateMsg("pop_promotino")
	end
	--UserDataManager:removeRedDotByKey("high_arena")
end

function M:refreshUI()
	local cur_stage_cfg = self.m_model:getCfgValueByKey(self.m_model.m_big_stage)
	if cur_stage_cfg and self.m_model.m_small_stage == 2 then
		self:setTextByLanKey("stage_des_text", cur_stage_cfg.show_time_1 or "")
	else
		self:setTextByLanKey("stage_des_text", "")
	end
	self:setObjectVisible("go_btn", self.m_model.m_big_stage > 1)
	self:refreshProgressBar()
	self:setSpine()
	self:refreshStageName()
end

function M:refreshProgressBar()
	local value = self.m_model.m_big_stage - 1
	value = value == 1 and 1.1 or value
	self.m_stage_slider.value = (value) 
end

function M:refreshStageName()
	for i = 2, 7 do
		local cur_stage_cfg = self.m_model:getCfgValueByKey(i)
		if cur_stage_cfg then
			self:setTextByLanKey("state_time" .. i - 1, cur_stage_cfg.show_time)
			self:setTextByLanKey("state_name" .. i - 1, cur_stage_cfg.name)
		end
	end
end

function M:setSpine()
	--for i = 1, 2 do
	--	local hk_obj = self:findGameObject("hero_sk" .. i)
	--	local c_id = "504"--self.m_model:getShowHeroId()[i]
	--	local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(tonumber(c_id))
	--	local spine_name = hero_cfg.hero_spine or "hero_0001_SkeletonData"
	--	GameUtil:updateSpineLoadSet(hk_obj, "RoleSpine/" .. spine_name, "idle", 0, true)
	--end
end

function M:destroy()
    M.super.destroy(self)
end

return M