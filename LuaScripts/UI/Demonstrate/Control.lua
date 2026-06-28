local M = class("DemonstrateSceneControl",LikeOO.OOControlBase)

function M:onEnter()
    if SceneManager ~= nil then
        SceneManager:init(2)
    end
end

function M:onSyncEnter()
    if not self.onlyone then
        self.onlyone = true
        local params = {
            data = self.m_model.m_data,
            mode = GlobalConfig.BATTLE_MODE.STAGE,
            isDemonstrate = true,
        }
        self:openView("GamePanel", params)
        SceneManager.curScene:resetUI()
    end
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
        self:openView("Main")
    elseif msg == "close_sync_load_big_loading" then
        self:closeView("Loading.SyncLoadBigLoading")
        self:onSyncEnter()
    elseif msg == "battle_end" then
        SceneManager.curScene:destroy()
        self:openView("Main", {heros = data})
        -- if data then
        --     local function callback()
        --         RewardUtil:rewardTipsByRewards(data)
        --     end
        --     EventDispatcher:registerTimeEvent("Demonstrate_newhero", callback, 1,1)
        -- end
    end
end

return M;
