local guide = class("MeridianList", LikeOO.OOGuideBase)

function guide:excuteGuideFunc1(info)
    local cell =  self.m_view.m_loop_scroll_view.m_cache_cells[1]
    if IsNull(cell) then
        return
    end
    local LuaBehaviour = UIUtil.findLuaBehaviour(cell)
    local node = LuaBehaviour:FindGameObject("check_btn")
    if node then
        self.m_control.slid_lock = true
        self.m_listener = {
            key = "wear_equip",
            key2 = "replace_equip",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end


return guide
