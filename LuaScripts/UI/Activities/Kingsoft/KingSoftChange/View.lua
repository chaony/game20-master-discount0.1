local M = class("KingSoftChangeView",LikeOO.OOPopBase)

M.m_uiName = "Activities/Kingsoft/KingsoftChangePop"
M.m_size_type = 2

function M:onEnter()
    self:setTextByLanKey("title_text", "kingsoft_text_0026")
    self:setTextByLanKey("sure_text", "new_str_0006")
    self:setTextByLanKey("cancel_text", "new_str_0007")
    self.input = self:findInputField('input')
    self.input.text = tostring(self.m_model.m_max_value) 
    for i = 1, 11 do
        if i < 4 then
            self:setTextByLanKey("title_text" .. i, "kingsoft_text_002" .. (6 + i))
            self:setTextByLanKey("name_text" .. i, "kingsoft_text_00" .. (29 + i))
        elseif i > 8 then
            self:setTextByLanKey("name_text" .. i, "kingsoft_text_00" .. (8 + i))
        else
            self:setTextByLanKey("name_text" .. i, "kingsoft_text_00" .. (29 + i))
        end
    end
    self:refreshUi()
end

function M:closeTips()
    self:setObjectVisible("tips_image", false)
    self:setObjectVisible("close_tips_btn", false)
end

function M:showTips(target_obj)
    local tips_cfg = self.m_model:getTipsCfgById(1)
    if tips_cfg then
        self:setTextByLanKey("tips_text", tips_cfg.des)
        --local head_img = self:setImg(tips_cfg.head, "main_ui", "head_img")
        --head_img:SetNativeSize()
        self:setObjectVisible("tips_image", true)
        self:setObjectVisible("close_tips_btn", true)
        self.m_control:setOnceTimer(2, function()
            self:setObjectVisible("tips_image", false)
            self:setObjectVisible("close_tips_btn", false)
            --self.m_tips_sequence = Tweening.DOTween.Sequence()
            --self.m_tips_sequence:Append(DOTweenModuleUI.DOFade(self:findImage("tips_image"), 0, 1))
            --self.m_tips_sequence:OnComplete(function()
            --	self:setObjectVisible("tips_image", false)
            --end)
            --self.m_tips_sequence:SetAutoKill(true)
        end)
    end
end

--获得当前输入的文字
function M:getMsg()
    return self.input.text
end

function M:refreshUi()
    local data = self.m_model.m_cell_data
    if data and next(data) then
        local show_id, real_id, real_num, cur_num = data[1], data[2], data[3], data[4]
        local show_cfg, real_cfg = nil, nil
        local show_cfg = self.m_model:getShowCfgById(show_id)
        if real_id > 0 then
            real_cfg = self.m_model:getRealCfgById(real_id)
        end
        local name = real_cfg and real_cfg.name or show_cfg.name
        local text_key, type_key = self.m_model:getTypeByNums(real_num)
        self:setText("value_text1", name)
        self:setText("value_text2", GameUtil:formatValueToString(cur_num))
        self:setText("value_text3",tostring(self.m_model.m_max_value))
        self:setTextByLanKey("value_text4", text_key)
        self:setText("value_text5", show_cfg.addres_des)
        for i = 3, 5 do
            self:setObjectVisible("select_img" .. i, type_key == i)
        end
    end
    
end

return M