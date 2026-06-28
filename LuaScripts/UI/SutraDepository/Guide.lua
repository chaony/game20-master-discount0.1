local guide = class("SutraDepository", LikeOO.OOGuideBase)

-- 点击可合成秘籍
function guide:excuteGuideFunc1(info)
    local data = self.m_view.m_list_scroll.m_show_data
    local node = nil
    for i,v in ipairs(data or {}) do
        if v.sort_value == 7 then
            local cell = self.m_view.m_list_scroll.m_cache_cells[i]
            local LuaBehaviour = UIUtil.findLuaBehaviour(cell)
            node = LuaBehaviour:FindGameObject("quality_img")
            break
        end
    end
    if node then
        self.m_listener = {
            key = "select_mystic",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 点击合成
function guide:excuteGuideFunc2(info)
    local node = self.m_view:findGameObject("synthetic_btn")
    if node then
        self.m_listener = {
            key = "synthetic_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 点击可升星秘籍
function guide:excuteGuideFunc3(info)
    local data = self.m_view.m_list_scroll.m_show_data
    local node = nil
    for i,v in ipairs(data or {}) do
        if v.sort_value == 6 then
            local cell = self.m_view.m_list_scroll.m_cache_cells[i]
            local LuaBehaviour = UIUtil.findLuaBehaviour(cell)
            node = LuaBehaviour:FindGameObject("quality_img")
            break
        end
    end
    if node then
        self.m_listener = {
            key = "select_mystic",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 点击升星
function guide:excuteGuideFunc4(info)
    local node = self.m_view:findGameObject("promote_btn")
    if node then
        self.m_listener = {
            key = "promote_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide
