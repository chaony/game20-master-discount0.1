local M = class("WorldBossSelectMainView",LikeOO.OOPopBase)

M.m_uiName = "Activities/WorldBoss/WorldBossSelectMain"
M.m_size_type = 1
M.m_iphoneXAdapter = true
function M:onEnter()
	self:setTextByLanKey("close_title_text", "world_boss_str_0029")
	self.m_gray_image = self:findImage("gray_img")
	self.boss_keys = {
		[1] = "worldboss",
		[2] = "activeboss",
		[3] = "legend",
		[4] = "jubao",
	}
	self.boss_ui = {
		["worldboss"] = {
			--名字
			name = "worldboss_name",
			--次数
			info_title = "worldboss_num_title_txt",
			--次数
			info = "worldboss_num_txt",
			--红点序号
			red_num = 29,
			red_point = "worldboss_red_point",
			show_reward_id = 504,
			reward_node = "worldboss_reward_node",
		},
		["activeboss"] = {
			--名字
			name = "activeboss_name",
			--次数
			info_title = "activeboss_num_title_txt",
			--次数
			info = "activeboss_num_txt",
			--红点序号
			red_num = 139,
			red_point = "activeboss_red_point",
			open_condition = 170,
			show_reward_id = 505,
			reward_node = "activeboss_reward_node",
		},
		["legend"] = {
			--名字
			name = "legend_name",
			--次数
			info_title = "legend_num_title_txt",
			--次数
			info = "legend_num_txt",
			--红点序号
			red_num = 141,
			red_point = "legend_red_point",
			open_condition = 119,
			show_reward_id = 506,
			reward_node = "legend_reward_node",
		},
		["jubao"] = {
			--名字
			name = "jubao_name_text",
			--红点序号
			red_num = 140,
			red_point = "jubao_red_point",
		},
	}
	self.area_name_key = {
		["worldboss"] = {name = "a_slyj_name_xuanwu", info_title = "world_boss_str_0033"},
		["activeboss"] = {name = "a_slyj_name_xiake", info_title = "legend_str_025"},
		["legend"] = {name = "a_slyj_jianghu", info_title = "legend_str_025"},
		["jubao"] = {name = "jubaoShan_str_004", info_title = "legend_str_025"},
	}
	self:updateTime()
	self:refreshUI()
end

function M:refreshUI()
	for i, v in ipairs(self.boss_keys) do
		--得到ui数据
		local ui_data = self.boss_ui[v];
		local server_data = self.m_model:getBossData(v);
		self:updateBoss(ui_data, server_data, v)
	end

	--快速导航
	self:setObjectVisible("guide_btn", true)
end

function M:refreshActiveBossNode(is_open, server_data)
	self:setObjectVisible("activeboss_node", true)
	local activeboss_btn = self:findImage("activeboss_btn")
	local activeboss_title_key = "legend_str_025"
	local bl,tips = RedPointUtil:hasRedPointById(139)
	if is_open then
		activeboss_btn.material = nil
		self:setTextByLanKey("activeboss_num_title_txt", self.area_name_key["activeboss"].info_title, server_data.num)
	else
		activeboss_btn.material = self.m_gray_image.material
		self:setTextByLanKey("activeboss_num_title_txt", "world_boss_str_0030")
		self:setTextByLanKey("activeboss_num_txt", "")
		bl = false
	end
	self:setObjectVisible("activeboss_red_point", bl == true)
end

function M:updateBoss(ui_data, server_data, key)
	if ui_data.info_title then
		self:setTextByLanKey(ui_data.info_title, self.area_name_key[key].info_title, server_data.num)
		self:setTextByLanKey(ui_data.info, server_data.num)
	end
	if ui_data.red_num then
		local bl,tips = RedPointUtil:hasRedPointById(ui_data.red_num)
		self:setObjectVisible(ui_data.red_point, bl == true)
	end
	if ui_data.open_condition ~= nil then
		local open_flag, tips_str = BtnOpenUtil:isBtnOpen(ui_data.open_condition)
		if key == "activeboss" then--侠客试炼的node特殊处理
			self:refreshActiveBossNode( open_flag, server_data)
		else
			self:setObjectVisible(key.."_node", open_flag)
		end
	end
	
	if ui_data.show_reward_id and ui_data.reward_node then
		local show_rewards = ConfigManager:getCommonValueById(ui_data.show_reward_id,0)
		if show_rewards ~= 0 then
			for i = 1, 2 do
				local reward_data = RewardUtil:getProcessRewardData(show_rewards[i])
				local item_node = self:findGameObject(ui_data.reward_node .. i)
				self:setObjectVisible(ui_data.reward_node .. i, true)
				local ui_element = GameUtil:updateItemElementByData(item_node, reward_data, false, true)
				ui_element.red_point_img:SetActive(false)
			end
		end
	end
	
	if string.find(ui_data.name, "text") ~= nil then
		self:setTextByLanKey(ui_data.name,self.area_name_key[key].name)
	else
		self:setImg(self.area_name_key[key].name, ResourceUtil:getLanAtlas(), ui_data.name)
	end

end

function M:updateTime()
	local legend_time = self.m_model:getLegendTime()
	if self.legend_last_time ~= legend_time then
		self:setTextByLanKey("legend_num_txt", legend_time)
		self.legend_last_time = legend_time
	end
	local activeboss_time = self.m_model:getActivebossTime()
	if self.activeboss_last_time ~= activeboss_time then
		self:setTextByLanKey("activeboss_num_txt", activeboss_time)
		self.activeboss_last_time = activeboss_time
	end
end

function M:destroy()
	M.super.destroy(self)
end

return M