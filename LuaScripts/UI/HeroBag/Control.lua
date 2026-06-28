---@class HeroBagControl:OOControlBase
---@field m_model HeroBagModel
---@field m_view HeroBagView
local M = class("HeroBagControl", LikeOO.OOControlBase)

function M:onEnter()
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.CLOSE_VIEW, {self, self.closeViewEvent})
    self.long_click_interval = true
    self.m_guide_file_name = "UI.HeroBag.Guide"
    if self.m_model:getCurHeroBank() then
        ResourceUtil:LoadRoleSound(self.m_model:getCurHeroBank())
    end
    SceneManager:getCurSceneModel():setCameraShow(false)
    self.interval_tim = false
    self:playTalk() -- 先来一句
    self.jishi = self:setTimer(1, handler(self, self.updateTime))
    --EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.refreshCombatRepress})
end

function M:startGuide()
    M.super.startGuide(self)
    self:triggerGuide()
end

function M:closeViewEvent(event, data)
    local view_name = data.name or ""
    if view_name == "HeroBag.FriendLikeLevelInfo" then
        self.m_model:setIsPlayOverFriendLevelUpEft(true)
    end
end

function M:onHandle(msg, data)
    if msg ~= "click_up" and  msg ~= "pass_on" and msg ~= "levet_up_btn" and self.m_model.m_level_up > 0 then
        --当弹出快速升级按钮时点击任意其他按钮、 关闭快速升级按钮
        self.m_model.m_level_up = 0
        self.m_model.m_show_quick_level_up = 0
        self:setShowQuickLevelUp(0)
    end
    if msg == 99999 then -- 返回
        if self.m_model.m_type == 2 and self.m_model.m_mode == 1 then
            self:sendLvUpNet(function ()
                self.m_view:switchType(1)
                self:switchTabBtn(1)
                self.m_view:changeTab(1)
                self.m_model:updateRefreshHeroListType(false)
            end)
            return
        end
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = -1})
    elseif type(msg) == "number" and msg >= 1 and msg <= 8 then
        -- 1属性、2经脉、3逸闻
        self:sendLvUpNet(function ()
            self:switchTabBtn(msg)
        end)
    elseif msg == "tab_btn" then --英雄类型
        self.m_model:switchHeroList(data)
        self.m_model:detectionAttrs()
        self.m_model:detectionEqps()
        self.m_view:updateHerosScroll()
        self.m_view:refreshUI()
        self.m_view:refreshRedPoint()
        self.m_view:sliderTop()
        self:SortDataList(self.m_model.sort_type)
    elseif msg == "select_hero" then
        if self.m_model.m_selected_id == data.id then
            return
        end
        if data.index ~= nil then
            if self.m_model.m_select_index > data.index then
                data.dir = 2
            else
                data.dir = 1
            end
            self.m_model.m_select_index = data.index
        end
        if self.m_model.m_hero_list_type == 1 then
            self.m_model.m_selected_id = data.id
        else
            self.m_model.m_select_book_id = data.id
        end
        if self.m_model:getCurHeroBank() then
            ResourceUtil:LoadRoleSound(self.m_model:getCurHeroBank())
        end
        self.interval_tim = false
        if self.tim then
            self:removeTimer(self.tim)
        end
        if data.dir == nil then
            data.dir = 1
        end
        self.m_model:resetMeridianFirstOpenIndex()
        self:playTalk() -- 先来一句
        self.m_model:updateHeroInfo()
        self:switchTabBtn(self.m_model.m_sel_tab_index)
        self.m_view:changeTab(self.m_model.m_sel_tab_index)
        self.m_model:detectionAttrs()
        self.m_model:detectionEqps()
        self.m_view:updateSelectHero()
        self.m_view:refreshUI(data, {center=1, right=1})
        self.m_view:refreshFettersItem()
        self.m_view:enterHideSkillRedPoint() --切换英雄隐藏红点
        self.m_view:setHeroBagBg() --设置背景
        if self.m_model.m_sel_tab_index == 4 then
            self:getNetFetterPop()
        end
        audio:SendEvtUI('Ui_NormalClick')
        self:setShowQuickLevelUp(0)
    elseif msg == "put_on_btn" then
        if self.m_model.isNil == true then
            return
        end
        self:putOn()
        self.m_model:updateRefreshHeroListType(true)
    elseif msg == "get_out_btn" then
        if self.m_model.isNil == true then
            return
        end
        self:getUp()
        self.m_model:updateRefreshHeroListType(true)
    elseif msg == "eq1_btn" then
        self:checkEqp(1)
    elseif msg == "eq2_btn" then
        self:checkEqp(2)
    elseif msg == "eq3_btn" then
        self:checkEqp(3)
    elseif msg == "eq4_btn" then
        self:checkEqp(4)
    elseif msg == "eq5_btn" then
        self:checkEqp(5)
    elseif msg == "eq6_btn" then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0055"), delay_close = 2})
    elseif msg == "mystic_eq_btn_1" then
        self:checkMaiEqp(1)
    elseif msg == "mystic_eq_btn_2" then
        self:checkMaiEqp(2)
    elseif msg == "mystic_eq_btn_3" then
        self:checkMaiEqp(3)
    elseif msg == "mystic_eq_btn_4" then
        self:checkMaiEqp(4)
    elseif msg == "mystic_eq_btn_5" then
        self:checkMaiEqp(5)
    elseif msg == "mai_img_1" then
        self.m_view:switchMeridianByIndex(1)
    elseif msg == "mai_img_2" then
        self.m_view:switchMeridianByIndex(2)
    elseif msg == "mai_img_3" then
        self.m_view:switchMeridianByIndex(3)
    elseif msg == "mai_img_4" then
        self.m_view:switchMeridianByIndex(4)
    elseif msg == "update_equip" then --穿脱装备、属性修改、装备升级的刷新回调
        self.m_model:updateResourceData()
        self.m_view:refreshUI()
        self.m_view:refreshRedPoint()
    elseif msg == "update_mystic" then --穿脱秘籍回调
        self.m_model:updateResourceData()
        self.m_view:refreshUI(data)
        self.m_view:refreshRedPoint()
    elseif msg == "cultivate_btn" then
        if self.m_model.isNil == true then
            return
        end
        self.m_view:switchType(2)
    elseif msg == "details_btn" then
        self.m_view:switchType(2)
    elseif msg == "skill1_img" then
        local skills = self.m_model:getHeroSkill()
        local hero_lv = self.m_model:getHero_lv()
        local click_obj = self.m_view:getSkillIcon(msg)
        local cur_skill = self.m_model:getCurSKill()
        local hero_id =self.m_model:getHeroid()
        local ordinary_skill = table.nums(cur_skill) > 0 and 3 or 0
        --四级是否解锁
        local lv4Unlock=self.m_model:checkSkillLv4Unlock(1)
        self:openView("Pops.SkillPop", {hero_id = hero_id,
                                        ordinary_skill = ordinary_skill,skill = skills[1],
                                        index = 1, cur_lv = hero_lv,
                                        click_transform = click_obj.transform,
                                        pivot = Vector2(0.5,0),
                                        lv4Unlock=lv4Unlock})
        self.m_view:updateSkillRedPoint(1, false)
        self:playTalk()
    elseif msg == "skill2_img" then
        local skills = self.m_model:getHeroSkill()
        local hero_lv = self.m_model:getHero_lv()
        local click_obj = self.m_view:getSkillIcon(msg)
        local cur_skill = self.m_model:getCurSKill()
        local hero_id =self.m_model:getHeroid()
        local ordinary_skill = table.nums(cur_skill) > 0 and 3 or 0
        --四级是否解锁
        local lv4Unlock=self.m_model:checkSkillLv4Unlock(2)
        self:openView("Pops.SkillPop", {hero_id = hero_id,ordinary_skill = ordinary_skill,skill = skills[2], index = 2, cur_lv = hero_lv, click_transform = click_obj.transform,pivot = Vector2(0.5,0),lv4Unlock=lv4Unlock})
        self.m_view:updateSkillRedPoint(2, false)
        self:playTalk()
    elseif msg == "skill3_img" then
        local skills = self.m_model:getHeroSkill()
        local hero_lv = self.m_model:getHero_lv()
        local click_obj = self.m_view:getSkillIcon(msg)
        local cur_skill = self.m_model:getCurSKill()
        local hero_id =self.m_model:getHeroid()
        local ordinary_skill = table.nums(cur_skill) > 0 and 3 or 0
        --四级是否解锁
        local lv4Unlock=self.m_model:checkSkillLv4Unlock(3)
        self:openView("Pops.SkillPop", {hero_id = hero_id,ordinary_skill = ordinary_skill,skill = skills[3], index = 3, cur_lv = hero_lv, click_transform = click_obj.transform,pivot = Vector2(0.5,0),lv4Unlock=lv4Unlock})
        self.m_view:updateSkillRedPoint(3, false)
        self:playTalk()
    elseif msg == "skill4_img" then
        local skills = self.m_model:getHeroSkill()
        local hero_lv = self.m_model:getHero_lv()
        local click_obj = self.m_view:getSkillIcon(msg)
        local cur_skill = self.m_model:getCurSKill()
        local hero_id =self.m_model:getHeroid()
        local ordinary_skill = table.nums(cur_skill) > 0 and 3 or 0
        --四级是否解锁
        local lv4Unlock=self.m_model:checkSkillLv4Unlock(4)
        self:openView("Pops.SkillPop", {hero_id = hero_id,ordinary_skill = ordinary_skill,skill = skills[4], index = 4, cur_lv = hero_lv, click_transform = click_obj.transform,pivot = Vector2(0.5,0),lv4Unlock=lv4Unlock})
        self.m_view:updateSkillRedPoint(4, false)
        self:playTalk()
    elseif msg == "pre_break_skill_img" then
        self:openskillPop(msg,false)
    elseif msg == "next_break_skill_img" then
        self:openskillPop(msg,true)
    elseif msg == "click_up" then -- 升级按钮抬起/短按
        if self.m_model.m_level_up == 0 then
            local can_q, q_lv = self.m_model:checkCanQuickLevelUp()
            if can_q == true then
                self.m_model.m_level_up = q_lv
                self.m_model.m_show_quick_level_up = 3
                self:setShowQuickLevelUp(q_lv)
            else
                self:checkSkillLvUp()
            end
        else
            self.m_model.m_show_quick_level_up = 3
            self:checkSkillLvUp()
        end
    elseif msg == "pass_on" then --长按循环
        self.m_model.m_show_quick_level_up = 3
        local can_q, q_lv = self.m_model:checkCanQuickLevelUp()
        if self.m_model.m_level_up == 0 and can_q == true then
            self.m_model.m_level_up = q_lv
            self:setShowQuickLevelUp(q_lv)
            self:setOnceTimer(self.m_model.m_delay_time, function ()
                self:checkSkillLvUp()
            end)
        else
            self:checkSkillLvUp()
        end
    elseif msg == "quick_levet_up_btn" then
        local can_q, q_lv = self.m_model:checkCanQuickLevelUp()
        if can_q == true then
            self:sendQuickLvUpNet(q_lv, function ()
                self:setShowQuickLevelUp(0)
            end)
            self.m_model:updateRefreshHeroListType(true)
        end
    elseif msg == "reset_btn" then
        self:sendLvUpNet(function ()
            local open_flag, tips_str = BtnOpenUtil:isBtnOpen(11)
            if open_flag then
                local evo = self.m_model:getEvo()
                local tab_index = evo > 6 and 1 or 3
                self:openView("Coach", {oid = self.m_model.m_selected_id, tab_index = tab_index})
            else
                GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2})
            end
            self.m_model:updateRefreshHeroListType(true)
        end)
    elseif msg == "intensify_btn" or msg == "breach_btn" then  --冲击穴道
        self:intensifyExcWeap(0)
        self.m_model:updateRefreshHeroListType(true)
    elseif msg == "activate_one_btn" then  --一键冲击
        self:intensifyExcWeap(1)
        self.m_model:updateRefreshHeroListType(true)
    elseif msg == "help_btn" then  --帮助按钮
        self:openHelp()
    elseif msg == "activate_btn" then
        self:activateExcWeap()
        self.m_model:updateRefreshHeroListType(true)
    elseif msg == "reset_meridian_btn" then
        self:resetExcWeap()
        self.m_model:updateRefreshHeroListType(true)
    elseif msg == "check_btn" then
        local h_data, h_cfg = self.m_model:getSelectHeroData()
        if self.m_model.m_mode == 3 then
            local params = {
                heroid = self.m_model.m_selected_id,
                player_data = self.m_model.m_player_data,
                look_model = 1,
                hero_data = h_data,
                hero_cfg = h_cfg
            }
            self:openView("Pops.Pro_Pop", params)
        else
            self:openView("Pops.Pro_Pop", {heroid = self.m_model.m_selected_id, look_model = 0})
        end
    elseif msg == "meridian_check_btn" then
        local atr_1, atr_2 = self.m_model:getMeridianAttrs()
        local tab = {}
        for k,v in pairs(atr_1) do
            table.insert(tab, {v[1], v[2]})
        end
        if atr_2 and next(atr_2) then
            for k,v in pairs(atr_2) do
                table.insert(tab, {v[1], v[2]})
            end
        end
        self:openView("Pops.Pro_Pop", {attrs = tab} )
    elseif msg == "lock_img" then
        self:lockHero()
    elseif msg == "get_reward_btn" then
        self:getKillReward()
    elseif msg == "goto1_btn" or msg == "goto2_btn" or msg == "goto3_btn" or msg == "goto4_btn" or msg == "goto5_btn" then
        local bl_flag, tips_str = BtnOpenUtil:isBtnOpen(89)
        if bl_flag == true then
            self:openView("WorldMap.WorldMapMain")
        else
            GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2})
        end
    elseif msg == "skill1_btn" or msg == "skill2_btn" or msg == "skill3_btn" or msg == "skill4_btn" or msg == "skill5_btn" then
        if self.m_view.m_cur_tab_node ~= nil then
            msg = string.split(msg, "skill")[2]
            msg = string.split(msg, "_btn")[1]
            self.m_view.m_cur_tab_node.right.m_cur_tab_node:skillOnClick(tonumber(msg))
        end
    elseif msg == "base_info_btn" then
        if self.m_view.m_cur_tab_node ~= nil then
            self.m_view.m_cur_tab_node.right.m_cur_tab_node:showBaseInfo()
        end
    elseif msg == "anecdote1_btn" or msg == "anecdote2_btn" or msg == "anecdote3_btn" or msg == "anecdote4_btn" or msg == "anecdote5_btn" then
        if self.m_view.m_cur_tab_node ~= nil then
            msg = string.split(msg, "anecdote")[2]
            msg = string.split(msg, "_btn")[1]
            if self.m_view.m_cur_tab_node.right.m_cur_tab_node.anecdoteOnClick then
                self.m_view.m_cur_tab_node.right.m_cur_tab_node:anecdoteOnClick(tonumber(msg))
            end
        end
    elseif msg == "Sliding_right" then
        if self.m_model.m_sel_tab_index == 1 or self.m_model.m_sel_tab_index == 2 or self.m_model.m_sel_tab_index == 4 or self.m_model.m_sel_tab_index == 5 or self.m_model.m_sel_tab_index == 6 then
            self:sendLvUpNet(function ()
                local c_id,isSelect_hero = self.m_model:getLeftHero()
                if isSelect_hero ~= nil and isSelect_hero then
                    if self.m_model.m_sel_tab_index == 2 then
                        local open_flag = self.m_model:checkExclusiveByHeroId(c_id)
                        if not open_flag then
                            GameUtil:lookInfoTips(self, {msg = "new_str_0847", delay_close = 2})
                            return
                        end
                    end
                    self:updateMsg("select_hero", {id = c_id,dir = 2, index = self.m_model.m_select_index-1})
                end
            end)
        end
    elseif msg == "Sliding_left" then
        if self.m_model.m_sel_tab_index == 1 or self.m_model.m_sel_tab_index == 2 or self.m_model.m_sel_tab_index == 4 or self.m_model.m_sel_tab_index == 5 or self.m_model.m_sel_tab_index == 6 then
            self:sendLvUpNet(function ()
                local c_id,isSelect_hero = self.m_model:getRightHero()
                if isSelect_hero ~= nil and isSelect_hero then
                    if self.m_model.m_sel_tab_index == 2 then
                        local open_flag = self.m_model:checkExclusiveByHeroId(c_id)
                        if not open_flag then
                            GameUtil:lookInfoTips(self, {msg = "new_str_0847", delay_close = 2})
                            return
                        end
                    end
                    self:updateMsg("select_hero", {id = c_id,dir = 1, index = self.m_model.m_select_index+1})
                end
            end)
        end
    elseif msg == "skip_btn" then
        self:sendLvUpNet(
                function()
                    local hero_Data = self.m_model:getSelectHeroData()
                    if self.m_model:checkEvoMax() == true then
                        QuickOpenFuncUtil:openFunc(21)
                    elseif self.m_model:checkMaxEvo() == false then
                        QuickOpenFuncUtil:openFunc(7, {oid = self.m_model.m_selected_id})
                    end
                    self.m_model:updateRefreshHeroListType(true)
                end
        )
    elseif msg == "goto_destiny_star_btn" then  --天命化星
        local h_data, h_cfg = self.m_model:getSelectHeroData()
        self:openView("DestinyStar",{id = h_data.id})
    elseif msg == "level_up" then
    elseif msg == "common_refresh" then --从其他界面返回后检测（当前英雄是否被吃掉、等级变化等--）
        self.m_model:refreshCheck()
        self.m_model:updateHeroInfo()
        self.m_view:refreshUI()
        self.m_view:updateHerosScroll()
        self.m_view:refreshMaskStatus()
        self.m_view:enterHideSkillRedPoint() --英雄隐藏红点
    elseif msg == "check_guide" then
        self.m_guide:checkGuide()
    elseif msg == "recommend_btn" then
        if self.m_model.isNil == true then
            return
        end
        self:openView("HeroBag.HeroTeamRecommendPop")
    elseif msg == "supportSys_btn" then
        self:openView("HeroBag.AdditionSupportSystem")
    elseif msg == "evaluate_btn" then --侠客评价
        if self.m_model.isNil == true then
            return
        end
        local data, cfg = UserDataManager.hero_data:getHeroDataById(self.m_model.m_selected_id)
        self:openView("HeroBag.HeroEvaluate",{hero_id = data.id})
    elseif msg == "tj_btn" then --图鉴
        self:openView("HeroBook")
    elseif msg == "use_skin_btn" then
        self:useHeroSkin(data)
    elseif msg == "exchange_skin_btn" then
        self:exchangeHeroSkin(data)
    elseif msg == "btn_sort" then
        self.m_view.m_cur_tab_node["left"]:setObjectVisible("img_sort_select", true)
    elseif msg == "refresh_tj_redPoint" then
        self.m_view:refreshTJRedPoint()
    elseif msg == "btn_sort_close" then
        self.m_view.m_cur_tab_node["left"]:setObjectVisible("img_sort_select", false)
    elseif msg == "legend_btn" then --侠客传奇
        self:openView("HeroBag.HeroLegend",{hero_id = self.m_model.m_selected_id,hero_data = self.m_model:getCurHeroCfg()})
    elseif msg == "point_icon" then
        local cell_data = data.cell_data
        local click_object = data.click_object
        if click_object then
            GameUtil:lookInfoTips(self, {click_transform = click_object.transform, msg = self.m_model:getMeridianAttrTipsStr(cell_data, data.index), top = true})
        end
    elseif msg == "meridians_cultivation_btn" then
        GameUtil:lookInfoTips(self, {click_transform = data.transform, msg = self.m_model:getMeridiansCultivationAttrTipsStr(), top = true})
    elseif msg == "refreshSkinSpine" then
        self.m_view.m_cur_tab_node["center"].isOnce = true
        self.m_model:switchHeroSkin(data.skin_cfg)
        self.m_view.m_cur_tab_node["center"]:refreshUI()
    elseif msg == "click_skin_item" then
        self.m_view.m_cur_tab_node["center"].isOnce = true
        self.m_model:switchHeroSkin(data.cell_data.cfg)
        self.m_view.m_cur_tab_node["center"]:refreshUI()
        --self:updateMsg("refreshSkinSpine", data)
    elseif msg == "apostle_rm_btn" then
        local params =
        {
            on_ok_call = function(msg)
                self:giveBackApostles()
            end,
            no_close_btn = false,
            text = Language:getTextByKey("friend_str_0033")
        }
        self:openView("Pops.CommonPop", params)
    elseif msg == "exchange_skin_list_btn" then
        self:openView("Pops.SkinExchangePop")
    elseif msg == "race_1_mask" or  msg == "race_2_mask" or  msg == "race_3_mask"
            or msg == "race_6_mask" or msg == "race_5_mask" or msg == "race_4_mask" or msg == "race_7_mask" or msg == "sp_mask" then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("hero_ui_str_0029"), delay_close = 2})
    elseif msg == "btn_sendAllBtn" then
        --- 打开一键赠送界面
        local allGiftData, needExp, isCanLevelUp = self.m_model:getAllGiftData()
        if needExp <= -1 then
            self:sendGivingGiftsNet({isNormalBtn = false, datas = {}})
            return
        end
        if #allGiftData <= 0 then
            GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("tid#haogandutips_6"), delay_close = 2})
            return
        end
        local attrsData = self.m_model:getHeroAttrsData()
        if #attrsData <= 0 then
            return
        end
        local sendGiftData = {}
        for _, itemData in pairs(allGiftData) do
            table.insert(sendGiftData, {
                item_id = itemData.itemId,
                num = itemData.needCount
            })
        end
        local sendServerData, sendCallBack = self:trimGivingGiftsNet({isNormalBtn = false, datas = sendGiftData})
        local params = {
            allGiftData = allGiftData,
            attrsData = attrsData,
            friendInfoData = self.m_model:getFettersData(),
            sendCallBack = sendCallBack,
            isCanLevelUp = isCanLevelUp,
        }
        --self.m_model:setIsPlayOverFriendLevelUpEft(false)
        --self:openView("HeroBag.FriendLikeLevelInfo", params)
        self:sendAllFriendLike(sendServerData,sendCallBack) --隐藏一键赠送弹框
        -- -- 之前如果有一键赠送升级没播放完，需要直接弹出好感度结算面板
        -- if self.m_model.friendLevelUpData then
        --     local tempData = self.m_model.friendLevelUpData
        --     local last_combat = tempData.last_combat
        --     local cur_combat = self.m_model:getHero_Combat()
        --     self:openView("HeroBag.HeroFriendShipLvUpPop", {
        --         cur_combat = cur_combat,
        --         last_combat = last_combat,
        --         order_data = tempData.order_data,
        --         hero_id = tempData.hero_id,
        --         friendLevelUpParams = tempData.friendLevelUpParams})
        --     self.m_model:setFriendLevelUpData(nil)
        -- end
    elseif msg == "skill_img_star" then
        self:openView("Pops.SkillPop", {title_text = data.name,skill_text = data.des,ordinary_skill = 1,click_transform = data.click_transform.transform,pivot = Vector2(0.5,0)})
    elseif msg == "fenghua_record_btn" then
        self:openView("FengHuaRecord")
        -----------------------------------------符篆
    elseif msg == "togger_out_btn" then
        --根据赛季判断是否开启
        local activeData = ConfigManager:getCfgByName("open_condition") or {}
        local active_data_item = activeData[390]
        local cur_season = UserDataManager:getCurSeason() -- 获取赛季
        local cur_stage = UserDataManager:getCurStage()
        local condition_fail = false
        if active_data_item == nil then
            condition_fail = true
        else
            local unlock3 = active_data_item.unlock_condition_param3 or 0
            if cur_season < active_data_item.season_unlock and (unlock3 <= 0 or unlock3 > cur_stage) then --赛季未解锁，并且，超前开启条件未设置或者设置了但不满足
                condition_fail = true
            end
        end
        if condition_fail == true then
            return
        end
        
        self.m_model.is_open_type = self.m_model.is_open_type == 1 and 2 or 1
        self.m_view:updateCurrentView()
    elseif msg == "fuzhuan_btn_1" then
        self:checkTalins(1)
    elseif msg == "fuzhuan_btn_2" then
        self:checkTalins(2)
    elseif msg == "fuzhuan_btn_3" then
        self:checkTalins(3)
    elseif msg == "fuzhuan_btn_4" then
        self:checkTalins(4)
    elseif msg == "combat_suppress_btn" then
        self:sendLvUpNet(
                function()
                    local icon = self.m_model:getHeroBigAnim()
                    self:openView("CombatSuppressSystem.CombatRepressInfo",{hero_oid = self.m_model.m_selected_id,spine_name = icon})
                end
        )
    elseif msg == "goto_awaken_system_btn" then
        self:openView("AwakeSystem.AwakeSystemMain",nil)
    elseif msg == "replace_btn" then
        self:replaceSkill(data)
    elseif msg == "skill_detail" then
        self:skillDetail(data)
    elseif msg == "goto_echo_btn" then
        self:openView("HeroBag.HeroEcho",nil)
    end
end


function M:openskillPop(msg,is_lv4)
    local break_skill=self.m_model:getCurBreakSkill()
    local hero_lv = self.m_model:getHero_lv()
    local click_obj = self.m_view:getBreakSkillIcon(msg)
    local cur_skill = self.m_model:getCurSKill()
    local hero_id =self.m_model:getHeroid()
    local ordinary_skill = table.nums(cur_skill) > 0 and 3 or 0
    self:openView("Pops.SkillPop", {hero_id = hero_id,ordinary_skill = ordinary_skill,skill =break_skill, cur_lv = hero_lv, click_transform = click_obj.transform,pivot = Vector2(0.5,0),is_lv4=is_lv4})
end

--打开帮助面板
function M:openHelp()
    local open_flag = BtnOpenUtil:isBtnOpen(62)
    local show_text = "tid#Musclepulse_Tips_1"
    if open_flag then
        if self.m_model:meridianShowByID(5) == true then --筑基
            show_text = "tid#Musclepulse_Tips_4"
        elseif self.m_model:meridianShowByID(4) == true then   --化境
            show_text = "tid#Musclepulse_Tips_3"
        else
            show_text = "tid#Musclepulse_Tips_2"
        end
    end
    self:openView("Pops.CommonHelpPop", { title = "hero_ui_str_0006", content = show_text })
end

-- tab按钮切换
function M:switchTabBtn(index)
    if self.m_model.m_sel_tab_index ~= index then
        if index == 2 then
            if self.m_model:checkExclusive() == true then
                self.m_view:switchTabNode(index)
                --查看别人的英雄不触发引导
                if self.m_model.m_mode ~= 3 then
                    -- 秘籍装备引导
                    local id = ConfigManager:getCommonValueById(280)
                    local have_guide = UserDataManager.guide_data:setAnyTeamGuide(id)
                    if have_guide then
                        self.m_guide:checkGuide()
                    end
                end
            else
                local open_flag, tips_str = BtnOpenUtil:isBtnOpen(147)
                if not open_flag then
                    GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2})
                else 
                    open_flag, tips_str = BtnOpenUtil:isBtnOpen(148)
                    if not open_flag then
                        GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2})
                    else
                        local open_evo = ConfigManager:getMeridianOpenEvoByPos(1)
                        local quality_item = GlobalConfig.HERO_QUALITY_COMMON_SETTING[open_evo] or {}
                        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0749", Language:getTextByKey(quality_item.name)), delay_close = 2})
                    end
                end
                self.m_view:changeTab(self.m_model.m_sel_tab_index)
                return
            end  
        elseif index == 4 then
            if self.m_model:checkOpenFriendShip() == false or self.m_model:checkOpenFriend() == false then
                local evo_name = self.m_model:getOpenFriendFetterLv()
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("hero_ui_str_0036",evo_name) , delay_close = 2})
                self.m_view:changeTab(self.m_model.m_sel_tab_index) 
                return
            else
                self.m_view:switchTabNode(index)    
            end
        else     
            self.m_view:switchTabNode(index)
        end
        self.m_model.m_sel_tab_index = index
        self.m_view:updateEquipState(true)
        if index == 1 then
            self.m_model:detectionAttrs()
        end
    else
        if index == 4 then
            if self.m_model:checkOpenFriendShip() == false or self.m_model:checkOpenFriend() == false then
                self.m_view:changeTab(1) 
            end
        end
    end
    --self.m_view:setCombatRepressVisible()
end

function M:getNetFetterPop()
    if self.m_model:checkFetterCanRevd() == true then
        local function callfunc(data)
            self.m_view:refreshFetterRedPoint()
            self:openFetterPop(data)
        end
        local hero_cfg = self.m_model:getCurHeroCfg()
        self.m_model:getNetData("hero_friend", {hero_id = hero_cfg.id}, callfunc)
    else
        local id = ConfigManager:getCommonValueById(315)
        if UserDataManager.guide_data:setAnyTeamGuide(id) then
            self.m_guide:checkGuide()
        end
    end
end

function M:openFetterPop(data)
    if data ~= nil and data.reward ~= nil then
        if table.nums(data.rewards) > 0 then
            self.m_view:lockTouch()
            self:setOnceTimer(0.1,function()
                self.m_view:unlockTouch()
                self:openView("HeroBag.HeroFetterPop", {data = data, callback = handler(self, self.openFetterPop)},nil, true)
            end
            )
        else
            local id = ConfigManager:getCommonValueById(315)
            if UserDataManager.guide_data:setAnyTeamGuide(id) then
                self.m_guide:checkGuide()
            end
            self:updateMsg("common_refresh")--
        end
    end
end

--一键穿装
function M:putOn()
    local function callfunc(data)
        self.m_view:updateEquipState(true)
        self.m_view:refreshUI(nil,{center=1,right = 1})
        self.m_view:refreshRedPoint()
        audio:SendEvtUI("Ui_Equip_Up")
    end
    self.m_model:getNetData("hero_auto_equip_wear", {hero_oid = self.m_model.m_selected_id}, callfunc)
end

--一键脱下
function M:getUp()
    local function callfunc()
        self.m_view:updateEquipState(false)
        self.m_view:refreshUI(nil,{center=1,right = 1})
	    self.m_view:refreshRedPoint()
        audio:SendEvtUI("Ui_Equip_Down")
        if self.m_model.m_type == 1 then
            self.m_model:detectionAttrs()
        end
    end
    if self.m_model:checkHeroEquips() == false then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("equip_str_018"), delay_close = 2})
        return 
    end
    self.m_model:getNetData("hero_equip_down", {hero_oid = self.m_model.m_selected_id, auto = "1"}, callfunc)
end

--一使用英雄皮肤
function M:useHeroSkin(data)
    if self.m_model.m_type == 2 then
        self.m_model:detectionAttrs()
    end
    local function callfunc()
        self.m_view:refreshUI(nil,{center=1,right = 1})
        self.m_view:refreshRedPoint()
        self.m_view:updateHerosScroll()
        self.changeSkin = true
        if self.m_model.m_type == 2 then
            self.m_model:detectionAttrs()
        end
    end
    self.m_model:getNetData("hero_use_hero_skin", {hero_oid = self.m_model.m_selected_id, skin_id = data.skin_id}, callfunc)
end

--一使用英雄皮肤
function M:exchangeHeroSkin(data)
    local function callfunc(response)
        self.m_view:refreshUI(nil,{center=1,right = 1})
        self.m_view:refreshRedPoint()
        self.m_view:updateHerosScroll()
        RewardUtil:rewardTipsByData(response.reward)
    end
    self.m_model:getNetData("hero_exchange_hero_skin", {skin_id = data.skin_id}, callfunc)
end

function M:checkEqp(index)
    if self.m_model.isNil == true then
        return
    end
    local equip_data = self.m_model:checkEqpForId(index)
    local function levelUpCallBack()
        self.m_view:updateEquipState(true)
        if equip_data then --当前身上有装备
            if self.m_model.m_mode == 3 then
                local h_data, h_cfg = self.m_model:getSelectHeroData()
                local params = {
                    heroid = self.m_model.m_selected_id,
                    pos = index,
                    look_model = 1,
                    equip_data = equip_data,
                    c_hero = h_data
                }
                self:openView("HeroInfo.EquipmentPop", params) --查看装备
            else
                local params = {
                    heroid = self.m_model.m_selected_id,
                    pos = index,
                    look_model = 0
                }
                self:openView("HeroInfo.EquipmentPop", params) --查看装备
                self.m_model:updateRefreshHeroListType(true)
            end
        else
            if self.m_model.m_mode ~= 3 then
                local params = {
                    heroid = self.m_model.m_selected_id,
                    pos = index
                }
                self:openView("HeroInfo.EquipmentList", params) --穿戴装备
                self.m_model:updateRefreshHeroListType(true)
            end
        end
    end
    self:sendLvUpNet(levelUpCallBack)
end

function M:checkMaiEqp(index)
    local open_flag, tips_str = self.m_model:meridanPosOpenFlagByPos(index)
    if not open_flag then
        GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2})
        return
    end
    if self.m_model.isNil == true then
        return
    end
    local equip_mystic_data = self.m_model:checkMysticEqpForId(index)
    local function levelUpCallBack()
        self.m_view:updateEquipState(true)
        self.m_model:updateRefreshHeroListType(true)
        if equip_mystic_data then --当前身上有秘籍
            if self.m_model.m_mode == 3 then
                local h_data, h_cfg = self.m_model:getSelectHeroData()
                local params = {
                    heroid = self.m_model.m_selected_id,
                    pos = index,
                    look_model = 0,
                    oid = equip_mystic_data,
                    c_hero = h_data,
                    mystic=self.m_model:getMysticDataById(equip_mystic_data),
                    other = true --其他玩家的秘籍
                }
                self:openView("SutraDepository.DepositoryPop", params) --查看其他玩家秘籍
            else
                local params = {
                    heroid = self.m_model.m_selected_id,
                    pos = index,
                    look_model = 0,
                    oid = equip_mystic_data,
                }
                self:openView("SutraDepository.DepositoryPop", params) --查看秘籍
            end
        else
            if self.m_model.m_mode ~= 3 then
                local params = {
                    heroid = self.m_model.m_selected_id,
                    pos = index
                }
                self:openView("HeroInfo.MeridianList", params) --穿戴秘籍
            end
        end
    end
    self:sendLvUpNet(levelUpCallBack)
end

--查看神器
function M:openArtifact()
    if self.m_model.m_mode == 3 then --查看别人的英雄
        if self.m_model:checkHaveArtifact() == true then --当前身上有神器
            local data, cfg = self.m_model:getArtifactData()
            local params = {
                heroid = self.m_model.m_selected_id,
                look_model = 1,
                artid = data.id,
                art_data = data
            }
            self:openView("HeroInfo.ArtifactPop", params)
        end
    else
        local flag, tips = self.m_model:checkArtifact()
        if flag == false then
            local params = {
                text = tips
            }
            self:openView("Pops.CommonPop", params)
            return
        end
        if self.m_model:checkHaveArtifact() == true then --当前身上有神器
            local data, cfg = self.m_model:getArtifactData()
            local params = {
                heroid = self.m_model.m_selected_id,
                look_model = 0,
                artid = data.id
            }
            self:openView("HeroInfo.ArtifactPop", params)
        else
            self:openView("HeroInfo.ArtifactList", {heroid = self.m_model.m_selected_id})
        end
    end
end

--升级前先检查是否会有技能解锁
function M:checkSkillLvUp()
    if self:canLevelUpCheck() == false then
        return
    end
    local up_expend = GameUtil:getHeroUpGrade(self.m_model.m_cur_Lv) --本级升级消耗资源
    local can_lv = self.m_model:checkCanLvUp(self.m_model.m_cur_Lv) --本级升级消耗资源
    if can_lv == true then
        local params = {
            cur_lv = self.m_model.m_cur_Lv,
            heroid = self.m_model.m_selected_id,
            data_exp = self.m_model.data_exp.user_num,
            data_coin = self.m_model.data_coin.user_num,
            data_special = self.m_model.data_special.user_num,
            callback = function(newskill, bl)
                self:levelUp()
                if bl == true then
                    self.m_view:updateSkillRedPoint(newskill, true)
                end
                self:sendLvUpNet()
                self.m_view:creatCurEffect(newskill, bl)
            end,
            close_callback = function()
            end
        }
        self:sendLvUpNet()
        self:openView("Pops.SkillLvUpPop", params)
    else
        self:levelUp()
    end
end

--升级
function M:levelUp()
    local function callfunc()
        audio:SendEvtUI("PLAY_UI_LEVELUP")
        self.long_click_interval = true
        self.m_view:refreshLevelUpUI()
        self.m_view:refreshRedPoint()
        if self.m_model.m_level_up > 0 and self.m_model.m_cur_Lv >= self.m_model.m_level_up then
            self:setShowQuickLevelUp(0)
        end
    end   
    if self:canLevelUpCheck() == true then
        self.long_click_interval = false
        self.m_view:updateEquipState(true)
        self.m_model:hero_lvUp(callfunc)
        self.m_model:updateRefreshHeroListType(true)
    end
end

--发送升级请求
function M:sendLvUpNet(callback)
    if self.m_model.m_hero_list_type == 2 or self.m_model.m_mode == 3 then
        if callback then
            callback()
        end
        return
    end
    local function callfunc(data)
        if data then
            self.m_model:updateResourceData()
            self.m_view:refreshUI()
            self.m_view:refreshRedPoint()
            if callback then
                callback()
            end
        else
            if callback then
                callback()
            end  
        end
    end
    local h_data, h_cfg = self.m_model:getSelectHeroData()
    local lv = self.m_model:getCurNetLv()
    if lv >= 300 then
        if callback then
            callback()
        end
        return
    end
    if self.m_model:inCrystal() == true then
        if callback then
            callback()
        end
        return
    end
    if h_data and lv ~= self.m_model.m_cur_Lv then
        if self.m_model:checkCanLvTrue(self.m_model.m_selected_id, self.m_model.m_cur_Lv) == true then
            self.m_model:getNetData("hero_fast_level_up", {hero_oid = self.m_model.m_selected_id, level = self.m_model.m_cur_Lv}, callfunc, nil, true )
        else
            if callback then
                callback()
            end
        end 
    else
        if callback then
            callback()
        end
    end
end

--一键升级
function M:sendQuickLvUpNet(lv, callback)
    if self.m_model.m_hero_list_type == 2 or self.m_model.m_mode == 3 then
        if callback then
            callback()
        end
        return
    end
    local function callfunc(data)
        if data and self.m_view then
            self.m_model.m_cur_Lv = lv
            self.m_model:updateResourceData()
            self.m_view:refreshUI()
            self.m_view:refreshRedPoint()
            if callback then
                callback()
            end
        else
            if callback then
                callback()
            end   
        end
    end
    self.m_model:getNetData("hero_fast_level_up", {hero_oid = self.m_model.m_selected_id, level = lv}, callfunc)
end


function M:canLevelUpCheck()
    if self.m_model:checkMaxLv() == true and self.m_model:checkMaxEvo() == true then
        local params = {
            text = Language:getTextByKey("new_str_0279")
        }
        self:openView("Pops.CommonPop", params)
        return false
    elseif self.m_model:checkMaxLv() == true then
        return false
    end
    local can_lv_up, index, count = self.m_model:checkCanLevelUp()
    if self.long_click_interval == true and can_lv_up == false then
        if index == 1 then
            local flag = QuickOpenFuncUtil:serverCostsTips(RewardUtil.ERROR_GIFT.ERROR_GIFT_COIN_NUM)
            if not flag then
                local params = {
                    text = string.format(Language:getTextByKey("new_str_0204"))
                }
                self:openView("Pops.CommonPop", params)
            end
        elseif index == 2 then
            local flag = QuickOpenFuncUtil:serverCostsTips(RewardUtil.ERROR_GIFT.ERROR_GIFT_HERO_EXP_NUM)
            if not flag then
                local params = {
                    text = string.format(Language:getTextByKey("new_str_0203"))
                }
                self:openView("Pops.CommonPop", params)
            end
        elseif index == 3 then
            local flag = QuickOpenFuncUtil:serverCostsTips(RewardUtil.ERROR_GIFT.ERROR_GIFT_DUST_NUM)
            if not flag then
                local params = {
                    text = string.format(Language:getTextByKey("tid#NoticeText_01"))
                }
                self:openView("Pops.CommonPop", params)
            end
        elseif index == 4 then
            local params = {
                text = string.format(Language:getTextByKey("new_str_0205"), count)
            }
            self:openView("Pops.CommonPop", params)
        end
    end
    return can_lv_up
end

function M:activateExcWeap()
    local open_flag, tips_str = self.m_model:meridanOpenFlagByPos(self.m_model.m_select_meridian_index)
    if not open_flag then
        GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2})
        return
    end
    local function callfunc(response)
        UserDataManager:mergeSigData(response.sig)
        self.m_model:updateSigData()
        -- 激活成功
        self.m_view:refreshUI(nil,{center=1, right=1})
        RewardUtil:rewardTipsByData(response.reward)
        self.m_view:playSigEffect()
        audio:SendEvtUI("PLAY_UI_LEVELUP")
    end
    local sig_type = ConfigManager:getMysticTypeByPos(self.m_model.m_select_meridian_index)
    self.m_model:getNetData("sig_enable", {hero_oid = self.m_model.m_selected_id, sig_type = sig_type}, callfunc)
end

function M:resetExcWeap(response)
    local function callfunc(response)
        UserDataManager:mergeSigData(response.sig)
        UserDataManager.m_sig_reset_times = response.sig_reset_times or UserDataManager.m_sig_reset_times
        self.m_model:updateSigData()
        self.m_view:refreshUI(nil,{center=1, right=1})
        RewardUtil:rewardTipsByData(response.reward)
    end
    
    -- local reset_cost = ConfigManager:getCommonValueById(295)[1]
    -- local cost_data = RewardUtil:getProcessRewardData(reset_cost)
    -- local params =
    -- {
    --     on_ok_call = function(msg)
    --         local sig_type = ConfigManager:getMysticTypeByPos(self.m_model.m_select_meridian_index)
    --         self.m_model:getNetData("hero_sig_reset", {hero_oid = self.m_model.m_selected_id, sig_type = sig_type}, callfunc)
    --     end,
    --     cost = reset_cost,
    --     text = string.format(Language:getTextByKey("new_str_0614"),cost_data.data_num, cost_data.name),
    -- }
    local reset_cost = ConfigManager:getCommonValueById(295)[1]
    local cost_data = RewardUtil:getProcessRewardData(reset_cost)
    local params =
    {  
        no_close_btn = false,
        tow_close_btn = true,
        m_show_own_flag = true,
        show_cost = true,
        on_ok_call = function(msg)
            local sig_type = ConfigManager:getMysticTypeByPos(self.m_model.m_select_meridian_index)
            self.m_model:getNetData("hero_sig_reset", {hero_oid = self.m_model.m_selected_id, sig_type = sig_type}, callfunc)
        end,
        text = Language:getTextByKey("hero_ui_str_0045")
    }
    if self.m_model:HavFreeNum() == true then
        local use_num = (self.m_model:getAllFreeNum() - self.m_model:getUseFreeNum()).."/"..self.m_model:getAllFreeNum()
        params.tip_text = Language:getTextByKey("weapon_str_0019",use_num) 
    else
        local reset_cost = ConfigManager:getCommonValueById(295)[1]
        params.cost2 = reset_cost
    end
    static_rootControl:openView("Pops.CommonPop", params)
end

function M:intensifyExcWeap(auto)
    local open_flag, tips_str = self.m_model:meridanOpenFlagByPos(self.m_model.m_select_meridian_index)
    if not open_flag then
        GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2})
        return
    end
    local sig_data = self.m_model:getSigDataByType(self.m_model.m_select_meridian_index)
    local can_break = self.m_model:getCurHeroSigCanBreak()
    local last_combat = self.m_model.last_combat
    local function callfunc(response)
        UserDataManager:mergeSigData(response.sig)
        RewardUtil:rewardTipsByData(response.reward)
        local cur_combat = self.m_model:getHero_Combat()
        self.m_model:updateSigData()
        self.m_model:detectionAttrs()
        if can_break then
            audio:SendEvtUI("UI_Tupo_fx")
            self.m_view:lockTouch()
            self.m_view:playSigBreachEffect(function()
                audio:SendEvtUI("JingMai_ani")
                self:openView( "Pops.VedioPlayerPop", { callback = function()
                        self.m_view:unlockTouch()
                        self.m_view:refreshUI(nil,{center=1, right=1})
                        self:openView("Pops.CommonSuccessPop", {sound_name = "UI_Tupo_Success", last_combat = last_combat, cur_combat = cur_combat})
                    end, vedio_name = "meridian_breach.mp4"
                })
            end)
        else
            self.m_view:creatJuQiEffect(auto,sig_data,
                    function()
                        -- 特效播放完毕刷新
                        self.m_view:refreshUI(nil,{center=1, right=1})
                    end
            )
            audio:SendEvtUI("PLAY_UI_LEVELUP")
        end
        self.m_view:playSigEffect(auto)
    end
    if can_break then -- 经脉突破
        local limit_lock, limit = self.m_model:checkIntensifyLimit()
        if limit_lock == false then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("hero_ui_str_0028",limit), delay_close = 2})
            return
        end
        local meridians_cultivation_cfg_item = self.m_model:getShowHeroSigBreakCfg()
        local break_cost = meridians_cultivation_cfg_item.cost
        local costTips = ""
        for i = 1, #break_cost do
            local data = RewardUtil:getProcessRewardData(break_cost[i])
            if data.data_num > data.user_num then
                costTips = costTips .. data.name .. "、"
            end
        end
        
        if costTips ~= "" then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("mystic_str_0063",costTips), delay_close = 2})
            return
        end
        
        local params =
        {
            on_ok_call = function(msg)
                self.m_model:detectionAttrs()
                self.m_model:getNetData("hero_sig_break", {hero_oid = self.m_model.m_selected_id}, callfunc)
            end,
            cost = break_cost,
            text = string.format(Language:getTextByKey("new_str_0834"), Language:getTextByKey(meridians_cultivation_cfg_item.lv_name)),
        }
        self:openView("Pops.CommonMultipleItemPop", params)
    else
        local lock, tips = self.m_model:meridanCanLevelUp()
        if lock == true then
            local sig_type = ConfigManager:getMysticTypeByPos(self.m_model.m_select_meridian_index)
            self.m_model:getNetData("sig_lvlup", {hero_oid = self.m_model.m_selected_id, sig_type = sig_type,auto = auto}, callfunc)
        else
            GameUtil:lookInfoTips(self, {msg = tips, delay_close = 2})
        end
    end
end

--锁定英雄
function M:lockHero()
    local function callfunc()
        self.m_view:refreshUI()
    end
    if self.m_model:getHeroLock() == true then
        self.m_model:getNetData("hero_unlock", {hero_oid = self.m_model.m_selected_id}, callfunc)
    else
        self.m_model:getNetData("hero_lock", {hero_oid = self.m_model.m_selected_id}, callfunc)
    end
end

--领取奖励
function M:getKillReward()
    local function callfunc(response)
        RewardUtil:rewardTipsByData(response.reward)
        UserDataManager.hero_data:updateOneHeroCollect(self.m_model.m_select_book_id)
        self.m_view:refreshUI()
        self.m_view:refreshRedPoint()
    end
    local data = {
        hero_id = self.m_model.m_select_book_id
    }
    self.m_model:getNetData("hero_collect_receive", data, callfunc)
end

function M:onUpdate()
    self:sendLvUpNet(function ()
        self.m_model:updateResourceData()
        self.m_view:refreshUI(nil,{center=1,right = 1})
    end)
end

function M:playTalk()
    if self.interval_tim == true then
        return
    end
    audio:StopPlayingID(self.cur_cv)
    self.cur_cv = audio:SendEvtUI(self.m_model:getTalkSe())
    self.interval_tim = true
    self.tim =
        self:setTimer(
        10,
        function()
            self.interval_tim = false
            if self.tim then
                self:removeTimer(self.tim)
                self.tim = nil
            end
            audio:StopPlayingID(self.cur_cv)
        end
    )
end

function M:setShowQuickLevelUp(lv)
    if lv == 0 then
        self.m_model.m_level_up = 0
    end
    self.m_view:setShowQuickLevelUp(lv)
end

function M:updateTime()
    if self.m_model.m_level_up > 0 then
        if self.m_model.m_show_quick_level_up > 0 then
            self.m_model.m_show_quick_level_up = self.m_model.m_show_quick_level_up - 1
        else
            --self:setShowQuickLevelUp(0)
        end
    end
end


-- 经脉和神器引导触发条件
function M:triggerGuide()
    local guide_info = UserDataManager.guide_data:getCurGuideInfo()
    if guide_info == nil or guide_info.key ~= "HeroBag" then
        local artifacts_data = UserDataManager.artifact_data:getEquipsData()
        if next(artifacts_data) ~= nil then
            local id = ConfigManager:getCommonValueById(281)
            UserDataManager.guide_data:setAnyTeamGuide(id)
            self.m_guide:checkGuide()
        end
    end
end

function M:SortDataList(type)
    self:refreshSortBtn(type)
    self.m_model.sort_type = type
    self.m_model:updateHeroesCombat()
    if type == 1 then -- 战力，队伍，等级，稀有
        local sortFunc = function (id1, id2)
            local t_data_1, t_cfg_1 = self.m_model:getHero(id1)
            local t_data_2, t_cfg_2 = self.m_model:getHero(id2)
            local combat_1 = t_data_1.combat
            local combat_2 = t_data_2.combat
            --local combat_1 = UserDataManager:computeHeroCombat(t_data_1, t_cfg_1)
            --local combat_2 = UserDataManager:computeHeroCombat(t_data_2, t_cfg_2)
            local main_team_1 = UserDataManager.hero_data:heroInMainTeam(id1)
            local main_team_2 = UserDataManager.hero_data:heroInMainTeam(id2)
            if combat_1 == combat_2 then
                if main_team_1 == main_team_2 then
                    if t_data_1.clv == t_data_2.clv then
                        return t_data_1.evo > t_data_2.evo
                    else
                        return t_data_1.clv == t_data_2.clv
                    end
                else
                    return main_team_1 > main_team_2
                end
            else
                return combat_1 > combat_2
            end
        end
        table.sort(self.m_model.hero_list, sortFunc)
    elseif type == 2 then -- 等级，队伍，战力，稀有
        local sortFunc = function (id1, id2)
            local t_data_1, t_cfg_1 = self.m_model:getHero(id1)
            local t_data_2, t_cfg_2 = self.m_model:getHero(id2)
            local combat_1 = t_data_1.combat
            local combat_2 = t_data_2.combat
            --local combat_1 = UserDataManager:computeHeroCombat(t_data_1, t_cfg_1)
            --local combat_2 = UserDataManager:computeHeroCombat(t_data_2, t_cfg_2)
            local main_team_1 = UserDataManager.hero_data:heroInMainTeam(id1)
            local main_team_2 = UserDataManager.hero_data:heroInMainTeam(id2)
            local lv_1 = t_data_1.clv> 0 and t_data_1.clv or t_data_1.lv
            local lv_2 = t_data_2.clv> 0 and t_data_2.clv or t_data_2.lv
            if lv_1 == lv_2 then
                if main_team_1 == main_team_2 then
                    if combat_1 == combat_2 then
                        return t_data_1.evo > t_data_2.evo
                    else
                        return combat_1 > combat_2
                    end
                else
                    return main_team_1 > main_team_2
                end
            else
                return lv_1 > lv_2
            end
        end
        table.sort(self.m_model.hero_list, sortFunc)
    elseif type == 3 then -- 稀有，队伍，等级，战力
        local sortFunc = function (id1, id2)
            local t_data_1, t_cfg_1 = self.m_model:getHero(id1)
            local t_data_2, t_cfg_2 = self.m_model:getHero(id2)
            local combat_1 = t_data_1.combat
            local combat_2 = t_data_2.combat
            --local combat_1 = UserDataManager:computeHeroCombat(t_data_1, t_cfg_1)
            --local combat_2 = UserDataManager:computeHeroCombat(t_data_2, t_cfg_2)
            local main_team_1 = UserDataManager.hero_data:heroInMainTeam(id1)
            local main_team_2 = UserDataManager.hero_data:heroInMainTeam(id2)
            if t_data_1.evo == t_data_2.evo then
                if main_team_1 == main_team_2 then
                    if combat_1 == combat_2 then
                        return t_data_1.clv > t_data_2.clv
                    else
                        return combat_1 > combat_2
                    end
                else
                    return main_team_1 > main_team_2
                end
            else
                return t_data_1.evo > t_data_2.evo
            end
        end
        table.sort(self.m_model.hero_list, sortFunc)
    end
    self.m_view.m_cur_tab_node["left"]:updateHerosScroll()
    self.m_view.m_cur_tab_node["left"]:setObjectVisible("img_sort_select", false)
end

function M:refreshSortBtn(type)
    -- for k, v in pairs(self.m_view.m_cur_tab_node["left"].sort_list) do
    --     if type and type == k then
    --         v.img_select:SetActive(true)
    --         v.txt_sort_type.color = Color(117 / 255, 82 / 255, 48 / 255)
    --     else
    --         v.img_select:SetActive(false)
    --         v.txt_sort_type.color = Color(255 / 255, 255 / 255, 255 / 255)
    --     end
    -- end
end

-- 归还佣兵
function M:giveBackApostles()
    local function callback(response)
        self:updateMsg("give_back", nil, "Friend")
        self:closeView()
    end
    local params = {}
    params.hero_oid = self.m_model.m_params.oid
    self.m_model:getNetData("apostle_give_back", params, callback)
end

-- 整理发送好感度数据
function M:trimGivingGiftsNet(giftData)
    -- 是否普通赠送按钮(反之一键升级)
    local isNormalBtn = giftData.isNormalBtn
    local datas = giftData.datas
    local h_data, h_cfg = self.m_model:getSelectHeroData()
    local hero_id = h_cfg.id
    local order_data = table.copy(self.m_model:getFettersData())
    local attrsData = self.m_model:getHeroAttrsData()
    local last_combat = self.m_model.last_combat
    local function callback(response)
        UserDataManager.m_friendliness[tostring(hero_id)] = response.hero_friendliness or {}
        self.m_model.send_friend_item_num = 0
        self.m_model:updateSetFettersItems()
        if isNormalBtn then
            self.m_view:showFriendLevelUpEft()
        end
        self.m_model.m_is_friend_up = response.up_level == 1
        self.m_view:refreshUI(nil, {center = 1, right=1})
        self.m_model:updateRefreshHeroListType(true)
        if response.up_level == 1 then
            self.m_model:setFriendLevelUpData({
                last_combat = last_combat,
                order_data = order_data, 
                hero_id = hero_id, 
                friendLevelUpParams = attrsData})
            self:showFriendEft(order_data, hero_id, attrsData)
        else
            self.m_view:showFriendLevelUpEft()
        end
    end
    local params = {}
    params.hero_id = h_cfg.id
    params.items = {}
    if datas and #datas > 0 then
        for _, itemData in pairs(datas) do
            if type(itemData) == "table" then
                local itemId = tostring(itemData.item_id)
                params.items[itemId] = itemData.num
            end
        end
    end
    return params, callback
end

--发送好感请求
function M:sendGivingGiftsNet(datas)
    local params, callback = self:trimGivingGiftsNet(datas)
    self.m_model:getNetData("giving_gifts", params, callback)
end

-- 显示侠客身上特效
function M:showFriendEft(order_data,hero_id, friendLevelUpParams)
    local isPlayOverFriendLevelUpEft = self.m_model.isPlayOverFriendLevelUpEft
    if not isPlayOverFriendLevelUpEft then
        return
    end
    self.m_view.m_cur_tab_node["center"]:showFriendLightenEft(order_data,hero_id, friendLevelUpParams)
end

function M:onDestroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.CLOSE_VIEW, {self, self.closeViewEvent})
    --EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.refreshCombatRepress})
    if self.changeSkin == true and SceneManager.curScene.sceneId == SceneManager.SceneID.HangUpScene then
        SceneManager.curScene:reset()
    end
    SceneManager:getCurSceneModel():setCameraShow(true)
    self:sendLvUpNet()
    audio:StopPlayingID(self.cur_cv)
    self.cur_cv = nil
    if self.m_model:getCurHeroBank() then
        ResourceUtil:UnLoadRoleSound(self.m_model:getCurHeroBank())
    end
end

-- 一键赠送 好感道具
function M:sendAllFriendLike(params, sendCallBack)
    self.m_model:getNetData("giving_gifts", params, function(response)
        sendCallBack(response)
    end)
end

-------------------------------符篆
function M:checkTalins(index)
    if self.m_model.isNil == true then
        return
    end
    local equip_data = self.m_model:checkTalisForId(index)
    --local function levelUpCallBack()
        --self.m_view:updateEquipState(true)
        if equip_data then --当前身上有装备
            if self.m_model.m_mode == 3 then
                local h_data, h_cfg = self.m_model:getSelectHeroData()
                local params = {
                    heroid = self.m_model.m_selected_id,
                    pos = index,
                    look_model = self.m_model.m_mode,
                    talins_data = equip_data,
                    c_hero = h_data
                }
                self:openView("HeroBag.HeroTalisMan.HeroTalisManPop", params) --查看装备
            else
                local params = {
                    heroid = self.m_model.m_selected_id,
                    pos = index,
                    look_model = 0
                }
                self:openView("HeroBag.HeroTalisMan.HeroTalisManPop", params) --查看装备
                --self.m_model:updateRefreshHeroListType(true)
            end
        else
            local talis_data = self.m_model:getTalisData()
            if #talis_data <= 0 then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("talisman_text_0028"), delay_close = 2})
                return
            end
            if self.m_model.m_mode ~= 3 then
                local params = {
                    heroid = self.m_model.m_selected_id,
                    pos = index
                }
                self:openView("HeroBag.HeroTalisMan.HeroTalisManList", params) --穿戴装备
                --self.m_model:updateRefreshHeroListType(true)
            end
        end
    --end
    --self:sendLvUpNet(levelUpCallBack) 
    end
function M:sendAllFriendLike(params, sendCallBack)
    self.m_model:getNetData("giving_gifts", params, function(response)
        sendCallBack(response)
    end)
end

function M:replaceSkill(param)
    local function replaceCallback(response)
        if response then
            self.m_model:initHerosData()
            self.m_view:refreshUI()
        end
    end
    local data,_ = UserDataManager.hero_data:getHeroDataById(self.m_model.m_selected_id)
    local params = {skill_idx = param.skill_idx,hero_id = data.id}
    self.m_model:getNetData("awaken_replace_skill", params, replaceCallback)
end

function M:skillDetail(param)
    local skills = self.m_model:getHeroSkill(true)
    local hero_lv = self.m_model:getHero_lv()
    local click_obj = param.click_obj
    local cur_skill = self.m_model:getCurSKill()
    local hero_id =self.m_model:getHeroid()
    local ordinary_skill = table.nums(cur_skill) > 0 and 3 or 0
    local select_id = param.skill_idx
    --self:openView("Pops.SkillPop", {hero_id = hero_id,ordinary_skill = ordinary_skill,skill = skills[select_id], index = 4, cur_lv = hero_lv, click_transform = click_obj.transform,pivot = Vector2(0.5,1)})

    local lv4Unlock=self.m_model:checkSkillLv4Unlock(select_id)
    self:openView("Pops.SkillPop", {hero_id = hero_id,ordinary_skill = ordinary_skill,skill = skills[select_id], index = 4, cur_lv = hero_lv, click_transform = click_obj.transform,pivot = Vector2(0.5,1),lv4Unlock=lv4Unlock})
end

function M:refreshCombatRepress(event,data)
    if data.event == "heros_update" or data.event == "combat_repress_update" then
        self.m_view:setCombatRepressVisible() 
    end
end

return M
