local M = class("GuessPopView",LikeOO.OOPopBase)

M.m_uiName = "PeakArena/GuessPop"
M.m_size_type = 2

function M:onEnter()
    self:setTextByLanKey("count_text", "peak_str_0001")	
    self:setTextByLanKey("common_title_text", "peak_str_0048")
    local function musicSlider(value)
		self:updateMsg("updateSliderValue", value)
	end 
	self:addSliderListener("Slider_Move", musicSlider)
    local headNode = self:findGameObject("HeadNode")
    if self.m_model.m_play_data then
        GameUtil:setUserAvatar(headNode, self.m_model.m_play_data.user,nil,nil,{show_flag = true, scale = 1})
        self:setTextByLanKey("player_name", self.m_model.m_play_data.user.name)
        local combat_num = UserDataManager.user_data:getUserStatusDataByKey("full_combat")
        self:setTextByLanKey("combat_text", Language:getTextByKey("friend_str_0041") ..self.m_model.m_play_data.combat)
    else
        GameUtil:setUserAvatar(headNode, UserDataManager.user_data.user_status,nil,nil,{show_flag = true, scale = 1})
    end
    self:refreshUI()
end

--刷新UI
function M:refreshUI()
    local cost_data = RewardUtil:getProcessRewardData({135,0,0})
    self:setImg(cost_data.icon_name, cost_data.atlas_name, "money_icon")
    self:setTextByLanKey("money_num", cost_data.user_num)
    self:setTextByLanKey("once_max_num", self.m_model.m_once_max)
    local slider = self:findSlider("Slider")
    if slider then
        local per_num = self.m_model.m_cur_num/ self.m_model.m_once_max
        slider.value = per_num
    end
    self:refreshNum()
end


function M:refreshNum()
    self:setTextByLanKey("cur_num_text", self.m_model.m_cur_num)
end

return M