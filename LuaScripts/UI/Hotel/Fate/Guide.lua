local guide = class("Fate", LikeOO.OOGuideBase)

-- 点击聆听故事
function guide:excuteGuideFunc1(info)
    local target = info.target[1]
    local node = nil
    self.m_view:lockTouch()
    local function endCallBack()
        self.m_view:unlockTouch()
        for i,v in ipairs(self.m_view.m_list_scroll.m_show_data or {}) do
            if v.hero_id == target then
                local cell_node = self.m_view.m_list_scroll.m_cache_cells[i]
                if cell_node then
                    local luaBehaviour = UIUtil.findLuaBehaviour(cell_node)
                    node = LuaBehaviourUtil.findGameObject(luaBehaviour, "story_btn")
                    break
                end
            end
        end
        if node then
            self.m_listener = {
                key = "story_btn",
            }
            self:guideTargetNode(node.transform, 1, 1)
        end
    end
    self.m_control:setOnceTimer(0.28, endCallBack)
end

return guide