local M = class("ShareRankPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg("refresh_ui", nil, "ShareLv") 
        self:closeView()
    elseif type(msg) == "number" and msg >= 1 and msg <= 3 then
        self:switchTabBtn(msg)
    elseif msg == "open_btn" then
    	local count = #self.m_model.m_data.crystal_slot
        local reset_cost = GameUtil:getRefreshCost(count, 7)
        local params =
        {
            on_ok_call = function(msg)
                self:requestOpenSlot(1)
            end,
            cost = reset_cost,
            text = string.format(Language:getTextByKey("shareLv_str_0009"), reset_cost[3])
        }
        static_rootControl:openView("Pops.CommonPop", params)
    elseif msg == "fresh_data" then
        self:refreshData()
    elseif msg == "check_btn" then
        self.m_model.m_open_hint = true
        self.m_view:updateHint()
    elseif msg == "close_hint_btn" then
        self.m_model.m_open_hint = false
        self.m_view:updateHint()
    end
end

-- 按钮切换
function M:switchTabBtn(index)
    if self.m_model.m_select_index ~= index then
        self.m_model.m_select_index = index
        self.m_view:switchTabNode(index)
    end
end

function M:refreshData()
    local function netCallback(response)
        self.m_model:setData(response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("hero_crystal_index", nil, netCallback)
end

return M;
