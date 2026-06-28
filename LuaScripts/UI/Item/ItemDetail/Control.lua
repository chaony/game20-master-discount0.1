local M = class("ItemDetailControl",LikeOO.OOControlBase)

function M:onEnter()
    if SceneManager.curScene.showMove ~= nil then
        SceneManager.curScene.showMove:SetDepth(80)
    end
    audio:SendEvtUI("Play_UI_Popup_1")
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "minus_ten_btn" then
    	self.m_model:addUseNum(-10)
        self.m_view:updateUseNum()
    elseif msg == "minus_one_btn" then
    	self.m_model:addUseNum(-1)
        self.m_view:updateUseNum()
    elseif msg == "add_one_btn" then
    	self.m_model:addUseNum(1)
        self.m_view:updateUseNum()
    elseif msg == "max_btn" then
    	self.m_model:addUseNum(self.m_model:getMaxNum())
        self.m_view:updateUseNum()
    elseif msg == "use_btn" then
        if self.m_model.m_cost then
            if self.m_model.m_ok_call_func then
                self:updateMsg(99999)
                if self.m_model.m_ok_call_func then
                    local params = {}
                    if self.m_model.m_isToday then
                        params = {isToday = self.m_view.today_callback,cur_server_ts = self.m_view.cur_server_ts,reward_isOk = true}
                    end
                    self.m_model.m_ok_call_func(params)
                end
            end
        else
            self:useItem()
        end
    elseif msg == "today_btn" then
        self.m_view.today = not self.m_view.today
        self.m_view:todayIsActive()
    end
end

--[[
    item_id: 道具id item_num: 道具数量
]]
function M:useItem()
    local item_num = self.m_model:getUseNum()
    local show_data = self.m_model.m_show_data
    local item_cfg = show_data.item_cfg
    local item_id = self.m_model.m_show_data.data_id
    if item_num < 1 then
        if item_cfg.type == 12 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0442"), delay_close = 2})
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey(item_cfg.sort == 2 and "new_str_0051" or "new_str_0052"), delay_close = 2})
        end
        return
    else
        if item_cfg.type == 9 then -- 4选1紫色卡
            self:openView("Pub.MartialGachaPop", {item_id = item_id})
            self:updateMsg(99999)
            return
        end
    end
    
    local function netCallback(response)
        if self.m_view then
            self.m_view:refreshUI()
            local user_num = self.m_model.m_show_data.user_num
            if user_num < 1 then
                self:updateMsg(99999)
            end
            RewardUtil:rewardTipsByData(response.reward)
        end
    end
    local params = {item_id = item_id, item_num = item_num or 1}
    self.m_model:getNetData("item_use_item", params, netCallback)
end

function M:destroy()
    M.super.destroy(self)
    if SceneManager.curScene.showMove ~= nil then
        SceneManager.curScene.showMove:SetDepth(120)
    end
end

return M
