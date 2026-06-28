local M = class("EquipmentPolishedsPopControl",LikeOO.OOControlBase)

function M:onEnter()
    self.can_close = false
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("updateUI",nil,"HeroInfo.EquipmentLevelUp")
        self:closeView()
    elseif msg == "ok_btn" then
        if self.m_model.m_select_index ~= 1 then
            --点击新词缀
            local callfunc = function ()
                local odr_combat = self.m_view.m_combat[1]
                local cur_combat = self.m_view.m_combat[self.m_model.m_select_index]
                if cur_combat < odr_combat then
                    local params = {
                        text = Language:getTextByKey("equip_str_030"),
                        tow_close_btn = true,
                        on_ok_call = function ()
                            self:netCancelAffix()
                        end
                    }
                    self:openView("Pops.CommonPop", params, true)
                else
                    self:netCancelAffix()
                end
            end
            local have_rare = self.m_model:checkOrdHaveRars() -- 原有稀有词缀
            if have_rare == true then
                local params = {
                    text = Language:getTextByKey("equip_str_047"),
                    tow_close_btn = true,
                    on_ok_call = function ()
                        callfunc()
                    end
                }
                self:openView("Pops.CommonPop", params)
            else
                callfunc()
            end
        else
            --点击原词缀
            local callfunc = function ()
                local odr_combat = self.m_view.m_combat[1]
                local cur_combat = 0
                for k,v in pairs(self.m_view.m_combat) do
                    if k ~= 1 and v > cur_combat then
                        cur_combat = v
                    end
                end
                if cur_combat > odr_combat then
                    local params = {
                        text = Language:getTextByKey("equip_str_030"),
                        tow_close_btn = true,
                        on_ok_call = function ()
                            self:netCancelAffix()
                        end
                    }
                    self:openView("Pops.CommonPop", params, true)
                else
                    self:netCancelAffix()
                end
            end
            local have_rare = self.m_model:checkHaveRars() -- 新的也稀有词缀
            if have_rare == true then
                local params = {
                    text = Language:getTextByKey("equip_str_048"),
                    tow_close_btn = true,
                    on_ok_call = function ()
                        callfunc()
                    end
                }
                self:openView("Pops.CommonPop", params)
            else
                callfunc() 
            end
        end
    elseif msg == "select_id" then
        self.m_model.m_select_index = data
        self.m_view:refreshUI()  
    elseif msg == "polished_btn" then
        local have_rare = self.m_model:checkHaveRars()
        if have_rare == true then
            local params = {
                text = Language:getTextByKey("equip_str_048"),
                tow_close_btn = true,
                on_ok_call = function ()
                    self:netPolishsRandom()
                end
            }
            self:openView("Pops.CommonPop", params)
        else
            self:netPolishsRandom()
        end
 
    end
end

function M:netCancelAffix(callback)
    local function callfunc()
        if callback then
            callback()
        end
        self:updateMsg(99999)
    end
    self.m_model:getNetData("select_affix_random",{ hero_oid = self.m_model.m_heroid, pos = self.m_model.m_pos, affix_index = self.m_model.m_select_index-1 }, callfunc)	
end

--继续词缀批量洗练
function M:netPolishsRandom()
    local function callfunc(data)
        self.m_model:refreshData()
        self.m_view:refreshUI() 
    end
    local params = {}
    params.hero_oid = self.m_model.m_heroid
    params.pos = self.m_model.m_pos
    self.m_model:getNetData("batch_affix_random", params, callfunc)	
end

return M
