---@class PetFactorySendPopView: OOPopBase
---@field m_model PetFactorySendPopModel
local M = class("PetFactorySendPopView", LikeOO.OOPopBase)

M.m_uiName = "PetBreeding/PetFactorySendPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

M.m_pet_scroll_view = nil

function M:onEnter()
    self:bindUI()
end

function M:bindUI()
    self:setTextByLanKey("common_title_text", "pet_factory_text_0007")
    self:setTextByLanKey("send_btn_text", "pet_factory_text_0013")
    self:setTextByLanKey("quick_send_btn_text", "pet_factory_text_0014")
    self:setTextByLanKey("sub_title_text", "pet_factory_text_0015")

    self:setPetList()

    self:refreshUI()
end

---设置宠物列表
function M:setPetList()
    local data = self.m_model:getList()
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            ui_name = self.m_uiName,
            one_line_count = 6,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updatePetItemCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("click_cell", cell_data)
            end,
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data, true)
    end
end

---刷洗宠物图标显示
function M:updatePetItemCell(index, cell_obj, cell_data)
    local luaBehaviour = cell_obj:GetComponent("LuaBehaviour")
    local reward_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.PETS, cell_data.id, 1, cell_data.oid})
    GameUtil:updatePetElement(cell_obj, reward_data, true, true)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_img", cell_data.isSelect)
end

---刷新界面
function M:refreshUI()
    print("[PetFactorySendPop][refreshUI]**************************************************")
    self:setPetList()
end

function M:destroy()
    M.super.destroy(self)
end

return M