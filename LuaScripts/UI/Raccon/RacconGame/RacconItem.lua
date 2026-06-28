local M = class("RacconItem", LikeOO.OOUIbase)

M.m_uiName = "Raccon/RacconItem"

function M:onEnter()
    self.m_graphic_root = self:findGameObject("graphic_root")
    self.m_effect_bomb = self:findGameObject("effect_bomb")
    self.m_effect_noodle = self:findGameObject("effect_noodle")
    self.m_effect_bubble = self:findGameObject("effect_bubble")
    self.m_item_left_up = self:findGameObject("item_left_up").transform
    self.m_item_right_down = self:findGameObject("item_right_down").transform
    
    self:initItem(self.m_params.item_data)
    self.count_id = self.m_item_data.count_id
end

-- 设置道具数据与显示
function M:initItem(data)
    self.m_item_data = data
    self.item_manager = self.m_item_data.item_manager
    self.item_type = self.m_item_data.type
    self.item_id = self.m_item_data.id
    self.bowl_left_up = self.m_item_data.bowl_left_up.transform
    self.bowl_right_down = self.m_item_data.bowl_right_down.transform
    self.desk_top = self.m_item_data.desk_top.transform

    self.m_fall_down_timer_id = self.m_control:setTimer(0.02, handler(self, self.fallDown))
    self.m_character_collision_timer_id = self.m_control:setTimer(0.05, handler(self, self.checkCollisionWithCharacter))
    self.m_ground_collision_timer_id = self.m_control:setTimer(0.05, handler(self, self.checkCollisionWithGround))

    self.m_rt.position = self.m_item_data.spawn_position
    self.m_graphic_root:SetActive(true)
    self:setItemImg()
    self:setItemText()
    self:setItemEffect()
end

-- 设置道具图片
function M:setItemImg()
    local sprite_name
    if self.item_id == 1001 then
        sprite_name = "a_ldxhxhd_fctj_icon_zhong"
    elseif self.item_id == 1002 then
        sprite_name = "a_ldxhxhd_fctj_icon_hong"
    elseif self.item_id == 1003 then
        sprite_name = "a_ldxhxhd_fctj_icon_fen"
    elseif self.item_id == 1004 then
        sprite_name = "a_ldxhxhd_fctj_icon_qipao"
    elseif self.item_id == 1005 then
        sprite_name = "a_ldxhxhd_fctj_icon_qipao"
    elseif self.item_id == 1006 then
        sprite_name = "a_ldxhxhd_fctj_icon_qipao"
    elseif self.item_id == 1007 then
        sprite_name = "a_ldxhxhd_fctj_icon_zhadan"
    end
    self:setImg(sprite_name, "maze_stage_ui", "item_img")
end

-- 设置道具文本
function M:setItemText()
    local text_name = "item_text"
    if self.item_type == 2 then
        self:setObjectVisible(text_name, true)
        local time_add = self.m_item_data.time_add
        local time_str = Language:getTextByKey("raccon_text_0024", time_add)
        self:setText(text_name, time_str)
    else
        self:setObjectVisible(text_name, false)
    end
end

-- 设置道具特效
function M:setItemEffect()
    if self.item_type == 1 then
        self.m_effect_noodle:SetActive(true)
        self.m_effect_bubble:SetActive(false)
        self.m_effect_bomb:SetActive(false)
    elseif self.item_type == 2 then
        self.m_effect_noodle:SetActive(false)
        self.m_effect_bubble:SetActive(true)
        self.m_effect_bomb:SetActive(false)
    elseif self.item_type == 3 then
        self.m_effect_noodle:SetActive(false)
        self.m_effect_bubble:SetActive(false)
        self.m_effect_bomb:SetActive(true)
    end
end

-- 道具下落
function M:fallDown()
    local new_position = self.m_rt.position
    new_position.y = new_position.y - self.m_item_data.speed
    self.m_rt.position = new_position
end

-- 与地面进行碰撞检测
function M:checkCollisionWithGround()
    local item_left_up_position = self.m_item_left_up.position
    local item_most_up = item_left_up_position.y
    local desk_top_position = self.desk_top.position
    local desk_top_y = desk_top_position.y
    if item_most_up < desk_top_y then
        self.m_control:removeTimer(self.m_fall_down_timer_id)
        self.m_control:removeTimer(self.m_character_collision_timer_id)
        self.m_control:removeTimer(self.m_ground_collision_timer_id)
        self.item_manager:onItemCollided(self)
        self.m_graphic_root:SetActive(false)
    end
end

-- 与角色的碗进行碰撞检测
function M:checkCollisionWithCharacter()
    local item_left_up_position = self.m_item_left_up.position
    local item_right_down_position = self.m_item_right_down.position
    local item_most_left = item_left_up_position.x
    local item_most_up = item_left_up_position.y
    local item_most_right = item_right_down_position.x
    local item_most_down = item_right_down_position.y
    
    local bowl_left_up_position = self.bowl_left_up.position
    local bowl_right_down_position = self.bowl_right_down.position

    local bowl_most_left
    local bowl_most_right
    local bowl_most_up = bowl_left_up_position.y
    local bowl_most_down = bowl_right_down_position.y
    if bowl_left_up_position.x < bowl_right_down_position.x then
        bowl_most_left = bowl_left_up_position.x
        bowl_most_right = bowl_right_down_position.x
    else  -- 角色转向时，左上变为右上，右下变为左下
        bowl_most_left = bowl_right_down_position.x
        bowl_most_right = bowl_left_up_position.x
    end
    
    local is_collided = false;
    if item_most_left > bowl_most_right then
        is_collided = false
    elseif item_most_right < bowl_most_left then
        is_collided = false
    elseif item_most_up < bowl_most_down then
        is_collided = false
    elseif item_most_down > bowl_most_up then
        is_collided = false
    else
        is_collided = true
    end
    
    if is_collided then
        self.m_control:removeTimer(self.m_fall_down_timer_id)
        self.m_control:removeTimer(self.m_character_collision_timer_id)
        self.m_control:removeTimer(self.m_ground_collision_timer_id)
        self:sendItemGotMsg()
        self.item_manager:onItemCollided(self)
        self.m_graphic_root:SetActive(false)
    end
end

-- 发送角色碰撞事件
function M:sendItemGotMsg()
    if self.item_type == 1 then
        self:updateMsg("add_score", {score = self.m_item_data.score})
    elseif self.item_type == 2 then
        self:updateMsg("add_time", {time_add = self.m_item_data.time_add})
    elseif self.item_type == 3 then
        self:updateMsg("end_game")
    end
end

return M
