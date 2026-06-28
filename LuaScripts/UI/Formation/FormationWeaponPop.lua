---@class FormationWeaponPop:OOUIbase
---@field m_model FormationModel
--- 遗物生效列表
local M = class("FormationWeaponPop",LikeOO.OOUIbase)

M.m_uiName = "Formation/FormationWeaponPop"
M.m_iphoneXAdapter = true
function M:onEnter()
    self:setTextByLanKey("title_text", "weapon_str_0021")
    self.content = self:findGameObject("Content")
    self.base_obj_fitter = self.content:GetComponent("ContentImmediate")
    if self.base_obj_fitter then
		--触发刷新自适应大小
		self.base_obj_fitter:ForceRefreshSize()
	end 
    self.m_model.can_click = false
    self:refreshUI()
end

function M:onButtonClick(obj, name)
	if name == "close_btn" or name == "big_close_btn" then
		self:destroy()
	end
end

function M:refreshUI()
    local solt = self.m_model.m_solts
    local open_lokc_num = self.m_model:getTreasurePosNum()
    if self.m_model.m_mult_team_flag == true and self.m_model.m_mult_solts and next(self.m_model.m_mult_solts) then
        solt = self.m_model.m_mult_solts[self.m_model.m_formation_index] or {}
    end
    for i = 1,4 do
        self:updateWeaponItem(i,solt[tostring(i)], open_lokc_num >= i)
    end
end

function M:updateWeaponItem(index, wea_id, is_lock)
    local obj = self:findGameObject("cell_"..index)
    if IsNull(obj) then
        return    
    end
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if is_lock == true then
        if wea_id and wea_id ~= 0 then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cell_title_text", true)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cell_title_lock", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "skill_lv_bg", true)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "skill_icon_lock", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "skill_des", true)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "wea_unlock_text", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "wea_zd_kong", false)
            local wea_data, wea_cfg = self.m_model:getWeaRelics(wea_id)
            local wea_lv_cfg = wea_cfg.detail[wea_data.lv] or wea_cfg.detail[1]
            local skill_cfg = self.m_model:getSkillDataById(wea_lv_cfg.skill_id)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_text", Language:getTextByKey(wea_lv_cfg.name_tips).." ("..wea_data.lv..Language:getTextByKey("new_str_0428")..")")
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "skill_lv",  wea_data.lv)
            if skill_cfg then
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "skill_des_text",  skill_cfg.des)
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "skill_name",  skill_cfg.name)
                LuaBehaviourUtil.setImg(luaBehaviour, "skill_icon", skill_cfg.icon, "skill_icon")
            end
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cell_title_text", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cell_title_lock", true)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "skill_lv_bg", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "skill_icon_lock", true)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "skill_des", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "wea_zd_kong", true)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "wea_unlock_text", true)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_lock", "weapon_str_0018")
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "wea_unlock_text", "weapon_str_0017")
        end
    else
        local pos_cfg = self.m_model:getTreasurePosition(index)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cell_title_text", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cell_title_lock", true)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "skill_lv_bg", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "skill_icon_lock", true)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "skill_des", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "wea_zd_kong", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "wea_unlock_text", true)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_lock", "weapon_str_0001", pos_cfg.unlock)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "wea_unlock_text", "weapon_str_0016")
    end
    luaBehaviour:RegistButtonClick(function(click_object, click_name, idx)
        if click_name == "wea_zd_kong" then
            if self.m_control and self.m_control.m_view and self.m_control.m_view.clickWeaSoltByIndex then
                self.m_control.m_view:clickWeaSoltByIndex(index)
            end
            self:destroy()
        end
    end)
end


function M:destroy()
    if self.m_control and self.m_control.m_view and self.m_control.m_view.clickWeaSoltByIndex then
        self.m_control.m_view:fonmationWeapopDestory()
    end
    self.m_model.can_click = true
    M.super.destroy(self)
end

return M