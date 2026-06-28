local M = class("MazeStageChoiceView",LikeOO.OOPopBase)

M.m_uiName = "MazeStage/MazeStageChoice"
M.m_iphoneXAdapter = true

function M:onEnter()
	self:setTextByLanKey("maze_tiaozhan_text", "new_str_0686")
	self:setTextByLanKey("maze_level_text", "new_str_0687")

	self:setTextByLanKey("close_title_text", "new_str_0388")
	self:setTextByLanKey("maze_word_text", "new_str_0172")
	--挑战剩余次数
	--self.maze_tiaozhan_num_text = self:findText("maze_tiaozhan_num_text")
	--最高通关层数
	--self.maze_level_num_text = self:findText("maze_level_num_text")
	--宝藏信息
	self.maze_info_text = self:findText("maze_info_text")
	--XX 分钟后重置
	self.maze_time_text = self:findText("maze_time_text")
	self.m_gray_img = self:findImage("gray_img")
	self:refreshUI()
	UserDataManager:removeRedDotByKey("maze_challenge")
end

function M:refreshUI()
	self:timeUpdate()
	--服务器获取到最大通关层数
	self:setTextByLanKey("maze_level_num_text", "budo_str_001", self.m_model.m_params.data.max_floor or 0)
	--剩余挑战次数
	self:setTextByLanKey("maze_tiaozhan_num_text", "new_str_0568", self.m_model.m_params.data.left_times or 0)
	--刷新信息
	self:setTextByLanKey("maze_info_text", "tid#maze_text3")
	
	self:updateLoopScroll();
	self:refreshRedPoint();
	--self:refreshFinishRewardNode()

	--快速导航
	self:setObjectVisible("guide_btn", true)
end

function M:refreshFinishRewardNode(obj, floors)
	local data, max_floor = self.m_model:getFinalReward(floors[#floors])
	if data and next(data) then
		reward_data = data[1]
		reward_data = RewardUtil:getProcessRewardData(reward_data)
		local ui_elemet = GameUtil:updateItemElementByData(obj, reward_data, true, true)
		local luaBehaviour = UIUtil.findLuaBehaviour(obj.transform)
		local add_panel = luaBehaviour:FindGameObject("add_panel")
		UIUtil.destroyAllChild(add_panel.transform)
		GameUtil:creatCommonItemEffect(add_panel, reward_data.quality,1)
	else
	end
end

function M:refreshRedPoint()
 
end

--时间更新
function M:timeUpdate()
	self:setTimeText();
	local time = self.m_model:getRefreshRemainingTime()
	local function tick(event, dt, remaining_time)
		self:setTimeText()
		if remaining_time <= 0 then
			self:updateMsg("refresh")
		end
	end
	EventDispatcher:registerTimeEvent("MazeStageChoiceView", tick, 1, time)
end

function M:setTimeText()
	local time = self.m_model:getRefreshRemainingTime()
	local ft = GameUtil:formatTimeBySecond(time)
	self.maze_time_text.text = ft
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	local data = {}
	if self.m_model.max_group <= 1 then
		data = self.m_model:getShowData()
	else
		data = self.m_model:getShowData2()
	end
	
	if self.m_loop_scroll_view == nil then
		--找到列表UI
		local loopscroll = self:findGameObject("stage_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, {id = index , cell_data = cell_data})
			end,
			ui_name = self.m_uiName
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
		self.m_loop_scroll_view:moveToCellIndex(#data - 1);
	else
		self.m_loop_scroll_view:reloadData(data, true)
	end
end

--
--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
	--["floor_id"] =
	--{
	--[1] = 1,
	--[2] = 2,
	--[3] = 3,
	--[4] = 4,
	--[5] = 5,
	--[6] = 6,
	--[7] = 7,
	--[8] = 8,
	--[9] = 9,
	--[10] = 10,
	--},
	--["show"] = 1,
	--["name"] = "tid#MazeMapGroup_01",
	--["stage"] = 212,
	--["pic"] = "a_cwbz_yeqiantu_1",
	local data = cell_data
	local transform = cell_object.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	local task_cell_btn = luaBehaviour:FindGameObject("task_cell_btn")
	local unlock_info = luaBehaviour:FindGameObject("unlock_info")
	--不是第一个格子
	local no_frist_cell = luaBehaviour:FindGameObject("no_frist_cell")
	--升级迷宫按钮
	local level_up_btn = luaBehaviour:FindButton("level_up_btn")
	local level_up_btn_img = luaBehaviour:FindImage("level_up_btn")

	local task_cell_real_btn = luaBehaviour:FindButton("task_cell_btn")
	--第一个格子
	local frist_cell = luaBehaviour:FindGameObject("frist_cell")
	local stage_bg = luaBehaviour:FindGameObject("stage_bg")
	local cell_img = luaBehaviour:FindGameObject("cell_img")
	local cell_img_real = luaBehaviour:FindImage("cell_img")
	local doubleReward = luaBehaviour:FindGameObject("doubleReward")
	local level_info_red_point = luaBehaviour:FindGameObject("level_info_red_point")
	if data.pic then
		GameUtil:updateResourcesImg(cell_img, "Texture/maze_stage/" .. tostring(data.pic))
	end
	if data.double ~= nil then
		doubleReward:SetActive(true);
	else
		doubleReward:SetActive(false);
	end
	local reward_node = luaBehaviour:FindGameObject("reward_node")

	if data.floor_id ~= nil then
		stage_bg:SetActive(true);
		unlock_info:SetActive(false);
		
		local my_max_floor = self.m_model.m_params.data.max_floor or 0
		if data.is_complete then
			reward_node:SetActive(false);
		else
			reward_node:SetActive(true);
			self:refreshFinishRewardNode(reward_node, data.floor_id)
		end
		task_cell_real_btn.interactable = true
		if index == 1 then
			--第一层
			task_cell_btn:SetActive(true)
			level_up_btn.gameObject:SetActive(false)
			frist_cell:SetActive(true)
			no_frist_cell:SetActive(false)
		else
			--其他层
			task_cell_btn:SetActive(true)
			level_up_btn.gameObject:SetActive(false)
			frist_cell:SetActive(false)
			no_frist_cell:SetActive(true)
		end
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"stage_info", data.name )
		--如果是未解锁的关卡的话

		local cur_stage = UserDataManager:getCurStage();
		local levelName = nil;
		local showText = nil;
		local seasonLock = nil;
		--最大的组是否解锁
		--if self.m_model:unlockMaxGroup() == false then
		if data.is_unlock_level_name ~= nil then
			levelName = Language:getTextByKey(data.is_unlock_level_name)
		end
		--end

		if cur_stage < data.stage then
			local stage_af = tostring(math.modf(data.stage/100));
			local stage_be = tostring(data.stage%100);
			showText = stage_af.."-"..stage_be
		end

		local cur_season = UserDataManager:getCurSeason()
		if cur_season < data.season and not data.is_complete then
			seasonLock = data.season 
		end

		if levelName ~= nil or showText ~= nil or seasonLock ~= nil then
			--reward_node:SetActive(false);
			stage_bg:SetActive(false);
			unlock_info:SetActive(true);
			task_cell_real_btn.interactable = false
			if seasonLock ~= nil then
				local stage_info = LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"unlock_info", "new_str_1047")
				stage_info.fontSize = 20
			elseif showText == nil then
				local stage_info = LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"unlock_info", "new_str_0711", levelName)
				stage_info.fontSize = 20
			elseif levelName == nil then
				local stage_info = LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"unlock_info", "new_str_0711", showText)
				stage_info.fontSize = 20
			else
				local stage_info = LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"unlock_info", "new_str_0617", showText, levelName)
				stage_info.fontSize = 20
			end

			cell_img_real.material = self.m_gray_img.material
		else
			stage_bg:SetActive(true);
			unlock_info:SetActive(false);
			task_cell_real_btn.interactable = true
			cell_img_real.material = nil
		end
	end
end


function M:destroy()
	EventDispatcher:unRegisterEvent("MazeStageChoiceView")
    M.super.destroy(self)
end

return M