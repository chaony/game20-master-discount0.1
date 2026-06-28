local M = class("EquipmentSmeltingPopControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "close_btn" then
        self:updateMsg(99999)
    elseif msg == "click_cell" then
        if data and data.oid then
            local is_select = self.m_model:isSelect(data.oid)
            if is_select then
                self.m_model:removeEquipFromSelect(data.oid)
            else
                self.m_model:addEquipToSelect(data.oid, data.cid)
            end
            self.m_model:udpateConsume(data.oid, data.cid, not(is_select))
            --self.m_view:refreshUi()
            self.m_view:updateRightLoopScroll()
        end
    elseif msg == "smelt_btn" then
        if next(self.m_model.m_cur_select_eqb_tab) then
            local tips = Language:getTextByKey("new_str_1018")
            local params =
            {
                on_ok_call = function(msg)
                    self:smeltEquip()
                end,
                on_cancel_call = function(msg)
                end,
                no_close_btn = false,
                tow_close_btn = true,
                text = tips,
            }
            static_rootControl:openView("Pops.CommonPop", params, nil, true)
        end
    elseif msg == "help_btn" then
        local params = {}
        params.title = "new_str_1016"
        params.content = "tid#Equipcommon_2"
        self:openView("Pops.CommonHelpPop", params)
    end
end

function M:smeltEquip()
    local function callfunc(response)
        RewardUtil:rewardTipsByData(response.reward or {})
        self:updateMsg("update_equip", nil, "HeroInfo")
        self.m_model:initData()
        self.m_view:refreshUi()
    end
    local equips = {}
    for i, v in pairs(self.m_model.m_cur_select_eqb_tab) do
        equips[#equips + 1] = tonumber(i)
    end
    self.m_model:getNetData("equip_smelt",{ equips = equips }, callfunc)
end

return M
