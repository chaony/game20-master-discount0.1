---@class TokenModel:OODataBase
---
local M=class("TokenModel",LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
end


function M:onEnter()
    self.m_sel_tab_index = 1 --一级页签
    self.tag_table = self:getShowActive()

end

--检查刷新单个页签的数据
function M:refreshTabData(open_id, url_name)
    if open_id == nil or url_name == nil then
        return
    end
    local active_tab = ConfigManager:getCfgByName("active")
    for k,v in pairs(self.m_data.actives) do
        local bl = false
        for kk,vv in pairs(v.actives) do
            if vv and vv.open_status > 0 then
                if vv.open_id == open_id then
                    bl = true
                elseif (open_id == 137 or open_id == 85 or open_id == 5000) and (vv.open_id == 85 or vv.open_id == 143 or vv.open_id == 144 or vv.open_id >= 5000)  then --成长基金、签到基金合并到一起
                    bl = true
                end
            end
        end
        if bl == true then
            if url_name == "war_order_valor_index" or url_name == "war_order_index" or url_name == "war_goal_common_index" then
                self.m_war_older_actives = v.actives[1]
                self:setWarOlderData(v)
            elseif url_name == "month_card" then
                --月卡数据
                self.m_month_card_data = v
            elseif url_name == "fund_index" then
                self.m_fund_data = v --成长基金数据
            elseif url_name == "sign_daily_index" then
                self.m_sign_daily_data = v or {} --签到
            elseif url_name == "tiktok_data" then
                if v and v.tiktok_record then
                    self.m_tiktok_data = v.tiktok_record
                else
                    self.m_tiktok_data = {}
                end
            end
        end
    end
end

--检查界面开启的活动按钮
function M:getShowActive()
    local opne_tab = ConfigManager:getCfgByName("open_condition")
    local active_tab = opne_tab[88]
    local temp_tab = table.copy(active_tab.buttons)
    local remove_tab = {}
    for i,v in pairs(temp_tab) do
        if self:checkHaveActive(v) == false then
            remove_tab[i] = true
        end
    end
    for i = #temp_tab, 1,-1 do
        if remove_tab[i] == true then
            table.remove(temp_tab, i)
        end
    end
    return temp_tab
end

--检查是否开启当前活动
function M:checkHaveActive(open_id)
    if open_id == 176 then
        local chn = ""
        for k,v in pairs(UserDataManager.server_data.all_server_data) do
            chn = v.ChannelID
            break
        end

        if chn ~= "bsdk" then
            return false
        end
        -- elseif open_id == 145 then
        --     return true
    end
    local cfg = BtnOpenUtil:getBtnCfg(open_id)
    if cfg == nil then return false end
    local buttons = cfg.buttons or {}
    if #buttons > 0 then
        for i, v in ipairs(buttons) do
            if open_id ~= v then
                if self:checkHaveActive(v) then
                    return true
                end
            else
                Logger.logError("open_condition cfg error, key is " .. tostring(open_id))
            end
        end
    end
    return self:checkActive(open_id)
end

function M:checkActive(open_id)
    local active_tab = ConfigManager:getCfgByName("active_recharge")
    for k,v in pairs(UserDataManager.m_active_recharge) do
        if v.open_status > 0 then
            local c_cfg = active_tab[v.id]
            if c_cfg and open_id == c_cfg.open_id then
                return true
            end
        end
    end
    return false
end

return M