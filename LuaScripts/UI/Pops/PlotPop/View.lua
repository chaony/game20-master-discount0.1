local M = class("CommonPopView",LikeOO.OOPopBase)

M.m_uiName = "Pops/PlotPop"
M.m_size_type = 2

function M:onEnter()	
	--过场字幕声
	ResourceUtil:LoadRoleSound("cts_01")
	audio:PlayFmodSound("guochangzimu","Transition")
	audio:PauseMusicBusVol();
	local event1 = false
	local event2 = false
	-- if self.m_model.m_demonstrate then
	-- 	event1 = true
	-- 	event2 = true
	-- else
		local stage_cfg = GameUtil:getBattleStageCfg()
		--if stage_cfg.img_event and stage_cfg.img_event ~= "" then
		--	--self:findImage("text_img"):SetNativeSize()
		--	local sentence = string.gsub(Language:getTextByKey(stage_cfg.img_event), "\\n", "\n")
		--	local sentences =  string.split(sentence,"\n")
		--	for i=1,4 do
		--		self:setText("des_text_" .. i, sentences[i] or "")
		--	end
		--	event2 = true
		--end

		if stage_cfg.chapter_img_event and next(stage_cfg.chapter_img_event) ~= nil then
			self:setTextByLanKey("chapter_text", stage_cfg.chapter_img_event[1])
			self:setTextByLanKey("chapter_zi_text", stage_cfg.chapter_img_event[2])
			event1 = true
		end
	-- end

	self:setObjectVisible("continue_btn", false)
	local function closePopFunc()
		self.m_model.m_close_pop = true
		if self.m_model.m_close_pop and self.m_model.m_load_scene_finish then
			self:updateMsg(99999)
		end
	end
	
	self.m_control:setOnceTimer(5.5, closePopFunc)
    self:setParticleRenderOrder(self.content_node)

    if event1 and event2 then
    	self.m_ui_obj:GetComponent("Animator"):PlayInFixedTime("fx_plotpop_03")
    elseif event1 then
    	self.m_ui_obj:GetComponent("Animator"):PlayInFixedTime("fx_plotpop_01")
	elseif event2 then
		self.m_ui_obj:GetComponent("Animator"):PlayInFixedTime("fx_plotpop_02")
	else
		self:updateMsg(99999)
	end
end

function M:continueSpine()
	self:setObjectVisible("continue_btn", false)
	self.m_ui_obj:GetComponent("Animator").speed = 1
end

function M:destroy()
	M.super.destroy(self)
	audio:ResumeMusicBusVol();
end

return M