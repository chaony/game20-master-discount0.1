local M = class("HeroBossControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        --self:updateMsg("common_refresh",nil,"parent")
        self:closeView()
    elseif msg == "challenge_btn" then
        local left_times = self.m_model:getLeftTimes(true)
        if left_times <= 0 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0574"), delay_close = 2})
            return
        end
        self:requestChallenge()
    elseif msg == "intercept_btn" then
        local left_times = self.m_model:getLeftTimes()
        if left_times <= 0 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0574"), delay_close = 2})
            return
        end
        self:openView("Activities.HeroBoss.HeroBossIntercept")
    elseif msg == "reward_btn" then
        self:openView("Activities.HeroBoss.HeroBossReward")
    elseif msg == "help_btn" then
        local params = {}
        params.title = "hero_boss_text_001"
        params.content = "tid#HeroBossDes_1"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "tog_2" then
        local myRank = self.m_model:getMyRank(self.m_model.m_data.rank, self.m_model.m_data.score)
        self.m_view:refreshRank(self.m_model.m_data.ranks, myRank)
    elseif msg == "tog_1" then
        self:requestUnionRank()
    elseif msg == "cell" then
        local cell_data = data.cell_data
        self:openView("Pops.PlayerInfo", {uid = cell_data.user.uid})
    elseif msg == "update_data" then
        self.m_model.m_data = data
        self.m_view:refreshUI()
    end
end

--挑战
function M:requestChallenge()
    local params =
    {
        state = 1,
        m_boss_id = self.m_model:getBossID(),
        m_mode = GlobalConfig.BATTLE_MODE.HERO_BOSS_PVE,
        max_time = GlobalTools.base60, --战斗时间
    }
    SceneManager:changeScene(SceneManager.SceneID.HeroTrainScene, params, true)
    local cfg = self.m_model.m_cfg
    self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.HERO_BOSS_PVE,
                               def_data = self.m_model.m_data.enemy_data,
                               battle_id = cfg.stage_battle,
                               --addition_race = cfg.race,
                               --deployment = self.m_model.m_data.deployment,
                               version = self.m_model.m_data.version,
                               boss_id = self.m_model:getBossID()})
    --SceneManager:scenestart()
end

--主页公会榜
function M:requestUnionRank()
    local function callback(response)
        local myRank = self.m_model:getMyRank(response.rank, response.score, true)
        self.m_view:refreshRank(response.ranks, myRank)
    end
    local params = {}
    self.m_model:getNetData("hero_boss_guild_rank", params, callback)
end

function M:destroy()
    --EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    M.super.destroy(self)
end

return M