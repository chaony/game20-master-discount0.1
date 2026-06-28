local guide = class("Outskirts", LikeOO.OOGuideBase)

-- 点击功能建筑
function guide:excuteGuideFunc1(info)
    local target = info.target[1]
    local build_tab = self.m_view.m_btn_lock_img
    local build_cfg = build_tab[target]
    --local jianzhu = U3DUtil:GameObject_Find("jianzhu")
    --local trans = jianzhu.transform:Find(build_cfg.bnt_key)
    local node = self.m_view:findGameObject(build_cfg.btn_key)
    if node then
        self.m_listener = {
            key = build_cfg.btn_key,
        }

        --local worldPos = trans.position
        --local Camera3D = U3DUtil:GameObject_Find("Camera3D"):GetComponent("Camera")
        --local position = Camera3D:WorldToScreenPoint(worldPos);
        -- --position.z = 0
        --position = static_ui_camera:ScreenToWorldPoint(position)
        --self:guideTargetNode(trans, 1, 1, nil, nil, nil, nil, position)
        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide
