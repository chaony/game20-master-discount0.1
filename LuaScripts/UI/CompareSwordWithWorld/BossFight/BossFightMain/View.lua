local M = class("BossFightMainView",LikeOO.OOPopBase)

M.m_uiName = "CompareSwordWithWorld/BossFight/BossFightMain"
M.m_size_type = 1
M.m_iphoneXAdapter = true

local _state_data = {
	{img = "a_hd_jstx_ssjl_xiaobiaoqiandi1",color = Color(191/255,119/255,66/255),text = "boss_fight_main_text_008"}, --进行中
	{img = "a_hd_jstx_ssjl_xiaobiaoqiandi2",color = Color(191/255,119/255,66/255),text ="boss_fight_main_text_007"}, --已开放
	{img = "a_hd_jstx_ssjl_xiaobiaoqiandi3",color = Color(108/255,81/255,45/255),text ="boss_fight_main_text_006"}, --明日开放
	{img = "a_hd_jstx_ssjl_xiaobiaoqiandi3",color = Color(108/255,81/255,45/255),text ="game_of_heaven_and_earth_reward_text_006"}, 
}
local _boss_transform_ = {  --记录boss模型在场景中的transform三项数据 
	{P = Vector3(0, 0.35, -0.3), R = Quaternion.Euler(20, 0, 0), S = Vector3(0.1, 0.1, 0.1)},
}
local _left_btn_img = {"a_hd_jstx_ssjl_btn_h","a_hd_jstx_ssjl_btn_n"} --1.h 高亮 2.n 正常
local _ready_text_color = {
	Color(183/255,65/255,65/255) , --红
	Color(207/255,193/255,162/255) ,	--黄
}

function M:onEnter()
	self.m_gray_img = self:findImage("img_gray")
	self.skill_panel = self:findGameObject("skill_panel")
	self.GameObject3D = self:findGameObject("GameObject3D")
	self.role_parent = self:findGameObject("role_3d")
	
	self:setTextByLanKey("rank_title_text", "boss_fight_main_text_001")
	self:setTextByLanKey("close_title_text", self.m_model.m_actives_name)
	self:setTextByLanKey("challenge_btn_text", "boss_fight_main_text_002")
	self:setTextByLanKey("new_rank_btn_text", "boss_fight_main_text_003")
	self:setTextByLanKey("top_output_name_text", "boss_fight_main_text_004")
	self:setTextByLanKey("shili_name", "boss_fight_main_text_009")
	self:setTextByLanKey("rank_desc_text", "boss_fight_main_text_0011")
	self:setTextByLanKey("shop_text","compare_sword_race_text_049")	--剑试商店
	self:setTextByLanKey("no_rank_text", self.m_model.m_actives_name)
	self:setObjectVisible("down_time_text",true)
	self:setObjectVisible("RImg_boss",true)
	self:setObjectVisible("ready_text" , false)

	self.GameObject3D.transform:SetParent(self.m_rootView.transform, false)
	UIUtil.setScale(self.GameObject3D.transform,1,1,1)
	self:refreshUI()
	self:setStageImg()
	self:updateActivityTimer()
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.NET_DATA_UPDATE_EVENT, {self, self.reqErrorEvent}) 
	self:creatRole3D()
	self:checkAndPlayVideo() 
end

function M:refreshUI()
	local curBossMaxDamage = 0
	local battleId_idx = tostring(self.m_model.m_select_data.battle_id)
	if self.m_model.m_boss_max_damage and self.m_model.m_boss_max_damage[battleId_idx] then
		curBossMaxDamage = self.m_model.m_boss_max_damage[battleId_idx].damage or 0
	end

	self:setTextByLanKey("top_output_text", GameUtil:formatValueToString(curBossMaxDamage))
	self:createLoopScroll()
	self:raceNode()
	self:updateBossSkill()
	self:updateActiveImg()
	self:setSpine()
	self:refreshRankNode()
	self:creatRole3D()
	
	local showChallengeBtn = self.m_model.m_active_day >= self.m_model.m_boss_cfg[self.m_model.m_select_data.id].day and self.m_model.m_phase ~= 8 and self.m_model.m_phase ~= 1
	local challenge_btnGO = self:findGameObject("challenge_btn")
	challenge_btnGO:SetActive(showChallengeBtn)
	local ready_text2 = self:findText("ready_text2") 
	ready_text2.color = self.m_model.m_phase == 1 and _ready_text_color[2] or _ready_text_color[1]
end

--左侧Boss列表
function M:createLoopScroll()
	local data = self.m_model.m_boss_cfg
	if self.m_scroll_view == nil then
		local loopscroll = self:findGameObject("tab_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_obj, cell_data)
				self:update_tag(index, cell_obj, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
				--if index > self.m_model.m_phase_day then return end
				if click_name == "btn_notOpen" then
					self:updateMsg("pop_not_open" , {index = index})
				else
					self:updateMsg("switch_tab",cell_data)
				end
			end,
			ui_name = self.m_uiName
		}
		self.m_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_scroll_view:reloadData(data, true, nil, true)
	end
end

function M:update_tag(index, obj, data)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	if luaBehaviour then
		local tag_name = luaBehaviour:FindText("tag_name_text")
		local btn_notOpen = luaBehaviour:FindGameObject("btn_notOpen")
		local text_flag = self.m_model.m_select_data.id == index --self.m_model.m_select_data.battle_id == data.battle_id
		local tips_img = _state_data[1].img
		local tips_str = _state_data[1].text
		local tips_color = _state_data[1].color
		btn_notOpen:SetActive(false)
		if self.m_model.m_phase  == 1 then
			--处于阶段一	：boss准备阶段
			tips_img = _state_data[4].img
			tips_str = _state_data[4].text
			tips_color = _state_data[4].color
			local tag_img = luaBehaviour:FindImage("tag_btn")
			tag_img.material = self.m_gray_img.material
			btn_notOpen:SetActive(true)
		elseif self.m_model.m_active_day > data.day then
			tips_img = _state_data[2].img
			tips_str = _state_data[2].text
			tips_color = _state_data[2].color
		elseif self.m_model.m_active_day < data.day then
			local idx = 4
			btn_notOpen:SetActive(true)
			local tag_img = luaBehaviour:FindImage("tag_btn")
			tag_img.material = self.m_gray_img.material
			if self.m_model.m_active_day + 1 == data.day then  --预览一天
				idx = 3 
				tag_img.material = nil
				btn_notOpen:SetActive(false)
			end 
			tips_img = _state_data[idx].img
			tips_str = _state_data[idx].text
			tips_color = _state_data[idx].color
		end
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"tag_normal_name_text",self.m_model.m_boss_cfg[index].name) --凶手降临
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"tag_select_name_text",self.m_model.m_boss_cfg[index].name) --凶手降临
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"tag_desc_text",data.tips) --特性描述
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"tag_select_name_text",text_flag)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"tag_desc_text",text_flag)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"tag_normal_name_text", not text_flag)
		local icon_img = text_flag and _left_btn_img[1] or _left_btn_img[2]
		LuaBehaviourUtil.setImg(luaBehaviour, "tag_tips", tips_img, "active_ui")
		local tips_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "tag_tips_name_text",tips_str)
		tips_text.color = tips_color 
		local img = LuaBehaviourUtil.setImg(luaBehaviour, "tag_btn", icon_img, "active_ui")
		img:SetNativeSize()
	end
end

--boss技能
function M:updateBossSkill()
	local stage_battle = ConfigManager:getCfgByName("stage_battle_active")
	local skill_detail = ConfigManager:getCfgByName("skill_detail")
	local battle_cfg = stage_battle[self.m_model.m_select_data.battle_id]
	local boss = battle_cfg.monster[battle_cfg.worldboss_position]
	if boss and next(boss) then
		local hero_detail = ConfigManager:getCfgByName("hero_detail")
		local boss_cfg = hero_detail[boss.id]
		local num = self.skill_panel.transform.childCount
		for i=1,num do
			local skill_bg = self.skill_panel.transform:GetChild(i-1)
			skill_bg.gameObject:SetActive(false)
			if i <= #boss_cfg.skill then
				skill_bg.gameObject:SetActive(true)
				local skill_img = self:findGameObject(string.format("skill_%d_img", i))
				local skill = GameUtil:getSkill(boss_cfg.skill[i][self.m_model.m_select_data.id][1])
				UIUtil.setImg(skill_img, skill.icon, "skill_icon")
			end
		end
	end		
end

--更新势力
function M:raceNode()
	local races = self.m_model.m_select_data.race or {}
	for i = 1,3 do
		if races[i] and GlobalConfig.TYPE_HERO_RACE[races[i]] then
			self:setObjectVisible("shili"..i, true)
			local race_img_info = GlobalConfig.TYPE_HERO_RACE[races[i]]
			LuaBehaviourUtil.setImg(self.m_luaBehaviour, "shili"..i, race_img_info.race_icon, ResourceUtil:getLanAtlas())
		else
			self:setObjectVisible("shili"..i, false)
		end
	end
end

--排行榜前三名
function M:refreshRankNode()
	local rank_data = self.m_model.m_top_three_info
	self:setObjectVisible("rank_content_node", rank_data and #rank_data > 0)
	--self:setObjectVisible("no_rank_img", not(rank_data) or #rank_data == 0)
	if rank_data and #rank_data > 0  then
		for i = 1, 3 do
			if rank_data[i] then
				self:setObjectVisible("rank_icon_" .. i, true)
				self:setObjectVisible("rank_name_text_" .. i, true)
				self:setText("rank_name_text_" .. i, rank_data[i].user.name)
			else
				self:setObjectVisible("rank_icon_" .. i, false)
				self:setObjectVisible("rank_name_text_" .. i, false)
			end
		end
	end
end

--更新倒计时
function M:updateActivityTimer()
	local end_ts = self.m_model:getEndTs()
	
	if self.m_model.m_phase == 8 or self.m_model.m_phase == 1 then	--1 boss准备期 8 结束后展示期
		self:setObjectVisible("ready_text" , true)
	end
	
	if end_ts >= 0 then
		local time_txt = GameUtil:formatTimeBySecond(end_ts, 999)
		self:setTextByLanKey("down_time_text","boss_fight_main_text_0010", time_txt)
		self:setTextByLanKey("ready_text", self.m_model.m_phase == 8 and "boss_fight_main_text_0012" or "")
		self:setTextByLanKey("ready_text2", self.m_model.m_phase == 8 and "boss_fight_main_text_0013" or "boss_fight_main_text_0014", time_txt)
		
	else
		GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("new_str_1087"), delay_close = 2})
		self:updateMsg(99999)
	end
end

--更新红点
function M:UpdataRedPoint()		
	local red_flag = RedPointUtil:localRedPointJudge("guild_zhan_bao")
	self:setObjectVisible("log_btn_red_point_img",red_flag)
	local team_flag = RedPointUtil:hasRedPointById(295)
	self:setObjectVisible("battle_team_btn_red_point_img",team_flag)
end

--背景图
function M:updateActiveImg()
	local image_name = self:findImage("active_bg_img")
	local img_name = self.m_model.m_select_data.picture
	GameUtil:updateResourcesImg( image_name, "Texture/map_plot/" .. img_name)
end

--获取boss模型路径
function M:getBossModelPath()
	local result = ""
	local img_name = self.m_model.m_select_data.model
	if not img_name or img_name == "" then
		result = "B_TaoW_100001/B_TaoW"
	else
		result = img_name
	end
	return result
end

function M:setSpine()	
	local hero_id = self.m_model.m_select_data.model
	local spine_obj = self:findGameObject("hero_spine")
	local cfg = ConfigManager:getPlayerPictureCfg(tonumber(hero_id))
	local spine =  "hero_0101_SkeletonData"
	if cfg and next(cfg) ~= nil then
		spine = cfg.hero_spine
	else
		local cur_skin_cfg = ConfigManager:getHeroSkinCfg(hero_id)
		if cur_skin_cfg and next(cur_skin_cfg) then
			spine = cur_skin_cfg.hero_spine
		end
	end
	GameUtil:updateSpineLoadSet(spine_obj, "RoleSpine/" ..spine, "idle", 0, true)
end

function M:setStageImg()
	local cfg = self.m_model.m_phase_info_cfg
	local lenght = #cfg
	local type = self.m_model.m_phase_cfg[self.m_model.m_phase].type or 0
	for i = 1,lenght do
		local cur_cfg = cfg[i]
		self:setTextByLanKey("state"..i.."_time_text",cur_cfg.time)
		self:setTextByLanKey("state"..i.."_name_text",cur_cfg.name)
		if i == 1 then
			self:setObjectVisible("state"..i.."_star_img",true)
			self:setObjectVisible("state"..i.."_img",true)
			local img = self:findImage("state"..i.."_img")
			img.fillAmount = self.m_model.m_active_day/self.m_model.m_phase_time_cfg[type].end_day
		else
			self:setObjectVisible("state"..i.."_star_img",false)
			self:setObjectVisible("state"..i.."_img",false)
		end
	end
end

function M:creatRole3D()
	UIUtil.destroyAllChild(self.role_parent.transform)
	ResourceUtil:LoadRole3dAsync(self:getBossModelPath(), self.role_parent, function(obj)
		obj.transform:SetParent(self.role_parent.transform, false)
		obj.transform.localPosition = _boss_transform_[1].P	
		obj.transform.localRotation = _boss_transform_[1].R	
		obj.transform.localScale = _boss_transform_[1].S	
	end, true)
end

--检测播放视频
function M:checkAndPlayVideo()
	local isCompareSwordVideoPlay = UserDataManager.local_data:getLocalDataByKey("compareSwordVideoPlay")
	if isCompareSwordVideoPlay == 1 then
		return 
	end
	self:playerVideo()	
end

function M:playerVideo()
	self:lockTouch()
	audio:PauseMusicBusVol()
	--self.sound_id = audio:SendEvtUI("S2_MovieIntro")
	local model = self.m_model
	self.m_control:openView("Pops.VedioPlayerPop", {
		callback = function()  
			if self.sound_id then
				--audio:StopPlayingID(self.sound_id)
			end
			audio:ResumeMusicBusVol()
			UserDataManager.local_data:setLocalDataByKey("compareSwordVideoPlay" , 1)
			self:unlockTouch()
		end, vedio_name = "jstx_boss_vedio.mp4" , no_close_btn = false, close_btn_type = 1	
	})

end

function M:destroy()
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.NET_DATA_UPDATE_EVENT, {self, self.reqErrorEvent})
	M.super.destroy(self)
end

return M





