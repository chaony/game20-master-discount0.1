local M = class("BudoServerSelectPopControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.BudoServer.BudoServerSelectPop.Guide"
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:updateMsg("refreshRedPoint" ,nil ,"Main.Outskirts")
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = 32})
    elseif msg == "btn_0" or msg == "btn_1" then
        self:openView("Budo", {tower_type = 0})
    elseif msg == "item_node_1" then
        if self.m_model:checkIsOpen(1) == false then
            GameUtil:lookInfoTips(self,{msg = Language:getTextByKey("new_str_0576"), delay_close = 2})
            return
        end
        self:openView("Budo", {tower_type = 1})
    elseif msg == "item_node_2" then
        if self.m_model:checkIsOpen(2) == false then
            GameUtil:lookInfoTips(self,{msg = Language:getTextByKey("new_str_0576"), delay_close = 2})
            return
        end
        self:openView("Budo", {tower_type = 2})
    elseif msg == "item_node_3" then
        if self.m_model:checkIsOpen(3) == false then
            GameUtil:lookInfoTips(self,{msg = Language:getTextByKey("new_str_0576"), delay_close = 2})
            return
        end
        self:openView("Budo", {tower_type = 3})
    elseif msg == "item_node_4" then
        if self.m_model:checkIsOpen(4) == false then
            GameUtil:lookInfoTips(self,{msg = Language:getTextByKey("new_str_0576"), delay_close = 2})
            return
        end
        self:openView("Budo", {tower_type = 4})
    elseif msg == "refreshData" then    
        self.m_view:refreshUI()
    elseif msg == "receive_btn" then --领取
        self:questRecvMainReward()
    end
end


-- 领取主线奖励 quest_id: 任务id
function M:questRecvMainReward()
    local function netCallback(response)
        if self.m_view then
            RewardUtil:rewardTipsByData(response.reward) --展示已领取奖励
            self.m_model:updateServerData(response)
            self.m_view:refreshQuestMain()
        end
    end
    local params = {quest_id = self.m_model.main_quest_id}
    self.m_model:getNetData("quest_recv_main_reward", params, netCallback)
end

return M;
