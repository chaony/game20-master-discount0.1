local M = class("RacconGameControl",LikeOO.OOControlBase)

M.m_character_position_x = 0

function M:onEnter()
    self.m_is_game_end = false
    self.m_move_range = self.m_model:getCharacterMoveRange()
    self.m_character_speed = self.m_model:getCharacterSpeed()
    
    self:refreshTimeInView()
    self:refreshScoreInView()
    self.m_item_manager = require("UI.Raccon.RacconGame.RacconItemManager").new()
    self.m_item_manager:init(self)
    self.m_item_manager:startGenerateItem()
    
    self.m_countdown_timer_id = self:setTimer(1, handler(self, self.countDownGameTime))
end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "close_view" then
        self:openView("Raccon.RacconGameEntrance")
        self:closeView()
    elseif msg == "result_close_btn" then
        self:openView("Raccon.RacconGameEntrance")
        self:closeView()
    elseif msg == "left_btn_long_press" then
        if self.m_view:getRightBtnState() == 1 then
            self.m_model:setCharacterState(2)
            self:moveCharacter(-1)
            self.m_view:setCharacterAnim("run")
        end
    elseif msg == "right_btn_long_press" then
        if self.m_view:getLeftBtnState() == 1 then
            self.m_model:setCharacterState(2)
            self:moveCharacter(1)
            self.m_view:setCharacterAnim("run")
        end
    elseif msg == "add_score" then
        audio:SendEvtUI("UI_Score")
        self:addScore(data)
        self.m_view:playCollidedEffect()
    elseif msg == "add_time" then
        audio:SendEvtUI("UI_Score")
        self:addGameTime(data)
        self.m_view:playCollidedEffect()
    elseif msg == "end_game" then
        audio:SendEvtUI("UI_Blast")
        self:endGame()
        self.m_view:playCollidedEffect()
    else
        self.m_model:setCharacterState(1)
        self.m_view:setCharacterAnim("idle")
    end
end

-- 角色移动
function M:moveCharacter(direction)
    if self.m_is_game_end then
        return
    end
    if direction == -1 and self.m_character_position_x > self.m_move_range[1] then
        self.m_character_position_x = self.m_character_position_x - self.m_character_speed
    elseif direction == 1 and self.m_character_position_x < self.m_move_range[2] then
        self.m_character_position_x = self.m_character_position_x + self.m_character_speed
    end
    self.m_view:setCharacterPosition(self.m_character_position_x)
    self.m_view:setCharacterDirection(direction)
end

-- 倒计时
function M:countDownGameTime()
    if self.m_is_game_end then
        return
    end
    self.m_model:countDownLeftTime(1)
    self:refreshTimeInView()
end

function M:addGameTime(item)
    if self.m_is_game_end then
        return
    end
    self.m_model:addLeftTime(item.time_add)
    self:refreshTimeInView()
end

function M:refreshTimeInView()
    local left_time = self.m_model:getLeftTime()
    if left_time > 0 then
        self.m_view:updateGameTime(left_time)
    else
        self.m_view:updateGameTime(0)
        self:endGame()
    end
end

-- 游戏分数
function M:addScore(item)
    if self.m_is_game_end then
        return
    end
    self.m_model:addScore(item.score)
    self:refreshScoreInView()
end

function M:refreshScoreInView()
    local current_score = self.m_model:getCurrentScore()
    self.m_view:updateCurrentScore(current_score)
end

-- 游戏结束
function M:endGame()
    self.m_is_game_end = true
    self.m_item_manager:stopGenerateItem()
    self:removeTimer(self.m_countdown_timer_id)
    
    local end_score = self.m_model:getCurrentScore()

    local netParams = {}
    netParams.score = end_score
    netParams.open_id = self.m_model:getOpenID()
    netParams.vsn = self.m_model:getGameVersion()
    self.m_model:getNetData("game_street_common_settlement", netParams)
    
    local params = {}
    params.score = end_score
    params.content = self.m_model:getGameEndContent(end_score)
    self:openView("Raccon.RacconGameEnd", params)
end

function M:destroy()
    self:removeTimer(self.m_countdown_timer_id)
    self.m_item_manager:stopGenerateItem()
    self.m_item_manager = nil
    M.super.destroy(self)
end

return M
