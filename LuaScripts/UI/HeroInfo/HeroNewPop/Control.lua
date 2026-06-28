local M = class("HeroNewPopControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.HeroInfo.HeroNewPop.Guide"
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
    	self:updateMsg("check_guide",{force_flag = true},"parent")
    	self:updateMsg("guide_check",nil,"Pub.GachaOnePop")
		self:updateMsg("close_new", nil, "Pub.GachaTenPop")
		local callback = self.m_model.m_callback
		if self:checkFirstYinYangHeroFlag() then -- 检查是否第一次抽到T0卡或阴阳卡
			GameUtil:openAppRating() -- 评价
		end
		self:closeView()
    	if type(callback) == "function" then
    		callback()
    	end
	elseif msg == "skill1_img" then
		local click_obj= self.m_view:findGameObject(msg)
		self:openSkillPop(1, click_obj.transform)
	elseif msg == "skill2_img" then
		local click_obj = self.m_view:findGameObject(msg)
		self:openSkillPop(2, click_obj.transform)
	elseif msg == "skill3_img" then
		local click_obj = self.m_view:findGameObject(msg)
		self:openSkillPop(3, click_obj.transform)
	elseif msg == "skill4_img" then
		local click_obj = self.m_view:findGameObject(msg)
		self:openSkillPop(4, click_obj.transform)
	elseif msg == "share_btn" then -- 分享
		self.m_view:ShareShow(false)
		local show_call = function()
			self.m_view:ShareShow(true)
		end
		self:openView("SharePicture", {picture_callback = show_call})
	end
end

function M:openSkillPop(index, transform)
	local skills, hero_lv = self.m_model:getHeroSkill()
	self:openView("Pops.SkillPop",{skill = skills[index], index = index, cur_lv = hero_lv ,click_transform = transform, pivot = Vector2(0,1)})
end

-- 检查是否是第一次抽到T0卡
function M:checkFirstExHeroFlag()
	local flag = false
	local appRating_Ex_hero = U3DUtil:PlayerPrefs_GetString("appRating_Ex_hero", "")
	if appRating_Ex_hero == "" then
		if self.m_model.m_hero_cfg and self.m_model.m_hero_cfg.Ex_hero == 1 then
			U3DUtil:PlayerPrefs_SetString("appRating_Ex_hero", "1")
			flag = true
		end
	end
	return flag
end

-- 检查是否是第一次抽到阴阳卡
function M:checkFirstYinYangHeroFlag()
	local flag = false
	local appRating_yinYang_hero = U3DUtil:PlayerPrefs_GetString("appRating_yinYang_hero", "")
	if appRating_yinYang_hero == "" then
		if self.m_model.m_hero_cfg and tonumber(self.m_model.m_hero_cfg.race) > 4 then
			U3DUtil:PlayerPrefs_SetString("appRating_yinYang_hero", "1")
			flag = true
		end
	end
	return flag
end

return M
