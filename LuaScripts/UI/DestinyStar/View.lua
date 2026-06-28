local M = class("DestinyStarView",LikeOO.OOPopBase)

M.m_uiName = "DestinyStar/DestinyStar"
M.m_iphoneXAdapter = true

local DESTINY_STAR_TAB = {
    {id = 1,btn_name = "destiny_btn",img_bg = "Img_1",lua_name = "UI.DestinyStar.Destiny"},
    {id = 2,btn_name = "chemical_star_btn",img_bg = "Img_2",lua_name = "UI.DestinyStar.ChemicalStar"},
    {id = 3,btn_name = "master_btn",img_bg = "Img_3",lua_name = "UI.DestinyStar.MasterNode", open_id = 317}
}


--天命化星
function M:onEnter()
    self.destiny_star = DESTINY_STAR_TAB
    --local bg = self:findGameObject("Image_bg")
    self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 27})
    self:setTextByLanKey("close_title_text","destinyStar_text_0001")
    self.parent_obj = self:findGameObject("parent_obj")
    self:switchTabNode(self.m_model.current_mode)
    self:refreshUI()
    self:switchModel()
end

--刷新UI
function M:refreshUI()
    if self.m_cur_tab_node then
        self.m_cur_tab_node:refreshUI()
    end 
end

--刷新领悟动画
function M:setDerstand()
    if self.m_cur_tab_node then
        self.m_cur_tab_node:setDerstand()
    end
end


--刷新页面内容
function M:switchTabNode(index)
    local btn_node = self:getTagCfg(index)
    if self.m_cur_tab_node then
        self.m_cur_tab_node:destroy()
        self.m_cur_tab_node = nil
    end
    if btn_node and #btn_node.lua_name > 0 then
        local tab_cls = CustomRequire(btn_node.lua_name)
        self.m_cur_tab_node = tab_cls.new(self.m_control, {parent = self.parent_obj})
    end
end

--刷新模式按钮
function M:switchModel()
    local destiny_light = false
    local chemical_star_light = false
    local master_light = false
    for i, v in ipairs(self.destiny_star) do
        self:setObjectVisible("Img_" .. v.id, false)
        if v.open_id then
            local show_flag = BtnOpenUtil:isBtnOpen(v.open_id)
            self:setObjectVisible(v.btn_name,  show_flag)
        end
    end
    destiny_light = self.m_model.current_mode == 1
    chemical_star_light = self.m_model.current_mode == 2
    master_light = self.m_model.current_mode == 3
    self:setObjectVisible("Img_" .. self.m_model.current_mode, true)
    self:setObjectVisible("destiny_light", destiny_light)
    self:setObjectVisible("destiny_light_no", not destiny_light)
    self:setObjectVisible("chemical_star_light", chemical_star_light)
    self:setObjectVisible("chemical_star_light_no", not chemical_star_light)
    self:setObjectVisible("master_light", master_light)
    self:setObjectVisible("master_light_no", not master_light)
end

--获取列表数据
function M:getTagCfg(id)
    for i, v in ipairs(self.destiny_star) do
        if v.id == id then
            return v
        end
    end
end

--设置点击遮罩
function M:setMaskImg(status)
    self:setObjectVisible("mask_img",status)
end

function M:destroy()
    if self.m_cur_tab_node then
        self.m_cur_tab_node:destroy()
        self.m_cur_tab_node = nil
    end
    if self.m_attr_node then
        self.m_attr_node:destroy()
        self.m_attr_node = nil
    end
    M.super.destroy(self)
end

return M