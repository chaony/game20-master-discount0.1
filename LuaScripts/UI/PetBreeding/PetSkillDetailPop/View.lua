---@class PetSkillDetailPopView: OOPopBase
---@field m_model PetSkillDetailPopModel
local M = class("PetSkillDetailPopView", LikeOO.OOPopBase)

M.m_uiName = "PetBreeding/PetSkillDetailPop"
M.m_size_type = 2

function M:onEnter()
    self:initUI()
    self:refreshUI()
end

function M:initUI()
    
    self:setTextByLanKey("common_title_text", "pet_bag_text_0038")
    self:setTextByLanKey("title_text", "pet_bag_text_0006", self.m_model:getPetName())
    self.m_calc_desc_text = self:findText("calc_desc_text")
    self.m_calc_desc_rt = self:findRectTransform("calc_desc_text")
    local cell_rt = self:findRectTransform("cell")
    self.m_cell_width = cell_rt.rect.width
    local title_rt = self:findRectTransform("title_node")
    self.m_cell_extra_height = title_rt.rect.height
    self.m_group_ids = self.m_model:getGroupList()
    local data
    for i = 1, 6 do
        data = self.m_model:getLeftSkillDataByGroupId(self.m_group_ids[i])
        self:setImg(data.img, "skill_icon", "skill_img" .. i)
        self:setObjectVisible("skill_mask" .. i, not data.isOwn)
        self:setObjectVisible("strengthen_bg" .. i, data.type == 1 and not data.isKillerSkill)
        self:setText("skill_type_text" .. i, data.type_text)
        if data.type == 1 then
            self:setText("strengthen_text" .. i, data.strengthen_text)
        end
    end
end

function M:refreshUI()
    self:refreshSelect()
    self:refreshSkillLoopScroll()
end

function M:refreshSelect()
    local index = self.m_model.m_curIndex
    for i = 1, 6 do
        self:setObjectVisible("skill_select" .. i, i == index)
    end
end

function M:refreshSkillLoopScroll()
    local cur_group_id = self.m_group_ids[self.m_model.m_curIndex]
    local data = self.m_model:getSkillDataByGroupId(cur_group_id)
    self.m_calc_desc_text.gameObject:SetActive(true)
    self.all_cell_size = self:calcCellSize(data)
    self.m_calc_desc_text.gameObject:SetActive(false)
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("skill_loopscroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            all_cell_size = self.all_cell_size,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateScrollViewCell(index, cell_object, cell_data, self.all_cell_size)
            end,
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data, false, self.all_cell_size)
    end
end

function M:calcCellSize(data)
    local all_cell_size = {}
    local desc = ""
    local height = 0
    for k, v in ipairs(data) do
        desc = Language:getTextByKey(v.skill_des) 
        self.m_calc_desc_text.text = desc
        self.m_calc_desc_rt:GetComponent("ContentSizeFitter"):SetLayoutVertical()
        height = self.m_calc_desc_rt.rect.height
        all_cell_size[k] = Vector2(self.m_cell_width, height + self.m_cell_extra_height + 5)
    end
    return all_cell_size
end

function M:updateScrollViewCell(index, cell_object, cell_data, all_cell_size)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    local cell_size = all_cell_size[index]
    local cur_cell_rt = cell_object.transform
    cur_cell_rt.sizeDelta = Vector2(cell_size.x, cell_size.y)
    local des = ""
    local name = ""
    local quality_bg = self.m_model:getSkillQualityBg(cell_data.quality)
    LuaBehaviourUtil.setImg(luaBehaviour, "quality_img", quality_bg, "main_ui2")
    if cell_data.skill_jump == 1 then
        local skill_cfg = ConfigManager:getCfgByName("skill_detail")
        if skill_cfg[cell_data.skill_id] then
            name = Language:getTextByKey(skill_cfg[cell_data.skill_id].name)
        end
    else
        name =  Language:getTextByKey("pet_bag_text_0042", Language:getTextByKey(cell_data.name_dictionary)) 
    end
    des = Language:getTextByKey(cell_data.skill_des)
    LuaBehaviourUtil.setText(luaBehaviour, "skill_name_text", name)
    LuaBehaviourUtil.setText(luaBehaviour, "skill_desc_text", des)
    U3DUtil.Get_LayoutRebuilder().ForceRebuildLayoutImmediate(cur_cell_rt)
end

return M
