local M = class("BattleBossTipsControl",LikeOO.OOControlBase)

function M:onEnter()
	self.m_close_timer_id = self:setOnceTimer(3, function()
		self.m_close_timer_id = nil
		self:updateMsg(99999)
	end)
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.CLOSE_VIEW, {self, self.closeViewEvent})
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
		local callback = self.m_model.m_callback
		self:closeView()
    	if type(callback) == "function" then
    		callback()
    	end
	elseif msg == "skill1_img" then
		self:openSkillPop(1)
	elseif msg == "skill2_img" then
		self:openSkillPop(2)
	elseif msg == "skill3_img" then
		self:openSkillPop(3)
	elseif msg == "skill4_img" then
		self:openSkillPop(4)
    end
end

function M:openSkillPop(index)
	if self.m_close_timer_id ~= nil then
		self:removeTimer(self.m_close_timer_id)
		self.m_close_timer_id = nil
	end
	local skills, hero_lv = self.m_model:getHeroSkill()
	local skill_trans = self.m_view:getSkillTransByIndex(index)
	self:openView("Pops.SkillPop",{skill = skills[index], index = index, cur_lv = hero_lv, click_transform = skill_trans, pivot = Vector2.New(0.5,1) })
end

function M:closeViewEvent(event, data)
	local view_name = data.name or ""
	if view_name == "Pops.SkillPop" then
		self.m_close_timer_id = self:setOnceTimer(3, function()
			self.m_close_timer_id = nil
			self:updateMsg(99999)
		end)
	end
end

function M:destroy()
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.CLOSE_VIEW, {self, self.closeViewEvent})
	self:closeView("Pops.SkillPop")
	M.super.destroy(self)
end

return M
