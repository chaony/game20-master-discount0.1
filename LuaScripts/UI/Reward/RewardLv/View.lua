local M = class("RewardLvView",LikeOO.OOPopBase)

M.m_uiName = "BountyMissions/BountyMissionsLv"
M.m_size_type = 2

function M:onEnter()	
	self:setTextByLanKey("max_lv_text", "new_str_0279")
	self:creatQuality()
	self:setSlider()
end

--slider_1
function M:creatQuality()
	self:setTextByLanKey("common_title_text", "bounty_str_0004", self.m_model.m_lv)
	self:setTextByLanKey("cur_lv","new_str_0075", self.m_model.m_lv)
	self:setTextByLanKey("next_lv","new_str_0075", self.m_model.m_lv + 1)
	self:setTextByLanKey("req_text_1","new_str_0063")
	self:setTextByLanKey("req_text_4","new_str_0063")

	local slider_1 = self:findSlider("slider_1")
	local slider_2 = self:findSlider("slider_2")
	local cur_grid = self:findGameObject("cur_grid")
	local next_grid = self:findGameObject("next_grid")
	for k,v in pairs(self.m_model:getCurQuestRank()) do
		local item = self:creatPrafabe(cur_grid)
		local com_c = GlobalConfig.BOUNTY_RANK[v]
		GameUtil:setLanImgText(item.transform, com_c.icon, "icon_img")
		-- UIUtil.setTextByLanKey(item.transform,"show_text",com_c.name)
		-- UIUtil.setTextColor(item.transform,com_c.RGBA,"show_text")
	end
	for k,v in pairs(self.m_model:getNextQuestRank()) do
		local item = self:creatPrafabe(next_grid)
		local com_c = GlobalConfig.BOUNTY_RANK[v]
		GameUtil:setLanImgText(item.transform, com_c.icon, "icon_img")
		-- UIUtil.setTextByLanKey(item.transform,"show_text",com_c.name)
		-- UIUtil.setTextColor(item.transform,com_c.RGBA,"show_text")
	end
end

function M:setSlider()
	local requireMents = self.m_model:getRequireMents()
	if next(requireMents) ~= nil then
		local person_quality = requireMents[1][1]
		local person_num = self.m_model:getCurSingleNum(person_quality) --个人任务进度
		local person_allnum = requireMents[1][2]
		local team_quality = requireMents[2][1]
		local team_num = self.m_model:getCurTeamNum(team_quality) or 0  --团队任务进度
		local team_allnum = requireMents[2][2]
	
		local p_c = GlobalConfig.BOUNTY_RANK[person_quality] or GlobalConfig.BOUNTY_RANK[1] 
		self:setTextByLanKey("req_text_2",p_c.name)
		self:setTextByLanKey("req_text_3","bounty_str_0005",person_allnum)
		local t_c = GlobalConfig.BOUNTY_RANK[team_quality] or GlobalConfig.BOUNTY_RANK[1]
		self:setTextByLanKey("req_text_5",t_c.name)
		self:setTextByLanKey("req_text_6","bounty_str_0006",team_allnum)
		self:setText("num_1", person_num.."/"..person_allnum)
		self:setText("num_2", team_num.."/"..team_allnum)
		local slider_1 = self:findSlider("slider_1")
		slider_1.value = person_num/person_allnum
		local slider_2 = self:findSlider("slider_2")
		slider_2.value = team_num/team_allnum
		if team_allnum == 0 then
			self:setObjectVisible("team_obj", false)
		end
		self:setObjectVisible("one_obj", true)
		self:setObjectVisible("max_lv_text", false)
		self:setObjectVisible("require_text", true)
		self:setObjectVisible(">>", true)
		self:setObjectVisible("next_obj", true)
	else
		local cur_obj = self:findGameObject("cur_obj")
		UIUtil.setLocalPosition(cur_obj.transform, 0)
		self:setObjectVisible(">>", false)
		self:setObjectVisible("next_obj", false)
		self:setObjectVisible("max_lv_text", true)
		self:setObjectVisible("require_text", false)
		self:setObjectVisible("one_obj", false)
		self:setObjectVisible("team_obj", false)
	end

end


function M:creatPrafabe(parent)
	local prefab = ResourceUtil:LoadUIGameObject("BountyMissions/Quality_text", Vector3.zero,parent)
	return prefab
end

return M