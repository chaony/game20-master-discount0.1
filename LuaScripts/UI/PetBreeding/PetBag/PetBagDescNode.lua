---@class PetBagDescNode: OOUIbase
---@field m_model PetBagModel
local M = class("PetBagDescNode", LikeOO.OOUIbase)

M.m_uiName = "PetBreeding/PetBagDescNode"

local TAB_BTN_NODE = {
    { btn_key = "tog_1", lua_name = "UI.PetBreeding.PetBag.PetBagAttributeNode", text_name = "tog_1_text", text_key = "pet_bag_text_0002", red_point_img = "tog_1_red_point_img" }, -- 属性
    { btn_key = "tog_2", lua_name = "UI.PetBreeding.PetBag.PetBagSkillNode", text_name = "tog_2_text", text_key = "pet_bag_text_0003", red_point_img = "tog_2_red_point_img" }, -- 技能
}

function M:onEnter()
    self.m_content_panel = self:findGameObject("content_panel")
    self.m_toggle_btns = {}
    for k, v in pairs(TAB_BTN_NODE) do
        self:setTextByLanKey(v.text_name, v.text_key)
        local tog_btn = self:findToggle(v.btn_key)
        self.m_toggle_btns[k] = tog_btn
        UIUtil.addToggleListener(tog_btn, function(is_on)
            self:switchTabUpdate(is_on, k)
        end, nil, self.m_uiName)
        self:setObjectVisible(v.red_point_img, false)
        self:switchTabUpdate(true, 1)
    end
    local isEgg = self.m_model:checkIsEgg(self.m_model.m_sel_pet_oid)
    self:setObjectVisible("tog2_lock", isEgg)
end

function M:InitType(c_type, first)
    if c_type == 1 then
        local move_x = self.m_model:getCurMoveX(877.5, self.m_control.m_view.m_view_width)
        if first == false then
            local callback = function()
                self.m_rt.gameObject:SetActive(false)
            end
            GameUtil:dotweenMoveX(self.m_rt.gameObject, move_x)
        else
            self.m_rt.localPosition = Vector3.New(move_x, 0, 0)
        end
    elseif c_type == 2 then
        self.m_rt.gameObject:SetActive(true)
        local move_x = self.m_model:getCurMoveX(377.5, self.m_control.m_view.m_view_width)
        if first == false then
            GameUtil:dotweenMoveX(self.m_rt.gameObject, move_x)
        else
            self.m_rt.localPosition = Vector3.New(move_x, 0, 0)
        end

    end
end

function M:switchTabUpdate(is_on, update_key)
    if is_on then
        self:updateMsg(update_key)
    end
end

function M:changeTab(index)
    for k, v in pairs(self.m_toggle_btns) do
        self.m_toggle_btns[k].isOn = k == index
    end
end

function M:switchTabNode(index)
    if self.m_cur_tab_node then
        self.m_cur_tab_node:destroy()
        self.m_cur_tab_node = nil
    end
    local btn_tab = TAB_BTN_NODE[index]
    for k, v in pairs(TAB_BTN_NODE) do
        local tog_text = self:findText(v.text_name)
        if index == k then
            tog_text.color = Color(255 / 255, 255 / 255, 255 / 255)
        else
            tog_text.color = Color(143 / 255, 147 / 255, 156 / 255)
        end
    end
    if btn_tab then
        local tab_cls = CustomRequire(btn_tab.lua_name)
        self.m_cur_tab_node = tab_cls.new(self.m_control, { parent = self.m_content_panel })
    end
end

function M:setShowQuickLevelUp(lv)
    if self.m_cur_tab_node and self.m_model.m_sel_tab_index == 1 then
        self.m_cur_tab_node:setShowQuickLevelUp(lv)
    end
end

function M:refreshUI()
    if self.m_cur_tab_node then
        self.m_cur_tab_node:refreshUI()
    end
    local isEgg = self.m_model:checkIsEgg(self.m_model.m_sel_pet_oid)
    self:setObjectVisible("tog2_lock", isEgg)
end

function M:updateBtnState()
    if self.m_model.m_sel_tab_index == 1 then
        self.m_cur_tab_node:updateBtnState()
    end
end

function M:updateTime()
    if self.m_model.m_sel_tab_index == 1 and self.m_cur_tab_node then
        self.m_cur_tab_node:updateTime()
    end
end

function M:refreshSelectInfo()
    if self.m_cur_tab_node then
        if self.m_model.m_sel_tab_index == 1 then
            self.m_cur_tab_node:refreshAttributeInfo()
        elseif self.m_model.m_sel_tab_index == 2 then
            self.m_cur_tab_node:refreshSkillInfo()
        end

    end
end


function M:refreshLevelUpUI()
    if self.m_cur_tab_node and self.m_model.m_sel_tab_index == 1 then
        self.m_cur_tab_node:playLvUpEffect()
    end
end

function M:destroy()
    if self.m_cur_tab_node then
        self.m_cur_tab_node:destroy()
        self.m_cur_tab_node = nil
    end
    M.super.destroy(self)
end

return M