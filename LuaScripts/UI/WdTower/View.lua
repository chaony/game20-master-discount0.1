local M = class("WdTowerView",LikeOO.OOPopBase)

M.m_uiName = "WdTower/WdTower"
M.m_iphoneXAdapter = true
M.m_size_type = 1

function M:onEnter()
	self:setTextByLanKey("close_title_text", "wdtower_text_0001")
	if self.m_model:getDesByKey("title") then
		title_str = self.m_model:getDesByKey("title")
		self:setTextByLanKey("close_title_text", title_str)
	end
	self:setTextByLanKey("left_bottom_tips", "wdtower_text_0002")
	self:setTextByLanKey("next_text","four_tower_str_0007")
	self:setTextByLanKey("relic_formation_btn_text","four_tower_str_0014")
	self:setTextByLanKey("rank_btn_text","yinTower_text_0007")
	self:setTextByLanKey("gift_btn_text","yinTower_text_0008")
	self:setObjectVisible("yun_left_img",false)
	self:setObjectVisible("yun_right_img",false)
	self.left_transform = self:findGameObject("yun_left_img")
	self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 13})
	self.relic_formation_btn = self:findGameObject("relic_formation_btn");
	self.m_bag_action = false;
	self.m_heirloom_fly_player = self:findGameObject("heirloom_fly_player")
	self.m_scroll_cache = {}
	self:refreshUI()
end

function M:refreshBg()
	local main_bg_img = self:findImage("main_bg_img")
	local bg_name = self.m_model:getBattleCfgByKey("background")
	if bg_name then
		GameUtil:updateResourcesImg( main_bg_img, "Texture/map_plot/" .. bg_name)
	end
end

function M:refreshUI()
	local cur_times = self.m_model.m_data.times or 0
	local total_times = self.m_model.m_data.total_times or 0
	self:setTextByLanKey("hero_lv_des_text","wdtower_text_0008", total_times - cur_times .. "/" .. total_times)

	--if self.m_model:isMaxFloor() then
	--	self:setTextByLanKey("top_text",Language:getTextByKey("yinTower_text_0011")) 
	--elseif self.m_model:getActStatus() == 2 then
	--	self:setTextByLanKey("top_text",Language:getTextByKey("yinTower_text_0013"))
	--else
	--	self:setTextByLanKey("top_text",Language:getTextByKey("wdtower_text_0006",self.m_model.current_flood))
	--end
	local my_score = self.m_model.m_data.score
	self:setTextByLanKey("top_text",Language:getTextByKey("wdtower_text_0006", my_score))
	self.isNext_flood = self.m_model:IsNextFlood()
	self:setObjectVisible("next_btn",false)
	self:refreshRedPoint()
	--快速导航
	self:setObjectVisible("guide_btn", true)
	self:refreshEnemy()
	self:refreshRaceIcon()
	self:refreshBg()
end

function M:refreshRaceIcon()
	local race_type = self.m_model:getTowerStageRace()
	for i = 1, 6 do
		self:setObjectVisible("race_img_" .. i, race_type[i] and true or false)
		if race_type[i] then
			local race_icon = Language:getTextByKey(GlobalConfig.TYPE_HERO_RACE[race_type[i]].race_icon)
			self:setImg(race_icon, ResourceUtil:getLanAtlas(), "race_img_" .. i)
		end
	end
end

function M:refreshEnemy()
	local seat = self.m_model:getBattleCfgByKey("seat") or {}
	local data = self.m_model:getTowerStageData()
	local score_tab = self.m_model:getEnemyScore()
	local battle_scale = self.m_model:getTowerStageBattleScale()
	for i = 1, 3 do
		local cell = self:findGameObject("cell_" .. i)
		local luaBehaviour = UIUtil.findLuaBehaviour(cell)
		local hero_sp = luaBehaviour:FindGameObject("hero_sp")
		local enemy_combat = self.m_model:getEnemyCombat(i)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_zl_text", "friend_str_0041")
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_zl_num_text", GameUtil:formatValueToString(enemy_combat * battle_scale[i]))
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_jf_text", "new_str_0222", score_tab[i])

		local reward = self.m_model:getEventsGifs(i)
		
		local reward_node = luaBehaviour:FindGameObject("reward_node")
		GameUtil:createRewards(reward_node.transform, reward, true, true, nil, 0.7)

		local hero_data = self.m_model:getHeroInfo(tonumber(data[i].show_pic))
		local hero_spine_name = hero_data.hero_spine
		GameUtil:updateSpineLoadSet(hero_sp,"RoleSpine/" .. hero_spine_name,"idle", 0,true)

		if seat[i] then
			local pos_x, pos_y, scale_num = seat[i][1], seat[i][2], seat[i][3]
			UIUtil.setLocalPosition(cell.transform, pos_x, pos_y)
			UIUtil.setLocalScale(cell.transform, scale_num)
		end
	end
end

--刷新时间
function M:updateTime()
	local remain_tim = self.m_model:getEndTs() --剩余时间
	if self.m_model:getActStatus() == 1 then
		local remain_day, remain_hour, remain_min, remain_sec = GameUtil:getTimeLayoutBySecond(remain_tim) --换算剩余时间
		if remain_day > 0  then
			self:setTextByLanKey("reset_time_text", Language:getTextByKey("yinTower_text_0002",remain_day)) --重置剩余天
		elseif remain_day <= 0 and remain_hour > 0 then
			self:setTextByLanKey("reset_time_text", Language:getTextByKey("yinTower_text_0003",remain_hour)) --重置剩余小时
		elseif remain_day <= 0 and remain_hour <= 0 and remain_min > 0 then
			self:setTextByLanKey("reset_time_text", Language:getTextByKey("yinTower_text_0004",remain_min)) --重置剩余分钟
		elseif remain_day <= 0 and remain_hour <= 0 and remain_min <= 0 and remain_sec > 0 then
			self:setTextByLanKey("reset_time_text", Language:getTextByKey("yinTower_text_0005",remain_sec)) --重置剩余秒
		else
			self:setTextByLanKey("reset_time_text", Language:getTextByKey("yinTower_text_0005",remain_sec)) --重置剩余秒
			self:updateMsg("battle_end_refresh_ui") --重置数据
		end
		if self.remain_day == nil or self.remain_day > remain_day then
			self.remain_day = remain_day
		end
	elseif self.m_model:getActStatus() == 2 and remain_tim <= 0 then
		GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
		self:updateMsg(99999)
	else
		--self:setTextByLanKey("top_text",Language:getTextByKey("yinTower_text_0013"))
		self:setTextByLanKey("reset_time_text", "yinTower_text_0013") --重置剩余秒
	end
end

function M:refreshRedPoint()
	local is_red = RedPointUtil:hasRedPointById(294)
	--local is_red2 = RedPointUtil:hasRedPointById(24402)
	self:setObjectVisible("gift_red_point", is_red or is_red2)
end


function M:showEffectTX()
	self:setObjectVisible("UI_Fivelines_ShangGuang_01", true)
	self.m_control:setOnceTimer(1.5, function ()
		self:setObjectVisible("UI_Fivelines_ShangGuang_01", false)
	end)
end

function M:showCloud()
	local fivelinesOpenAnim = ResourceUtil:LoadUIGameObject("FivelinesNew/FivelinesOpenAnim", Vector3.zero, nil)
	fivelinesOpenAnim.transform:SetParent(self.m_rootView.transform, false)
	self.m_control:setOnceTimer(1.5, function() UIUtil.destroyObject(fivelinesOpenAnim) end)
end

function M:tantanBag()
	if self.m_bag_action ~= true then
		self.m_bag_action = true
		local bag_togglebtn = self.relic_formation_btn
		local sequence = Tweening.DOTween.Sequence()
		sequence:Append(bag_togglebtn.transform:DOScale(1.2, 0.05))
		sequence:Append(bag_togglebtn.transform:DOScale(1.0, 0.05))
		sequence:Append(bag_togglebtn.transform:DOScale(1.2, 0.05))
		sequence:Append(bag_togglebtn.transform:DOScale(1.0, 0.05))
		sequence:Append(bag_togglebtn.transform:DOScale(1.2, 0.05))
		sequence:Append(bag_togglebtn.transform:DOScale(1.0, 0.05))
		sequence:OnComplete(function ()
			self.m_bag_action = false
		end)
		sequence:SetAutoKill(true)
	end
end

function M:maskOn(last_time)
	self:setObjectVisible("Mask_img", true)
	self.m_control:setOnceTimer(last_time, function ()
		self:setObjectVisible("Mask_img", false)
	end)
end

function M:destroy()
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
	M.super.destroy(self)
end

return M