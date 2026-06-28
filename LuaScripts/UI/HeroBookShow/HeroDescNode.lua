--- 简介
local M = class("HeroDescNode",LikeOO.OOUIbase)

M.m_uiName = "HeroBookShow/HeroDescNode"
M.m_iphoneXAdapter = true

function M:onEnter()
	self.attr_parent = self:findGameObject("pro_parent")
    self:refreshUI()    
end

function M:refreshUI()
	self:setSpine()
	self:setBaseInfo()
	self:updateSkill()
	self:setObjectVisible("next_btn", self.m_model.m_type == 1)
	self:setObjectVisible("last_btn", self.m_model.m_type == 1)
	self:updateAttrs(self.m_model:getHeroAttrs())
end

function M:setBaseInfo()
	local cfg = self.m_model:getCfgByCid(self.m_model.m_cur_id)
	if cfg then
		local common = GlobalConfig.HERO_QUALITY_COMMON_SETTING[cfg.max_evo].icon --英雄品质icon
		self:setImg(common, "common_ui", "souch_img")
		local race = GlobalConfig.TYPE_HERO_RACE[cfg.race].big_race_icon --英雄种族icon
		self:setImg(race, ResourceUtil:getLanAtlas(), "camp_img_btn")
		local type = GlobalConfig.TYPE_HERO_PROPERTY[cfg.type].pro_icon --英雄属性icon
		self:setImg(type, "hero_ui", "pro_img_btn")
		self:setTextByLanKey("hero_desc_text", Language:getTextByKey(cfg.des))
		self:setObjectVisible("get_reward_btn", self.m_model:checkRedPoint())
	end
end
--更新技能信息
function M:updateSkill()
	local skills = self.m_model:getHeroSkill()
	for i = 1,4 do
		self:setObjectVisible("skill"..i.."_img",false)
		self:setObjectVisible("di_"..i, false)
	end
	for k,v in pairs(skills) do 
		if k <= 4 then
			local str_name = "skill"..k.."_img"
			local str_num = "sk_num_"..k
			local cur_skill = GameUtil:getSkill(v[1][1]) 
			local sk_img_name = "skill"..k.."_img"
			local lv = #v
			if cur_skill ~= nil then
				self:setImg(cur_skill.icon, "skill_icon", str_name)
				self:setTextByLanKey (str_num, lv)
				self:setObjectVisible(sk_img_name,true)
				self:setObjectVisible("di_"..k, true)
			end
		end
	end
end

--[[
    @desc: 英雄动画
]]
function M:setSpine()
	local icon = self.m_model:getHeroBigAnim()
	if self.cacheSpineName == icon then
		return
	else
		self.cacheSpineName = icon	
	end
	local pos_x = 0
	local pos_y = -142
	local play_img = self:findGameObject("hero_spine")
 	local sg = play_img:GetComponent("SkeletonGraphic")
	local hehe = ResourceUtil:GetSk(self.cacheSpineName, "rolespine_"..string.lower(self.cacheSpineName))
	sg.skeletonDataAsset = hehe
	sg:Initialize(true)
	local linshi_pos = self.m_model:getSpinePos()
	pos_x = pos_x + linshi_pos[1]
	pos_y = pos_y + linshi_pos[2]
	UIUtil.setLocalPosition(play_img.transform,pos_x, pos_y, 0)
end

function M:updateAttrs(attrs)
	UIUtil.destroyAllChild(self.attr_parent.transform)
	local index = 1
	local max = #attrs
	while  max > index do
		local attr_item = self:creatAttrItem()
		attr_item.transform:SetParent(self.attr_parent.transform, false)
		local LuaBehaviour  = UIUtil.findLuaBehaviour(attr_item.transform) 
		if LuaBehaviour then
			LuaBehaviourUtil.setObjectVisible(LuaBehaviour,"bg", true)
			local cell_data1 = attrs[index]
			index = index + 1
			local cell_data2 = attrs[index]
			if cell_data1 then
				LuaBehaviourUtil.setTextByLanKey(LuaBehaviour,"attr_name1_text", GameUtil:getAttrsName(cell_data1[1])..":")
				LuaBehaviourUtil.setTextByLanKey(LuaBehaviour,"attr_num1_text", GameUtil:formatValueToString(cell_data1[2]))
				LuaBehaviourUtil.setObjectVisible(LuaBehaviour,"attr_name1_text", true)
				LuaBehaviourUtil.setObjectVisible(LuaBehaviour,"attr_num1_text", true)
			end
			if cell_data2 then
				LuaBehaviourUtil.setObjectVisible(LuaBehaviour,"attr_name2_text", true)
				LuaBehaviourUtil.setObjectVisible(LuaBehaviour,"attr_num2_text", true)
				LuaBehaviourUtil.setTextByLanKey(LuaBehaviour,"attr_name2_text", GameUtil:getAttrsName(cell_data2[1])..":")
				LuaBehaviourUtil.setTextByLanKey(LuaBehaviour,"attr_num2_text", GameUtil:formatValueToString(cell_data2[2]))
			end
		end
		index = index + 1
	end
end


function M:creatAttrItem()
	local cell = ResourceUtil:LoadUIGameObject("HeroInfo/HeroAttribute_Cell", Vector3.zero,nil)
	return cell
end

return M