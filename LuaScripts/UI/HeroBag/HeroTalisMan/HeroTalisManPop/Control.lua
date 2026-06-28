local M = class("TalisManmentPopControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refresh_red_point",nil,"parent")
        self:closeView()
    elseif msg == "buy_btn" then
        local talis_data = self.m_model:getTalisData()
        if #talis_data <=0 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("talisman_text_0028"), delay_close = 2})
            return
        end
        local params = {
            heroid = self.m_model.m_selected_id,
            pos = self.m_model.pos
        }
        self:openView("HeroBag.HeroTalisMan.HeroTalisManList",params)  
        self:closeView()
    elseif self:clickslider(msg) then 
        
    end
end

function M:clickslider(msg)
    for i = 1,3 do
        if msg == "left_property_slider_button_"..i  then
            local data = self.m_model:getCurrentTalinsDataByPos(self.m_model.pos)
            local cfgData = self.m_model:getTalisSuitConfigByCid(data.id or 1)
            local attrsData = data.attrs[tostring(i)]
            local showArr = self.m_model:getCurrentAttrs({attrsData.value})
            local currentValue,allValue = self.m_model:getSliderLimit(cfgData.quality,self.m_model.pos,attrsData.team_id,attrsData.value[1])
            local at_name = GameUtil:getAttrsName(showArr[1]).."："
            local text = ""
            if GameUtil:newattrTransition2(showArr[1]) == true then
                text = string.format(Language:getTextByKey("talisman_text_0029"),currentValue.."%",allValue.."%")
            else
                text = string.format(Language:getTextByKey("talisman_text_0029"),currentValue,allValue)
            end
            local click_object = self.m_view:findGameObject(msg)
            GameUtil:lookInfoTips(self, { click_transform = click_object.transform, msg = at_name..text})
        end
    end
end


function M:destroy()
   
    M.super.destroy(self)
end

return M
