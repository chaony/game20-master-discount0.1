local M = class("InvitationLetterView", LikeOO.OOPopBase)

M.m_uiName = "CompareSwordWithWorld/GameOfHeavenAndEarth/InvitationLetter" --CompareSwordWithWorld.InvitationLetter
M.m_iphoneXAdapter = true
M.m_size_type = 2

function M:onEnter()
	self:refreshUI()
end

function M:refreshUI()
	local img_bg = self:findImage("bg")
	local img_title = self:findImage("tips_img")
	local img_bg_name = ""
	local img_title_name = ""
	local race_type_lang = ""
	if self.m_model.m_invitation_index == 1 then -- 天赛
		img_bg_name =  "a_jstx_yqh_BJ"
		img_title_name  = "a_jstx_yqh_biaotidi"
		race_type_lang = "compare_sword_race_text_041"
	elseif self.m_model.m_invitation_index == 2 then --地赛
		img_bg_name = "a_jstx_dsyqh_BJ"
		img_title_name = "a_jstx_dsyqh_biaotidi"
		race_type_lang = "compare_sword_race_text_042"
	end
	local race_type_text = Language:getTextByKey(race_type_lang)
	GameUtil:updateResourcesImg( img_bg, "Texture/zh_cn/" .. img_bg_name)
	GameUtil:updateResourcesImg( img_title, "Texture/compareswordwithworld/" .. img_title_name)
	
	self:setTextByLanKey("name_text" , "compare_sword_invitation_text_001" )
	self:setTextByLanKey("desc_text" , "compare_sword_invitation_text_002" , self.m_model.self_boss_rank , race_type_text)
	self:setTextByLanKey("author_text" , "compare_sword_invitation_text_003")
end

function M:destroy()

	M.super.destroy(self)
end


return M