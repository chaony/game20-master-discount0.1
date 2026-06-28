---@class SettlementCommonBgNode:OOUIbase
---@field m_model SettlementModel
local M = class("SettlementCommonBgNode",LikeOO.OOUIbase)

M.m_uiName = "Settlement/SettlementCommon"
M.callback = nil
M.m_cache_ui_flag = true
function M:onEnter()
    self:setObjectVisible("win_record_btn", self.m_model.m_show_record_btn ~= false)	
    self:setObjectVisible("lost_record_btn", self.m_model.m_show_record_btn ~= false)	
    self:setObjectVisible("win_ok_btn", false)	
    self:setObjectVisible("return_btn", false)		
    self:setObjectVisible("lost_ok_btn", false)
    self:setObjectVisible("over_word",false)
    self:setTextByLanKey("over_word","new_str_0639")
    self:setTextByLanKey("com_next_text","new_str_0243")
    self:setTextByLanKey("lost_ok_btn_text","new_str_0242")
    self:setTextByLanKey("lost_ok_btn_text2","new_str_0242")
    self:setTextByLanKey("next_text","new_str_0243")
    self:setTextByLanKey("next_text2","new_str_0243")
    self:setSpine()
    self:refreshUI()

    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE 
            or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FIVE_ARRAY 
            or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.EVIL_SHADOW 
            or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.SORT_CHIVALROUS 
            or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.COMMON_BATTLE 
            or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.DRAGONSWORD
            or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE
            or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS
            or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then
        --大侠试炼隐藏掉回放按钮
        self:setObjectVisible("win_record_btn", false)
    end

end


function M:showOverWord()
    self:setObjectVisible("win_ok_btn", false)
    self:setObjectVisible("return_btn", false)
    self:setObjectVisible("lost_ok_btn", false)
    self:setObjectVisible("over_word",true)
end



function M:refreshUI()
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.RTA_ARENA then
        self:setObjectVisible("Loser_obj",false)
        if self.m_model.rta_result==0 then
            self:setObjectVisible("Loser_obj2",true)
            self:setObjectVisible("Win_obj",false)
            self.m_anim_name = "SettlementCommonLost_show"
        elseif self.m_model.rta_result == 1 then
            self:setObjectVisible("Loser_obj2",false)
            self:setObjectVisible("Win_obj",true)
        end
    else
        if self.m_model.m_result == 0 then

            self:setObjectVisible("Loser_obj",true)
            self:setObjectVisible("Win_obj",false)
            self.m_anim_name = "SettlementCommonLost_show"
        elseif self.m_model.m_result == 1 then
            self:setObjectVisible("Loser_obj2",false)
            self:setObjectVisible("Loser_obj",false)
            self:setObjectVisible("Win_obj",true)
            self.m_anim_name = "SettlementCommonWin_show"
            --self.win_spine = self:findGameObject("win_spine")
            --self.animation = self.win_spine:GetComponent("SkeletonGraphic")
            --self:addSpineComplete(self.animation.AnimationState, handler(self,self.setAnimation))
        end
    end

    self:setObjectVisible("mvp_img", self.m_model.m_result == 1)   
    -- self:setObjectVisible("w_bg_img", self.m_model.m_result == 1)  
    -- self:setObjectVisible("l_bg_img", self.m_model.m_result == 0)  
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HIGH_ARENA 
            or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HUASHAN_SWORD
            or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE
            or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS
            or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then
        self:setObjectVisible("lost_record_btn", false)
        self:setObjectVisible("win_record_btn", false)
    end
    --self:playAnim()
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE then
        local stage = UserDataManager:getCurStage()
        local new_chapter = self.m_model:getIsNewChapter()
        self:setObjectVisible("win_ok_btn", stage > 4 and not new_chapter)
        self:setObjectVisible("lost_ok_btn", stage > 4 and not new_chapter)
        self:setObjectVisible("return_btn", stage > 4 and not new_chapter)
        self:setTextByLanKey("win_ok_btn_text", "new_str_0241")       
        self:setTextByLanKey("return_btn_text", "new_str_0478")
    elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.TOWER then   
        self:setObjectVisible("win_ok_btn", true)
        self:setObjectVisible("return_btn", true)
        self:setTextByLanKey("win_ok_btn_text", "new_str_0640")  
    else
        self:setObjectVisible("win_ok_btn", false)
        self:setObjectVisible("return_btn", false)
        self:setObjectVisible("lost_ok_btn", false)
    end
end

function M:RigCallback(call)
    self.callback = call
end

function M:playAnim()
    if self.m_luaBehaviour then
        self.m_luaBehaviour:RunAnim(self.m_anim_name, handler(self, self.endCallFunc), 1)
    end
end

function M:onButtonClick(obj, name)
    self:updateMsg(name)
end

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
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_ONE or
            self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_THREE or
            self.m_model.m_mode == GlobalConfig.BATTLE_MODE.RTA_ARENA
    then
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