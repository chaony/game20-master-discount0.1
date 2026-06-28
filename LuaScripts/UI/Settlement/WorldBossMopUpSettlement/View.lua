local M = class("WorldBossMopUpSettlementView",LikeOO.OOPopBase)

M.m_uiName = "Settlement/Settlement"

function M:onEnter()
    self.m_content_panel = self:findGameObject("content_panel")
    self:LoadResultsBg()
    local tab_cls = CustomRequire("UI.Settlement.SettlementWorldBossWinNode")
    self.m_cur_node = tab_cls.new(self.m_control, {parent = self.m_content_panel})
    -- 下一关 或 再次挑战
    self:setTextByLanKey("lost_ok_btn_text", "new_str_0242")
    self:setTextByLanKey("win_ok_btn_text", "new_str_0241")
    self:setTextByLanKey("next_text", "new_str_0243")
    self:setObjectVisible("record_btn", self.m_model:getShowRecordFlag())
    -- 战斗胜利光环
    EventDispatcher:registerTimeEvent("ShenliSound", function()
        audio:SendEvtUI(self.m_model.m_result == 0 and "UI_Lose" or 'Ui_Win')
    end ,0.5, 0.5)

    self:findButton("big_close_btn").interactable = false
    self:setObjectVisible("content_panel", false)
end

function M:battleResultSpineAnimEnd(delay_time)
    delay_time = delay_time or 1.5
    EventDispatcher:registerTimeEvent("ShenliSound", function()
        self:setObjectVisible("content_panel", true)
        self:setObjectVisible("win_sp", false)
        self:setObjectVisible("lose_sp", false)
        self:findButton("big_close_btn").interactable = true
        self:guideVisible()
        audio:SendEvtUI('Play_UI_Settlement')
        NetWork:delayCheckHope()
    end ,delay_time, delay_time)
end

function M:openTransitionEnd()
    if self.m_model:checIsSkip() == true then
        self:updateMsg(99999)
    else
        if self.m_model.m_replay then-- 不播放spine动画
            self:battleResultSpineAnimEnd(0.1)
            self:updateMsg("win_record_btn")
        else
            if self.m_model.m_result == 1 then
                self:setObjectVisible("lose_sp", false)
                self:setObjectVisible("win_sp", true)
                --local eff_obj = self:setObjectVisible("UI_Settlement_Win_001", true)
                --self:setParticleRenderOrder(eff_obj)
                --local obj = self:findGameObject("win_bg")
                --local anim = obj:GetComponent("SkeletonGraphic")
                --anim.AnimationState:SetAnimation(0, "victory_1", false)
                --self:addSpineComplete(anim.AnimationState,handler(self, self.battleResultSpineAnimEnd))

                local function winCard(msg)
                    self:battleResultSpineAnimEnd()
                end
                local win_main = self:findGameObject("win_main")
                local win_main_luabehaviour = win_main:GetComponent("LuaBehaviour")
                win_main_luabehaviour:RunAnim("Zhandoushengli", winCard)
                
            else
                self:setObjectVisible("lose_sp", true)
                self:setObjectVisible("win_sp", false)

                local function endCard(msg)
                    self:battleResultSpineAnimEnd()
                end
                local lose_main = self:findGameObject("lose_main")
                local lose_main_luabehaviour = lose_main:GetComponent("LuaBehaviour")
                lose_main_luabehaviour:RunAnim("Zhandoushibai", endCard)
                --local obj = self:findGameObject("lose_bg")
                --local anim = obj:GetComponent("SkeletonGraphic")
                --anim.AnimationState:SetAnimation(0,"defeat", false)
                --self:addSpineComplete(anim.AnimationState,handler(self, self.battleResultSpineAnimEnd))
            end
        end
    end
end

function M:guideVisible()
    self.m_control.m_guide:checkGuide()
    if UserDataManager.guide_data:isGuiding() then
        --self:setObjectVisible("ok_btn", false)
        if self.m_model.bl_new_panel == 1 
                and (self.m_model.m_mode == GlobalConfig.BATTLE_MODE.STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE
                    or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT) then
            self.m_temp_node:update_ok_btn(false)
        else    
            if self.m_bg_node then
                self.m_bg_node:update_ok_btn(false)
                if self.m_cur_node ~= nil and self.m_cur_node.updateButtonVisible ~= nil then
                    self.m_cur_node:updateButtonVisible(false)
                end
            end
        end
    end
end

function M:LoadResultsBg()
    local tab_cls = CustomRequire("UI.Settlement.SettlementCommonBgNode")
    self.m_bg_node = tab_cls.new(self.m_control, {parent = self.m_content_panel})
    --self.m_bg_node:RigCallback(handler(self, self.bgRunEnd))
    if self.m_model.m_result == 0 then
        self.audio = audio:SendEvtUI('PLAY_UI_LOSE')
    else
        self.audio = audio:SendEvtUI('PLAY_UI_WIN')
    end
    audio:PauseMusicBusVol()
end

function M:bgRunEnd()
    if self.m_cur_node then
        if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.STAGE 
                or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.TOWER 
                or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.RACE_TOWER 
                or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MAZE
                or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MAZE then
           -- self.m_cur_node:playAnim()
        end 
    end
end

function M:destroy()
    audio:StopPlayingID(self.audio)
    self.audio = nil
    if self.m_cur_node then
		self.m_cur_node:destroy()
		self.m_cur_node = nil
    end
    if self.m_bg_node then
		self.m_bg_node:destroy()
		self.m_bg_node = nil
	end
    audio:ResumeMusicBusVol()
    EventDispatcher:unRegisterEvent("ShenliSound")
    M.super.destroy(self)
end

return M