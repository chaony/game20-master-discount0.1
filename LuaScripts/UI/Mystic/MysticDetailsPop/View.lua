local M = class("MysticDetailsPopView",LikeOO.OOPopBase)

M.m_uiName = "Mystic/MysticDetailsPop"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("upgrade_btn_text", "mystic_str_0002")
	self:setTextByLanKey("remove_btn_text", "mystic_str_0005")
	self:setTextByLanKey("replace_btn_text", "mystic_str_0006")
	self:setText("type_text", Language:getTextByKey("mystic_str_0007") .. ":")
	self.mystic_icon = self:findGameObject("mystic_icon")
	self:refreshUI()	
end

function M:refreshUI()
	self:setObjectVisible("upgrade_btn", self.m_model.m_solt ~= nil)
	self:setObjectVisible("remove_btn", self.m_model.m_solt ~= nil)
	self:setObjectVisible("replace_btn", self.m_model.m_solt ~= nil)
	local data, cfg
	if self.m_model.m_oid then
		data, cfg = UserDataManager.mystic_data:getMysticDataById(self.m_model.m_oid)
	else
		cfg = UserDataManager.mystic_data:getMysticConfigByCid(self.m_model.m_id)
	end
	local cur_cfg = cfg[self.m_model.m_evo]
	self:setTextByLanKey("common_title_text", cur_cfg.name)
	self:setTextByLanKey("des_text", cur_cfg.des)

	local evo = self.m_model.m_evo > 5 and 5 or self.m_model.m_evo
	local star = self.m_model.m_evo - evo
	
	for i=1, 5 do
		local star_img = self:findGameObject("star_" .. i)
		if star_img then
			star_img:SetActive(i <= star)
		end
	end

	if cur_cfg.race_id > 0 then
		local text_key = GlobalConfig.TYPE_HERO_RACE[cur_cfg.race_id].name
		self:setText("type_text_2", Language:getTextByKey(text_key) .. Language:getTextByKey("new_str_0391"))
	elseif cur_cfg.hero_type > 0 then
		local text_key = GlobalConfig.TYPE_HERO_PROPERTY[cur_cfg.hero_type].name
		self:setText("type_text_2", Language:getTextByKey(text_key) .. Language:getTextByKey("new_str_0391"))
	-- elseif cur_cfg.hero_id  > 0 then -- 临时
	-- 	local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(cur_cfg.hero_id)
	-- 	self:setText("type_text_2", Language:getTextByKey(hero_cfg.name))
	else
		self:setText("type_text_2", Language:getTextByKey("mystic_str_0019"))
	end

	local attr_cfg = GameUtil:getAttrCfg(cur_cfg.attr[1][1])
	self:setText("value_text", Language:getTextByKey(attr_cfg.name) .. "+" .. (attr_cfg.is_percent == 1 and tostring(cur_cfg.attr[1][2]*100) .. "%" or tostring(cur_cfg.attr[1][2])))
	
	self:setTextByLanKey("type_text", GlobalConfig.TYPE_MYSTIC[cur_cfg.type].name)
	-- Logger.log(cur_cfg,"cur_cfg ====")
	local group_cfg = ConfigManager:getCfgByName("mystic_buff")[cur_cfg.group][cur_cfg.buff_lv or 1]
	self:setTextByLanKey("skill_title_text", group_cfg.name)
	self:setTextByLanKey("skill_des_text", group_cfg.dse)

	GameUtil:updateItemElement(self.mystic_icon, {RewardUtil.REWARD_TYPE_KEYS.MYSTIC, self.m_model.m_id, self.m_model.m_evo, oid = self.m_model.m_oid}, false, false)
end

return M