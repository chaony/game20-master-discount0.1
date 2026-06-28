---@class FukubukurokuShareView: OOPopBase
local M = class("FukubukurokuMainView", LikeOO.OOPopBase)

M.m_uiName = "Fukubukuroku/FukubukurokuShare"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
    self.grade_img = self:findImage("grade_img_slider")
    self:refreshUI()
end

function M:refreshUI()
    local cfg =  ConfigManager:getCfgByName("luckybag")
    local cfgData = cfg[self.m_model.open_id][self.m_model.version]
    local reward = cfgData[self.m_model.can_share] and cfgData[self.m_model.can_share].share_reward or {}
    local days = cfgData[self.m_model.can_share] and cfgData[self.m_model.can_share].target_day or 365
    for i = 1,4 do
        local reward_item_node = self:findGameObject("ItemNode"..i)
        local rewardData = reward[i] or nil
        if rewardData then
            local ui_element = GameUtil:updateItemElement(reward_item_node,rewardData , true, true)
        else 
            self:setObjectVisible("ItemNode"..i,false)    
        end
    end
    local userData = UserDataManager.user_data:getOwnRankData({})
    local head_node = self:findGameObject("head_node")
    GameUtil:setUserAvatar(head_node, userData.user, false, false, {show_flag = true, scale = 1})
    self:setTextByLanKey("head_name_txt",userData.user.name or "")
    local server_name = UserDataManager.server_data:getServerName()
    self:setTextByLanKey("head_server_txt",server_name or "")
    self:setTextByLanKey("title_day_txt",days)
  
    self:setObjectVisible("shou_suo_image", false) --官服
    self:setObjectVisible("er_wei_ma_image",false)
    --local reward_node = self:findGameObject("reward_node")
    --GameUtil:createRewards(reward_node.transform, reward, true, true, nil, 1)
end


function M:ShareShow(flag)
    self:setObjectVisible("share_btn",flag)
    self:setObjectVisible("er_wei_ma_image",false)
    local application_Id = SDKUtil.sdk_params.applicationId or ""
    if application_Id == "com.hermes.wl" or SDKUtil.sdk_params.app == 2 then
        self:setObjectVisible("shou_suo_image", false) --官服
    else
        self:setObjectVisible("shou_suo_image",flag==false) --渠道
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M
