local M = class("HeroBoxControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "onCardClick" then
        if self.m_model.cur_select_index == data.index then
            self:openView("Pops.HeroLookInfo", {hero_id = data.hero_id, is_new = false})
        else
            self.m_model.cur_select_index = data.index
            self.m_view:refreshUI()
        end
    elseif msg == "choice_btn" then
        if self.m_model.cur_select_index <= 0 then
            return
        end
        if self.m_model.m_callBack then
            self.m_model.m_callBack(self.m_model.cur_select_index)
            self:closeView()
        else
            self:useItem(self.m_model.cur_select_index)
        end
    end
end

--[[
    item_id: 道具id item_num: 道具数量 item_index: 玩家自选道具
]]
function M:useItem(index)
    local item_num = self.m_model:getUseNum()
    item_num = math.min(item_num, self.m_model.m_show_data.user_num)
    if item_num < 1 then
        local show_data = self.m_model.m_show_data
        local item_cfg = show_data.item_cfg
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey(item_cfg.sort == 2 and "new_str_0051" or "new_str_0052"), delay_close = 2})
        return
    end
    local item_id = self.m_model.m_show_data.data_id
    local function netCallback(response)
        if self.m_view then
            self.m_view:refreshUI()
            --local user_num = self.m_model.m_show_data.user_num
            --if user_num < 1 then
            --    self:updateMsg(99999)
            --end
            self:updateMsg(99999)
            RewardUtil:rewardTipsByData(response.reward)
        end
    end
    local params = {item_id = item_id, item_num = self.m_model.m_use_num, item_index = index - 1}
    if self.m_model.m_show_data.item_cfg.type == 20 then
        params.item_index = self.m_model.m_cur_select_id
    end
    self.m_model:getNetData("item_use_item", params, netCallback)
end

return M
