local guide = class("JuBaoShanHeroSelectPop", LikeOO.OOGuideBase)

-- 点击派遣英雄
function guide:excuteGuideFunc1(info)
    local race = info.target[1]
    local index = nil
    local heros = self.m_model:getHeros()
    for i,v in ipairs(heros) do
        local hero_data, hero_cfg = self.m_model:getHero(v)
        if hero_cfg.race == race then
            index = i
        end
    end
    if index then
        self.m_view.m_loop_scroll_view:moveToCellIndex(index)
        local node = self.m_view.m_loop_scroll_view.m_cache_cells[index]
        if node then
            self.m_listener = {
                key = "select_hero",
            }
            self:guideTargetNode(node.transform, 1, 1)
        end
    end
end

-- 派遣
function guide:excuteGuideFunc2(info)
    local node = self.m_view:findGameObject("send_btn")
    if node then
        self.m_listener = {
            key = "send_btn",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 一键
function guide:excuteGuideFunc3(info)
    local node = self.m_view:findGameObject("one_keydispatch")
    if node then
        self.m_listener = {
            key = "one_keydispatch",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide
