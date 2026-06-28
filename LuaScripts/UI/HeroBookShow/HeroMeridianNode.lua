--- 经脉
local M = class("HeroMeridianNode",LikeOO.OOUIbase)

M.m_uiName = "HeroBookShow/HeroMeridianNode"
M.m_iphoneXAdapter = true

function M:onEnter()
    self:refreshUI()    
end

function M:refreshUI()
    self:updateSkill()
    self:setPass()
    local atr_1, atr_2 = self.m_model:getMeridianAttrs()
    self:updateLoopScroll(atr_1, atr_2)
    if self.m_model:checkMaxSig() == true then
        self:setObjectVisible("activate_btn", false)
        self:setObjectVisible("icon_node", false)
        self:setObjectVisible("intensify_btn", false)
    end
    if self.m_model:getSigLv() >= 30 then
        GameUtil:setLanImgText(self:findRectTransform("left_title_img"), "a_jm_dacheng")
        self:setImg("a_jm_dacheng_yuan_2","hero_ui","center_bg_img")
        self:setImg("a_jm_dacheng_yuan_3","hero_ui","center_bg_img2")
        self:setImg("a_jm_dacheng_renwu","hero_ui","center_img")
    elseif self.m_model:getSigLv() >= 20 then
        GameUtil:setLanImgText(self:findRectTransform("left_title_img"), "a_jm_ronghui")
        self:setImg("a_jm_ronghui_yuan_2","hero_ui","center_bg_img")
        self:setImg("a_jm_dacheng_yuan_3","hero_ui","center_bg_img2")
        self:setImg("a_jm_ronghui_renwu","hero_ui","center_img")
    else
        GameUtil:setLanImgText(self:findRectTransform("left_title_img"), "a_jm_renmai")
        self:setImg("a_jm_renmai_yuan_2","hero_ui","center_bg_img")
        self:setImg("a_jm_dacheng_yuan_3","hero_ui","center_bg_img2")
        self:setImg("a_jm_renmai_renwu","hero_ui","center_img")
    end
end

function M:updateSkill()
    if self.m_model.sig_cfg then
        self:setTextByLanKey("cur_name", "经脉圆满")
        local sig_data = self.m_model:checkSig()
        if sig_data then
            self:setTextByLanKey("cur_skill_desc", sig_data.des1)
            self:setTextByLanKey("progress1_desc", sig_data.des2)
            self:setTextByLanKey("progress2_desc", sig_data.des3)
            self:setTextByLanKey("progress3_desc", sig_data.des4)
        end
        self:setTextByLanKey("progress1_name", "任脉圆满")
        self:setTextByLanKey("progress2_name", "督脉圆满")
        self:setTextByLanKey("progress3_name", "融会贯通")
        if self.m_model:getSigLv() >= 10 then
            self:setImg("a_ui_shuzhi_di","common_ui","progress_1")
        else
            self:setImg("a_ui_shuzhihui_di","common_ui","progress_1")
        end
        if self.m_model:getSigLv() >= 20 then
            self:setImg("a_ui_shuzhi_di","common_ui","progress_2")
        else
            self:setImg("a_ui_shuzhihui_di","common_ui","progress_2")
        end
        if self.m_model:getSigLv() >= 30 then
            self:setImg("a_ui_shuzhi_di","common_ui","progress_3")
        else
            self:setImg("a_ui_shuzhihui_di","common_ui","progress_3")
        end
    end
end

function M:setPass()
    self.pass = self:findGameObject("pass")
    local num = self.pass.transform.childCount
	for i=1, num do
        local pass_cell = self.pass.transform:GetChild(i-1)
        local luaBehaviour = UIUtil.findLuaBehaviour(pass_cell)
        local cell_data = self.m_model:getPassNameByIndex(i - 1)
        if luaBehaviour then
            local pass_name = LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"pass_name", cell_data.lv_name)
        end
    end
    self.points = self:findGameObject("points")
    local point_num = self.points.transform.childCount
    for i=1, point_num do
        local point_cell = self.points.transform:GetChild(i-1)
        --已激活
        UIUtil.setImg(point_cell.transform,"a_jm_xuewei_now","hero_ui") 
        UIUtil:setLocalDelta(point_cell.transform,14,14)
    end
    ------------------------------------------------------

end

--[[	
	属性列表
]]
function M:updateLoopScroll(attrs, next_attrs)
    self:sort(attrs)
    local data = UserDataManager:appendAttrs(attrs)
    local data2
    if next_attrs ~= nil then
        data2 = UserDataManager:appendAttrs(next_attrs)
    end
	local tab = {}
    for i, v in pairs(data) do
        if next_attrs then
            table.insert(tab, {i, v, data2[i]})
        else
            table.insert(tab, {i, v, 0})
        end
    end
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("attr_loopscroll")
        local params = {
            show_data = tab,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:setProCell(cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                
            end
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(tab)
    end
end

function M:setProCell(obj, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        local cp = GameUtil:getAttrsName(data[1])
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "attr_name_text", cp)
        local attr_value = data[2] or 0
        attr_value = math.floor(attr_value * 10 + 0.5)/10
        local attr_value_text = LuaBehaviourUtil.setText(luaBehaviour, "num_1", tostring(attr_value))
        local attr_value2 = data[3] or 0
        attr_value2 = math.floor(attr_value2 * 10 + 0.5)/10
        local attr_value2_text = LuaBehaviourUtil.setText(luaBehaviour, "num_2", tostring(attr_value2))
        if attr_value2 == 0 then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "arrows_img", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "num_2", false)
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "arrows_img", true)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "num_2", true)
        end
    end
end

return M