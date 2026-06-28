local M = class("LegendView",LikeOO.OOPopBase)

M.m_uiName = "Legend/LegendIndex"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
	self:setTextByLanKey("close_title_text", "legend_str_001")
	self:setTextByLanKey("enter_btn_text", "legend_str_002")
	self:setTextByLanKey("story_name_text", "legend_str_003")
	self:setTextByLanKey("rule_name_text", "legend_str_004")
	self:setTextByLanKey("level_title_text", "legend_str_016")
	self:setTextByLanKey("history_title", "legend_str_031")
	self:setTextByLanKey("reward_text", "new_str_0373")
	self:setTextByLanKey("mopup_btn_text", "new_str_0573")
	self:setTextByLanKey("right_content_text", "legend_str_035")
	self:setTextByLanKey("rank_text", "new_str_0235")
	UserDataManager:removeRedDotByKey("legend")
	self:refreshUI()
end

function M:refreshUI()
	local legend = self.m_model:getLegend()
	if legend ~= nil then
		self:setTextByLanKey("legend_name_text", legend.name)
		self:setTextByLanKey("story_text", legend.story)
		self:setTextByLanKey("rule_text", legend.rule)
		local data = self.m_model.m_data
		
		local record = data.progress[tostring(legend.type)] or 0
		--self:setObjectVisible("history_content", record > 0)
		self:refreshRecordNum(record)

		self:refreshLevelNum(data.level)
		
		local legend_upgrade_table = ConfigManager:getCfgByName("legend_upgrade")
		local cfg = legend_upgrade_table[data.legend_type][data.level]
		if cfg ~= nil then
			self:setObjectVisible("attr_bg", true)
			if data.legend_type == 1 then
				self:setTextByLanKey("attr_text", "legend_str_017")
				self:setTextByLanKey("attr_value_text", self:getAttrStr(cfg.attr_add.hp))
			elseif data.legend_type == 2 then
				self:setTextByLanKey("attr_text", "legend_str_018")
				self:setTextByLanKey("attr_value_text", self:getAttrStr(cfg.attr_add.atk))
			end
		else
			self:setObjectVisible("attr_bg", false)
		end
		local chapter_img = self:findGameObject("chapter_img")
		GameUtil:updateResourcesImg(chapter_img, "Texture/biography/" .. legend.pic)

		local legend_quest = UserDataManager:getRedDotByKey("legend_quest")
		--self:setObjectVisible("UI_Bio_BaoXiang_001", legend_quest == 1)
		self:setObjectVisible("reward_btn_point_img", legend_quest == 1)
		
		if self.m_model.talk_group_id ~= nil then
			local random_talk_cfg = ConfigManager:getCfgByName("legend_random_talk")
			local cfg = random_talk_cfg[self.m_model.talk_group_id]
			self:playTalk(cfg, self.m_model.talk_start)
		end
		
		self:setObjectVisible("mopup_btn", self.m_model:isAtTopLevel())
	end

	--快速导航
	self:setObjectVisible("guide_btn", true)
end

function M:playTalk(cfg, id)
	self:setTextByLanKey("talk_text", cfg[id].des)
	self.timer = self.m_control:setOnceTimer(cfg[id].time, function()
		local next_id = self.m_model.talk_list[id]
		if next_id == nil then
			self:playTalk(cfg, self.m_model.talk_start)
		else
			self:playTalk(cfg, next_id)
		end
	end)
end

function M:getAttrStr(attr)
	if attr > 0 then
		return tostring(GameUtil:formatNum(attr * 100)) .. "%"
	else
		return Language:getTextByKey("legend_str_019")
	end
end

function M:refreshLevelNum(num)
	local num_str = tostring(num)
	for i = 1, 2 do
		if i <= string.len(num_str) then
			self:setImg("a_jhcg_nandu_"..string.sub(num_str,i,i), "main_ui", "level"..tostring(i))
			self:setObjectVisible("level"..tostring(i), true)
		else
			self:setObjectVisible("level"..tostring(i), false)
		end
	end
end

function M:refreshRecordNum(num)
	local num_str = tostring(num)
	for i = 1, 4 do
		if i <= string.len(num_str) then
			self:setImg("a_jhcg_nandu_"..string.sub(num_str,i,i), "main_ui", "num"..tostring(i))
			self:setObjectVisible("num"..tostring(i), true)
		else
			self:setObjectVisible("num"..tostring(i), false)
		end
	end
end

function M:destroy()
	self.m_control:removeTimer(self.timer)
	M.super.destroy(self)
end
	
return M