local M = class("RacconGameView",LikeOO.OOPopBase)

M.m_uiName = "Raccon/RacconGame"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
	self.left_btn_state = 1  -- 1 up, 2 down
	self.right_btn_state = 1
	self.desk_top = self:findGameObject("desk_top")
	self.play_area = self:findGameObject("play_area")
	self.bowl_left_up = self:findGameObject("bowl_left_up")
	self.bowl_right_down = self:findGameObject("bowl_right_down")
	self.m_character_spine = self:findSkeletonGraphic("character")
	self.m_collided_effect_run = self:findGameObject("collided_effect_run")
	self.m_collided_effect_idle = self:findGameObject("collided_effect_idle")
	self.m_collided_spine_run = self:findSkeletonGraphic("collided_spine_run")
	self.m_collided_spine_idle = self:findSkeletonGraphic("collided_spine_idle")
	self.m_character_transform = self:findRectTransform("character")
	self.m_spawn_point_1_position = self:findRectTransform("spawn_point_1").position
	self.m_spawn_point_2_position = self:findRectTransform("spawn_point_2").position
	self.m_spawn_point_3_position = self:findRectTransform("spawn_point_3").position
	self.m_spawn_point_4_position = self:findRectTransform("spawn_point_4").position
	self.m_spawn_point_5_position = self:findRectTransform("spawn_point_5").position

	self:displayRule()
	self.m_collided_effect_run:SetActive(false)
	self.m_collided_effect_idle:SetActive(false)
	self:setTextByLanKey("close_title_text", "raccon_text_0021")
	
	self:addActionChangAn("left_btn", nil, handler(self, self.leftBtnLongPress))
	self:addActionChangAn("right_btn", nil, handler(self, self.rightBtnLongPress))
	self:addTriggerEnter("left_btn")  -- 为了触发 point exit 回调停止奔跑动画
	self:addTriggerEnter("right_btn")
	self:addTrigger("left_btn", handler(self, self.setLeftPressDown), handler(self, self.setLeftPressUp))
	self:addTrigger("right_btn", handler(self, self.setRightPressDown), handler(self, self.setRightPressUp))
end

-- 处理左右按钮状态
function M:getRightBtnState()
	return self.right_btn_state
end

function M:getLeftBtnState()
	return self.left_btn_state
end

function M:setLeftPressDown()
	self.left_btn_state = 2
end

function M:setLeftPressUp()
	self.left_btn_state = 1
end

function M:setRightPressDown()
	self.right_btn_state = 2
end

function M:setRightPressUp()
	self.right_btn_state = 1
end


-- 按钮长按事件
function M:leftBtnLongPress()
	self:updateMsg("left_btn_long_press")
end

function M:rightBtnLongPress()
	self:updateMsg("right_btn_long_press")
end

-- 设置角色位置
function M:setCharacterPosition(new_position_x)
	if self.m_character_transform == nil then
		return
	end
	local new_position = self.m_character_transform.localPosition
	new_position.x = new_position_x
	self.m_character_transform.localPosition = new_position
end

-- 设置角色朝向
function M:setCharacterDirection(direction)
	if self.m_character_transform == nil then
		return
	end
	self.m_character_transform.localScale = Vector3(direction, 1, 1)
end

-- 播放角色运动 spine 动画
function M:setCharacterAnim(anim_name)
	if self.m_character_spine.skeletonDataAsset ~= nil and self.m_character_spine.AnimationState:ToString() ~= anim_name then
		self.m_character_spine.AnimationState:SetAnimation(0, anim_name, true)
	end
end

-- 播放物品获取特效
function M:playCollidedEffect()
	if self.m_model:isCharacterRunning() then
		self.m_collided_effect_run:SetActive(true)
		self.m_collided_spine_run.AnimationState:SetAnimation(0, "Raccon_JieQuDaoJu_001", false)
	else
		self.m_collided_effect_idle:SetActive(true)
		self.m_collided_spine_idle.AnimationState:SetAnimation(0, "Raccon_JieQuDaoJu_001", false)
	end
end

-- 更新游戏分数
function M:updateCurrentScore(score)
	local score_str = Language:getTextByKey("raccon_text_0022", score)
	self:setText("score_text", score_str)
end

-- 更新游戏时间
function M:updateGameTime(time)
	local minute = time // 60
	local second = time % 60
	local time_format = "%02d:%02d"
	local left_time_str = string.format(time_format, minute, second)
	self:setText("countdown_text", left_time_str)
end

-- 显示规则文案
function M:displayRule()
	local item_cfg = self.m_model:getItemCfg()
	local item1_score = item_cfg[1001][1001]["score"]
	local item2_score = item_cfg[1001][1002]["score"]
	local item3_score = item_cfg[1001][1003]["score"]
	local item1_score_str = Language:getTextByKey("raccon_text_0025", item1_score)
	local item2_score_str = Language:getTextByKey("raccon_text_0025", item2_score)
	local item3_score_str = Language:getTextByKey("raccon_text_0025", item3_score)
	self:setText("item1_score_text", item1_score_str)
	self:setText("item2_score_text", item2_score_str)
	self:setText("item3_score_text", item3_score_str)
end

-- 获取 UI 数据
function M:getItemParentObj()
	return self.play_area
end

function M:getBowlLeftUp()
	return self.bowl_left_up
end

function M:getBowlRightDown()
	return self.bowl_right_down
end

function M:getDeskTop()
	return self.desk_top
end

function M:getItemSpawnPosition(group_num)
	if group_num == 1001 then
		return self.m_spawn_point_1_position
	elseif group_num == 1002 then
		return self.m_spawn_point_2_position
	elseif group_num == 1003 then
		return self.m_spawn_point_3_position
	elseif group_num == 1004 then
		return self.m_spawn_point_4_position
	elseif group_num == 1005 then
		return self.m_spawn_point_5_position
	end
end

return M