---@class TokenControl:OOControlBase
local M=class("TokenControl",LikeOO.OOControlBase)


function M:onEnter()
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.CHARGE_BACK, {self, self.dataUpdateEvent})
    audio:SendEvtUI("UI_HuoDong")
end


function M:onHandle(msg, data)


    if msg == 99999 then -- 返回
        self:updateMsg("common_refresh", nil, "parent")
        if self.m_model.is_tokens == true then
            self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensEntrancPop")
        end
        if self.ref_buy_token and self.ref_buy_token == true then
            self:updateMsg("update_task_token", nil, "Task")
        end
        self:closeView()

    elseif msg == "switch_tab" then
        self:switchTabBtn(data.index, data.cell_object)
    end
end

-- tab按钮切换
function M:switchTabBtn(index,obj)
    if self.m_model.m_sel_tab_index ~= index then
        self.m_model.m_sel_tab_index = index
        self.m_view:switchTabNode(index,obj)
    end
end


function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.CHARGE_BACK, {self, self.dataUpdateEvent})
    M.super.destroy(self)
end

return M