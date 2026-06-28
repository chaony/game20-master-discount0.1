local M = class("DaySevenPopControl", LikeOO.OOControlBase)

function M:onEnter()
    --self.m_timer_id = self:setTimer(1, handler(self, self.UpdateTime))
end

function M:onHandle(msg, data)
    if msg == 99999 then -- 关闭
        if self.m_model.m_callback then
            self.m_model.m_callback(self.m_model.m_callback_new)
        end
       --self:updateMsg("common_refresh", nil, "parent")
        self:updateMsg("refresh_red_point",nil,"parent")
        self:closeView()
    elseif msg == "get_day_btn_1" then
        self:overTaskEvent(self.m_model.m_task_data[1].id)
    elseif msg == "get_day_btn_2" then
        self:overTaskEvent(self.m_model.m_task_data[2].id)
    elseif msg == "get_day_btn_3" then
        self:overTaskEvent(self.m_model.m_task_data[3].id)
    elseif msg == "look_hero_btn" then
        local id = tonumber(TONGYONG_ZHAOYUN[self.m_model.is_open_type].hero_id or 605)
        self:openView("Pops.HeroLookInfo", {hero_id = id, is_new = false,is_open_type = 1})
    elseif msg == "get_day_btn"  then
        self:updateMsg("update_share_bg",false,"GuildHighWar.GuildHighWarNewMainYan")
        self.m_view:ShareShow(false)
    elseif msg == "update_share_bg" then
        local show_call = function()
            self:updateMsg("update_share_bg",true,"GuildHighWar.GuildHighWarNewMainYan")
            self.m_view:ShareShow(true)
        end
        local close_call = function()
            local function receivetCallback(response)
                RewardUtil:rewardTipsByData(response.reward)
                self:updateMsg("is_share", { is_share = 1},"GuildHighWar.GuildHighWarNewMainYan")
                self:closeView()
            end
            local params = {}
            params.sort = 1
            params.open_id = 295
            local activeData = UserDataManager:getActivesDataByOpenId( params.open_id)
            local curVersion = activeData.version
            params.vsn = curVersion
            self.m_model:getNetData("user_share", params, receivetCallback)
        end
        --local close_call = function()
        --    local callback = function(response)
        --        self:closeView()
        --        self:updateMsg("change_double_time",response , "Activities.ZhangMenSimulator") --开启双倍收益
        --    end
        --    self.m_model:getNetData("simulator_double_time",nil,callback)
        --end
        self:openView("SharePicture", {picture_callback = show_call,picture_closeback = close_call})  -- 分享图片
    end
end

--领取任务
function M:overTaskEvent(quest_id)
    local params = {open_id = self.m_model.m_open_id, vsn = self.m_model.m_version, quest_id = quest_id}
    self.m_model:getNetData("common_quest_recv_task", params, function(response)
        if response then
            self.m_model:refreshData(response)
            self.m_view:refreshUI()
            RewardUtil:rewardTipsByData(response.reward)
        end
    end, nil, nil, nil)
end
--计时器
function M:UpdateTime()
    self.m_view:updateActivityTimer()
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M
