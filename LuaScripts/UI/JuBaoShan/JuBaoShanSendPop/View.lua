local M = class("JuBaoShanSendPopView",LikeOO.OOPopBase)

M.m_uiName = "JuBaoShan/JuBaoShanSendPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

local __BuildConfig = {
	[2] = { imgName = "a_jbs_qianzhuang" },
	[8] = { imgName = "a_jbs_jianghugaoshi" },
	[9] = { imgName = "a_jbs_xiakexunlianying" },
	[10] = { imgName = "a_jbs_jiaozigongfang" },
	[11] = { imgName = "a_jbs_danlu" },
	[12] = { imgName = "a_jbs_jieyuankezhan" },
}

function M:onEnter()
	self:setTextByLanKey("common_title_text", "jubaoShan_str_010")
    self.roll_reward =self:findGameObject("roll_reward");
	self:refreshUI()
end

function M:refreshUI()
	self:updateCycleView();
	self:createLoopScroll()
	if self.m_loop_scroll_view ~= nil then 
		self.m_loop_scroll_view:moveToCellIndex(1)
	end
end


function M:updateCycleView()
	local cycleReward = self.m_model:getCycleReward();
	local luaBehaviour = self.roll_reward:GetComponent("LuaBehaviour")
	local buiding_image = luaBehaviour:FindImage("buiding_image");
	local buiding_lv = luaBehaviour:FindText("buiding_lv");
	local buiding_des = luaBehaviour:FindText("buiding_des");
	--组件等级
	buiding_lv.text = Language:getTextByKey(Language:getTextByKey("jubaoShan_str_024"));
	--local cell_ui_config = __BuildConfig[2]
	--if cell_ui_config ~= nil then
	--	buiding_image.sprite = ResourceUtil:GetSprite(cell_ui_config.imgName,"maze_stage_ui")
	--end
	--奖励
	local data = RewardUtil:getProcessRewardData(cycleReward)
	local content = Language:getTextByKey("tid#credit_dicel_origin")
	buiding_des.text = content;
	local reward = luaBehaviour:FindGameObject("reward");
	GameUtil:updateItemElementByData(reward, data, true)
end


function M:checkCondition( cell_data )
	--需要的条件
	local m_need = cell_data.cell_config.param.need
	--品质
	local evo_condition = {}
	--需要的条件
	local slotNum = 0;
	for i, v in pairs(cell_data.cell_config.slot) do
		slotNum = slotNum + 1;
		evo_condition[i] = v;
	end
	--当前开启的槽位
	local max_solt_num = 0;
	for i = 1, slotNum do
		local need_lv = evo_condition[i][1]
		if cell_data.lv >= need_lv then
			max_solt_num = i;
		end
	end

	for i, v in pairs(m_need) do
		local race_heros = self:getRaceHeros(v);
		if _G.next(race_heros) ~= nil then
			for i = 1, max_solt_num do
				for race_index, race_hero_id in pairs(race_heros) do
					if self:hasHero(race_hero_id) == false then
						local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(race_hero_id)
						local hero_evo = hero_data.evo;
						if hero_evo >= evo_condition[i][2] then
							return true;
						end
					end
				end
			end
		end
	end
	return false;
end


function M:hasHero( hero_id )
	self.m_allCells = SceneManager:getCurSceneModel().allCellPools;
	for i, v in pairs(self.m_allCells) do
		if v.team ~= nil then
			for team_i, team_hero in pairs(v.team) do
				if team_hero == hero_id then
					return true;
				end
			end
		end
	end
	return false;
end


function M:getRaceHeros( race )
	local race_heros = {}
	-- 我的所有英雄
	local heros = table.copy(UserDataManager.hero_data:getHerosId())
	for i, v in pairs(heros) do
		local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(v)
		local hero_race = hero_cfg.race;
		if hero_race == race then
			table.insert(race_heros, v)
		end
	end
	return race_heros;
end



--英雄列表
function M:createLoopScroll()
	local data = self.m_model:getBuildingData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("list_scroll")
		local params = {
            show_data = data,
			loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateCellData(cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("item_btn", { name = cell_object.name, clickData = cell_data})
			end,
			ui_name = self.m_uiName,
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

--更新子元素
function M:updateCellData( cell_object, cell_data )
	--重新设置英雄头像
	local heroCellState = {
		[1] = {
			lock = false,
			show = false,
		},
		[2] = {
			lock = false,
			show = false,
		},
		[3] = {
			lock = false,
			show = false,
		},
		[4] = {
			lock = false,
			show = false,
		}
	}
	
	local luaBehaviour = cell_object:GetComponent("LuaBehaviour")
	local buiding_image = luaBehaviour:FindImage("buiding_image");
	local buiding_lv = luaBehaviour:FindText("buiding_lv");
	local buiding_des = luaBehaviour:FindText("buiding_des");
	local progress = luaBehaviour:FindText("progress");

	cell_data.isCanShow = false;

	local trigger_time = cell_data.trigger_time or 0;
	if trigger_time <= 0 then
		trigger_time = 1;
	end
	--组件等级
	buiding_lv.text = Language:getTextByKey(cell_data.cell_config.name).."  "..cell_data.lv..Language:getTextByKey("new_str_0428");
	
	local evo_condition = {}
	--需要的条件
	local slotNum = 0;
	for i, v in pairs(cell_data.cell_config.slot) do
		slotNum = slotNum + 1;
		evo_condition[i] = v;
	end
	for i = 1, 4 do
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "hero_cell"..i, i <= slotNum)
	end
	local max_solt_num = 0;
	for i = 1, slotNum do
		local need_lv = evo_condition[i][1]
		if cell_data.lv >= need_lv then
			max_solt_num = i;
		end
	end

	local index = 0
	if cell_data.team ~= nil and _G.next(cell_data.team) ~= nil then
		for i, v in pairs(cell_data.team) do
			index = index + 1;
			if index <= slotNum then
				local obj = luaBehaviour:FindGameObject("hero_cell"..index);
				local hero_data,hero_cfg = UserDataManager.hero_data:getHeroDataById(v)
				if hero_data and hero_cfg then
					local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 1, hero_data.oid})
					GameUtil:updateItemElementByData(obj, itemData)
				end
			end
		end
		
		for i = 1, slotNum do
			if i > max_solt_num then
				local hero_cell = luaBehaviour:FindGameObject("hero_cell"..i);
				local hero_haviour = UIUtil.findLuaBehaviour(hero_cell.transform)
				LuaBehaviourUtil.setObjectVisible(hero_haviour, "have_panel", false)
				LuaBehaviourUtil.setObjectVisible(hero_haviour, "stars", false)
				LuaBehaviourUtil.setObjectVisible(hero_haviour, "no_panel", false)
				LuaBehaviourUtil.setObjectVisible(hero_haviour, "lock_image", true)
				LuaBehaviourUtil.setObjectVisible(hero_haviour, "red_point_img", false)
				LuaBehaviourUtil.setObjectVisible(hero_haviour, "quality_up_img", false)
				LuaBehaviourUtil.setObjectVisible(hero_haviour, "equip_t_corner_mark", false)
				heroCellState[i].lock = true;
			else
				if i > index and i <= max_solt_num then
					local hero_cell = luaBehaviour:FindGameObject("hero_cell"..i);
					local hero_haviour = UIUtil.findLuaBehaviour(hero_cell.transform)
					LuaBehaviourUtil.setObjectVisible(hero_haviour, "have_panel", false)
					LuaBehaviourUtil.setObjectVisible(hero_haviour, "no_panel", true)
					LuaBehaviourUtil.setObjectVisible(hero_haviour, "red_point_img", true)
					LuaBehaviourUtil.setObjectVisible(hero_haviour, "stars", false)
					LuaBehaviourUtil.setObjectVisible(hero_haviour, "lock_image", false)
					LuaBehaviourUtil.setObjectVisible(hero_haviour, "quality_up_img", false)
					LuaBehaviourUtil.setObjectVisible(hero_haviour, "equip_t_corner_mark", false)
					heroCellState[i].show = true;
					cell_data.isCanShow = true;
				end
			end
		end
	else
		for i = 1, slotNum do
			if i > max_solt_num then
				local hero_cell = luaBehaviour:FindGameObject("hero_cell"..i);
				local hero_haviour = UIUtil.findLuaBehaviour(hero_cell.transform)
				LuaBehaviourUtil.setObjectVisible(hero_haviour, "have_panel", false)
				LuaBehaviourUtil.setObjectVisible(hero_haviour, "stars", false)
				LuaBehaviourUtil.setObjectVisible(hero_haviour, "lock_image", true)
				LuaBehaviourUtil.setObjectVisible(hero_haviour, "add_panel", false)
				LuaBehaviourUtil.setObjectVisible(hero_haviour, "no_panel", false)
				LuaBehaviourUtil.setObjectVisible(hero_haviour, "red_point_img", false)
				LuaBehaviourUtil.setObjectVisible(hero_haviour, "quality_up_img", false)
				LuaBehaviourUtil.setObjectVisible(hero_haviour, "equip_t_corner_mark", false)
				heroCellState[i].lock = true;
			else
				local hero_cell = luaBehaviour:FindGameObject("hero_cell"..i);
				local hero_haviour = UIUtil.findLuaBehaviour(hero_cell.transform)
				LuaBehaviourUtil.setObjectVisible(hero_haviour, "have_panel", false)
				LuaBehaviourUtil.setObjectVisible(hero_haviour, "no_panel", true)
				LuaBehaviourUtil.setObjectVisible(hero_haviour, "stars", false)
				LuaBehaviourUtil.setObjectVisible(hero_haviour, "lock_image", false)
				local hasRed = self:checkCondition(cell_data);
				LuaBehaviourUtil.setObjectVisible(hero_haviour, "red_point_img", hasRed)
				LuaBehaviourUtil.setObjectVisible(hero_haviour, "quality_up_img", false)
				LuaBehaviourUtil.setObjectVisible(hero_haviour, "equip_t_corner_mark", false)
				heroCellState[i].show = true;
				cell_data.isCanShow = true;
			end
		end
	end
	
	--奖励
	local reward_data = self.m_model:updateRewardData(cell_data, index)
	local data = RewardUtil:getProcessRewardData(reward_data)
	local content = Language:getTextByKey("jubaoShan_str_007",trigger_time,data.name)
	buiding_des.text = content;
	if cell_data.team ~= nil and _G.next(cell_data.team) ~= nil then
		--buiding_des.text = content;
		if trigger_time > 0 then
			progress.text = Language:getTextByKey("jubaoShan_str_021",trigger_time);
		else
			progress.text = "";
		end
	else
		progress.text = "";
		--buiding_des.text = Language:getTextByKey("jubaoShan_str_011");
	end
	
	local reward = luaBehaviour:FindGameObject("reward");
	GameUtil:updateItemElementByData(reward, data, true)
	--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "count_text", true)
	--local count_text = luaBehaviour:FindText("count_text");
	--count_text.text = data.num;
	
	--local cell_ui_config = __BuildConfig[cell_data.id]
	--if cell_ui_config ~= nil then
	--	buiding_image.sprite = ResourceUtil:GetSprite(cell_ui_config.imgName,"maze_stage_ui")
	--end

	for i = 1, 4 do
		local hero_cell = luaBehaviour:FindGameObject("hero_cell"..i);
		local hero_haviour = UIUtil.findLuaBehaviour(hero_cell.transform)
		hero_haviour:RegistButtonClick(function (obj, name)
			self:updateMsg("clickHeroCell", { index = i, stateData = heroCellState[i], clickData = cell_data});
		end )
	end
end


return M