---@class DeliciousFeastCookPopView: OOPopBase
---@field m_model DeliciousFeastCookPopModel
local M = class("DeliciousFeastCookPopView", LikeOO.OOPopBase)

M.m_uiName = "Activities/DeliciousFeast/DeliciousFeastCookPop"
M.m_size_type = 2

function M:onEnter()
    self:refreshUI()
end

function M:refreshUI()
    local target_data = self.m_model:getTargetItemData()
    local material_data = self.m_model:getMaterialItemData()
    self:setImg(target_data.icon_name, target_data.atlas_name, "icon_node")

    self:setTextByLanKey("common_title_text", "feast_text_0014")
    self:setTextByLanKey("once_btn_text", "feast_text_0015")
    self:setTextByLanKey("all_btn_text", "feast_text_0016")
    self:setTextByLanKey("item_name_text", target_data.name)
    self:setTextByLanKey("des_text", target_data.story)
    self.m_cook_once_img = self:findImage("cook_once_btn")
    self.m_cook_all_img = self:findImage("cook_all_btn")
    self.m_gray_img = self:findImage("gray_img")
    self:setImgGray()
    self:refreshLoopScrollList()
end

function M:setImgGray()
    if not self.m_model:checkCanCook() then
        self.m_cook_once_img.material = self.m_gray_img.material
        self.m_cook_all_img.material = self.m_gray_img.material
    end
end

function M:refreshLoopScrollList()
    local material_data = self.m_model:getMaterialItemData()
    if self.loopscroll == nil then
        self.loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = material_data,
            loop_scroll_object = self.loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateScrollViewCell(index, cell_object, cell_data)
            end,
        }
        self.task_loopscroll = LoopScrollViewUtil.new(params)
    else
        self.task_loopscroll:reloadData(material_data, false)
    end

end

function M:updateScrollViewCell(index, cell_object, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    local item_data = RewardUtil:getProcessRewardData(cell_data)
    local item_parent = luaBehaviour:FindRectTransform("itemIcon")
    if item_data then
        GameUtil:createRewards(item_parent, { cell_data  }   , true, true, nil, 1)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "have_text", Language:getTextByKey("feast_text_0017", item_data.user_num))
        --LuaBehaviourUtil.setImg(luaBehaviour, "itemIcon", item_data.icon_name, item_data.atlas_name)
    end
  

end
function M:destroy()
    M.super.destroy(self)
end

return M