local M = class("HeroSkinLookInfoControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
		local callback = self.m_model.m_callback
		self:closeView()
    	if type(callback) == "function" then
    		callback()
    	end
	elseif msg == "skill1_img" then
		local sk_obj = self.m_view:findGameObject(msg)
		self:openSkillPop(1, sk_obj)
	elseif msg == "skill2_img" then
		local sk_obj = self.m_view:findGameObject(msg)
		self:openSkillPop(2, sk_obj)
	elseif msg == "skill3_img" then
		local sk_obj = self.m_view:findGameObject(msg)
		self:openSkillPop(3, sk_obj)
	elseif msg == "skill4_img" then
		local sk_obj = self.m_view:findGameObject(msg)
		self:openSkillPop(4, sk_obj)
	elseif msg == "evaluate_btn" then
		self:openView("HeroBag.HeroEvaluate",{hero_id = self.m_model.m_hero_id})
    end
end

function M:openSkillPop(index, click_obj)
	local skills, hero_lv = self.m_model:getHeroSkill()
	self:openView("Pops.SkillPop",{skill = skills[index], index = index, cur_lv = hero_lv , click_transform = click_obj.transform})
end

return M
