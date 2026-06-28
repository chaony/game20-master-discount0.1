
local M = class("HeroDestinyStar",LikeOO.OOUIbase)

M.m_uiName = "HeroBag/HeroDestinyStar"

local tab_exp = {RewardUtil.REWARD_TYPE_KEYS.HERO_EXP, 0, 0} --英雄经验
local tab_money = {RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 0} --金币
local tab_yueli = {RewardUtil.REWARD_TYPE_KEYS.DUST, 0, 0} --粉尘

M.SKILL_POS_3 = {
	{pos = Vector3(-70, 17, 0)},
	{pos = Vector3(0, -19, 0)},
	{pos = Vector3(70, 17, 0)},
}
M.SKILL_POS_4 = {
	{pos = Vector3(-103, 17, 0)},
	{pos = Vector3(-36, -19, 0)},
	{pos = Vector3(36, -19, 0)},
	{pos = Vector3(103, 17, 0)}
}

function M:onEnter()
	self:setTextByLanKey("goto_destiny_star_btn_text", "destinyStar_text_0009")
	self:setTextByLanKey("hp_text","destinyStar_text_0011")
	self:setTextByLanKey("attack_text","destinyStar_text_0012")
	self:setTextByLanKey("def_text", "destinyStar_text_0013")
	self.star_start_hui_naterial = self:findImage("star_img_hui").material
	self.star_img = self:findImage("star_img")
	self:refreshUI()
end

function M:refreshUI()
	local btn_show = self.m_model:getHeroStarBtnShow()
	if btn_show then
		self:setFatesState()
		self:updateSkill()
	end
end

function M:refreshLevelUpUI()
	self:refreshUI()
end

--设置天命化星状态
function M:setFatesState()
	local hero_Data = self.m_model:getSelectHeroData()
	local star_id,is_fate = self.m_model:getFatesInfo(hero_Data.oid) --获取星辰id，英雄是否领悟天命化星
	local star_info = self.m_model:getFateByStarId(star_id) --获取化星数据
	self.star_img.material = nil
	local hp_value,atk_value,def_value = 0,0,0
	local fate_open = self.m_model:getHeroStarBtnShow()  --是否开启天命化星页签
	if fate_open then --开启天命化星进行展示
		if not is_fate then  --没激活通过英雄id获取化星数据
			star_info,star_id = self.m_model:getFatesByHeroId(hero_Data.id)
			self.star_img.material = self.star_start_hui_naterial
		else
			hp_value,atk_value,def_value = self.m_model:setAdditionData(star_id,star_info.add_base,hero_Data.oid)
		end
		local star_start_num = self.m_model:getStarStartNum(star_id)
		local Img_bg = self:findGameObject("star_img")
		GameUtil:updateResourcesImg(Img_bg,"Texture/zh_cn/tmhx_start/"..star_info.star_icon)
		self:setTextByLanKey("hp_num", hp_value)
		self:setTextByLanKey("attack_num", atk_value)
		self:setTextByLanKey("def_num", def_value)
		local fate_num = self.m_model:getFateNum(star_start_num.heros or {})
		local star_text = Language:getTextByKey("destinyStar_text_0014", Language:getTextByKey(star_info.star_name),fate_num,#star_info.hero_group)
		self:setTextByLanKey("star_name_text",star_text)
	end
end

--更新技能信息
function M:updateSkill()
	local skills = self.m_model:getFateSkillData()
	--获取星辰开启数量
	local hero_Data = self.m_model:getSelectHeroData()
	local star_ids,is_fate = self.m_model:getFatesInfo(hero_Data.oid) --获取星辰id，英雄是否领悟天命化星
	local star_info,star_id = self.m_model:getFatesByHeroId(hero_Data.id)
	local star_start_num = self.m_model:getStarStartNum(tostring(star_id))
	local open_skill_num = self.m_model:getFateNum(star_start_num.heros or {})
	local fate_skill_icon_name = self.m_model:getFateSkillIconName(tostring(star_id)) or "icon_jinengkuang_ziwei" --天命技能边框
	for i = 1,4 do
		self:setObjectVisible("skill"..i.."_img_star",false)
		self:setObjectVisible("di_"..i, false)
	end
	for i = 1, #skills.name do
		local icon_name = skills.icon[i] or "JN_beimoshanzhuang1"
		local str_name = "skill"..i.."_img_star"
		local sk_img_name = "skill"..i.."_img_star"
		local sk_gary_img_name ="skill"..i.."_img_gray"
		local is_open_gray = true
		self:setImg(icon_name, "skill_icon", str_name)
		self:setImg(icon_name, "skill_icon", sk_gary_img_name)
		self:setImg(fate_skill_icon_name, "battle_ui", "skill_kuang_"..i)
		self:setObjectVisible(sk_img_name,true)
		self:setObjectVisible("di_"..i, true)
		if i <= open_skill_num and is_fate then
			is_open_gray = false
		end
		self:setObjectVisible(sk_gary_img_name,is_open_gray)
		local function clickCallback()
			self:updateMsg("skill_img_star", { name = skills.name[i],des = skills.des[i],click_transform = self:getSkillIcon(str_name) })
		end
		local str_btn = self:findButton(str_name).transform
		UIUtil.setButtonClick(str_btn, clickCallback)
	end
	if #skills.name == 4 then
		self:setObjectVisible("skill_effect_4", true)
		for k,v in pairs(self.SKILL_POS_4) do
			local skill_bg = self:findGameObject("di_"..k)
			local skill_ef = self:findGameObject("skill_effect_"..k)
			if not IsNull(skill_bg) then
				skill_bg.transform.localPosition = v.pos
			end
			if not IsNull(skill_ef) then 
				skill_ef.transform.localPosition = v.pos
			end
		end
	else
		self:setObjectVisible("skill_effect_4", false)
		for k,v in pairs(self.SKILL_POS_3) do
			local skill_bg = self:findGameObject("di_"..k)
			local skill_ef = self:findGameObject("skill_effect_"..k)
			if not IsNull(skill_bg) then
				skill_bg.transform.localPosition = v.pos
			end
			if not IsNull(skill_ef) then 
				skill_ef.transform.localPosition = v.pos
			end
		end
	end
end

function M:destroy()
	M.super.destroy(self)
end

function M:getSkillIcon(index)
	return self:findGameObject(index)
end

return M