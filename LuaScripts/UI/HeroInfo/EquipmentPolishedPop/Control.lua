local M = class("EquipmentPolishedPopControl",LikeOO.OOControlBase)

function M:onEnter()
    self.can_close = false
end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "big_close_btn" then    -- 返回
        -- self:netCancelAffix(function ()
        --     self:closeView()
        -- end)
    elseif msg == "order_btn" then
        function CloseFunc()
             --原属性
             self:netCancelAffix(function ()
                self:closeView()
            end)
        end
        if self.m_model.new_affix_combat > self.m_model.order_affix_combat then
            local params = {
                text = Language:getTextByKey("equip_str_030"),
                tow_close_btn = true,
                on_ok_call = function ()
                    CloseFunc()
                end
            }
            self:openView("Pops.CommonPop", params)
            return
        end
        CloseFunc()
    elseif msg == "new_btn" then
        function CloseFunc()
               --新属性
            self:updateMsg("updateUI",nil,"HeroInfo.EquipmentLevelUp")
            self:closeView()
        end
        if self.m_model.order_affix_combat > self.m_model.new_affix_combat then
            local params = {
                text = Language:getTextByKey("equip_str_030"),
                tow_close_btn = true,
                on_ok_call = function ()
                    CloseFunc()
                end
            }
            self:openView("Pops.CommonPop", params)
            return
        end
        CloseFunc()
    end
end

function M:netCancelAffix(callback)
    local function callfunc()
        self:updateMsg("updateUI",nil,"HeroInfo.EquipmentLevelUp")
        if callback then
            callback()
        end
    end
    self.m_model:getNetData("cancel_affix_random",{ hero_oid = self.m_model.m_heroid, pos = self.m_model.m_pos }, callfunc)	
end

return M
