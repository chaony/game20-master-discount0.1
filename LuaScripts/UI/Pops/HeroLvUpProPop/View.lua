local M = class("HeroLvUpProPopView",LikeOO.OOPopBase)

M.m_uiName = "Pops/HeroLvUpProPop"
M.m_size_type = 2

local CACHE_TAB = {
	{ name = "new_str_0309", pre = "con_1", pro = "combat"},
	{ name = "new_str_0310", pre = "con_2", pro = "lv_max" },
	{ pro_id = 902 , pre = "con_3", },
	{ pro_id = 901 , pre = "con_4", },
	{ pro_id = 903 , pre = "con_5", },
}
function M:onEnter()
	self:refreshUI()
	self:setPro()
end

function M:refreshUI()
	local sk1_obj = self:findGameObject("skill_item1")
	local sk2_obj = self:findGameObject("skill_item2")
	sk1_obj:SetActive(false)
	sk2_obj:SetActive(false)
	local skill1, skill2 = self.m_model:getSkillData()
	if skill1 then
		local sk1_data = self.m_model:getSkillDataById(skill1[1])
		local sk2_data = self.m_model:getSkillDataById(skill2[1])
		sk1_obj:SetActive(true)
		sk2_obj:SetActive(true)
		self:setSkillDesc(sk1_obj, sk1_data, false)
		self:setSkillDesc(sk2_obj, sk2_data, false)
		self:setObjectVisible("jiantou", true)
		self:setTextByLanKey("skill_text", "技能升级")
	else
		local sk2_data = self.m_model:getSkillDataById(skill2[1])
		sk1_obj:SetActive(true)
		self:setSkillDesc(sk1_obj, sk2_data, true)
		self:setObjectVisible("jiantou", false)
		self:setTextByLanKey("skill_text", "技能解锁")
	end
end

function M:setSkillDesc(obj, data, new)
	local LuaBehaviour = UIUtil.findLuaBehaviour(obj.transform)
	local new_hint = LuaBehaviour:FindGameObject("new_hint")
	new_hint:SetActive(new)
	LuaBehaviourUtil.setImg(LuaBehaviour, "skill_img", data.icon, "skill_icon")
	LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "skill_name", data.name)
	LuaBehaviourUtil.setText(LuaBehaviour, "lv_text", data.level)
end

function M:setPro()
	for k,v in pairs(CACHE_TAB) do
		local com = self:findGameObject(v.pre)
		local LuaBehaviour = UIUtil.findLuaBehaviour(com.transform)
		if LuaBehaviour then
			if v.name ~= nil then
				LuaBehaviourUtil.setText(LuaBehaviour, "title_text", Language:getTextByKey(v.name))
				local atr_1, atr_2 = self.m_model:getProChange(v.pro)
				LuaBehaviourUtil.setText(LuaBehaviour, "count_text", atr_1)
				LuaBehaviourUtil.setText(LuaBehaviour, "count2_text", atr_2)
			elseif v.pro_id then
				local key = GameUtil:getAttrsKey(v.pro_id)
				local pro_name = GameUtil:getAttrsName(key)
				LuaBehaviourUtil.setText(LuaBehaviour, "title_text", pro_name)
				local atr_1, atr_2 = self.m_model:getProChange(key)
				LuaBehaviourUtil.setText(LuaBehaviour, "count_text", atr_1)
				LuaBehaviourUtil.setText(LuaBehaviour, "count2_text", atr_2)
			end
		
		end
	end
end

return M