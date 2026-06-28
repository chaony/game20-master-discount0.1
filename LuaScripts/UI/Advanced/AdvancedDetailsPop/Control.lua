local M = class("AdvancedDetailsPopControl",LikeOO.OOControlBase)

function M:onEnter()
  	self.m_guide_file_name = "UI.Advanced.AdvancedDetailsPop.Guide"
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:closeView()
    elseif msg == "back_btn" or msg == "cancel_btn" then
    	self:closeView()
    elseif msg == "yes_btn" then
        if self.m_model.m_islink == true then
            if self.m_model.m_link_type == 2 then
                local can_lv = true
                for i,v in pairs(self.m_model.m_martial) do
                    if v == 0 then
                        can_lv = false
                    end
                end
                if can_lv == false then
                    GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("new_str_0098", "结义消耗材料"), delay_close = 2 })
                    return 
                end
                self:updateMsg("link_level_up_net", self.m_model.m_martial, "Advanced")
            elseif self.m_model.m_link_type == 3 then
                self:updateMsg("link_remove_net", self.m_model.m_martial, "Advanced")
            elseif self.m_model.m_link_type == 1 then
                self:updateMsg("link_net", nil, "Advanced")
            end 
            self:updateMsg(99999)
        else
            self:TipsOne()
        end
    end
end

function M:TipsOne()
    local flag = false
    local hero = UserDataManager.hero_data:getHeroDataById(self.m_model.m_hero)
    if hero.evo >= 18 then
        for i,v in ipairs(self.m_model.m_martial) do
            local hero, cfg = UserDataManager.hero_data:getHeroDataById(v)
            if cfg.evo > 4 then
                if self.m_model.m_slot_consume[i] and self.m_model.m_slot_consume[i][1] ~= 1 then
                    flag = true
                    break
                end
            end
        end
    end
    if flag then
        local params =
        {
            on_ok_call = function(msg)
                self:TipsTwo()
            end,
            no_close_btn = false,
            text = Language:getTextByKey("advanced_str_0018")
        }
        static_rootControl:openView("Pops.CommonPop", params, nil, true)
    else
        self:TipsTwo()
    end
end

function M:TipsTwo()
    local hero, cfg = UserDataManager.hero_data:getHeroDataById(self.m_model.m_hero)
    if hero.evo == 18 then
        local num = self.m_model:getAllMartial()
        local tips = Language:getTextByKey("coach_str_0024")
        if num > 0 then
            local name =  Language:getTextByKey(cfg.name)
            tips = Language:getTextByKey("coach_str_0025",name,num)
        end
        local params =
        {
            on_ok_call = function(msg)
                self:TipsThree(num)
            end,
            no_close_btn = false,
            text = tips
        }
        static_rootControl:openView("Pops.CommonPop", params, nil, true)
    else
        self:updateMsg("advanced", nil, "Advanced")
        self:closeView()
    end
end

function M:TipsThree(num)
    local tips = Language:getTextByKey("coach_str_0026")
    if num > 0 then
        tips = Language:getTextByKey("coach_str_0027",num)
    end
    local params =
    {
        on_ok_call = function(msg)
            self:updateMsg("advanced", nil, "Advanced")
            self:closeView()
        end,
        no_close_btn = false,
        red_ok = true,
        text = tips
    }
    static_rootControl:openView("Pops.CommonPop", params, nil, true)
end

return M;
