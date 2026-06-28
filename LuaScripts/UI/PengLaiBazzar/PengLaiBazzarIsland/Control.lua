---@class PengLaiBazzarIslandControl: OOControlBase
---@field m_model PengLaiBazzarIslandModel
---@field m_view PengLaiBazzarIslandView
local M = class("PengLaiBazzarIslandControl", LikeOO.OOControlBase)

function M:onEnter()
    M.super.onCreate(self)
end

function M:onHandle(msg, data)
    if msg == 99999 then
        -- 返回
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = -1})
    elseif msg == "open_btn7" then --宠物大厅
        self:openView("PetBreeding.PetBreedingMain")
    elseif msg == "open_btn3" then --蓬莱集市
        self:openView("PengLaiBazzar.PengLaiBazzarMain", { openId = 349 })
    elseif msg == "open_btn2" then --斗技馆
        if self:checkPvp() then
            self:openView("PetBreeding.PetArenaMain")
        end
    elseif msg == "open_btn4" then
        self:openView("Prestige.PrestigeMain")
        --self:closeView()
    elseif msg == "open_btn5" then
        local open_flag = BtnOpenUtil:isBtnOpen(417)
        if open_flag then
            self:openView("AwakeSystem.AwakeSystemMain")
        else
            GameUtil:lookInfoTips(self,{msg = Language:getTextByKey("awake_system_text_0063"), delay_close = 2})
        end
        
    elseif msg == "refresh_entrances" then
        -- 刷新红点和入口状态
        self.m_view:refreshEntrances()
    end
end

function M:checkPvp()
    local open_flag, tips_str = BtnOpenUtil:isBtnOpen(365)
    if not open_flag then
        GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2})
        return false
    end
    local ids = UserDataManager.pet_data:getPetsId()
    if #ids <= 0 then
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("pet_bag_text_0114"), delay_close = 2 })
        return false
    end
    local data = UserDataManager:getPetPvpSeasonData()
    if not data or not data.season then
        Logger.logError("pet_pvp_season_data error")
        return false
    elseif data.season <= 0 then
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("pet_bag_text_0115"), delay_close = 2 })
        return false
    end
    return true
end

function M:destroy()
    M.super.destroy(self)
end

return M
