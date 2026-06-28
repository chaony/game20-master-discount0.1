local M = class("FateStoryControl", LikeOO.OOControlBase)

function M:onEnter()
    M.super.onCreate(self)
    self.m_guide_file_name = "UI.Hotel.Fate.FateStory.Guide"
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "click" then
        local state = 0
        if data.index == self.m_model.m_cur_stage_index + 1 then
            state = 1 --可以打
        elseif data.index <= self.m_model.m_cur_stage_index then
            state = 2 --通关
        else
            state = 0 --不能打
        end
        local params = {state = state, hero_id = self.m_model.m_cur_hero_id, stage = data.data}
        self:openView("Hotel.Fate.FateStoryChallengePop", params)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M