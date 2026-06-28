local guide = class("Hotel", LikeOO.OOGuideBase)

-- 点击开始经营
function guide:excuteGuideFunc1(info)
    local node = self.m_view:findGameObject("hall_btn")
    if node then
        self.m_listener = {
            key = "hall_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    else
        self:doNextGuide()
    end
end

--点击酒楼人物 room_id = 1,2,3
function guide:excuteGuideFunc2(info)
    local room_id = info.target[1]
    local node = self.m_view:findGameObject("room_btn_" .. room_id)
    if node then
        self.m_listener = {
            key = "room_btn_" .. room_id,
        }
        self:guideTargetNode(node.transform, 1, 1)
    else
        self:doNextGuide()
    end
end

--点击酒楼人物选项 choice_index = 1,2,3,4
function guide:excuteGuideFunc3(info)
    local choice_index = info.target[1]
    local node = self.m_view:findGameObject("game" .. choice_index .. "_btn")
    if node then
        self.m_listener = {
            key = "game" .. choice_index .. "_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    else
        self:doNextGuide()
    end
end

return guide