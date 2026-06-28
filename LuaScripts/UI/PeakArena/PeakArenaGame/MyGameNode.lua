local M = class("MyGameNode", LikeOO.OOUIbase)

M.m_uiName = "PeakArena/MyGameNode"

local __TRIPOD_TAB = {
	{name = "", big_icon = "a_bh_icon_tanke_da"},
	{name = "", big_icon = "a_bh_fu_da"},
	{name = "", big_icon = "a_bh_icon_waigong_da"},
	{name = "", big_icon = "a_bh_gong_da"},
	{name = "", big_icon = "a_bh_icon_mushi_da"},
	{name = "", big_icon = "a_bh_icon_neigong_da"},
}

function M:onEnter()
    self.m_type = self.m_model:getRankType() -- 1对阵阵容/2尚未开始/3未获得资格/4晋级失败
	self:setTextByLanKey("my_title", "帮会科技")
	self:setTextByLanKey("my_title2", "帮会科技")
    self:refreshUI()
	self:updateTime()
end

function M:refreshUI()
    self:setObjectVisible("have_com", false)
    self:setObjectVisible("no_open_com", false)
    self:setObjectVisible("no_get_com", false)
    self:setObjectVisible("fail_com", false)
    if self.m_type == 1 then
        self:setObjectVisible("have_com", true)
    elseif self.m_type == 2 then    
        self:setObjectVisible("no_open_com", true)
		local rank_num = self.m_model:getMyScoreRank()
		if rank_num > 0 then
			self:setTextByLanKey("no_open_rank", "当前名次："..rank_num.."名")
		else
			self:setTextByLanKey("no_open_rank", "当前名次：9999名")
		end
    elseif self.m_type == 3 then    
        self:setObjectVisible("no_get_com", true)
		local rank_num = self.m_model:getMyScoreRank()
		if rank_num > 0 then
			self:setTextByLanKey("no_get_rank", "当前名次："..rank_num.."名")
		else
			self:setTextByLanKey("no_get_rank", "当前名次：9999名")
		end
    elseif self.m_type == 4 then    
        self:setObjectVisible("fail_com", true)
    end
	if self.m_type == 1 then
		self:updatePlayerUI()
		self.hero_team = self.m_model:geMyGameTeams()
		self:updateLeftLoopScroll()
		self:updateRightLoopScroll()
		self:updateUnionSc()
	end
end

function M:updatePlayerUI()
	if self.m_model.m_top_data.week == 1 then
		self:setObjectVisible("bottom_com", true)
		self:setTextByLanKey("se_num", "第"..self.m_model.m_selete_battle_log .."场")
	else
		self:setObjectVisible("bottom_com", false)
	end
    local left_data = self.m_model:getBattlePlayerData(1)
	local right_data = self.m_model:getBattlePlayerData(2)
	if left_data == nil or right_data == nil or right_data.user == nil then
		return
	end
	local left_head = self:findGameObject("left_head")
	local right_head = self:findGameObject("right_head")
	self:setTextByLanKey("left_name", left_data.user.name)
	self:setTextByLanKey("right_name", right_data.user.name)
	self:setTextByLanKey("left_combat", "战力："..left_data.combat or 0 )
	self:setTextByLanKey("right_combat", "战力："..right_data.combat or 0)
	self:setSpine(1,self.m_model:getUserHeadAvatar(left_data.user.avatar))
	self:setSpine(2,self.m_model:getUserHeadAvatar(right_data.user.avatar))
	GameUtil:setUserAvatar(left_head, left_data.user, false, false,{show_flag = true, scale = 1})
	GameUtil:setUserAvatar(right_head, right_data.user, false, false,{show_flag = true, scale = 1})
end

function M:setSpine(index, hero_spine)
	local play_img = index == 1 and self:findGameObject("left_hero_spine") or self:findGameObject("right_hero_spine")
	if hero_spine == nil then
		hero_spine = "hero_0181_SkeletonData"
	end
	GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" ..hero_spine, "idle", 0, true)
end

function M:updateUnionSc()
	for i = 1,6 do
		local img_str = "left_kj_"..i
		local img_str2 = "right_kj_"..i
		local gripid_tab = __TRIPOD_TAB[i]
		local cfg_1, lv_1 = self.m_model:getUnionTripo(1, i)
		local cfg_2, lv_2 = self.m_model:getUnionTripo(2, i)
		local img_1 = self:setImg(gripid_tab.big_icon, "maze_stage_ui" , img_str)
		local img_2 = self:setImg(gripid_tab.big_icon, "maze_stage_ui" , img_str2)
		UIUtil.setTextByLanKey(img_1.gameObject.transform, "kj_lv", cfg_1.layer or 0)
		UIUtil.setTextByLanKey(img_2.gameObject.transform, "kj_lv", cfg_2.layer or 0)
	end
end

function M:updateLeftLoopScroll()
	local data = self.m_model:getTeams(1)
	if self.m_left_scroll_view == nil then
		local loopscroll = self:findGameObject("left_loopscroll")
		local params = {
            show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateTeam(cell_object, cell_data,index)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
			
			end
		}
		self.m_left_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_left_scroll_view:reloadData(data)
	end
end

function M:updateRightLoopScroll()
	local data = self.m_model:getTeams(2)
	if self.m_right_scroll_view == nil then
		local loopscroll = self:findGameObject("right_loopscroll")
		local params = {
            show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateTeam(cell_object, cell_data, index)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
			
			end
		}
		self.m_right_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_right_scroll_view:reloadData(data)
	end
end

function M:updateTeam(obj, data, index)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	if luaBehaviour then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "team_name", "第"..index.."队")
		for i = 1,5 do
			local hero_node = luaBehaviour:FindGameObject("hero_"..i)
			local hero_cfg_id = data[i]
			if hero_cfg_id == "" then
				CommonUIUtil:updateHeroElementAdd(hero_node, nil, true)
			else
				local data, cfg = UserDataManager.hero_data:getHeroDataById(hero_cfg_id) 
				if data then
					local reward_data = RewardUtil:getProcessRewardData({101,data.id,1, hero_cfg_id})
					local function lookHero(item_object, item_data)
						self:updateMsg("look_hero", {oid = hero_cfg_id, data = self.hero_team})
					end
					CommonUIUtil:updateHeroElementByData(hero_node, reward_data,lookHero)
				else
					data = self.m_model:getEnemyHeroData(hero_cfg_id)
					local function lookHero(item_object, item_data)
						self:updateMsg("look_hero", {oid = hero_cfg_id, data = self.hero_team})
					end
					if data then
						local reward_data = RewardUtil:getProcessRewardData({101,data.id,1})
						CommonUIUtil:updateHeroElementByData(hero_node, reward_data,lookHero)
						CommonUIUtil:updateHeroLvByData(hero_node, data)
					else
						CommonUIUtil:updateHeroElementAdd(hero_node, nil, true)
					end
				end
			end
		end
	end
end

function M:updateTime()
	local end_tim = self.m_model:getDownTime()
	if end_tim > 0 and end_tim >= UserDataManager:getServerTime() then
		self:setTextByLanKey("star_time", "战斗开始倒计时："..GameUtil:formatTimeBySecond(end_tim - UserDataManager:getServerTime()))
		local lock_tim = end_tim - UserDataManager:getServerTime() - 3600
		if lock_tim <= 0 then
			self:setTextByLanKey("lock_time", "阵容已锁定")
		else
			self:setTextByLanKey("lock_time", "阵容锁定倒计时："..GameUtil:formatTimeBySecond(lock_tim))
		end
	end
end

function M:onButtonClick(obj, name)
	if self.m_model:checkCanClick() == false then
        self.m_control:checkIsClose()
        return
    end
    if name == "go_to_btn" then
        GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("跳转天下演武"), delay_close = 1})
    elseif name == "zb_btn" then
        self:openView("PeakArena.FightReportPop", self.m_model.m_top_data)
    elseif name == "team2_btn" then
		if self.m_model:checkTeamLock() == false then
            GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("阵容已锁定"), delay_close = 2})
            return 
        end
		self:openView("Arena.ArenaHigher.ArenaHigherDefendTeam", {back_refresh = true, top_arena = true})
	elseif name == "left_btn" then
		if #self.m_model.m_battle_logs > 1 then
			if self.m_model.m_selete_battle_log > 1 then
				self.m_model.m_selete_battle_log = self.m_model.m_selete_battle_log - 1
				self:refreshUI()
			end
		end
	elseif name == "right_btn" then
		if #self.m_model.m_battle_logs > 1 then
			if self.m_model.m_selete_battle_log < #self.m_model.m_battle_logs  then
				self.m_model.m_selete_battle_log = self.m_model.m_selete_battle_log + 1	
				self:refreshUI()
			end
		end
	else
        self:updateMsg(name)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M
