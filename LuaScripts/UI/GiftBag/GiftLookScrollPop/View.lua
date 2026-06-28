local M = class("GiftLookScrollPopView", LikeOO.OOPopBase)

M.m_uiName = "GiftBag/GiftLookScrollPop"
M.m_size_type = 2

function M:onEnter()
    self:setTextByLanKey("common_title_text", "奖励预览")
	self:refreshUI()
end

function M:refreshUI()
    self:createLoopScroll()
    if self.m_scroll_view ~= nil then
        self.m_scroll_view:moveToCellIndex(1)
    end
end

--[[
    创建礼包列表
]]
function M:createLoopScroll()
    self.m_gift_tab = {}
    local data = self.m_model:getBigReward()
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            one_line_count = 6, 
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self.m_gift_tab[index] = cell_obj
                self:updateTimItem(index, cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "ItemNode" then
                    
                end
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data)
    end
end

function M:updateTimItem(index, obj, cell_data)
    local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
    local cell_text = UIUtil.findText(obj.transform, "cell_text")
    local big_reward = self.m_model:getRewardById(cell_data.reward_id)
    local data = big_reward.reward[1]
    if LuaBehaviour then
        GameUtil:updateItemElement(obj, data, true, true)
        cell_text.text = cell_data.reward_num.."/"..cell_data.reward_num
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M