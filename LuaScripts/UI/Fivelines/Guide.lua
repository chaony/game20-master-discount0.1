local guide = class("Fivelines", LikeOO.OOGuideBase)

-- 点击人
function guide:excuteGuideFunc1(info)
    local target = info.target[1]
    local ply = SceneManager:getCurSceneModel():getRoleDataByIndex(target or 1)
    if ply then
        local node = ply.view
        if node then
            self.m_listener = {
                key = "battle_start_openDetail",
            }

            local worldPos = node.obj.transform.position
            local position = SceneManager.curScene.wxCameraController.Camera_3D:WorldToScreenPoint(worldPos);
            -- position.z = 0
            position = static_ui_camera:ScreenToWorldPoint(position)
            position.y = position.y + 4
            self:guideTargetNode(node.obj.transform, 1, 1, nil, nil, nil, nil, position)
        end
    end
end

-- 点击印记
function guide:excuteGuideFunc2(info)
    local node = self.m_view:findGameObject("left_bottom")
    if node then
        self.m_listener = {

        }
        self:guideTargetNode(node.transform, 1, 2)
    end
end

-- 点击挑战
function guide:excuteGuideFunc3(info)
    local node = self.m_view:findGameObject("battle_btn")
    if node then
        self.m_listener = {
            key = "battle_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide
