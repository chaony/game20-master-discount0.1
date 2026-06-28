local guide = class("WorldMapTaskReward", LikeOO.OOGuideBase)

-- 点击建筑
function guide:excuteGuideFunc1(info)
    if self.m_model.m_sel_tab_index == 2 then
        if self.m_view.m_cur_tab_node.m_map_obj_tab then
            local target = info.target[1]
            local map_obj = self.m_view.m_cur_tab_node.m_map_obj_tab[target]
            if map_obj then
                local luaBehaviour = UIUtil.findLuaBehaviour(map_obj)
                local node = luaBehaviour:FindGameObject("map_btn")
                if node then
                    if node then
                        self.m_listener = {
                            key = "map_btn",
                        }
                        self:guideTargetNode(node.transform, 1, 1)
                    end
                end
            end
        end
    end
end

return guide
