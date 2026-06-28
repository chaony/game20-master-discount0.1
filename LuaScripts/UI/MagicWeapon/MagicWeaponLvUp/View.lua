local M = class("MagicWeaponLvUpView",LikeOO.OOPopBase)

M.m_uiName = "MagicWeapon/MagicWeaponLvUp"
M.m_iphoneXAdapter = true

function M:onEnter()
	self.right_parent = self:findGameObject("right_parent")
    self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 16})
    self:refreshUI()
	self:setTextByLanKey("close_title_text", "weapon_str_0002")
	self:setTextByLanKey("title_text", "new_str_0436")
	self.m_control:setOnceTimer(0.5, function ()
		self.m_model.m_transfer = "left_to_right"
	end)

end

function M:refreshUI()
	if self.m_model.m_wea_cfg == nil then
		return
	end
	local lv = self.m_model:getWeaLv()
	if lv == 1 then
		self:setObjectVisible("reset_btn", false)
	else
		self:setObjectVisible("reset_btn", true)
	end
	self:setTextByLanKey("wea_lv", string.cutTextForString(Language:getTextByKey("new_str_0075",lv)))
	local lv_max = self.m_model.m_wea_cfg.skill_limit
	self:setTextByLanKey("title_lv_text", "("..lv.."/"..lv_max..")")
	local heros = self.m_model:getWeaHeros()
	if next(heros) ~= nil then
		self:setObjectVisible("hero_jc_btn", true)
	else
		self:setObjectVisible("hero_jc_btn", false)	
	end
	local attrs = self.m_model:getWeaAttr()
	local cell_attrs = self:findGameObject("cell_attrs")
	UIUtil.destroyAllChild(cell_attrs.transform)
	for i = 1,2 do
	if attrs[i] then
			local cur_atr_data = attrs[i]
			local next_num = self.m_model:getAttrNextById(cur_atr_data[1])
			local atr_key = GameUtil:getAttrsKey(cur_atr_data[1])
			local attr_obj = GameUtil:createEqpLevelUp_Cell(atr_key,cur_atr_data[2],next_num)
			attr_obj.transform:SetParent(cell_attrs.transform, false)
			local luaBehaviour = UIUtil.findLuaBehaviour(attr_obj) 
			if luaBehaviour then
				local title_name = luaBehaviour:FindText("title")
				local num = luaBehaviour:FindText("num")
				local num2 = luaBehaviour:FindText("num2")
				title_name.color = Color.New(155/255, 173/255, 213/255)
				num.color = Color.New(1, 1, 1)
				num2.color = Color.New(0/255, 252/255, 0/255)
			end
		end
	end
	self:updateSkillDes()
	local cost_data = self.m_model:getWeaCost()
	if cost_data then
		self:setImg(cost_data.icon_name, cost_data.atlas_name, "cost_img")
		local cost_text = self:setTextByLanKey("cost_num", cost_data.user_num.."/"..cost_data.data_num)
		if cost_data.user_num >= cost_data.data_num then
			cost_text.color = GlobalConfig.COMMON_COLLOR.COMMON_1
		else
			cost_text.color = GlobalConfig.COMMON_COLLOR.COMMON_11
		end
	else

	end
end

function M:updateSkillDes()
	--等级/图标/名字/描述
	local lv,icon_img,name,des = self.m_model:getWeaSkill() 
	local next_des = self.m_model:getWeaNextSkill() 
	local name_img = self:findImage("name_img")
	GameUtil:updateResourcesImg(name_img, "Texture/zh_cn/".. self.m_model.m_wea_cfg.name)
	local wea_icon = self:findImage("wea_icon")
	GameUtil:updateResourcesImg(wea_icon, "Texture/common/".. self.m_model.m_wea_cfg.img)
	if #icon_img == 0 then
		icon_img = "JN_xingyi1"
	end
	if #des == 0 then
		des = ""
	end
	if #next_des == 0 then
		next_des = ""
	end
	self:setTextByLanKey("skill_name", name)
	self:setTextByLanKey("skill_des", des.."\n\n"..next_des)
	self:setTextByLanKey("skill_lv", lv)
	self:setImg(icon_img, "skill_icon", "skill_img")
	if self.m_model:checkMaxLv() == true then
		self:setObjectVisible("cost_bg", false)
		self:setObjectVisible("cost_img", false)
		self:setObjectVisible("cost_num", false)
		self:setObjectVisible("level_max_text", true)
		self:setObjectVisible("level_up_btn", false)
	else
		self:setObjectVisible("level_max_text", true)
		self:setObjectVisible("level_up_btn", true)
		self:setObjectVisible("cost_bg", true)
		self:setObjectVisible("cost_img", true)
		self:setObjectVisible("cost_num", true)
	end
end


function M:destroy()
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
    M.super.destroy(self)
end

return M