---@class DeliciousFeastCookView: OOPopBase
---@field m_model DeliciousFeastCookModel
local M = class("DragonBoatCookView", LikeOO.OOPopBase)

M.m_uiName = "Activities/DragonBoat/DragonBoatCook"
M.m_size_type = 1
M.m_iphoneXAdapter = true

local Item_Node = {
    { index = 1,table_id = 1, parent_transform = "item1", select_show_go = "fire1", name_text = "name_text1", make_text = "num_text1" },
    { index = 2,table_id = 2, parent_transform = "item2", select_show_go = "fire2", name_text = "name_text2", make_text = "num_text2" },
    { index = 3,table_id = 3, parent_transform = "item3", select_show_go = "fire3", name_text = "name_text3", make_text = "num_text3" },
    { index = 4,table_id = 4, parent_transform = "item4", select_show_go = "fire4", name_text = "name_text4", make_text = "num_text4" }

}

function M:onEnter()
    self:bindUI()
    self:refreshUI()
end

function M:bindUI()
    self:setObjectVisible("menu_node", self.m_model:checkIsOfficial())
    self:setTextByLanKey("close_title_text", "feast_text_0002")
    self:setTextByLanKey("menu_btn_text", "feast_text_0014")
    --local isOfficial = self.m_model:checkIsOfficial()
    --local spine_name = self.m_model:getSpineName()
    --local spine_img
    --if isOfficial then
    --    spine_img = self:findGameObject("meituan_spine")
    --    GameUtil:updateSpineLoadSet(spine_img,"RoleSpine/" .. spine_name.meituan,"idle", 0,true)
    --else
    --    spine_img = self:findGameObject("hero_spine")
    --    GameUtil:updateSpineLoadSet(spine_img,"RoleSpine/" .. spine_name.xian,"idle", 0,true)
    --end
end

function M:refreshUI()
    local targetData = self.m_model:getTargetData()
    local targetNum = self.m_model:getTargetMaxNums()
    for k, v in pairs(Item_Node) do
        local itemData = targetData[v.index]
        self:setTextByLanKey(v.name_text, itemData.name)     
        self:setImg(itemData.icon_name, itemData.atlas_name, v.parent_transform)
        local num = targetNum[v.index]
        self:setTextByLanKey(v.make_text, "feast_text_0012", num)
        self:setObjectVisible(v.select_show_go, num > 0)
    end
end



function M:refreshCookItem()
    --可能有重复材料 全刷
    local targetNum = self.m_model:getTargetMaxNums()
    self:setTextByLanKey("v.make_text", "feast_text_0012", num)
    for k, v in pairs(Item_Node) do
        local num = targetNum[v.index] or 0
        self:setTextByLanKey(v.make_text, "feast_text_0012", num)
        self:setObjectVisible(v.select_show_go, num > 0)
    end
end

function M:destroy()
    self.m_control:updateMsg("refreshRedPoint", nil, "Activities.DeliciousFeast.DeliciousFeastMain")
    M.super.destroy(self)
end

return M