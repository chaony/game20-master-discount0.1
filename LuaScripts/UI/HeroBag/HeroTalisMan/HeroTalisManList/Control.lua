local M = class("TalisManmentListControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        --self:updateMsg("refresh_red_point",nil,"parent"
        self:updateMsg("update_equip",nil,"HeroBag")
        self:closeView()
    elseif msg == "shiyong_btn" then
        if not self:clickShiYong() then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("talisman_text_0034"), delay_close = 2})
            return
        end
        local callback = function(response)
            if response.first_use == 1 then --第一次使用
                --self:updateMsg("update_equip",nil,"HeroBag")
                self.m_model.is_refresh_effet = true
                self:openView("HeroBag.HeroTalisMan.HeroTalinsManSuccessPop")
                self.m_view:refreshUI()
                return
            end
            local params2 = {
                heroid = self.m_model.m_selected_id,
                pos = self.m_model.pos,
                response = response,
                use_data = self.m_model.m_select_cell_data
            }
            self:openView("HeroBag.HeroTalisMan.HeroTalisManCompare", params2) --查看装备
        end
        local params = {
            seal_character_id =  self.m_model.m_select_cell_data.id,
            hero_oid = self.m_model.m_selected_id,
            pos = self.m_model.pos,
        }
        self.m_model:getNetData("seal_character_use",params,callback)
    elseif msg == "update_seal_character" then
        local talins_data = self.m_model:getTalisData()
        if #talins_data<=0 then
            self:updateMsg("update_equip",nil,"HeroBag")
            self:closeView() --没有符篆关闭界面
            return 
        end
        --使用光了 默认用第一个
        local data_ = self.m_model:getTalisDataById(self.m_model.m_select_cell_data.id)
        if not data_ then
            self.m_model.m_select_cell_index = 1
        end
        if data then
            self.m_model.is_refresh_effet = data.is_refresh_effet
        end
        self.m_view:refreshUI()
    elseif self:clicklock(msg) then
    elseif self:clickslider(msg) then
    elseif msg == "help_btn" then
        local params = {}
        params.title = ""
        params.content = "tid#seal_character_tips"
        self:openView("Pops.CommonHelpPop", params)
    end
end

function M:clicklock(msg)
    for i = 1,3 do
        if msg == "left_property_lock_"..i then
            local callback = function(response)
                --self.m_model:refreshListData(response)
                self.m_view:refreshUI()
            end
            local data = self.m_model:getCurrentTalinsDataByPos(self.m_model.pos)
            local params ={
                hero_oid = self.m_model.m_selected_id,
                pos = self.m_model.pos,
                lock = data.attrs[tostring(i)].locked == 1 and 0 or 1,
                attr_idx = i
            }
            self.m_model:getNetData("seal_character_lock_attr",params,callback)
        end
    end
end

function M:clickShiYong()
    local commonData = ConfigManager:getCfgByName("common")
    local commonDataIndex = commonData[771]
    local diamond_num = UserDataManager.user_data:getUserStatusDataByKey("diamond") or 0
    local num = 0
    if self.m_model.lock_num > 0 then
        num = commonDataIndex.value[self.m_model.lock_num][2] or 0
    else
        num = 0
    end
    return diamond_num >= num
end

function M:clickslider(msg)
    for i = 1,3 do
        if msg == "left_property_button_"..i then
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
