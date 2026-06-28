---@class PetEvolvePreviewView: OOPopBase
---@field m_model PetEvolvePreviewModel
local M = class("PetEvolvePreviewView", LikeOO.OOPopBase)

M.m_uiName = "PetBreeding/PetEvolvePreview"
M.m_size_type = 2


function M:onEnter()
    self:setTextByLanKey("common_title_text", "pet_evo_lv_0006")
    self:refreshUI()
    self:refreshLeftUI()
end

function M:refreshUI()
    local master_data,master_cfg =self.m_model:getPetDataById(self.m_model.m_main_id)
    local second_data,second_cfg =self.m_model:getPetDataById(self.m_model.m_sec_id)
    
    self:setObjectVisible("jiantou_1", #master_data.skills >= 2)
    self:setObjectVisible("jiantou_2", #second_data.skills >= 2)
    self:updateSkill1LoopScroll(master_data.skills)
    self:updateSkill2LoopScroll(second_data.skills)
    self:setTextByLanKey("skill_text1", Language:getTextByKey("pet_evo_lv_0007").. Language:getTextByKey(master_cfg.name))
    self:setTextByLanKey("skill_text2", Language:getTextByKey("pet_evo_lv_0007").. Language:getTextByKey(master_cfg.name))
    local skill_num = #master_data.skills
    local in_herit_num =  #second_data.skills
    self:setTextByLanKey("total_text", Language:getTextByKey("pet_evo_lv_0008")..(skill_num+in_herit_num).."个")
    self:setTextByLanKey("inherit_text", Language:getTextByKey("pet_evo_lv_0009")..self.m_model.m_lock_skill_nums.."个")
end

function M:refreshLeftUI()
    local node1 = self:findGameObject("node1")
    local node2 = self:findGameObject("node2")
    GameUtil:createPetElement(self.m_model.m_main_id, node1.transform,true,true)
    GameUtil:createPetElement(self.m_model.m_sec_id, node2.transform,true,true)
    local pet_data,pet_cfg = UserDataManager.pet_data:getPetDataById(self.m_model.m_main_id)
end


function M:updateSkill1LoopScroll(data)
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("skill_loopscroll1")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:PreCell(cell_object,index,cell_data, true)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "lock_img" then
                    self:updateMsg("add_lock", cell_data)
                end
            end
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data,true)
    end
end

function M:updateSkill2LoopScroll(data)
    if self.m_loop_scroll_view2 == nil then
        local loopscroll = self:findGameObject("skill_loopscroll2")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:PreCell(cell_object,index,cell_data, false)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "lock_img" then
                    self:updateMsg("add_lock", cell_data)
                end
            end
        }
        self.m_loop_scroll_view2 = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view2:reloadData(data,true)
    end
end

function M:PreCell(cell_object, index, cell_data, is_main)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    if luaBehaviour then
        local random_cfg, skill_cfg = self.m_model:getMinLvByEvo(cell_data)
        local skill_des = Language:getTextByKey(random_cfg.skill_des)..(random_cfg.random_max == 1 and Language:getTextByKey("pet_evo_lv_0010") or "")
        local skill_type = random_cfg.type --:1=斗技技能 2=协战技能 3=根骨技能
        local type_name = ""
        if skill_type == 1 then
            type_name = Language:getTextByKey("pet_bag_text_0019") 
        elseif skill_type == 2 then
            type_name = Language:getTextByKey("pet_bag_text_0020")
        elseif skill_type == 3 then
            type_name = Language:getTextByKey("pet_bag_text_0021")    
        end
        --如果不需要跳转 就代表没有名称 只显示技能描述即可
        if random_cfg.skill_jump == 1 then --显示技能名称
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "skill_name_text", skill_cfg.name)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "skill_desc_text", skill_des)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "skill_type_text", type_name)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "n_name_obj", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "h_name_obj", true)
            LuaBehaviourUtil.setImg(luaBehaviour, "skill_img", skill_cfg.icon == "" and "JN_badao1" or skill_cfg.icon, "skill_icon")
        else --不显示技能名称
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "skill_desc_text2", skill_des)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "skill_type_text2", type_name)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "n_name_obj", true)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "h_name_obj", false)
        end
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_img", is_main == true and self.m_model.can_lock_skill_nums > 0)
        local h_cell_obj = luaBehaviour:FindGameObject("h_name_obj")
        local n_name_obj = luaBehaviour:FindGameObject("n_name_obj")
        if self.m_model:checkIsLick(cell_data) then
            LuaBehaviourUtil.setImg(luaBehaviour, "lock_img", "a_zbxl_jinsuo", "mystic_ui")
        else
            LuaBehaviourUtil.setImg(luaBehaviour, "lock_img", "a_zbxl_suo_open", "active_ui")  
        end
        if is_main == true and self.m_model.can_lock_skill_nums > 0 then
            UIUtil.setLocalPosition(h_cell_obj.transform,250)
            UIUtil.setLocalPosition(n_name_obj.transform,250)
        else
            UIUtil.setLocalPosition(h_cell_obj.transform,214)
            UIUtil.setLocalPosition(n_name_obj.transform,214)
        end
    end
end


function M:setNextItem(obj,oid)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        local pet_data,pet_cfg = UserDataManager.pet_data:getPetDataById(oid)
        LuaBehaviourUtil.setImg(luaBehaviour, "pet_icon", "a_ui_currency_dj_lan", "equip_icon")
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "pet_level_text","new_str_0075", 1)
        local generation_data  = GameUtil:getPetInfoByData(pet_data)
        LuaBehaviourUtil.setText(luaBehaviour, "pet_generation_text",generation_data.evo_text)
        LuaBehaviourUtil.setImg(luaBehaviour, "pet_generation_img", generation_data.evo_bg, "main_ui2")
        LuaBehaviourUtil.setImg(luaBehaviour, "pet_icon", pet_cfg.icon, "hero_head_ui")
    end  
end


function M:destroy()
    M.super.destroy(self)
end

return M
