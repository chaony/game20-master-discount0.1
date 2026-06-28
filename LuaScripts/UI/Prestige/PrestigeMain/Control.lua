---@class PrestigeMainControl : OOControlBase
local M = class("PrestigeMainControl", LikeOO.OOControlBase)

function M:onEnter()
    --判断是否有新棋子获得
    local new_blocks = PrestigeUtil:getNewBlockData()
    if new_blocks and #new_blocks > 0 then
        self:openView("Prestige.PrestigeGetPop",{data = new_blocks or {}})
    end
    self:closeView("Prestige.PrestigeEditor")
    self:initBlockManager()
    EventDispatcher:registerEvent("prestige_data_update", {self, self.refreshView })
end

function M:onHandle(msg, data)
    if msg == 99999 then
        self:closeView()
        self:updateMsg("refresh_entrances",nil,"PengLaiBazzar.PengLaiBazzarIsland")
    elseif msg == "bag_btn" then
        self:openView("Prestige.PrestigeBag")
    elseif msg == "edit_btn" then
        self:openView("Prestige.PrestigeEditor")
        self:closeView()
    elseif msg == "fetter_btn" then
        self:openView("Prestige.PrestigeHeroFetter", {index = PrestigeUtil.cur_board_type})
    elseif msg == "help_btn" then
        self:showHelpPop()
    elseif msg == "upgrade_btn" then
        self:upgradeBoard()
    elseif msg == "reset_btn" then
        self:resetBoardLevel()
    elseif type(msg) == "number" and msg >= 1 and msg <= 7 then
        self:switchTabBtn(msg)
    elseif msg == "refresh_ui" then
        self:refreshView()
    elseif msg == "click_lock_slot" then
        local unlock_text = Language:getTextByKey("prestige_text_017", data)
        GameUtil:lookInfoTips(self, {msg = unlock_text, delay_close = 2})
    elseif msg == "check_btn" then
        self:openView("Prestige.PrestigeAttribute", { prestige_attr_list = self.m_model:getPrestigeAttr() })
    end
end

function M:initBlockManager()
    self.block_manager = require("UI.Prestige.PrestigeBlockManager").new()
    self.block_manager:init()
    self.block_manager:setData(self)
end

-- 刷新显示
function M:refreshView()
    self.m_view:refreshUI(PrestigeUtil.cur_board_type)
end

-- 帮助弹窗
function M:showHelpPop()
    local params = {}
    params.title = "prestige_text_006"
    params.content = "tid#prestige_des"
    self:openView("Pops.CommonHelpPop", params)
end

-- 棋盘升级
function M:upgradeBoard()
    local type = PrestigeUtil.cur_board_type
    local params = {
        c_id = type,
        level = PrestigeUtil:getBoardLevel(type) + 1
    }
    local function callback(response)
        PrestigeUtil:updateAllBoardData(response.checkerboard_info)
        self:refreshView()
    end
    self.m_model:getNetData("prestige_upgrade", params, callback)
end

-- 切换棋盘
function M:switchTabBtn(index)
    if PrestigeUtil:isBoardUnlocked(index) then
        if PrestigeUtil.cur_board_type ~= index then
            PrestigeUtil.cur_board_type = index
            self.m_view:refreshUI(index)
        end
    else
        GameUtil:lookInfoTips(self, {msg = "prestige_text_005", delay_close = 2})
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("prestige_data_update", {self, self.refreshView })
    M.super.destroy(self)
end

return M
