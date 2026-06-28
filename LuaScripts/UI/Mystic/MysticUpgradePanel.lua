--- 英雄
local M = class("MysticUpgradePanel",LikeOO.OOUIbase)

M.m_uiName = "Mystic/MysticUpgradePanel"

function M:onCreate()
    self:setTextByLanKey("upgrade_btn_text", "mystic_str_0002")
    self:setTextByLanKey("onekey_upgrade_btn_text", "mystic_str_0004")
    self.select_panel = self:findGameObject("select_panel")
    self.onekey_upgrade_btn = self:findGameObject("onekey_upgrade_btn")
    self.full_bg_light = self:findGameObject("full_bg_light")

    --local UI_MysticUp_SetTing01 = self:findGameObject("UI_MysticUp_SetTing01")
    --self:setParticleRenderOrder(UI_MysticUp_SetTing01)
    self.UI_Advanced_ComMon_001 = self:findGameObject("UI_Advanced_ComMon_001")
    self:setParticleRenderOrder(self.UI_Advanced_ComMon_001)
end

function M:onEnter()  
    self:refreshUI()
end

function M:refreshUI()
    self.UI_Advanced_ComMon_001:SetActive(self.m_model.m_need_count > 0 and self.m_model.m_need_count == #self.m_model.m_select)
    self.full_bg_light:SetActive(self.m_model.m_need_count > 0 and self.m_model.m_need_count == #self.m_model.m_select)
    local onekey_type = self.m_model:getOneKeyData()
    if onekey_type then
        self.onekey_upgrade_btn:SetActive(true)
        local img_name = onekey_type == 1 and "cjg_canwu_btn_ren" or "cjg_canwu_btn_shu" 
        local btn_name = onekey_type == 1 and "mystic_str_0004" or "mystic_str_0014"
        self:setTextByLanKey("onekey_upgrade_btn_text", btn_name)
    else
        self.onekey_upgrade_btn:SetActive(false)
    end
    self:refreshSelectData()
    self:updateScroll()
end

function M:updateScroll()
    local data = self.m_model.m_list_data
    -- Logger.log(data,"data ====")
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("list_scroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            one_line_count = 5,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                local transform = cell_object.transform
                local data = cell_data
                self:setCellHander(cell_object, data, index)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                local oid = cell_data
                for i=1,self.m_model.m_need_count do
                    if self.m_model.m_select[i] == oid then
                        self:updateMsg("remove_mystic", {oid = oid})
                        return
                    end
                end
                self:updateMsg("select_mystic", {oid = oid, cell_obj = cell_object})
            end
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data)
    end
end

function M:setCellHander(obj, data, id)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local duigoudi_img = luaBehaviour:FindGameObject("duigoudi_img")
    local up_image = luaBehaviour:FindGameObject("up_image")
    local mystic_data, mystic_cfg = UserDataManager.mystic_data:getMysticDataById(data)
    GameUtil:updateItemElement(obj, {RewardUtil.REWARD_TYPE_KEYS.MYSTIC, mystic_data.id, mystic_data.evo, oid = data}, false, false)
    local flag = self.m_model:isSelected(data)
    duigoudi_img:SetActive(flag)
    if self.m_model.m_select[1] == data then
        LuaBehaviourUtil.setImg(luaBehaviour, "duigou_img", "a_ui_gou_ye", "common_ui")
    else
        LuaBehaviourUtil.setImg(luaBehaviour, "duigou_img", "a_ui_gou_lv", "common_ui")
    end
    up_image:SetActive(flag == false and self.m_model.m_recommend_id == mystic_data.id)
    --local count_text = luaBehaviour:FindGameObject("count_text")
    --count_text:SetActive(true)
    --luaBehaviour:FindText("count_text").text = mystic_data.id
end

function M:refreshSelectData()
    if self.m_control.m_model.m_need_count > 0 then
        self.select_panel:SetActive(true)
        for i=1,3 do
            local trans = self:findGameObject(string.format("select%d_panel", i)).transform
            trans.gameObject:SetActive(true)
            UIUtil.destroyAllChild(trans)
            if self.m_control.m_model.m_select[i] then
                local oid = self.m_control.m_model.m_select[i]
                local data, cfg = UserDataManager.mystic_data:getMysticDataById(oid)
                local icon = GameUtil:createItemElement({RewardUtil.REWARD_TYPE_KEYS.MYSTIC,data.id,data.evo, oid = oid}, false, false, function ()
                    self:updateMsg("remove_mystic",{oid = oid})
                end)
                icon.transform:SetParent(trans, false)
                local luaBehaviour = icon:GetComponent("LuaBehaviour")
                if self.m_model.upgrade_anim_slot == i then
                    self.m_model.upgrade_anim_slot = nil
                    local slot_anim = ResourceUtil:GetUIEffectItem("Mystic/UI_MysticUsePanel_ChuFa_001", icon)
                    --slot_anim.transform:SetParent(icon.transform, false)
                    self:setParticleRenderOrder(slot_anim)
                end
            else
                local icon = GameUtil:createItemElement({RewardUtil.REWARD_TYPE_KEYS.MYSTIC,0,1}, false, false)
                icon.transform:SetParent(trans, false)
                GameUtil:updateItemElementNoData(icon, RewardUtil.REWARD_TYPE_KEYS.MYSTIC)
                -- UIUtil.setOpacity(icon.transform, 0.5)
                local luaBehaviour = icon:GetComponent("LuaBehaviour")
                local quality_item = GlobalConfig.QUALITY_MYSTIC_SETTING[self.m_model.m_need_evo] or GlobalConfig.QUALITY_MYSTIC_SETTING[1]
                LuaBehaviourUtil.setImg(luaBehaviour,"no_quality_img", quality_item.frame_name, "equip_icon")
                local no_quality_up_img = luaBehaviour:FindGameObject("no_quality_up_img")
                no_quality_up_img:SetActive(quality_item.is_add)
            end
        end
    else
        for i=1,3 do
            local trans = self:findGameObject(string.format("select%d_panel", i)).transform
            UIUtil.destroyAllChild(trans)
        end
    end
end

function M:upgradeAnimation()
    local animator = self:findGameObject("UI_MysticUp_hecheng"):GetComponent("Animator")
    animator:CrossFade("MysticUpgradePanel",0)
end

function M:resetUpgradeAnimation()
    local animator = self:findGameObject("UI_MysticUp_hecheng"):GetComponent("Animator")
    animator:CrossFade("idle",0)
end

return M