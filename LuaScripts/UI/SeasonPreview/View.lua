---@class SeasonPreviewView
local M = class("SeasonPreviewView",LikeOO.OOPopBase)

M.m_uiName = "SeasonPreview/SeasonPreviewMain"
M.m_size_type = 1
M.m_iphoneXAdapter = true
local __season_ui_data = {
	{season_node = "season_1", lua_name = "UI.SeasonPreview.SeasonNode1", img_bg = "a_sj1_bgnew", btn_name = {"jianghu", "high_arena", "mystic", "union_war", "top_race_arena"}},
	{season_node = "season_2", lua_name = "UI.SeasonPreview.SeasonNode2", img_bg = "a_sj2_bgnew", btn_name = {"wxlm", "mj", "jianghu2", "magic_weapon"}},
	{season_node = "season_3", lua_name = "UI.SeasonPreview.SeasonNode3", img_bg = "a_dssj_bg", btn_name = {"qmdj", "tmhx", "xsty", "xtmm"}},
	{season_node = "season_4", lua_name = "UI.SeasonPreview.SeasonNode4", img_bg = "a_d4sj_bg", btn_name = {"tmxx", "sjjm", "hslj", "wdsl"}},
	{season_node = "season_5", lua_name = "UI.SeasonPreview.SeasonNode5", img_bg = "a_dwsj_bg", btn_name = {"qcjy", "xxxz"}},
	{season_node = "season_6", lua_name = "UI.SeasonPreview.SeasonNode6", img_bg = "a_dlsj_bg", btn_name = {"s6_tmxx", "s6_xxsh"}},
	{season_node = "season_7", lua_name = "UI.SeasonPreview.SeasonNode7", img_bg = "a_dlsj_bg", btn_name = {"s7_cwmz", "s7_tdzz"}},
	{season_node = "season_8", lua_name = "UI.SeasonPreview.SeasonNode8", img_bg = "a_dlsj_bg", btn_name = {"s8_pljs", "s8_plqs"}},
	{season_node = "season_9", lua_name = "UI.SeasonPreview.SeasonNode9", img_bg = "a_dlsj_bg", btn_name = {"s8_pljs", "s8_plqs"}},
	{season_node = "season_10", lua_name = "UI.SeasonPreview.SeasonNode10", img_bg = "a_dlsj_bg", btn_name = {"s8_pljs", "s8_plqs"}},
	{season_node = "season_11", lua_name = "UI.SeasonPreview.SeasonNode11", img_bg = "a_dlsj_bg", btn_name = {"s8_pljs", "s8_plqs"}},
	{season_node = "season_12", lua_name = "UI.SeasonPreview.SeasonNode12", img_bg = "a_dlsj_bg", btn_name = {"s8_pljs", "s8_plqs"}},
	{season_node = "season_13", lua_name = "UI.SeasonPreview.SeasonNode13", img_bg = "a_dlsj_bg2", btn_name = {"s13_dfbz", "s13_jstx"}},
}

function M:onEnter()
	self:setText("text_time", self.m_model.m_regroup_time)
	self:setTextByLanKey("close_title_text", "new_str_1026")
	self:setTextByLanKey("reward_tips_text", "new_str_1030")
	self:setTextByLanKey("reward_tips_text2", "new_str_1029")
	self:setTextByLanKey("daily_reward_tips_text", "new_str_1059")
	self:setTextByLanKey("reward_finish_text", "summer_text_received")
	self.m_ui_data = __season_ui_data[self.m_model.m_cur_season]
	local season_parent_node = self:findGameObject("season_parent_node")
	local tab_cls = CustomRequire(self.m_ui_data.lua_name)
	self.m_cur_tab_node = tab_cls.new(self.m_control, {parent = season_parent_node})
	self.m_cur_tab_node:initUi(self.m_ui_data)
	local season_bg_img = self:findImage("season_bg_img")
	self:setTextByLanKey("receive_btn_text", "new_str_0056")
	GameUtil:updateResourcesImg(season_bg_img, "Texture/season_preview/" .. self.m_ui_data.img_bg)
	self:refreshUI()
	self:updateDropLoopScroll()
	self:updateDailyLoopScroll()
	self:enterPlayVideo()
end

function M:onBtnClick( btn_name, msg, params)
	local function btnClick(trans,params)
		self:updateMsg(msg, params)
	end
	local btn = self.m_cur_tab_node:findGameObject(btn_name)
	UIUtil.setButtonClick(btn.transform, btnClick, params)
end

function M:updateFuncDesNode(func_name)
	self.m_cur_tab_node:updateFuncDesNode(func_name)
end

function M:updateRewardDesNode()
	self:setObjectVisible("reward_content_node", self.m_model.m_is_show_reward_node)
	if self.m_model.m_is_show_reward_node then
		self:setObjectVisible("reward_img", self.m_model.m_is_show_reward_node)
	end
end

function M:refreshUI()
	self.m_cur_tab_node:refreshUI()
	self:refreshGetBtn()
end

function M:refreshGetBtn()
	local goto_btn = self:findGameObject("goto_btn")
	local btn_spine = self:findGameObject("btn_spine")
	--tx_obj.gameObject:SetActive(not data.lock_flag and status == 2)
	btn_spine.gameObject:SetActive(true)
	local status = self.m_model.m_can_get_reward
	goto_btn.gameObject:SetActive(status)
	self:setObjectVisible("receive_btn_text",status)
	self:setObjectVisible("btn_spine",status)
	self:setObjectVisible("reward_finish_text",not(status))
	if status then--领取
		UIUtil.setImg(goto_btn.transform, "a_ui_currency_btn_small_2", "common_ui", "goto_btn")
	end
end

function M:updateDailyLoopScroll()
	local data = self.m_model:getSeasonDailyReward() or {}
	if self.m_daily_scroll_view == nil then
		local loopscroll = self:findGameObject("daily_loopscroll")
		local params = {
			show_data = data,
			pos_center = true,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local data = cell_data
				local reward_data = RewardUtil:getProcessRewardData(data)
				local ui_element = GameUtil:updateItemElementByData(cell_object, reward_data, true, true)
				ui_element.red_point_img:SetActive(false)
				local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
			end,
			ui_name = self.m_uiName
		}
		self.m_daily_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_daily_scroll_view:reloadData(data, false, nil, nil, true)
	end
end

function M:updateDropLoopScroll()
	local data = self.m_model:getSeasonReward() or {}
	if self.m_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			pos_center = true,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local data = cell_data
				local reward_data = RewardUtil:getProcessRewardData(data)
				local ui_element = GameUtil:updateItemElementByData(cell_object, reward_data, true, true)
				ui_element.red_point_img:SetActive(false)
				local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
			end,
			ui_name = self.m_uiName
		}
		self.m_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_scroll_view:reloadData(data, false, nil, nil, true)
	end
end

function M:updateHeroInfo()
end

function M:updateTime()
	self.m_cur_tab_node:updateTime()
end

function M:enterPlayVideo()
	-- 改成按赛季刷新
	local isSeasonVideoPlay = UserDataManager.local_data:getLocalDataByKey("seasonPreviewVideoS".. self.m_model.m_cur_season)
	if isSeasonVideoPlay == 1 then
		return
	end
	self:seasonVideo()
end

function M:seasonVideo()
	local cfg = self.m_model.m_cur_season_notice_cfg
	if cfg.video_name and cfg.video_name ~= "" then
		self:lockTouch()
		audio:PauseMusicBusVol()
		self.sound_id = audio:SendEvtUI("S2_MovieIntro")
		local model = self.m_model
		self.m_control:openView("Pops.VedioPlayerPop", {callback = function()
			if self.sound_id then
				audio:StopPlayingID(self.sound_id)
			end
			audio:ResumeMusicBusVol()
			UserDataManager.local_data:setLocalDataByKey("seasonPreviewVideoS".. model.m_cur_season or 0, 1)
			self:unlockTouch()
		end, vedio_name = cfg.video_name .. ".mp4", no_close_btn = false, close_btn_type = 1})
	end
	
end

function M:destroy()
	if self.m_cur_tab_node then
		self.m_cur_tab_node:destroy()
		self.m_cur_tab_node = nil
	end
	M.super.destroy(self)
end

return M