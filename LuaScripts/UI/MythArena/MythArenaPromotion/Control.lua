local M = class("MythArenaPromotionControl",LikeOO.OOControlBase)

function M:onEnter()
    audio:SendEvtUI("UI_Success_Star01")
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
        --local not_close_tab = {}
        --not_close_tab = {["Loading.SyncLoadBigLoading"] = 1, ["Loading.SmallLoading"] = 1, ["Loading.BattleLoading"] = 1, ["Loading.BigLoading"] = 1, ["Main.TotalWorld"] = 1}
        --static_rootControl:closeAllViewPop(not_close_tab)
    elseif msg == "go_btn" then --快速导航
        self:openView("MythArena.MythArenaMain")
    elseif msg == "player_bg_img" then
        local uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
        self:openView("Pops.PlayerInfo", {uid = uid, look_model = 10})
    elseif msg == "share_btn"  then
        self.m_view:showShareNode()
        -- 分享
        local show_call = function()
            self.m_view:hideShereNode()
        end
        self:openView("SharePictureNoLogo", {picture_callback = show_call})
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M;
