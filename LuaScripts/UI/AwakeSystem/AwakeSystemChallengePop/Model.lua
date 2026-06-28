---
---
local M = class("AwakeSystemChallengePopModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData()
end

function M:onEnter()
    self.m_hero_id = self.m_params.hero_id  or 0
    self.m_stage_id = self.m_params.stage_id  or 0
    self.m_stage = 0
    self.m_stage_cfg = {} 
end


function M:refreshData(response)
   
end

return M