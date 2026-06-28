local M = class("LakesLoveControl", LikeOO.OOControlBase)

function M:onEnter()
    --self.m_timer_id = self:setTimer(1, handler(self, self.UpdateTime))
end

function M:onHandle(msg, data)
    if msg == 99999 or msg == "close_new_btn" then -- 关闭
        --if self.m_model.m_callback then
        --    self.m_model.m_callback(self.m_model.m_callback_new)
        --end
        --self:updateMsg("common_refresh", nil, "parent")
        --self:updateMsg("refresh_red_point",nil,"parent")
        self:closeView()
    elseif msg == "help_btn" then
        local params = {title = "lakes_love_text_006", content = self.m_model.m_help_content}
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "select_hero" then
        self.m_model.m_select_hero_id = data
        self.m_view:refreshHero(self.m_model.m_select_hero_id)
    elseif msg == "confirm_btn" then
        local params = {
            text = Language:getTextByKey("lakes_love_text_005"),
            tow_close_btn = true,
            on_ok_call = function ()
                local params = {hero_id = self.m_model.m_select_hero_id}
                self.m_model:getNetData("lakes_love_decide_hero", params, function(response)
                    if response then
                        self.m_model.m_hero_id = response.hero_id
                        self.m_model.m_conds = response.conds
                        self.m_view:confirmHero()
                    end
                end, nil, nil, nil)
            end
        }
        self:openView("Pops.CommonPop", params)
    elseif msg == "goto_btn1" then
        self:openGoto(1)
    elseif msg == "goto_btn2" then
        self:openGoto(2)
    elseif msg == "goto_btn3" then
        self:openGoto(3)
    elseif msg == "goto_btn4" then
        self:openGoto(4)
    elseif msg == "unlock_btn1" then
        self:requestUnlock(1)
    elseif msg == "unlock_btn2" then
        self:requestUnlock(2)
    elseif msg == "unlock_btn3" then
        self:requestUnlock(3)
    elseif msg == "unlock_btn4" then
        self:requestUnlock(4)
    elseif msg == "skill1_img" then
        local sk_obj = self.m_view:findGameObject(msg)
        self:openSkillPop(1, sk_obj)
    elseif msg == "skill2_img" then
        local sk_obj = self.m_view:findGameObject(msg)
        self:openSkillPop(2, sk_obj)
    elseif msg == "skill3_img" then
        local sk_obj = self.m_view:findGameObject(msg)
        self:openSkillPop(3, sk_obj)
    elseif msg == "skill4_img" then
        local sk_obj = self.m_view:findGameObject(msg)
        self:openSkillPop(4, sk_obj)
    end
end

function M:openGoto(index)
    local k, cond = self.m_model:getCond(index)
    local go_type = cond.go_type
    QuickOpenFuncUtil:openFunc(go_type)
    self:closeView() --关闭界面
end

function M:requestUnlock(index)
    local k, cond = self.m_model:getCond(index)
    local params = {cond_id = k}
    self.m_model:getNetData("lakes_love_unlock", params, function(response)
        if response then
            self.m_view:refreshCond(response.cond_id)
            if response.reward ~= nil then
                self:setOnceTimer(1.0, function ()
                    local reward = RewardUtil:mergeRewardAndFormat(response.reward)
                    RewardUtil:rewardTipsByRewards(reward)
                    self:closeView()
                end)
            end
        end
    end, nil, nil, nil)
end

function M:openSkillPop(index, click_obj)
    local skills, hero_lv = self.m_model:getHeroSkill()
    self:openView("Pops.SkillPop",{skill = skills[index], pivot = Vector2(0,1), index = index, cur_lv = hero_lv , click_transform = click_obj.transform})
end

function M:destroy()
    M.super.destroy(self)
end

return M