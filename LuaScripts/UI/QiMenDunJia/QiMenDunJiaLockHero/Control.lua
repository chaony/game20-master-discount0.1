local M = class("QiMenDunJiaLockHeroControl",LikeOO.OOControlBase)

function M:onEnter()
   
end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "close_btn" then   
        self:closeView()
    elseif msg == "ok_btn" then
        self:questLockHero(data)
    end
end

function M:questLockHero()
    local function netCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self.m_model:updateLockStatus(response)
        self:updateMsg(99999)
    end
    local params = {
        ver = self.m_model:getVersion(),
        hero_oid = self.m_model:getLockHeroID()
    }
    self.m_model:getNetData("gve_lock_hero", params, netCallback)
end

function M:destroy()
    M.super.destroy(self)
end

return M
