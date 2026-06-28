---@class PetBagSkillNode: OOUIbase
---@field m_model PetBagModel
local M = class("PetBagSkillNode", LikeOO.OOUIbase)

M.m_uiName = "PetBreeding/PetBagSkillNode"

local Skill = {
    { skill_level_img = "skill_level_img1", text_num = "talent_hp_num" }, --生命
    { text_name = "talent_attack_text", text_num = "talent_attack_num" }, -- 攻击
    { text_name = "talent_def_text", text_num = "talent_def_num" }, -- 防御
    { text_name = "talent_anger_text", text_num = "talent_anger_num" }, -- 气势
}

function M:onEnter()
    self:bindUI()
    self:refreshUI()
end

function M:bindUI()
    self:setTextByLanKey("skill_num_title", "pet_bag_text_0016")
    self:setTextByLanKey("skill_text", "pet_bag_text_0003")
    self:setTextByLanKey("reset_btn_text", "pet_bag_text_0009")
    self:setTextByLanKey("no_skill_tips", "pet_bag_text_0022")
    self.m_calc_desc_text = self:findText("calc_desc_text")
    self.m_calc_desc_rt = self:findRectTransform("calc_desc_text")
    self.m_cell_rt = self:findRectTransform("cell")
    self.m_content_rt = self:findRectTransform("Content")
    local gray_img = self:findImage("lock_img1")
    self.m_gray_material = gray_img.material
    local normal_img = self:findImage("combat_img")
    self.m_normal_material = normal_img.material
end

function M:refreshUI()
    self:refreshSkillList()
    self:refreshSkillLoopScroll()
    self:refreshText()
end

function M:refreshText()
    local skillsNum = self.m_model:getOwnSkillNum()
    local combat = self.m_model:getCurCombat()
    self:setText("skill_num_text", skillsNum)
    self:setText("combat_text", GameUtil:formatValueToString(combat))
end

function M:refreshSkillList()
    local killer_skill_data = self.m_model:getKillerSkillCfg()
    local help_skill_data = self.m_model:getHelpSkillCfg()
    local isLock = false
    for i = 1, 2 do
        if i == 1 then
            --必杀技
            isLock = killer_skill_data.isLock
            self:setImg(killer_skill_data.type_bg, "main_ui2", "skill_type_img1")
            self:setTextByLanKey("Killer_skills_1", "pet_bag_text_0022")
            local skill_img = self:setImg(killer_skill_data.skill_img, "skill_icon", "skill_img1")
            self:setImg(killer_skill_data.quality_bg, "main_ui2", "skill_level_img1")
            self:setObjectVisible("skill_lock_img1", killer_skill_data.isLock)
            self:setObjectVisible("killer_skills_img1", true)
            self:setText("skill_type_text1", killer_skill_data.type_text)
            skill_img.material = isLock and self.m_gray_material or self.m_normal_material
        else
            --协站技
            isLock = help_skill_data.isLock
            self:setObjectVisible("no_skill" ..i, isLock)
            self:setObjectVisible("skill" ..i, not isLock)
            if isLock then
                self:setImg(help_skill_data.skill_img, "skill_icon", "noskill_img" ..i)
                break
            end
            self:setImg(help_skill_data.type_bg, "main_ui2", "skill_type_img" .. i)
            local skill_img = self:setImg(help_skill_data.skill_img, "skill_icon", "skill_img" .. i)
            self:setImg(help_skill_data.quality_bg, "main_ui2", "skill_level_img" .. i)
            self:setObjectVisible("killer_skills_img" .. i, false)
            self:setText("skill_type_text" .. i, help_skill_data.type_text)
        end

    end
end

function M:refreshSkillLoopScroll()
    local data = self.m_model:getCurSkillList()
    if #data <= 0 or not self.m_model.m_sel_pet_oid then
        self:setObjectVisible("no_skill_tips", true)
        self:setObjectVisible("skill_loopscroll", false)
        return
    end
    self:setObjectVisible("no_skill_tips", false)
    self:setObjectVisible("skill_loopscroll", true)
    self.m_calc_desc_text.gameObject:SetActive(true)
    self.m_all_cell_size = self:calcCellSize(data)
    self.m_calc_desc_text.gameObject:SetActive(false)
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("skill_loopscroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            loop_scroll_object = loopscroll,
            all_cell_size = self.m_all_cell_size,
            update_cell = function(index, cell_object, cell_data)
                self:updateScrollViewCell(index, cell_object, cell_data, self.m_all_cell_size)
            end,
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data, false, self.m_all_cell_size)
    end
end

function M:updateScrollViewCell(index, cell_object, cell_data, all_cell_size)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    local pet_skill_id = cell_data
    local data = self.m_model:getSkillDataByPetSkill(pet_skill_id)
    if not data then
        return
    end
    local skill_bg = GameUtil:getPetSkillBg(pet_skill_id)
    LuaBehaviourUtil.setImg(luaBehaviour, "skill_type_img", skill_bg, "main_ui2")
    local cell_size = all_cell_size[index]
    local cur_cell_rt = cell_object.transform
    cur_cell_rt.sizeDelta = Vector2(self.m_cell_rt.rect.width, cell_size.y)
    LuaBehaviourUtil.setText(luaBehaviour, "skill_name_text", data.name_text)
    LuaBehaviourUtil.setText(luaBehaviour, "skill_desc_text", data.desc_text)
    LuaBehaviourUtil.setText(luaBehaviour, "skill_type_text", data.type_text)
end

function M:calcCellSize(ids)
    local all_cell_size = {}
    local desc = ""
    local height = 0
    local cell_width = self.m_cell_rt.rect.width
    for k, v in ipairs(ids) do
        desc = self.m_model:getDescByPetSkillId(v)
        self.m_calc_desc_text.text = desc
        self.m_calc_desc_rt:GetComponent("ContentSizeFitter"):SetLayoutVertical()
        height = self.m_calc_desc_rt.rect.height
        all_cell_size[k] = Vector2(cell_width, height)
    end
    return all_cell_size
end

function M:onButtonClick(obj, name)
    if name == "skill_img1" then
        local click_transform = self:findRectTransform("skill_img1")
        self:updateMsg("skill_click", { type = 1, click_transform = click_transform })
    elseif name == "skill_img2" then
        local click_transform = self:findRectTransform("skill_img2")
        self:updateMsg("skill_click", { type = 2, click_transform = click_transform })
    elseif name == "no_skill2" then
        local pop_transform = self:findRectTransform("no_skill_pop_pos")
        self:updateMsg("no_skill2", {click_transform = pop_transform })
    else
        M.super.onButtonClick(self, obj, name)
    end
end
function M:destroy()
    M.super.destroy(self)
end

return M
