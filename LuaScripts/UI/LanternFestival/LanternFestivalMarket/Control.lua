local M = class("LanternFestivalMarketControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refresh_index", nil, "LanternFestival")
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = -1})
    elseif msg == "refreshRedPoint" then
        self.m_view:refreshRedPoint() 
    elseif msg == "help_btn" then
        local params = {}
        params.title = "lantern_festival_text_0004"
        params.content = self.m_model.m_help_id
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "eat_exchange" then --兑换
        self:requestRankData(data)
    end
end

function M:destroy()
    M.super.destroy(self)
end

--兑换
function M:requestRankData(data)
    local function netCallback(response)
        if self.m_view then
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
            RewardUtil:rewardTipsByData(response.reward) --展示奖励
            self.m_model:initData(response)
            self.m_view:refreshUI()
        end
    end
    self.m_model:getNetData("active_lantern_exchange", { vsn = data.version,gift_id = data.id }, netCallback)
end
return M;
