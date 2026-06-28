---@class HalfAnniversaryGroupingPopView: OOPopBase
---@field m_model HalfAnniversaryGroupingPopModel
local M = class("HalfAnniversaryGroupingPopView", LikeOO.OOPopBase)

M.m_uiName = "HalfAnniversary/HalfAnniversaryGroupingPop"
M.m_size_type = 2

function M:onEnter()
    self:refreshUI()
    self:refreshLoopScroll()
end

function M:refreshUI()
    self:setTextByLanKey("title_text", "gift_group_text_0009")
    self:setTextByLanKey("tips_text", "gift_group_text_0012")
    self:setTextByLanKey("empty_text", "gift_group_text_0036")
end

function M:refreshLoopScroll()
    local data = self.m_model:getCurDayGiftList()
    local isEmpty = #data <= 0
    self:setObjectVisible("empty_node", isEmpty)
    self:setObjectVisible("loopscroll", not isEmpty)
    if isEmpty then
        return
    end
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            loop_scroll_object = loopscroll,
            pos_center = true,
            update_cell = function(index, cell_object, cell_data)
                self:updateScrollViewCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "create_btn" then
                    self:updateMsg("create_btn", cell_data.gift_id)
                end
            end
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data, true)
    end
end

-- 更新
function M:updateScrollViewCell(index, cell_object, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    local data = cell_data.gift_cfg
    local reward_node = luaBehaviour:FindRectTransform("reward_node")
    local time_limit = data.time_limit
    local return_num = data.phase[#data.phase].rtn

    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "group_text", "gift_group_text_0028")
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "create_btn_text", "gift_group_text_0023")
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "top_text", "gift_group_text_0022")
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "money_text", "gift_group_text_0025", data.price)
    LuaBehaviourUtil.setText(luaBehaviour, "num_text", return_num)
    --实际只能为1次
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "time_text", "gift_group_text_0024", time_limit, time_limit)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "gain_text", "gift_group_text_0021")
    GameUtil:createRewards(reward_node, data.reward, true, true, nil, 1)


end

function M:destroy()
    M.super.destroy(self)
end
return M