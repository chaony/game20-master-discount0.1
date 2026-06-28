local M = class("BuySkinControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "close_btn" then    -- 返回
        self:closeView()
    elseif msg == "levelup_btn" then
        local consItem = RewardUtil:getProcessRewardData(self.m_model.select_skin_cfg.cost[1])
        if consItem.user_num < consItem.data_num then
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("fenghua_record_text10"), delay_close = 2})
        else
            self:getSkin()    
        end
	end
end

function M:getSkin()
    local function netcallback(response)
        if response[1] == 0 then
            self:updateMsg("updateFengHualist",nil,"FengHuaRecord")
            self:closeView()
        end
    end
    local params = {skin_id = self.m_model.skin_id}
    self.m_model:getNetData("fenghua_record_buy_record", params, netcallback)
end

return M
