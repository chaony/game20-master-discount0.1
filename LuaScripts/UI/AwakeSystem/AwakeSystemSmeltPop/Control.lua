---
---
local M = class("AwakeSystemSmeltPopControl",LikeOO.OOControlBase)

function M:onEnter()
    M.super.onCreate(self)
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg("smelt_refresh",nil,"AwakeSystem.AwakeSystemMain")
        self:closeView()
    elseif type(msg) == "number" and msg >= 1 and msg <= 5 then
        self:switchTabBtn(msg)
    elseif msg == "add_item" then
        self:addItem(data)
    elseif msg == "remove_item" then
        self:removeItem(data)
    elseif msg == "complete_btn" then
        local send_item_data = self.m_model:dealWithItemForServer()
        local function Callback(response)
            if response and next(response) and response.reward then
                RewardUtil:rewardTipsByData(response.reward)
                self.m_model:refreshListData(self.m_model.m_sel_tab_index,true)
                self.m_model:refreshMaterialListData()
                self.m_model:countResultItem()
                self.m_view:switchTabNode(self.m_model.m_sel_tab_index)
                self.m_view:setEqpCell()
            end
        end
        local params = {item_data = send_item_data}
        self.m_model:getNetData("awaken_recycle", params, Callback)
    end
end

-- 按钮切换
function M:switchTabBtn(index)
    if self.m_model.m_sel_tab_index ~= index then
        self.m_model:refreshListData(index)
        self.m_model:refreshMaterialListData()
        self.m_model:countResultItem()
        self.m_view:switchTabNode(index)
        self.m_view:setEqpCell()
        self.m_model.m_sel_tab_index = index
    end
end

function M:addItem(data)
    if not self.m_model:checkIsInEqpList(data) then
        self.m_model:addCheckEqp(data) --添加
        self.m_model:countResultItem()
        self.m_view:setEqpCell()
    end
end

function M:removeItem(data)
    self.m_model:removeCheckEqp(data) --移除
    self.m_model:countResultItem()
    self.m_view:setEqpCell()
end



function M:dataUpdateEvent(event, data)
    local curEvent = data.event
    if curEvent == "items_update" or curEvent == "equips_update" or curEvent == "mystices_update" then
        self.m_model:refreshListData(self.m_model.m_sel_tab_index, true)
        self.m_view:switchTabNode(self.m_model.m_sel_tab_index, true)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    M.super.destroy(self)
end

return M