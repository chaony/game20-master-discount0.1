local M = class("GuJianQiTanShowView",LikeOO.OOPopBase)

M.m_uiName = "GuJianQiTan/GuJianQiTanShow"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
    self.m_gray_material = self:findImage("gray_image").material
    self:setTextByLanKey("close_title_text", "gu_jian_qi_tan_str_002")
    self:setTextByLanKey("stage_detail_reward_text", "gu_jian_qi_tan_str_017")
    self:setTextByLanKey("stage_target_title_text", "gu_jian_qi_tan_str_030")
    self:setTextByLanKey("challenge_btn_text", "gu_jian_qi_tan_str_057")
    self:setTextByLanKey("stage_detail_enemy_text", "biography_str_006")
    self:refreshUI()
    self:initStagePathEffect()
end

function M:refreshUI()
    self:updateStage()
    self:updateEnemyAndReward()
    self:updateStageTarget()
    self:updateTiaoZhanStatus()
end

--关卡按钮
function M:updateStage()
    --local stage_id_selected = self.m_model:getSelectedStage()
    local stage_data = self.m_model:getStageData()
    local stage_bts = self.m_model:getStageBtns()
    for k, v in pairs(stage_data) do
        self:setObjectVisible(stage_bts[k], v.visible_flag)
        self:setText("stage_name_" .. k, v.name)

        if self.m_model:checkStageDone(k) == true then
            self:setTextColor("stage_name_" .. k, Color(43/255, 43/255, 43/255))
        end
        
        --if k == stage_id_selected then
        --    self:findImage(stage_bts[k]).color = Color(214/255, 105/255, 70/255)
        --else
        --    if v.open_flag == true then
        --        self:findImage(stage_bts[k]).color = Color(255/255, 255/255, 255/255)
        --    else
        --        self:findImage(stage_bts[k]).color = Color(200/255, 200/255, 200/255)
        --    end
        --end
    end

    self:playStagePathEffectPhase()
end

--关卡详情
function M:updateEnemyAndReward()
    local stage_item = self.m_model:getCurrentStageData()
    if stage_item ~= nil then
        self:setObjectVisible("stage_detail_node", true)
        self:setText("stage_detail_title_text", stage_item.name)
        self:updateStageEnemyLoopScroll(stage_item.enemy)
        self:updateStageRewardLoopScroll(stage_item.reward)
    else
        self:setObjectVisible("stage_detail_node", false)
    end

    self:updateTiaoZhanStatus()
end

function M:updateStageEnemyLoopScroll(show_data)
    local scroll_object = self:findGameObject("stage_detail_enemy_loopscroll")
    scroll_object:SetActive(true)
    if show_data == nil or next(show_data) == nil then
        scroll_object:SetActive(false)
        return
    end
    if self.m_enemy_loopscroll_view == nil then
        local loopscroll = scroll_object
        local params = {
            show_data = show_data,
            one_line_count = 1,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                local transform = cell_object.transform
                local data = cell_data
                local luaBehaviour = UIUtil.findLuaBehaviour(transform)
                local item_node = luaBehaviour:FindGameObject("item_node")
                local ui_element = CommonUIUtil:updateHeroElementByData(item_node, cell_data, nil , true)
                CommonUIUtil:updateHeroLvByData(item_node, data.hero_data)
            end
        }
        self.m_enemy_loopscroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_enemy_loopscroll_view:reloadData(show_data)
    end
end

function M:updateStageRewardLoopScroll(show_data)
    local scroll_object = self:findGameObject("stage_detail_reward_loopscroll")
    scroll_object:SetActive(true)
    if show_data == nil or next(show_data) == nil then
        scroll_object:SetActive(false)
        return
    end

    if self.m_reward_loopscroll_view == nil then
        local params = {
            show_data = show_data,
            one_line_count = 1,
            loop_scroll_object = scroll_object,
            update_cell = function(index, cell_object, cell_data)
                local item_data = RewardUtil:getProcessRewardData(cell_data)
                GameUtil:updateItemElementByData(cell_object, item_data, true, true)
                --对勾
                local luaBehaviour = cell_object:GetComponent("LuaBehaviour")
                if luaBehaviour then
                    local duigoudi_img = luaBehaviour:FindGameObject("duigoudi_img")
                    duigoudi_img:SetActive(self.m_model:checkStageDone())
                end
            end
        }
        self.m_reward_loopscroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_reward_loopscroll_view:reloadData(show_data)
    end

end

--目标
function M:updateStageTarget()
    self:setTextByLanKey("stage_target_des_text", self.m_model:getCurrentStageTargetText())
    self:setObjectVisible("stage_target_node", self.m_model:checkAllStageDone() == false)
end

--初始化路径特效
function M:initStagePathEffect()
    local path_data = self.m_model:getStagePathData()
    for k, v in pairs(path_data) do
        local petard_Ani = self:findGameObject("stage_path_effect_" .. v.id)
        GameUtil:updateSpineLoadSet(petard_Ani, "RoleSpine/" .. "GuJianQiTan_LuX001_SkeletonData", "GuJianQiTan_LuX001a", 0, false)

        DOTweenModuleUI.DOFade(self:findText("stage_name_" .. v.id), 1.0, 0.0)
        DOTweenModuleUI.DOFade(self:findImage("stage_name_bg_" .. v.id), 1.0, 0.0)
        DOTweenModuleUI.DOFade(self:findImage("stage_light_" .. v.id), 1.0, 0.0)

        if v.id == 101 then
            DOTweenModuleUI.DOFade(self:findSkeletonGraphic("GuJianQiTan_ChuanS001"), 1.0, 0.0)
        end
    end
end

--阶段路径特效
function M:playStagePathEffectPhase()
    local stage_data = self.m_model:getStageDataWithPhase()
    local sequenceA = Tweening.DOTween.Sequence()
    for i, v in ipairs(stage_data) do
        if i <= 5 then
            sequenceA:AppendInterval(0.25)
            sequenceA:AppendCallback(function()
                self:playStagePathEffect(v.id)
            end)
        else
            break
        end
    end
    sequenceA:SetAutoKill(true)

    --针对第二阶段，open_stage == 2
    if #stage_data > 5 then
        audio:SendEvtUI("UI_ChuanSongLine")
        local sequenceB = Tweening.DOTween.Sequence()
        for i, v in ipairs(stage_data) do
            if i > 4 then
                sequenceB:AppendInterval(0.25)
                sequenceB:AppendCallback(function()
                    self:playStagePathEffect(v.id)
                end)
            end
        end
        sequenceB:SetAutoKill(true)
    end

    if #stage_data > 0 then
        local item_count = #stage_data
        if self.m_model:getOpenStageCurrent() == 1 then
            item_count = 8
        end
        item_count = item_count / 2
        if item_count < 1 then
            item_count = 1
        end
        self:lockTouch()
        self.m_control:setOnceTimer(0.3 * item_count, function ()
            self:unlockTouch()
        end)
    end
    
end

--特定路径特效
function M:playStagePathEffect(stage_id)
    local petard_Ani = self:findGameObject("stage_path_effect_" .. stage_id)
    GameUtil:updateSpineLoadSet(petard_Ani, "RoleSpine/" .. "GuJianQiTan_LuX001_SkeletonData", "GuJianQiTan_LuX001b", 0, false)
    
    local fade_time = 0.1
    if stage_id == 101 then
        fade_time = 1.0
    end
    local sequence = Tweening.DOTween.Sequence()
    sequence:PrependInterval(0.4)
    if stage_id == 101 then
        sequence:Append(DOTweenModuleUI.DOFade(self:findSkeletonGraphic("GuJianQiTan_ChuanS001"), 1, 1.0))
    end
    sequence:Append(DOTweenModuleUI.DOFade(self:findText("stage_name_" .. stage_id), 1.0, fade_time))
    sequence:Join(DOTweenModuleUI.DOFade(self:findImage("stage_name_bg_" .. stage_id), 1.0, fade_time))
    sequence:Join(DOTweenModuleUI.DOFade(self:findImage("stage_light_" .. stage_id), 1.0, fade_time))
    sequence:SetAutoKill(true)
end

--挑战按钮
function M:updateTiaoZhanStatus()
    self:setObjectVisible("challenge_btn", self.m_model:canStartBattle())
end


return M