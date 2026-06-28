local guide = class("Advanced", LikeOO.OOGuideBase)

-- 点击英雄
function guide:excuteGuideFunc1(info)
    if self.m_model.m_params.oid then
        UserDataManager.guide_data:skipCurGuide()
        return
    end
    local target = info.target[1]
    local list_data = self.m_model.m_list_data
    local main_team = table.copy(UserDataManager.hero_data:getTeamByKey("stage"))
    local team_hero_oid = nil
    self.list_index = nil
    self.m_guide_hero = nil
    for i,v in ipairs(main_team) do
        local heroData, cfg = UserDataManager.hero_data:getHeroDataById(v)
        if cfg and cfg.id == target then
            team_hero_oid = v
        end
    end
    for i,v in ipairs(list_data) do
        if team_hero_oid then
            if v == team_hero_oid then
                self.list_index = i
                self.m_view:updateHerosScroll()
                self.m_view.m_list_scroll:moveToCellIndex(i)
            end
        else
            local heroData, cfg = UserDataManager.hero_data:getHeroDataById(v)
            if cfg.id == target then
                if self.m_model:isSelectedByIndex(v) == false then
                    self.list_index = i
                    self.m_view:updateHerosScroll()
                    self.m_view.m_list_scroll:moveToCellIndex(i)
                    break
                end
            end
        end
    end

    if self.m_guide_hero then
        local heros_scroll = self.m_view:findGameObject("heros_scroll")
        heros_scroll:GetComponent("ScrollRect").vertical = false
        local luaBehaviour = UIUtil.findLuaBehaviour(self.m_guide_hero)
        local node = luaBehaviour:FindGameObject("hero_bg")
        if node then
            self.m_listener = {
                key = "select_hero",
            }   
            self:guideTargetNode(node.transform, 1, 1)
        end
    end
end

-- 展示材料区域
function guide:excuteGuideFunc2(info)
    if self.m_model.m_params.oid then
        UserDataManager.guide_data:skipCurGuide()
        return
    end
    local target = info.target[1]
    local list_data = self.m_model.m_list_data
    self.list_index = nil
    self.m_guide_hero = nil

    for i,v in ipairs(list_data) do
        local heroData, cfg = UserDataManager.hero_data:getHeroDataById(v)
        if cfg.id == target then
            if self.m_model:isSelectedByIndex(v) == false then
                self.list_index = i
                self.m_view:updateHerosScroll()
                self.m_view.m_list_scroll:moveToCellIndex(i)
                break
            end
        end
    end

    if self.m_guide_hero then
        local luaBehaviour = UIUtil.findLuaBehaviour(self.m_guide_hero)
        local node = luaBehaviour:FindGameObject("hero_bg")
        if node then
            self.m_listener = {
                key = "select_hero",
            }
            self:guideTargetNode(node.transform, 1, 1)
        end
    end
end

-- 展示进阶按钮
function guide:excuteGuideFunc3(info)
    if self.m_model.m_params.oid then
        UserDataManager.guide_data:skipCurGuide()
        return
    end
    local heros_scroll = self.m_view:findGameObject("heros_scroll")
    heros_scroll:GetComponent("ScrollRect").vertical = true
    local node = self.m_view:findGameObject("advanced_btn")
    if node then
        self.m_listener = {
            key = "advanced_btn",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 一键进阶
function guide:excuteGuideFunc4(info)
    if self.m_model.m_params.oid then
        UserDataManager.guide_data:skipCurGuide()
        return
    end
    if self.m_model.m_evo_num > 0 or self.m_model.m_adv_num > 0 then
        local node = self.m_view:findGameObject("one_key_btn")
        if node then
            self.m_listener = {
                key = "one_key_btn",
            }
            self:guideTargetNode(node.transform, 1, 1)
        end
        return
    end
    UserDataManager.guide_data:skipCurGuide()
end

return guide