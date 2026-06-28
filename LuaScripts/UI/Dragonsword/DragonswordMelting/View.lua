local M = class("DragonswordMeltingView",LikeOO.OOPopBase)

M.m_size_type = 1
M.m_iphoneXAdapter = true
M.m_uiName = "Dragonsword/DragonswordMelting"

M.light_color = Color( 206/255, 238/255, 249/255)
M.not_light_color = Color( 141/255, 148/255, 170/255)

function M:onEnter()
    if self.m_model.m_active_data ~= nil and self.m_model.m_active_data.name ~= nil then
        self:setTextByLanKey("close_title_text",self.m_model.m_open_data.name)
    end
    self:setTextByLanKey("one_melting_btn_text","dragonsword_text_0004")
    self:setTextByLanKey("ten_melting_btn_text","dragonsword_text_0005")
    self:setTextByLanKey("spar_btn_text","dragonsword_text_0006")
    self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 28})
	self:refreshUI()
end

--刷新
function M:refreshUI()
	self:setMilepost()
    self:setObjectVisible("spar_red_point",self.m_model:isHasQuestRed()) --展示任务红点
end

--设置累计任务
function M:setMilepost()
    local milepost_data = self.m_model:getMilepostData()
    for i = 1, 5 do
        --设置晶石 全服进度/里程碑进度
        local milepost_text_name = "materia_text_"..i
        local milepost_text = self.m_model.m_score.."/"..milepost_data[i].score
        self:setTextByLanKey(milepost_text_name,milepost_text)
        --设置晶石滑动条
        local slider = self:findSlider("material_hui_di_img_"..i)
        if slider ~= nil then
            if self.m_model.m_score >= milepost_data[i].score  then
                slider.value = 1
            else
                slider.value = self.m_model.m_score/milepost_data[i].score
            end
        end
        --设置名称
        local name_text_name = "materia_name_text_"..i
        local name_text = self:setTextByLanKey(name_text_name,milepost_data[i].name)
        --设置奖励
        local reward_node_name = "material_jian_img_"..i
        local reward = milepost_data[i].reward or {}
        local reward_node = self:findGameObject(reward_node_name)
        GameUtil:createRewards(reward_node.transform, reward, true, true, nil, 1)
        --设置达到状态
        local materia_img_di_name = self.m_model.m_score >= milepost_data[i].score and "a_lq_zjly_yuandi2" or "a_lq_zjly_yuandi1"
        local name_color = self.m_model.m_score >= milepost_data[i].score and self.light_color or self.not_light_color
        local materia_img_di = "material_di_img_"..i
        local materia_img_di = self:setImg(materia_img_di_name,"active_ui",materia_img_di)
        materia_img_di:SetNativeSize()
        name_text.color = name_color
        --设置奖励领取状态
        local is_receive = self.m_model:getIsReceiveMilepost(i) --true已领取，false未领取
        self:setObjectVisible("receive_img_bg_"..i,is_receive)
        self:setObjectVisible("receive_btn_"..i,not is_receive)
        self:setObjectVisible("material_red_point_"..i,self.m_model.m_score >= milepost_data[i].score and not is_receive)
    end
end


function M:destroy()
    if self.m_attr_node then
        self.m_attr_node:destroy()
        self.m_attr_node = nil
    end
    M.super.destroy(self)
end

return M