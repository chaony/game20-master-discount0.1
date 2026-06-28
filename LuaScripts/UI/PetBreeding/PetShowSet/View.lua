---@class PetShowSetView: OOPopBase
---@field m_model PetShowSetModel
local M = class("PetShowSetView", LikeOO.OOPopBase)

M.m_uiName = "PetBreeding/PetShowSet"
M.m_size_type = 1

function M:onEnter()
    self:setTextByLanKey("common_title_text", "pet_bag_text_0101")
    self:setTextByLanKey("show_text", "pet_bag_text_0102")
    self:refreshUI()
end

function M:refreshUI()
    for i=1, self.m_model.m_show_num do
        local obj = self:findGameObject("pet_cell" .. i)
        local luaAnimator = obj:GetComponent("LuaBehaviour")
        local pet_oid = self.m_model:getViewPetByIndex(i)
        if pet_oid and pet_oid ~= "" then
            local pet_obj = LuaBehaviourUtil.setObjectVisible(luaAnimator,"pet_cell", true)
            LuaBehaviourUtil.setObjectVisible(luaAnimator,"no_panel", false)
            local pet_cell = luaAnimator:FindGameObject("pet_cell")
            local pet_data = UserDataManager.pet_data:getPetDataById(pet_oid)
            if pet_data then
                local reward_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.PETS, pet_data.id, 1, pet_oid})
                GameUtil:updatePetElement(pet_cell, reward_data, true, true)
            end
            local pet_luaAnimator = pet_obj:GetComponent("LuaBehaviour")
            pet_luaAnimator:RegistButtonClick(function()
                self:updateMsg("set_down", i)
            end)
        else
            LuaBehaviourUtil.setObjectVisible(luaAnimator,"pet_cell", false)
            LuaBehaviourUtil.setObjectVisible(luaAnimator,"no_panel", true)
        end
    end
    self:updateLoopScroll()
end

function M:updateLoopScroll()
    local data = self.m_model:getList()
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            ui_name = self.m_uiName,
            one_line_count = 4,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateItem(cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("click_cell", cell_data)
            end,
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data)
        if self.m_control.m_load_end == true then
            self:pullRefreshListOffset()
        end
    end
end

function M:updateItem(obj, data)
    local luaAnimator = obj:GetComponent("LuaBehaviour")
    local pet_cell = luaAnimator:FindGameObject("pet_cell")
    local reward_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.PETS, data.id, 1, data.oid})
    GameUtil:updatePetElement(pet_cell, reward_data, true, true)
    LuaBehaviourUtil.setObjectVisible(luaAnimator, "select_img", data.is_view)
end

return M