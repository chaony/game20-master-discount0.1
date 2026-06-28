local M = class("SkinExchangePopControl",LikeOO.OOControlBase)

function M:onEnter()
    audio:SendEvtUI("Play_UI_Popup_1")
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
	elseif msg == "exchange_btn" then
        self:exchangeHeroSkin(data.cell_data)
    elseif msg == "look_btn" then
        local hero_id = data.cell_data.cfg.hero
        local skin_id = data.cell_data.id
        self:openView("Pops.HeroSkinLookInfo", {is_new = false, skin_id = skin_id})
    end
end

--一使用英雄皮肤
function M:exchangeHeroSkin(data)
    local convert = data.cfg.convert or {}
    if #convert > 0 then
        local cost = convert[1]
        local cost_data = RewardUtil:getProcessRewardData(cost)
        if cost_data.user_num < cost_data.data_num then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0098", cost_data.name), delay_close = 2})
            return
        end
        local params =
        {
            on_ok_call = function(params)
                local function callfunc(response)
                    self.m_view:refreshUI()
                    RewardUtil:rewardTipsByData(response.reward)
                    self:updateMsg("common_refresh", nil, "HeroBag")
                end
                self.m_model:getNetData("hero_exchange_hero_skin", {skin_id = data.id}, callfunc)
            end,
            text = Language:getTextByKey("new_str_0932", tostring(cost_data.data_num), cost_data.name),
        }
        self:openView("Pops.CommonPop", params)
    else
        Logger.logError(data, "cfg not found cost : ")
    end
end

return M;
