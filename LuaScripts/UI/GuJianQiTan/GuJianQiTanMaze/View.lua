local M = class("GuJianQiTanMazeView",LikeOO.OOPopBase)

M.m_uiName = "GuJianQiTan/GuJianQiTanMaze"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
	--self.m_time_text = self:findText("time_text")
	--XX 分钟后重置
	self.maze_time_text = self:findText("maze_time_text")
	self.count_slider = self:findSlider("count_slider")
	self:setTextByLanKey("count_tips_des", "tid#mazedes_0001")
	self:setTextByLanKey("count_tips_title", "new_str_0630")
	self:setTextByLanKey("close_title_text", "gu_jian_qi_tan_str_003")
	self:setTextByLanKey("time_reset_text", "new_str_0172")
	self:setTextByLanKey("attr_add_title_text", "new_str_0174")
	self:setTextByLanKey("combat_add_text", "new_str_0175")	
	self:setTextByLanKey("hero_btn_text", "new_str_0433")
	self:setTextByLanKey("shop_btn_text", "new_str_0178")
	self:setTextByLanKey("combat_num_title_text", "new_str_0490")
	self:setObjectVisible("UI_MazeStage_Zhanli_001", false)
	self:setObjectVisible("UI_Fivelines_ShangGuang_01", false)
	self.m_box_node = self:findGameObject("box_node")
	self.count_tips = self:findGameObject("count_tips")
	self:refreshUI()
	UserDataManager:removeRedDotByKey("maze_challenge")
end


function M:showLevelEffect()
	self:setObjectVisible("UI_Fivelines_ShangGuang_01", true)
	self.m_control:setOnceTimer(1.5, function ()
		self:setObjectVisible("UI_Fivelines_ShangGuang_01", false)
	end)
end


function M:refreshUI()
	local data = self.m_model.m_data
	local floor_id = data.floor_id or -1
	--local group_id = data.group_id or 1
	--local group = self.m_model.m_maze_map_group[group_id]
	local maze_floor = ConfigManager:getCfgByName("sword_akuma_floor")[self.m_model.m_data.version or 1]
	--local floor_ids = group.floor_id;
	local floor_data = maze_floor[floor_id];
	--local one_floor_id = floor_ids[1] or 1;
	--local max_floor_id = floor_ids[#floor_ids];
	--local cell_id = data.cell_id or -1
	--local max_floor_data = maze_floor[floor_id];
	local finish_reward = floor_data.finish_reward
	if finish_reward and next(finish_reward) then
		self:refreshFinishRewardNode(finish_reward, floor_id)
	else
		--参数传空 ui隐藏
		self:refreshFinishRewardNode()
	end
	--Logger.logError( floor_ids," 层数据 ")
	--Logger.logError( floor_id," 层数据 floor_id ")
	--if floor_id == 0 then
	--	self:setTextByLanKey("level_text", "new_str_0173", Language:getTextByKey(tostring(floor_id)))
	--else
	--	self:setTextByLanKey("level_text", "new_str_0173", Language:getTextByKey("num_str_000" .. tostring(floor_id)))
	--end
	
	--之前的层数显示 第 4/5 层 显示暂时不要了
	--if floor_id == 0 then
	--	self:setTextByLanKey("level_text", "new_str_0173", Language:getTextByKey(tostring(floor_id)))
	--else
	--	self:setTextByLanKey("level_text", "new_str_0173", Language:getTextByKey(tostring((floor_id - one_floor_id + 1).."/"..(max_floor_id - one_floor_id + 1))))
	--end
	
	--改成了 第一层 第二层
	self:setTextByLanKey("level_text", floor_data.name or "new_str_0173");
	
	-- 'recv': 0,              # 当前层是否领取大奖, 1：已领取，0：未领取
	-- local is_over = self.m_model:getFloorIsOver()
	-- if is_over then
	-- 	self:setObjectVisible("box_btn", data.recv == 0)
	-- 	self:setObjectVisible("next_btn", data.recv ~= 0)
	-- else
		self:setObjectVisible("box_btn", false)
		self:setObjectVisible("next_btn", false)
	-- end
	
	--刷新信息
	self:setTextByLanKey("maze_info_text", "tid#maze_text3")
	
	--self:updateRewardBox()

	local heirloom_num = self.m_model:getHeirloomNum()
	for k,v in pairs({7,5,3}) do
		local heirloom_num_item = heirloom_num[v] or {}
		self:setTextByLanKey("attr_add_text_" .. k, tostring(heirloom_num_item.num or 0))	
	end

	self.grid_root = self:findGameObject("grid_root")
	self.grid_root_tween = self.grid_root:GetComponent(typeof(CS.DG.Tweening.DOTweenAnimation));
	
	local add_value, heros_combat = self.m_model:getHeirloomCombatAddRatio()
	self.m_model.heros_combat = heros_combat
	self:setText("combat_add_value_text", string.format("+%0.2f%%", add_value*100))
	self:setText("combat_num_text", tostring(heros_combat))
	if self.m_heros_combat ~= nil and self.m_heros_combat ~= heros_combat then
		self:setObjectVisible("UI_MazeStage_Zhanli_001", true)
		self.m_control:setOnceTimer(2, function()
			self:setObjectVisible("UI_MazeStage_Zhanli_001", false)
		end)
	end
	self.m_heros_combat = heros_combat
	self:timeUpdate()
	local box_num_14 = self.m_model:getNotExploredCellNum(14) --普通宝箱
	local box_num_21 = self.m_model:getNotExploredCellNum(21) --上锁宝箱
	self:setTextByLanKey("box_num_text", "new_str_0693", box_num_14 + box_num_21)
	--self:setObjectVisible("hero_red_point", self.m_model:checkisDie() == true)
	self:updatekeyLeft()
	self:updateBlessValue()
	self:updateBuffValue()
	--快速导航
	self:setObjectVisible("guide_btn", true)
	
end

function M:refreshFinishRewardNode(data, floor_id)
	local reward_data = nil
	if data and next(data) then
		self:setObjectVisible("reward_node", true)
		reward_data = data[1]
		reward_data = RewardUtil:getProcessRewardData(reward_data)
		local reward_obj = self:findGameObject("final_reward_node")
		GameUtil:updateItemElementByData(reward_obj, reward_data, true, true)

		local luaBehaviour = UIUtil.findLuaBehaviour(reward_obj.transform)
		local add_panel = luaBehaviour:FindGameObject("add_panel")
		UIUtil.destroyAllChild(add_panel.transform)
		GameUtil:creatCommonItemEffect(add_panel, reward_data.quality,1)
		self:setTextByLanKey("reward_des_text", "gu_jian_qi_tan_str_031")
	else
		self:setObjectVisible("reward_node", false)
	end
end

function M:updateRewardBox()
	local box_trans = self.m_box_node.transform
	local box_node_rt = UIUtil.findRectTransform(self.m_box_node)
	UIUtil.destroyAllChild(box_trans)
	local show_data, cur_num = self.m_model:getBoxData()
	local width = box_node_rt.rect.width
	local max_num = 0
	if show_data[#show_data] then
		max_num = show_data[#show_data].cfg.num
	end
	max_num = max_num > 0 and max_num or 100
	self:setText("maze_count_text", cur_num)
	self.count_slider.value = cur_num/max_num
	for i=1,#show_data do
		local data = show_data[i]
		local cfg = data.cfg
		local task_box = GameUtil:createPrefab("Task/TaskBox", box_trans)
		local transform = task_box.transform
		UIUtil.setLocalPosition(task_box, width*cfg.num/max_num - width*0.5, 0)
		local function btns(trans,params)
			self:updateMsg("box_click", {click_transform = trans, data = data})
			audio:SendEvtUI('UI_TresureChest_Open')
		end
		UIUtil.setButtonClick(transform, btns, i)
		local score_text = UIUtil.setText(transform, tostring(cfg.num), "score_text")
		local finish_text = UIUtil.setTextByLanKey(transform,"finish_text", "new_str_0080")
		finish_text.gameObject:SetActive(data.status == -1)
		score_text.gameObject:SetActive(data.status ~= -1)

		local box_effect = UIUtil.findRectTransform(transform, "UI_Task_BaoXiang_001")
		if data.status == 0 then
			UIUtil.setImg(transform, "a_rw_baoxiang_di_n2", "main_ui", "box_bg")
			 UIUtil.setImg(transform, "a_rw_xiangzi_weikai", "main_ui", "box_img")
			box_effect.gameObject:SetActive(false)
		elseif data.status == 2 then
			UIUtil.setImg(transform, "a_rw_baoxiang_di_h", "main_ui", "box_bg")
			UIUtil.setImg(transform, "a_rw_xiangzi_weikai", "main_ui", "box_img")
			self.m_control:setOnceTimer(0.1, function()
				if not IsNull(task_box) then
					local luaBehaviour = UIUtil.findLuaBehaviour(transform)
					luaBehaviour:RunAnim("UI_TaskBox_BaoXiang_001", nil , 1)
				end
			end)
			box_effect.gameObject:SetActive(true)
		elseif data.status == -1 then
			UIUtil.setImg(transform, "a_rw_baoxiang_di_n1", "main_ui", "box_bg")
			UIUtil.setImg(transform, "a_rw_xiangzi_kai", "main_ui", "box_img")
			box_effect.gameObject:SetActive(false)
		end
	end
end

function M:getGridName(w, h)
	return "grid_"..w.."_".."h";
end

--清理格子
function M:clear_grid()
	for w = 1, 9 do
		for h = 1, 9 do
			self:setObjectVisible(self:getGridName(w,h), false)
		end
	end
end

--显示格子
function M:maze_show_grid( data )
	local w = data.w_pos;
	local h = data.h_pos;
	self:setObjectVisible(self:getGridName(w,h), true)
end


function M:set_grid_position( data )
	local w = data.w_pos;
	local h = data.h_pos;
	local pos = {x = 0,y = 0,z = 0}
	pos.x = w * 56 + h * 36  + w * 0;
	pos.y = h * 46 + h * -12 + w * -4;
	self.grid_root.transform.localPosition = pos;
end

--移动格子
function M:move_grid( data )
	
	local w = data.w_pos;
	local h = data.h_pos;
	local pos = {x = 0,y = 0,z = 0}
	pos.x = w * 56 + h * 36  + w * 0;
	pos.y = h * 46 + h * -12 + w * -4;
	
	if self.grid_root_tween ~= nil then
		--移动时间
		self.grid_root_tween.duration = 1;
		self.anim_time = 1
		--移动目标点
		self.grid_root_tween.endValueV3 = Vector3(-pos.x,-pos.y,-pos.z)
		self.grid_root_tween.easeType = CS.DG.Tweening.Ease.OutQuad;
		self.grid_root_tween:CreateTween();
		self.grid_root_tween.tween:Play();
	end
end


function M:timeUpdate()
	--self:setTimeText();
    --local time = self.m_model:getRefreshRemainingTime()
    --local function tick(event, dt, remaining_time)
    --    self:setTimeText()
    --    if remaining_time <= 0 then
    --        self:updateMsg("refresh")
    --    end
    --end
    --EventDispatcher:registerTimeEvent("MazeStageViewTime", tick, 1, time)
end

function M:setTimeText()
    local time = self.m_model:getRefreshRemainingTime()
    local ft = GameUtil:formatTimeBySecond(time)
    self.maze_time_text.text = ft
end

function M:selectRelicMoveAnim(select_cell_obj, quality)
	if not IsNull(select_cell_obj) then
		local select_cell_obj_trans = select_cell_obj.transform
        local luaBehaviour = UIUtil.findLuaBehaviour(select_cell_obj)
        local select_btn = luaBehaviour:FindGameObject("select_btn")
        select_btn:SetActive(false)
        local pos = select_cell_obj_trans.parent:TransformPoint(select_cell_obj_trans.localPosition) --世界坐标
        pos = self.m_ui_obj.transform:InverseTransformPoint(pos) -- 相对坐标
        select_cell_obj_trans:SetParent(self.m_ui_obj.transform, false)
        select_cell_obj_trans.localPosition = pos

        local move_pos = self:getPelicMovePos(quality)
        select_cell_obj_trans:DOLocalMove(move_pos,0.7)
        select_cell_obj_trans:DOScale(0.1,0.7)
        self.m_control:setOnceTimer(0.8, function()
            U3DUtil:Destroy(select_cell_obj)
        end)
    end
end

function M:getPelicMovePos(quality)
	local add_icon_key = "add_icon_2"
	if quality == 3 then
		add_icon_key = "add_icon_3"
	elseif quality == 7 then
		add_icon_key = "add_icon_1"	
	end
	local add_icon = self:findGameObject(add_icon_key)
	local trans = add_icon.transform
	local pos = trans.parent:TransformPoint(trans.localPosition) --世界坐标
	pos = self.m_ui_obj.transform:InverseTransformPoint(pos) -- 相对坐标
	return pos
end

function M:updatekeyLeft()
	local businessman_num = self.m_model:getKeyCount() --拥有的钥匙数量
	self:setTextByLanKey("businessman_num_text", "new_str_0693", businessman_num)
end

function M:updateBlessValue()
	local bless_nums = table.nums(self.m_model:getBlessData())
	self:setTextByLanKey("bless_text", "gu_jian_qi_tan_str_058", bless_nums)
end

function M:updateBuffValue()
	self:setTextByLanKey("buff_text", "gu_jian_qi_tan_str_032", tostring(self.m_model:getBuffValue()))
end

function M:updateRemainTime()
	local remain_time = self.m_model:getRemainTimeInRound()
	self:setTextByLanKey("remain_time_text", Language:getTextByKey("gu_jian_qi_tan_str_056", GameUtil:formatTimeBySecond2(remain_time, 999)))
	if remain_time < 0 then
		GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("gu_jian_qi_tan_str_061"), delay_close = 2})
		self:updateMsg("refresh")
	end
end

function M:destroy()
    --EventDispatcher:unRegisterEvent("MazeStageViewTime")
    M.super.destroy(self)
end

return M