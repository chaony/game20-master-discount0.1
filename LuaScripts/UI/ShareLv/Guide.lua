local guide = class("ShareLv", LikeOO.OOGuideBase)

-- 点击单抽
function guide:excuteGuideFunc1(info)
    local data = self.m_model:getSoltDataByIndex(1)
    if data.hid and data.hid ~= "" then
        self:doNextGuide()
        return
    end
    local down_time = data.etime - UserDataManager:getServerTime()
    if down_time > 0 then
        self:doNextGuide()
        return
    end

    local luaBehaviour = UIUtil.findLuaBehaviour(self.m_view.m_guide_cell)
    local node = luaBehaviour:FindGameObject("add_btn")
    if node then
        self.m_listener = {
            key = "add_hero",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide
