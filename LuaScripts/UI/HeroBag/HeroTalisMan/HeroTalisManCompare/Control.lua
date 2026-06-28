local M = class("TalisManmentCompareControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        ----self:updateMsg("refresh_red_point",nil,"parent")
        --local params = {
        --    left_name = "talisman_text_0024",
        --    right_name = "talisman_text_0025",
        --    tips_text = "talisman_text_0026",
        --    right_callback= function()
        --        self:updateMsg("update_seal_character",{is_refresh_effet = true},"HeroBag.HeroTalisMan.HeroTalisManList")
        --        self:closeView()
        --    end,
        --}
        --self:openView("Pops.CommonTipsPop", params)
    elseif msg == "close_btn_new" then
        local params = {
            left_name = "talisman_text_0024",
            right_name = "talisman_text_0025",
            tips_text = "talisman_text_0026",
            right_callback= function()
                self:updateMsg("update_seal_character",{is_refresh_effet = true},"HeroBag.HeroTalisMan.HeroTalisManList")
                self:closeView()
            end,
        }
        self:openView("Pops.CommonTipsPop", params)
    elseif msg == "keep_btn" then
        if self.m_model.left_value > self.m_model.right_value then
            local params = {
                left_name = "talisman_text_0024",
                right_name = "talisman_text_0025",
                tips_text = "talisman_text_0038",
                right_callback= function()
                    local callback = function()
                        --self:updateMsg("refresh_data", nil, "HeroBag.HeroTalisMan.HeroTalisManList")
                        self:updateMsg("update_seal_character",{is_refresh_effet = true},"HeroBag.HeroTalisMan.HeroTalisManList")
                        self:openView("HeroBag.HeroTalisMan.HeroTalinsManSuccessPop")
                        self:closeView()
                    end
                    local params = {
                        hero_oid = self.m_model.m_selected_id,
                        pos = self.m_model.pos,
                    }
                    self.m_model:getNetData("seal_character_save",params,callback)
                end,
            }
            self:openView("Pops.CommonTipsPop", params)
        else
            local callback = function()
                --self:updateMsg("refresh_data", nil, "HeroBag.HeroTalisMan.HeroTalisManList")
                self:updateMsg("update_seal_character",{is_refresh_effet = true},"HeroBag.HeroTalisMan.HeroTalisManList")
                self:openView("HeroBag.HeroTalisMan.HeroTalinsManSuccessPop")
                self:closeView()
            end
            local params = {
                hero_oid = self.m_model.m_selected_id,
                pos = self.m_model.pos,
            }
            self.m_model:getNetData("seal_character_save",params,callback)
        end
    elseif msg == "shiyong_btn" then
        if not self:isCanUpdateTalins() then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("talisman_text_0028"), delay_close = 2})
            return
        end
        local callback = function(response)
            self.m_model:refreshListData(response)
            self.m_view:refreshUI()
            return
        end
        local params = {
            seal_character_id =  self.m_model.use_data.id,
            hero_oid = self.m_model.m_selected_id,
            pos = self.m_model.pos,
        }
        self.m_model:getNetData("seal_character_use",params,callback)
    --elseif self:clicklock(msg) then --去掉上锁
    elseif self:clickslider(msg) then 
    end
end


function M:isCanUpdateTalins()
    local current_num = self.m_model:getTalisDataById(self.m_model.m_talins_id).number or 0
    if current_num > 0 then
        return true
    end
    return false
end

function M:clicklock(msg)
    for i = 1,3 do
        if msg == "left_property_lock_"..i then
            local callback = function(response)
                self.m_model:refreshListData(response)
                self:updateMsg("update_seal_character",nil,"HeroBag.HeroTalisMan.HeroTalisManList") --同步数据
                self.m_view:refreshUI()
            end
            local params ={
                hero_oid = self.m_model.m_selected_id,
                pos = self.m_model.pos,
                lock = self.m_model.left_data.attrs[tostring(i)].locked == 1 and 0 or 1,
                attr_idx = i
            }
            self.m_model:getNetData("seal_character_lock_attr",params,callback)    
        --elseif msg == "right_property_lock_"..i then
        --    local callback = function(response)
        --        self.m_model:refreshListData(response)
        --        self.m_view:refreshUI()
        --    end
        --    local params ={
        --        hero_oid = self.m_model.m_selected_id,
        --        pos = self.m_model.pos,
        --        lock = self.m_model.right_data.attrs[tostring(i)].locked == 1 and 0 or 1,
        --        attr_idx = i
        --    }
        --    self.m_model:getNetData("seal_character_lock_attr",params,callback)
        end
    end
end

function M:clickslider(msg)
    for i = 1,3 do
        if msg == "left_property_slider_button_"..i or msg == "right_property_slider_button_"..i then
            local data = msg == "left_property_slider_button_"..i and self.m_model.left_data or self.m_model.right_data
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
