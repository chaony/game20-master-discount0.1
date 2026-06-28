local M = class("GuJianQiTanMazeBattleOverControl",LikeOO.OOControlBase)

function M:onEnter()
    audio:SendEvtUI("UI_CWBZ_Clear")
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        if SceneManager.curScene.resetClickRoom ~= nil then
            SceneManager.curScene:resetClickRoom();
        end
        self:closeView()
    elseif msg == "ok_btn" then
        --SceneManager:changeScene(SceneManager.SceneID.HangUpScene);
        --打开迷宫主界面
        --local function netDataCallBack(response)
        --    if response.finish == 0 and response.cells ~= nil and _G.next(response.cells) ~= nil then
        --        QuickOpenFuncUtil:openFunc({18, response})
        --    else
        --        QuickOpenFuncUtil:openFunc({38, response})
        --    end
        --    self:closeAllViewPop({ ["Loading.SyncLoadBigLoading"] = 1 })
        --end
        --self.m_model:getNetData("maze_index", nil, netDataCallBack)
        self:closeView()
        static_rootControl:updateMsg(99999, nil, "GuJianQiTan.GuJianQiTanMaze")
    end
end

function M:destroy()
    M.super.destroy(self)
    
end

return M
