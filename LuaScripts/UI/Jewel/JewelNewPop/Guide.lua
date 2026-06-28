local guide = class("JewelNewPop", LikeOO.OOGuideBase)

-- 升级后返回挂机界面
function guide:excuteGuideFunc1(info)
    self.m_listener = {
        key = "big_close_btn2",
    }
    local btn = self.m_view:findGameObject("big_close_btn2")
    if btn then 
        local function clickback()
            self.m_control:updateMsg("common_refresh",nil,"parent")
            self.m_control:updateMsg("check_guide",{force_flag = true},"parent")
        end
        self:guideTargetNode(btn.transform, 3, 3, nil,nil,nil,nil,nil,nil,clickback)
    end
end

return guide
