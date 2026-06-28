local guide = class("ArenaSelectMain", LikeOO.OOGuideBase)

-- 普通竞技
function guide:excuteGuideFunc1(info)
    local node = self.m_view:findGameObject("normal_btn")
    if node then
        self.m_listener = {
            key = "normal_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 高阶竞技
function guide:excuteGuideFunc2(info)
    local node = self.m_view:findGameObject("high_btn")
    if node then
        self.m_listener = {
            key = "high_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 种族竞技
function guide:excuteGuideFunc3(info)
    local server_data = self.m_model:getAreaData("race_arena") or {}
    local race_open_flag, _ = BtnOpenUtil:isBtnOpen(141)
    local season = server_data.season or 1
    if race_open_flag and season > 0  then
        if server_data.races ~= nil and _G.next(server_data.races) ~= nil then
            local node = self.m_view:findGameObject("race_btn")
            if node then
                self.m_listener = {
                    key = "race_btn",
                }
                self:guideTargetNode(node.transform, 1, 1)
            end
        end
    end
end

return guide
