local guide = class("Reward", LikeOO.OOGuideBase)

-- 点击第一个任务派遣
function guide:excuteGuideFunc1(info)
    if not self.m_view.m_loop_scroll_view then
        return
    end
    local cell = self.m_view.m_loop_scroll_view.m_cache_cells[1]
    if cell then
        local luaBehaviour = UIUtil.findLuaBehaviour(cell)
        local node = luaBehaviour:FindGameObject("opensend_btn")
        if node then
            self.m_listener = {
                key = "open_send",
            }
            self:guideTargetNode(node.transform, 1, 1)
        end
    end
end

-- 领取第一个任务派遣
function guide:excuteGuideFunc2(info)
    if not self.m_view.m_loop_scroll_view then
        return
    end
    local cell = self.m_view.m_loop_scroll_view.m_cache_cells[1]
    if cell then
        local luaBehaviour = UIUtil.findLuaBehaviour(cell)
        local node = luaBehaviour:FindGameObject("reward_btn")
        if node then
            self.m_listener = {
                key = "get_reward",
            }
            self:guideTargetNode(node.transform, 1, 1)
        end
    end
end

return guide
