---@class PetBagView: OOPopBase
---@field m_model PetBagModel
local M = class("PetBagView", LikeOO.OOPopBase)

M.m_uiName = "PetBreeding/PetBag"
M.m_size_type = 1
M.m_iphoneXAdapter = true

local TAB_BTN_NODE = {
    { name = "center", lua_name = "UI.PetBreeding.PetBag.PetBagPetNode" }, -- 宠物
    { name = "left", lua_name = "UI.PetBreeding.PetBag.PetBagListNode" }, -- 列表
    { name = "right", lua_name = "UI.PetBreeding.PetBag.PetBagDescNode" }, -- 详情
}

function M:onEnter()
    self:adaptScreen()
    self.m_content_panel = self:findGameObject("content_panel")
    self.m_hero_bag_bg = self:findGameObject("petBag_bg")
    self.m_attr_node = GameUtil:commonAttrNode(self.m_control, { mode = 38 })
    self.m_cur_tab_node = {}
    self:setTextByLanKey("close_title_text", "pet_bag_text_0001")
    for k, v in pairs(TAB_BTN_NODE) do
        local tab_cls = CustomRequire(v.lua_name)
        local temp_node = tab_cls.new(self.m_control, { parent = self.m_content_panel })
        temp_node:InitType(self.m_model.m_panel_type, true)
        self.m_cur_tab_node[v.name] = temp_node
    end
    UIUtil:registerDragEvent(self.m_ui_obj, handler(self, self.fingerSliding))
end

function M:adaptScreen()
    local bg_rt = self:findRectTransform("bg_obj")
    local rect = bg_rt.rect
    self.m_bg_scale_w = rect.width / GlobalConfig.UI_DESIGN_WIDTH
    self.m_bg_scale_h = rect.height / GlobalConfig.UI_DESIGN_HEIGHT
    self.m_bg_scale = math.max(self.m_bg_scale_w, self.m_bg_scale_h)
    local bg_rect_tran = self:findRectTransform("petBag_bg")
    UIUtil.setScale(bg_rect_tran, self.m_bg_scale)
end

function M:fingerSliding(locat)
    if locat then
        self:updateMsg("Sliding_right")
    else
        self:updateMsg("Sliding_left")
    end
end

function M:updateCurPetInfo()
    if self.m_cur_tab_node["right"] then
        self.m_cur_tab_node["right"]:refreshUI()
    end
end

function M:updateSelectPet(isClick)
    if self.m_cur_tab_node["center"] then
        self.m_cur_tab_node["center"]:refreshUI()
    end
    if self.m_cur_tab_node["right"] then
        self.m_cur_tab_node["right"]:refreshUI()
    end
    if self.m_cur_tab_node["left"] and not isClick then
        self.m_cur_tab_node["left"]:updateSelectPet()
    end
end

function M:switchType(type)
    if type == self.m_model.m_panel_type then
        return
    end
    self.m_model.m_panel_type = type
    for k, v in ipairs(TAB_BTN_NODE) do
        local node = self.m_cur_tab_node[v.name]
        if node then
            node:InitType(self.m_model.m_panel_type, false)
        end
    end
    if type == 2 then
        self:runAnim("HeroBag_bg_1")
    elseif type == 1 then
        self:runAnim("HeroBag_bg_2")
    end
end

function M:setDetailBtn(isShow)
    local cur_node = self.m_cur_tab_node["center"]
    if cur_node then
        cur_node:setDetailBtn(isShow)
    end
end

function M:changeDescTab(index)
    local cur_node = self.m_cur_tab_node["right"]
    if cur_node then
        cur_node:changeTab(index)
        cur_node:switchTabNode(index)
    end
end

function M:refreshUI(ref_tab_key)
    if ref_tab_key == nil then
        for k, v in ipairs(TAB_BTN_NODE) do
            local node = self.m_cur_tab_node[v.name]
            if node then
                node:refreshUI()
            end
        end
    else
        for k, v in pairs(self.m_cur_tab_node) do
            if ref_tab_key[k] then
                v:refreshUI()
            end
        end
    end
end

function M:refreshLevelUpUI()
    local right_node = self.m_cur_tab_node["right"]
    local center_node = self.m_cur_tab_node["center"]
    if right_node then
        right_node:refreshLevelUpUI()
    end
    if center_node then
        center_node:refreshLevelUpUI()
    end
end

function M:updateBtnState()
    if self.m_cur_tab_node["right"] and self.m_model.m_sel_tab_index == 1 then
        self.m_cur_tab_node["right"]:updateBtnState()
    end
end

function M:refreshRedPoint()
    for k, v in pairs(self.m_cur_tab_node) do
        if v.refreshRedPoint then
            v:refreshRedPoint()
        end
    end
end

function M:switchHeroTypeBtn()
    local cur_node = self.m_cur_tab_node["left"]
    if cur_node then
        cur_node:switchHeroBtnType()
    end
end

function M:sliderTop()
    local cur_node = self.m_cur_tab_node["left"]
    if cur_node and self.m_model.m_sel_tab_index == 1 then
        cur_node:sliderTop()
    end
end

function M:setShowQuickLevelUp(lv)
    local cur_node = self.m_cur_tab_node["right"]
    if cur_node and self.m_model.m_sel_tab_index == 1 then
        cur_node:setShowQuickLevelUp(lv)
    end
end

function M:updateTime()
    local eggs = self.m_model:getEggList()
    local curTime = UserDataManager:getServerTime()
    local endTime = 0
    for k, v in ipairs(eggs) do
        endTime = self.m_model:getEggEndTime(v)
        if endTime - curTime <= 0 then
            self:updateMsg("pet_egg_success", { oid = v, pos = k })
            table.remove(self.m_model.m_egg_list, k)
            break
        end
    end
    local cur_node = self.m_cur_tab_node["right"]
    if cur_node and self.m_model.m_sel_tab_index == 1 then
        cur_node:updateTime()
    end
    cur_node = self.m_cur_tab_node["left"]
    if cur_node then
        cur_node:updateTime()
    end
end

function M:showLvEffect()
    for k, v in ipairs(TAB_BTN_NODE) do
        local node = self.m_cur_tab_node[v.name]
        if node and node.showLvEffect then
            node:showLvEffect()
        end
    end
end

function M:playMoodEffect()
    if self.m_cur_tab_node["center"] then
        self.m_cur_tab_node["center"]:playMoodEffect()
    end
end

function M:destroy()
    for k, v in pairs(self.m_cur_tab_node) do
        v:destroy()
    end
    self.m_cur_tab_node = {}
    if self.m_attr_node then
        self.m_attr_node:destroy()
        self.m_attr_node = nil
    end
    M.super.destroy(self)
end

return M