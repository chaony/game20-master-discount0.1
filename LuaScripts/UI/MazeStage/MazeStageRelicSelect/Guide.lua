local guide = class("MazeStageRelicSelect", LikeOO.OOGuideBase)

-- 点击遗物
function guide:excuteGuideFunc1(info)
    local target = info.target[1]
    local cell_object = self.m_view.m_guide_nodes[target]
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    local node = luaBehaviour:FindGameObject("cell_bg")
    if node then
        self.m_listener = {
            key = "cell_bg",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 点击选择按钮
function guide:excuteGuideFunc2(info)
    local cell_object = self.m_view.m_select_cell
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    local node = luaBehaviour:FindGameObject("select_btn")
    if node then
        self.m_listener = {
            key = "select_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide
