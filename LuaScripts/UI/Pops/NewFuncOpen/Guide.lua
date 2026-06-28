local guide = class("NewFuncOpen", LikeOO.OOGuideBase)

-- 点击关闭
function guide:excuteGuideFunc1(info)
    local func_id = info.target[1]
    if func_id ~= self.m_model.m_function_id then
        return
    end
    local node = self.m_view:findGameObject("ok_btn")
    if node then
        self.m_listener = {
            --key = 99999,
            key = "ok_btn",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    else
    	self:doNextGuide()
    end
end

return guide