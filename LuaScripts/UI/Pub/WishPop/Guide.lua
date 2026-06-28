local guide = class("WishPop", LikeOO.OOGuideBase)

-- 点击栏位
function guide:excuteGuideFunc1(info)
    local cell = self.m_view.m_list_scroll.m_cache_cells[1]
    local luaBehaviour = UIUtil.findLuaBehaviour(cell.transform)
    local node = luaBehaviour:FindGameObject("card_panel_5")
    if node then
        self.m_listener = {
            key = "show_cards",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 点击英雄
function guide:excuteGuideFunc2(info)
    local target = info.target[1]
    local index = nil
    for i,v in ipairs(self.m_view.m_cards_scroll.m_show_data or {}) do
        if v.id == target then
            index = i
            break
        end
    end
    if index then
        local cell = self.m_view.m_cards_scroll.m_cache_cells[index]
        local luaBehaviour = UIUtil.findLuaBehaviour(cell.transform)
        local node = luaBehaviour:FindGameObject("head_btn")
        if node then
            self.m_listener = {
                key = "click_card",
            }
            self:guideTargetNode(node.transform, 1, 1)
        end
    end
end

return guide
