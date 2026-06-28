---@class SettlementRTANode:OOUIbase
---@field m_model SettlementModel
local M = class("SettlementRTANode",LikeOO.OOUIbase)

M.m_uiName = "Settlement/SettlementRTANode"
M.callback = nil
M.m_cache_ui_flag = true
function M:onEnter()

    self:setTextByLanKey("wendaoB_text","arena_rta_str_0023")
    self:setText("wendaoB_change_num_text","+"..self.m_model.rta_wendaoBNum)
    if self.m_model.rta_score>=0 then
        self:setText("score_change_text","+"..self.m_model.rta_score)
        self:setTextColor("score_change_text",Color( 74/255, 203/255, 57/255))
    else
        self:setText("score_change_text",self.m_model.rta_score)
        self:setTextColor("score_change_text",Color( 161/255, 44/255, 20/255))
    end

    self:setTextByLanKey("previousScore_text","arena_rta_str_0024",self.m_model.rta_preScore)
    --self:setSpine()
    --self:refreshUI()

    self:setObjectVisible("win_record_btn", false)

end


function M:showOverWord()
    self:setObjectVisible("win_ok_btn", false)
    self:setObjectVisible("return_btn", false)
    self:setObjectVisible("lost_ok_btn", false)
    self:setObjectVisible("over_word",false)
end



function M:refreshUI()
    self:setText("wendaoB_change_num_text","+"..self.m_model.rta_wendaoBNum)
end

function M:RigCallback(call)
    self.callback = call
end

function M:playAnim()
    if self.m_luaBehaviour then
        self.m_luaBehaviour:RunAnim(self.m_anim_name, handler(self, self.endCallFunc), 1)
    end
end

--function M:onButtonClick(obj, name)
--    self:updateMsg(name)
--end

function M:setAnimation( )
	if self.animation.AnimationState:ToString() == "animation_1" then
		self.animation.AnimationState:SetAnimation(0, "animation_2", true)
	end
end

function M:endCallFunc(animName)
    if animName == "SettlementCommonLost_show" or  animName == "SettlementCommonWin_show" then
        --self:setObjectVisible("win_record_btn", false)
        --self:setObjectVisible("lost_record_btn", false)
        local guide_info = UserDataManager.guide_data:getCurGuideInfo()
        if UserDataManager.guide_data:isGuiding() and guide_info.key == "Settlement" then
            self:setObjectVisible("win_ok_btn", false)
            self:setObjectVisible("return_btn", false)
            self:setObjectVisible("lost_ok_btn", false)
            self:setObjectVisible("win_record_btn", false)
            self:setObjectVisible("lost_record_btn", false)
        else
            if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE then
                local stage_cfg = GameUtil:getBattleStageCfg()
                local skip_deploy = stage_cfg.skip_deploy or 0
                if skip_deploy == 0 then
                    
                    local stage = UserDataManager:getCurStage()
                    local new_chapter = self.m_model:getIsNewChapter()
                    self:setObjectVisible("win_ok_btn", stage > 4 and not new_chapter)
                    self:setObjectVisible("return_btn", stage > 4 and not new_chapter)
                    self:setObjectVisible("lost_ok_btn", stage > 4 and not new_chapter)
                    self:setTextByLanKey("win_ok_btn_text", "new_str_0241")       
                    self:setTextByLanKey("return_btn_text", "new_str_0478")                     
                end
            else
                self:setObjectVisible("win_ok_btn", false)
                self:setObjectVisible("return_btn", false)
                self:setObjectVisible("lost_ok_btn", false)
            end
        end
        if self.callback then
            self.callback()
        end
    end
end

function M:update_ok_btn(bl)
    self:setObjectVisible("win_ok_btn", bl)
    self:setObjectVisible("return_btn", bl)
    self:setObjectVisible("lost_ok_btn", bl)
    self:setObjectVisible("lost_record_btn", bl)
    --self:setObjectVisible("win_record_btn", bl)
end

--[[
    @desc: 英雄动画
]]
function M:setSpine()
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.PET_DOUJI then
        return
    end
	local icon,hero_cfg = self.m_model:getHeroBigAnim()
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_ONE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_THREE  then
        icon,hero_cfg = self.m_model:getPvpHeroBigAnim()
    end
	local play_img = self:findGameObject("hero_spine")
    GameUtil:updateSpineLoadSet(play_img, "RoleSpine/"..icon, "idle", 0, true)

    local pos_x = -8
    local pos_y = -8
    local spine_pos, spine_scale = self.m_model:getSpinePos(hero_cfg)
    local pos = play_img.transform.localPosition
    pos.x = spine_pos[1] or 0
    pos.y = spine_pos[2] or 0
    play_img.transform.localPosition = pos
    play_img.transform.localScale = Vector3(spine_scale,spine_scale,1)
end

return M