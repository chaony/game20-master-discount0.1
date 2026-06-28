local M = class("HeavenBlessRewardTaskPanelControl", LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg, data)
    if msg == 99999 then -- 关闭
        self:updateMsg("refreshUI", nil, "GiftBag")
        EventDispatcher:dipatchEvent("kongMing_setAward") --刷新天赐祈福主界面
        self:closeView()
    elseif msg == "mask_btn" then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0535"), delay_close = 2})
    elseif msg == "go_to" then
      local func_id = data
      if func_id then
          local jump = ConfigManager:getCfgByName("jump")
          local jump_item = jump[func_id]
          if jump_item then
              local open_condition_id = jump_item.open_condition_id or 0
              local open_flag, tips_str = BtnOpenUtil:isBtnOpen(open_condition_id)
              if open_flag == true then
                  self:updateMsg("common_refresh", nil, "parent") 
                  static_rootControl:closeAllViewPop()
                  local go_type = data or {}
                  QuickOpenFuncUtil:openFunc(go_type)
              else
                  GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2}) 
              end
          end
      end
    elseif msg == "get_buy" then
        self:getDrawBuy()
    elseif msg == "get_login" then
        self:getDrawLogin()
    elseif msg == "select_tag" then
        self.m_model.m_select_index = data
        RedPointUtil:setDrawTaskShopRedPoint(self.m_model.m_select_index)
        self.m_view:refreshUI()
    elseif msg == "get_reward" then
        self:getDrawTask(data)
    elseif msg == "all_get_btn" then
        --self:getAllDrawTask(data)
    end
end

function M:getAllDrawTask(data)
    local function callback(response)
        if response then
            if response["end"] == 1 then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
                self:updateMsg("updateNewNet", nil, "GiftBag")
                self:updateMsg(99999)
                return
            end
            RewardUtil:rewardTipsByData(response.reward)
            self.m_model.m_task_data = response.quests
            self.m_model.m_login_done = response.login_done
            self:updateMsg("updateDrawData", response, "GiftBag")
            self.m_view:refreshUI()
        end
    end
    if self.m_model:checkCanQuick() == false then
        GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("gf_str_0106"), delay_close = 2})
        return
    end
    local params = {}
    params.vsn = self.m_model.m_version
    self.m_model:getNetData("draw_recv_all", params, callback, nil, true)
end

function M:getDrawTask(data)
    local function callback(response)
        if response then
            if response["end"] == 1 then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
                self:updateMsg("updateNewNet", nil, "GiftBag")
                self:updateMsg(99999)
                return
            end
            RewardUtil:rewardTipsByData(response.reward)
            --self.m_model.m_task_data = response.quests
            --self:updateMsg("updateDrawData", response, "GiftBag")
            self.m_model:updateData(response)
            self.m_view:refreshUI()
        end
    end
    local params = {}
    params.quest_id = data
    params.vsn = self.m_model.m_version
    params.open_id = self.m_model.m_openId
    self.m_model:getNetData("common_quest_recv_task", params, callback, nil, true)
end

function M:getDrawBuy()
    local function callback(response)
        if response then
            if response["end"] == 1 then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
                self:updateMsg("updateNewNet", nil, "GiftBag")
                self:updateMsg(99999)
                return
            end
            RewardUtil:rewardTipsByData(response.reward)
            --self.m_model.m_task_data = response.quests
            --self.m_model.m_shop_done = response.shop_done
            --self.m_model.m_login_done = response.login_done
            --self:updateMsg("updateDrawData", response, "GiftBag")
            self.m_model:updateData(response)
            self.m_view:refreshUI()
        end
    end
    local params = {}
    params.day = self.m_model.m_select_index
    params.vsn = self.m_model.m_version
    params.open_id = self.m_model.m_openId
    self.m_model:getNetData("common_quest_buy", params, callback, nil, true)
end


function M:getDrawLogin()
    local function callback(response)
        if response then
            if response["end"] == 1 then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
                self:updateMsg("updateNewNet", nil, "GiftBag")
                self:updateMsg(99999)
                return
            end
            RewardUtil:rewardTipsByData(response.reward)
            --self.m_model.m_task_data = response.quests
            --self.m_model.m_shop_done = response.shop_done
            --self.m_model.m_login_done = response.login_done
            --self:updateMsg("updateDrawData", response, "GiftBag")
            self.m_model:updateData(response)
            self.m_view:refreshUI()
        end
    end
    local params = {}
    params.day = self.m_model.m_select_index
    params.vsn = self.m_model.m_version
    params.open_id = self.m_model.m_openId
    self.m_model:getNetData("common_quest_recv_login", params, callback, nil, true)
end

return M
