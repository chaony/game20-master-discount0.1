local M = class("FateStoryChallengePopModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self.m_transfer = "scale"
    self:getData()
end

function M:onEnter()
    self.m_state = self.m_params.state
    local hero_id = self.m_params.hero_id
    self.m_stage = self.m_params.stage
    --local all_cfg = ConfigManager:getCfgByName("hotel_love_stage")
    --local stages = all_cfg[hero_id]
    --self.m_stage_cfg = stages[self.m_stage_id]
    --self.m_stage = self.m_stage_cfg.stage
end

return M