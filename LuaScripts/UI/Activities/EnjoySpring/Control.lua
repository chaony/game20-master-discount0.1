local M = class("EnjoySpringControl",LikeOO.OOControlBase)

function M:onEnter()
    audio:SendEvtBGM("Set_State_Spring")
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        if self.m_model.is_tokens == true then
            self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensEntrancPop")
            self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensSelectGiftBagPop")
        end
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    elseif msg == "btn_1" then--翠柳轩（节日商店） 
        if self.m_model:getActStatus() == 1 then
            RedPointUtil:saveLocalRedPointFreshTime("literature_shop_once")
            self.m_view:refreshRedPoint()
            self:openView("Activities.EnjoySpring.LiteratureShop", {is_token = self.m_model.m_is_token})
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
        end
    elseif msg == "btn_2" then --云鸢柳（活动任务）
        if self.m_model:getActStatus() == 1 then
            RedPointUtil:saveLocalRedPointFreshTime("literature_task_once")
            self.m_view:refreshRedPoint()
            local params = self.m_model.m_data
            self:openView("Activities.EnjoySpring.LiteratureTaskPop", params)
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
        end
    elseif msg == "btn_3" then --文曲榜（核心玩法）
        if self.m_model.m_data.force and self.m_model.m_data.force > 0 then
            RedPointUtil:saveLocalRedPointFreshTime("literature_rank_task_once")
            self.m_view:refreshRedPoint()
            local params = {}
            params.version = self.m_model.version
            params.is_token = self.m_model.m_is_token
            self:openView("Activities.EnjoySpring.LiteratureRankTask", params)
        else
            local params = self.m_model.m_data
            self:openView("Activities.EnjoySpring.LiteratureRank", params)
        end
    elseif msg == "btn_4" then --赏春阁（签到活动）
        if self.m_model:getActStatus() == 1 then
            RedPointUtil:saveLocalRedPointFreshTime("literature_signIn_once")
            self:openView("Activities.EnjoySpring.LiteratureSignIn")
            self.m_view:refreshRedPoint()
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
        end
        -- self:openView("Activities.EnjoySpring.LiteratureSharePop")
    elseif msg == "update_data" then
        self:updateData(data)
    elseif msg == "update_question" then
        self.m_model.m_data.cur_question = data
    elseif msg == "refresh_literatureRedDot" then
        self.m_view:refreshRedPoint()
    end
end

function M:updateData(data)
    local function callback(response)
        if response.update then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
            self:closeView()
            return
        end
        if response["end"] then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
            self:closeView()
            return
        end
        self.m_model:updateData(response)

        --文曲榜选择奖励后，重新打开，造成刷其UI的效果
        if data and data.msg_source == "literature_group_select" then
            self:updateMsg("btn_3")
        end
    end
    self.m_model:getNetData("enjoy_spring_index", nil, callback)
end

--计时器
function M:updateTime()
    self.m_view:updateActivityTimer()
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    SceneManager:getCurSceneView():setBGMusic()
    M.super.destroy(self)
end

return M;
