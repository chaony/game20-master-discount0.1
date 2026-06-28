local guide = class("BudoSelectPop", LikeOO.OOGuideBase)

function guide:excuteGuideFunc1(info)
    local node = nil
    local key = ""
    for i = 1, 4 do
        local open_bl = self.m_model:checkIsOpen(i)
        if open_bl then
            node = self.m_view:findGameObject( "item_img_"..i)
            key = "item_node_" .. i
            break
        end
    end
    if node then
        self.m_listener = {
            key = key,
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide
