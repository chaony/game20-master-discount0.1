local M = class("CompareSwordMyRaceView", LikeOO.OOPopBase)

M.m_uiName = "CompareSwordWithWorld/GameOfHeavenAndEarth/CompareSwordMyRace"
M.m_iphoneXAdapter = true
M.m_size_type = 1

function M:onEnter()

	self:refreshUI()
end

function M:refreshUI()
	self:refreshUIText()
	self:updateLoopScroll()
	self:updateSelfData()
	self:refreshRed()
	if not next(self.m_model.rank_data) then
		local text = self.m_model.racePhase == 2 and "compare_sword_race_text_051" or "compare_sword_race_text_054"
		self:setTextByLanKey("text_no_data" , text)
		self:setObjectVisible("text_no_data" , true)
	else
		self:setObjectVisible("text_no_data" , false)
	end
end

function M:refreshRed()
	if self.m_model.racePhase == 3 then
		local flag = GameUtil:getCompareSwordDefendTeamsRedFlag()  or false
		self:setObjectVisible("editor_red_point" ,flag)
	end
end

function M:updateLoopScroll()
	self.m_click_cell_object = nil
	local data =self.m_model.rank_data
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")  --挂载LoopScroll名称
		local params = {
			ui_name = self.m_uiName,
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data) --更新列表内容
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				--点击事件
				if click_name == "btn_formation" then  -- 个人侠客
					self:updateMsg("btn_formation", cell_data)
				elseif click_name == "btn_editor" then --个人情报
					self:updateMsg("btn_editor", cell_data)
				end
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true)
	end
end

function M:updateScrollViewCell(idx , cell_object , data)
	local luaBehaviour = cell_object:GetComponent("LuaBehaviour")
	local head_node = luaBehaviour:FindGameObject("head_node")
	local own_uid = UserDataManager.user_data:getUid()
	local curData = own_uid == data.players[2].uid and data.players[1] or data.players[2]
	GameUtil:setUserAvatar(head_node, curData, false, false, {show_flag = true, scale = 1})
	for i = 1, 5 do
		local hero_node_ = luaBehaviour:FindGameObject("hero_node_" .. i)
		--if #data.players[2].teams <=0 then
		--	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "team_node", false)
		--	break
		--else
		--	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "team_node", true)
		--end
		local hero_id = ""
		if  #curData.teams >0 then
			hero_id =  curData.teams[1][i] and curData.teams[1][i] or ""
		end
		local hero_data =  curData.heros[hero_id] or nil
		--if hero_data then
		--	--self:heroHandle(hero_node_, hero_data)
		--	--GameUtil:updateItemElementByData(hero_node_.gameObject,hero_data,false,false, callback)
		--else
		--	--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "hero_node_" .. i, false)
		--end
		if hero_data then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "hero_node_" .. i, true)
			local show_data = self.m_model:getShowHeroData(hero_data)
			GameUtil:updateItemElementByData(hero_node_.gameObject,show_data,false,false, callback)
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "hero_node_" .. i, false)
		end
	end
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "text_playerName", curData.name)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "text_point",curData.score)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "text_power", GameUtil:formatValueToString(curData.full_combat))
	--local time = TimeUtil.gmTime(curData.last_active_time)
	local textTime = data.date -- time.year.."/"..time.month.."/"..time.day
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "text_fightTime", "compare_sword_race_text_029",textTime)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "text_formation", "compare_sword_race_text_018")
	if data.winner == 0 then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "img_raceState", false)
	else
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "img_raceState", true)
		local win = tostring(own_uid) == data.winner and 0 or 1
		local imagePath = tostring(own_uid) == data.winner and "a_sjjs_shengli" or "a_sjjs_shibai"
		LuaBehaviourUtil.setImg(luaBehaviour, "img_raceState", imagePath, ResourceUtil:getLanAtlas())
	end
	--if hero_id and hero_id ~= "" then
	--	local show_hero = cell_data.show_hero[hero_id]
	--	GameUtil:updateItemElementByData(hero_node.gameObject,show_hero,false,false, callback)
	--else
	--	local ui_element = GameUtil:updateItemElementNoData(hero_node)
	--	ui_element.add_img.gameObject:SetActive(false)
	--end
	
end

function M:heroHandle(obj, hero_data)
	local data = hero_data
	local cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_data.id)
	--GameUtil:updateItemElementByData(obj,data,false,false, callback)
	GameUtil:updateHeroContentByData(obj,data,cfg)
end

function M:updateSelfData()
	self:setTextByLanKey("text_petRank","compare_sword_race_text_024",self.m_model.boss_damage_rank)
	local rise_rank_text = Language:getTextByKey("compare_sword_race_text_031")
	if self.m_model.rise_rank == nil or self.m_model.rise_rank == 0 then
		rise_rank_text = self.jinji_rank and self.jinji_rank or Language:getTextByKey("compare_sword_race_text_031")
	else
		rise_rank_text = Language:getTextByKey("compare_sword_race_text_053" , self.m_model.rise_rank)
	end
	self:setTextByLanKey("text_raceRank","compare_sword_race_text_025",rise_rank_text)
	self:setTextByLanKey("text_raceScore","compare_sword_race_text_026",self.m_model.point_race_score)
	self:setTextByLanKey("text_pointRaceNum","compare_sword_race_text_027",self.m_model.full_service_point_race_rank)

	local user_data = UserDataManager.user_data.user_status
	--加载spine动画
	local hero = self:findGameObject("spine_hero")
	local cfg = ConfigManager:getPlayerPictureCfg(user_data.avatar)
	GameUtil:updateSpineLoadSet(hero, "RoleSpine/" .. tostring(cfg.hero_spine), "idle", 0, true)
end

function M:refreshUIText()
	self:setTextByLanKey("close_title_text" , "compare_sword_race_text_020")

	local title_lang =""
	if self.m_model.racePhase == 2 then
		title_lang = Language:getTextByKey("compare_sword_race_text_019",self.m_model.phase_day)
	elseif self.m_model.racePhase == 3 then
		title_lang = "compare_sword_rise_title_00" .. (self.m_model.data_racePhase == 5 and 1 or self.m_model.phase_day)
	end
	self:setTextByLanKey("text_scrollTitle" , title_lang)
	self:setTextByLanKey("text_selfTitle" , "compare_sword_race_text_021")
	--btn
	self:setTextByLanKey("text_myReport" , "compare_sword_race_text_022")
	self:setTextByLanKey("text_formation" , "compare_sword_race_text_023")
	
	
end



function M:destroy()

	M.super.destroy(self)
end

return M