local M = class("HeroGatherPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refresh_red_point",nil,"Activities")
        self:closeView()
    elseif msg == "back_btn" then
    	self:closeView()
    elseif msg == "receive_btn" then
        self:requestReceive(data)
    elseif msg == "pub_btn" then
    	self:openView("Pub")
    elseif msg == "shop_btn" then
    	self:openView("Shop", { shop_type = 3})
    elseif msg == "advanced_btn" then
    	self:openView("Advanced")
    elseif msg == "help_btn" then
        local cfg_data = ConfigManager:getCfgByName("hero_gather")

        local params = {}
        params.title = "activities_str_0002"
        params.content = cfg_data[1].des
        self:openView("Pops.CommonHelpPop", params)
    end
end

function M:requestReceive(data)
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self.m_model:updateData({hero_gather_received = response.hero_gather_received})
        self.m_view:refreshUI()
    end
    local params = {}
    params.reward_id = data
    self.m_model:getNetData("active_receive_hero_gather", params, receivetCallback)
end

return M;
