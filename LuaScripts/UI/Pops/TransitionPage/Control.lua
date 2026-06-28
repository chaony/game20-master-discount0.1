local M = class("TransitionPageControl",LikeOO.OOControlBase)

function M:onEnter()
    self:updateMsg("transition_open_view")
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.CLOSE_VIEW, {self, self.closeViewEvent})
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
		if self.m_model.m_params.m_on_call_back then
			self.m_model.m_params.m_on_call_back()
		end
        self:closeView()
    elseif msg == "transition_open_view" then
        local func = self["transition" .. tostring(self.m_model.m_open_view_name)]
        if func then
            func(self)
        else
            self:setOnceTimer(5, function()
                SceneManager:continue()
                self:updateMsg(99999)
            end)
        end
    end
end

function M:transitionFormation()
    local battle_id = nil
    local mode = self.m_model.m_open_view_params.mode
    if mode == GlobalConfig.BATTLE_MODE.STAGE or mode == GlobalConfig.BATTLE_MODE.MULT_STAGE then -- 推图
        battle_id = UserDataManager:getBattleStage()
    elseif mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then -- 古剑奇谭
        battle_id = UserDataManager:getGuJianStage()
    end
    local function netCallback(response)
        if response then
            self.m_model.m_open_view_params.net_data = response
            self:openView("Formation", self.m_model.m_open_view_params)
        end
        self:setOnceTimer(0.5, function()
            SceneManager:continue()
            self:updateMsg(99999)
        end)
    end
    self.m_model:getNetData("battle_array_data", {battle_sort = mode, battle_id = battle_id}, netCallback, true)
end

function M:closeViewEvent(event, data)
    local view_name = data.name or ""
    if view_name == "Formation" or view_name == self.m_model.m_open_view_name then
    	self:updateMsg(99999)
    end
end

function M:destroy()
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.CLOSE_VIEW, {self, self.closeViewEvent})
    M.super.destroy(self)
end

return M;
