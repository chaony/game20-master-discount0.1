--- 事件
local M = class("HongEventNode",LikeOO.OOUIbase)

M.m_uiName = "HangReward/HongEventNode"
M.m_iphoneXAdapter = true

function M:onEnter()
    self.m_model.m_event_point = 1
    self:refreshUI()    
end

function M:refreshUI()
    self:setObjectVisible("last_btn", false)   
    self:setObjectVisible("next_btn", false)   
    if self.m_model.m_event_point > 1 then
        self:setObjectVisible("last_btn", true)    
    end
    if #self.m_model.m_data.idle_events > self.m_model.m_event_point then
        self:setObjectVisible("next_btn", true)   
    end
    local cfg = self.m_model:getCfg()
    if cfg then
        local num = self.m_model:getRewardByType(cfg.item_reward)
        local reward_item = RewardUtil:getProcessRewardData({cfg.item_reward, 0, 1, num})
        self:setImg(reward_item.icon_name, reward_item.atlas_name, "icon_img")
        self:setTextByLanKey("event_name_text", cfg.des)
        self:setTextByLanKey("num_text",  math.floor((num * cfg.reward_per) + 0.5) )
    end
end

function M:onButtonClick(obj, name)
    if name == "last_btn" then
        if self.m_model.m_event_point == 1 then
            return
        else
            self.m_model.m_event_point = self.m_model.m_event_point - 1 
        end
    elseif name == "next_btn" then    
        if self.m_model.m_event_point >= #self.m_model.m_data.idle_events then
            return
        else
            self.m_model.m_event_point = self.m_model.m_event_point + 1
        end     
    else
        self:updateMsg(name)
    end
    self:refreshUI()
end

return M