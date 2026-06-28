---@class SkillLvUpPopView :OOPopBase
local M = class("SkillLvUpPopView",LikeOO.OOPopBase)

M.m_uiName = "Pops/SkillLvUpPop"
M.m_size_type = 2

local tab_exp = {RewardUtil.REWARD_TYPE_KEYS.HERO_EXP, 0, 0} --经验
local tab_money = {RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 0} --金币
local tab_yueli = {RewardUtil.REWARD_TYPE_KEYS.DUST, 0, 0} --粉尘

function M:onEnter()
	self:refreshUI()
	self:setTextByLanKey("combat_text", "shareLv_str_0015")
	self:setTextByLanKey("common_title_text", "new_str_0446")
end

function M:refreshUI()
	local sk1_obj = self:findGameObject("skill_item1")
	local sk2_obj = self:findGameObject("skill_item2")
	sk1_obj:SetActive(false)
	sk2_obj:SetActive(false)
	local index, skill1, skill2 = self.m_model:getSkillData()
	self.isnew_skill = index
	if skill1 then
		self.new_skill = false
		local sk1_data = self.m_model:getSkillDataById(skill1[1])
		local sk2_data = self.m_model:getSkillDataById(skill2[1])
		sk1_obj:SetActive(true)
		sk2_obj:SetActive(true)
		self:setSkillDesc(sk1_obj, sk1_data, false)
		self:setSkillDesc(sk2_obj, sk2_data, false)
		self:setObjectVisible("jiantou", true)
	else
		self.new_skill = true
		local sk2_data = self.m_model:getSkillDataById(skill2[1])
		sk1_obj:SetActive(true)
		self:setSkillDesc(sk1_obj, sk2_data, true)
		self:setObjectVisible("jiantou", false)
		audio:SendEvtUI("Play_UI_SkillUnlock")
	end
	self:setConsume()
	self:setTextByLanKey("combat_num", self.m_model:getAddCombat())
end

function M:setSkillDesc(obj, data, new)
	local LuaBehaviour = UIUtil.findLuaBehaviour(obj.transform)
	local new_hint = LuaBehaviour:FindGameObject("new_hint")
	new_hint:SetActive(new)
	LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "lv_img", new == false)
	LuaBehaviourUtil.setImg(LuaBehaviour, "skill_img", data.icon, "skill_icon")
	LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "skill_name", data.name)
	LuaBehaviourUtil.setText(LuaBehaviour, "lv_text", data.level)
end

function M:setConsume()
	local up_expend = self.m_model:getConsume()
    local need_exp = GameUtil:formatValueToString(up_expend.exp)
	local need_coin = GameUtil:formatValueToString(up_expend.coin)
	local need_special = GameUtil:formatValueToString(up_expend.special_num)
	local data_exp = RewardUtil:getProcessRewardData(tab_exp)
	local data_coin = RewardUtil:getProcessRewardData(tab_money)
	local data_special = RewardUtil:getProcessRewardData(tab_yueli)
	local cur_exp = GameUtil:formatValueToString(self.m_model.m_data_exp)
	local cur_coin = GameUtil:formatValueToString(self.m_model.m_data_coin)
	local cur_special = GameUtil:formatValueToString(self.m_model.m_data_special)
	self:setText("exp_text", need_exp)
	self:setText("gold_text", need_coin)
	self:setText("fenchen_text", need_special)
	self:setImg(data_coin.icon_name, data_coin.atlas_name, "gold_img")	--金币
	self:setImg(data_exp.icon_name, data_coin.atlas_name, "exp_img")	--英雄经验
	self:setImg(data_special.icon_name, data_coin.atlas_name, "fenchen_img")	--特殊
	self:setText("combat_num", self.m_model:getAddCombat())
end

return M