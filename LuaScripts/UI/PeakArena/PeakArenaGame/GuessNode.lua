local M = class("GuessNode", LikeOO.OOUIbase)

M.m_uiName = "PeakArena/GuessNode"

local __TRIPOD_TAB = {
	{name = "", big_icon = "a_bh_icon_tanke_da"},
	{name = "", big_icon = "a_bh_fu_da"},
	{name = "", big_icon = "a_bh_icon_waigong_da"},
	{name = "", big_icon = "a_bh_gong_da"},
	{name = "", big_icon = "a_bh_icon_mushi_da"},
	{name = "", big_icon = "a_bh_icon_neigong_da"},
}

function M:onEnter()
	self:setTextByLanKey("my_title", "帮会科技")
	self:setTextByLanKey("my_title2", "帮会科技")
    self:refreshUI()
	self:updateTime()
end

function M:refreshUI()
    self:updatePlayerUI()
end

function M:updatePlayerUI()
    self.left_data, self.right_data = self.m_model:getGuessBattlePlayerData()
	local left_head = self:findGameObject("left_head")
	local right_head = self:findGameObject("right_head")
	if self.left_data == nil or self.right_data == nil then
		return
	end
	self.trmp_heros = table.copy(self.left_data.heros)
	table.merge(self.trmp_heros, self.right_data.heros)
	self:setTextByLanKey("left_name", self.left_data.user.name)
	self:setTextByLanKey("right_name", self.right_data.user.name)
	self:setTextByLanKey("left_combat", "战力："..self.left_data.combat or 0 )
	self:setTextByLanKey("right_combat", "战力："..self.right_data.combat or 0)
	self:setSpine(1,self.m_model:getUserHeadAvatar(self.left_data.user.avatar))
	self:setSpine(2,self.m_model:getUserHeadAvatar(self.right_data.user.avatar))
	GameUtil:setUserAvatar(left_head, self.left_data.user, false, false, {show_flag = true, scale = 1})
	GameUtil:setUserAvatar(right_head, self.right_data.user, false, false, {show_flag = true, scale = 1})
	if #self.m_model.m_battle_logs > 1 then
		self:setObjectVisible("bottom_com", true)
		self:setTextByLanKey("se_num", "第"..self.m_model.m_selete_battle_log .."场")
	else
		self:setObjectVisible("bottom_com", false)
	end
	self:updateLeftLoopScroll(self.left_data.teams)
    self:updateRightLoopScroll(self.right_data.teams)
	self:updateUnionSc(self.left_data.tripods, self.right_data.tripods)
	self:updateRatio(self.left_data.user.uid, self.right_data.user.uid)
end

function M:setSpine(index, hero_spine)
	local play_img = index == 1 and self:findGameObject("left_hero_spine") or self:findGameObject("right_hero_spine")
	if hero_spine == nil then
		hero_spine = "hero_0181_SkeletonData"
	end
	GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" ..hero_spine, "idle", 0, true)
end

function M:updateUnionSc(tripod_1, tripod_2)
	for i = 1,6 do
		local img_str = "left_kj_"..i
		local img_str2 = "right_kj_"..i
		local gripid_tab = __TRIPOD_TAB[i]
		local cfg_1, lv_1 = self.m_model:getTripodCfgByType(i, tripod_1 or {}) 
		local cfg_2, lv_2 = self.m_model:getTripodCfgByType(i, tripod_2 or {}) 
		local img_1 = self:setImg(gripid_tab.big_icon, "maze_stage_ui" , img_str)
		local img_2 = self:setImg(gripid_tab.big_icon, "maze_stage_ui" , img_str2)
		UIUtil.setTextByLanKey(img_1.gameObject.transform, "kj_lv", cfg_1.layer or 0)
		UIUtil.setTextByLanKey(img_2.gameObject.transform, "kj_lv", cfg_2.layer or 0)
	end
end

function M:updateLeftLoopScroll(data)
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

function M:updateRightLoopScroll(data)
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
				local data = self.trmp_heros[hero_cfg_id]
				if data then
					local cfg = UserDataManager.hero_data:getHeroIdsByCid(data.id)
					if cfg then
						local function lookHero(item_object, item_data)
							self:updateMsg("look_hero", {oid = hero_cfg_id, data = self.trmp_heros})
						end
						local reward_data = RewardUtil:getProcessRewardData({101,data.id,1})
						CommonUIUtil:updateHeroElementByData(hero_node, reward_data, lookHero)
						CommonUIUtil:updateHeroLvByData(hero_node, data)
					else
						CommonUIUtil:updateHeroElementAdd(hero_node, nil, true)
					end
				end
			end
		end
	end
end

function M:updateRatio(id_1, id_2)
	local guess_get_data = self.m_model:getGuessData()
	local left_num = self.m_model:getGuessTicketNum(id_1)
	local right_num = self.m_model:getGuessTicketNum(id_2)
	local rotio_p = 0.5
	if left_num > 0 or right_num > 0 then
		local sub_num = left_num + right_num
		rotio_p = left_num/sub_num
	end
	local slider = self:findSlider("Slider")
	if slider then
		slider.value = rotio_p
	end
	self:setTextByLanKey("left_ratio_num", math.floor(rotio_p*100).."%")
	self:setTextByLanKey("right_ratio_num", math.floor((1-rotio_p)*100).."%")
	self:setObjectVisible("zhichi_get_1", false)
	self:setObjectVisible("zhichi_get_2", false)
	if next(guess_get_data) ~= nil then
		self:setObjectVisible("zhichi_1", false)
		self:setObjectVisible("zhichi_2", false)
		if guess_get_data[1] == id_1 then
			self:setObjectVisible("zhichi_get_1", true)
		elseif 	guess_get_data[1] == id_2 then
			self:setObjectVisible("zhichi_get_2", true)
		end
	else
		self:setObjectVisible("zhichi_1", true)
		self:setObjectVisible("zhichi_2", true)
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
    if name == "zhichi_1" then
		local play_data = self.left_data
        self.m_control:openView("PeakArena.GuessPop",{ data = play_data})
    elseif name == "zhichi_2" then
		local play_data = self.right_data
        self.m_control:openView("PeakArena.GuessPop",{ data = play_data})
    else
        self:updateMsg(name)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M
