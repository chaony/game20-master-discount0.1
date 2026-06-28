local M = class("YinTowerRestraintPopView",LikeOO.OOPopBase)

M.m_uiName = "YinTower/YinTowerRestraintPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
    local ke_data = self.m_model:getKeZhi()
    local beike_data = self.m_model:getBeiKe()
    local m_data = GlobalConfig.FIVE_ELEMENT_TYPE[self.m_model.m_cur_element]
    GameUtil:setLanImgText(self:findRectTransform("m_img"), m_data.img)
    if ke_data and beike_data then
        local k_data = GlobalConfig.FIVE_ELEMENT_TYPE[ke_data.enemy_type]
        local b_data = GlobalConfig.FIVE_ELEMENT_TYPE[beike_data.my_type]
        local atr_1 = self.m_model:getAttr(beike_data.param2[1])
        local atr_2 = self.m_model:getAttr(ke_data.param2[1])
        GameUtil:setLanImgText(self:findRectTransform("next_img"), k_data.img)
        GameUtil:setLanImgText(self:findRectTransform("last_img"), b_data.img)
        local show_attr_1 = Language:getTextByKey(atr_1.name) 
        local show_attr_2 = Language:getTextByKey(atr_2.name) 
        if beike_data.param2[1][1][2] == 1 then
            show_attr_1 = show_attr_1.." +"..beike_data.param2[1][3][2]
        else
            show_attr_1 = show_attr_1.." +"..(beike_data.param2[1][3][2]*100).."%"
        end
        if ke_data.param2[1][1][2] == 1 then
            show_attr_2 = show_attr_2.." +"..ke_data.param2[1][3][2]
        else
            show_attr_2 = show_attr_2.." +"..(ke_data.param2[1][3][2]*100).."%"
        end
        self:setText("ke_1", show_attr_1)
        self:setText("ke_2", show_attr_2)
        self:setObjectVisible("last_img", true)
        self:setObjectVisible("next_img", true)
        self:setObjectVisible("res_2", true)
        self:setObjectVisible("res_1", true)
        self:setObjectVisible("ke_1", true)
        self:setObjectVisible("ke_2", true)
    else
        self:setObjectVisible("last_img", false)
        self:setObjectVisible("next_img", false)
        self:setObjectVisible("res_2", false)
        self:setObjectVisible("res_1", false)
        self:setObjectVisible("ke_1", false)
        self:setObjectVisible("ke_2", false)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M