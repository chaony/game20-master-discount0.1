local M = class("ChivalryAcademyControl", LikeOO.OOControlBase)

function M:onEnter()
    --self:initBlockManager()
end

function M:onHandle(msg, data)
    if msg == 99999 then -- 关闭
        self:updateMsg("refreshRedPoint", nil, "Chivalry.ChivalryMain")
        if self.m_model.refresh_main then
            self:updateMsg("refreshRedPoint", nil, self.m_model.refresh_main)
        end
        self:closeView()
    elseif msg == "last_btn" then  --上一章
        self.m_model.write = nil
        if self.m_model.customs > 1 then
            self.m_model.customs = self.m_model.customs - 1
        end
        self.m_model:getContent()
        self.m_model:getFontLibrary()
        self.m_view:refreshUI()
    elseif msg == "next_btn" then   --下一章
        self.m_model.write = nil
        if self.m_model.customs < self.m_model.open_customs_num then
            self.m_model.customs = self.m_model.customs + 1
            self.m_model:getContent()
            self.m_model:getFontLibrary()
            self.m_view:refreshUI()
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("chivalry_text_0019"), delay_close = 2})
        end
    --elseif msg == "create_block" then
    --    local block_data = data.block_data
    --    local grid_obj = data.grid_obj
    --    local block = self.block_manager:generateNormalBlock(block_data, grid_obj)
    --    self.m_view:onBlockCreated(block)
    elseif msg == "drag_write" then --点击
        self.m_model.write = data.cell_data
        self.m_model.write_pos = data.index
        if self.m_model.write_object then
            self.m_view:isMoveChangeRed(self.m_model.write_object,false)
        end
        self.m_model.write_object = data.cell_object
        self.m_view:isMoveChangeRed(data.cell_object,true)
    elseif msg == "up_write" then  --放字
        if self.m_model.write ~= nil then
            self.m_model.show_data[data.index].is_write = 1
            self.m_model.show_data[data.index].write_value = self.m_model.write.value
            self.m_view:createLoopScroll()
            self.m_model.write = nil
        end
    elseif msg == "revoke" then  --撤销
        if self.m_model.write_object then
            self.m_view:isMoveChangeRed(self.m_model.write_object,false)
        end
        self:setOnceTimer(2,function()
            self.m_model.show_data[data.index].is_write = 0
            self.m_model.show_data[data.index].write_value = nil
            self.m_view:refreshUI()
        end)
    elseif msg == "preservation" then  --保存
        local active_type = self.m_model:getActiveType()
        local function netCallback(response)
            if response["end"] == 1 then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
                self:closeView()
                return
            end
            self.m_model:updateServer(response)
            self.m_model.fontLibrarys[active_type.type][self.m_model.write_pos].status = 1
            self.m_model:preservationWriteStage(data.data.id,active_type.type)
            self.m_view:refreshUI()
        end
        self.m_model:getNetData("fillword_save_word",{open_id = self.m_model.open_id,vsn = self.m_model.m_version,pos = data.data.id,stage = active_type.type},netCallback)
    elseif msg == "reward_btn" then --领奖
        local active_type = self.m_model:getActiveType()
        local is_receive = self.m_model:getIsHasReward() --是否已领过奖励 领取：true，没领取：false
        local is_write_end = self.m_model:getIsReceive() --已填完
        local additional = 1 --没有额外奖励
        if active_type.reward2 then
            local current_additional = self.m_model:getIsHasReward(-1)
            if current_additional then
                additional = 2 --已领取额外奖励
            else
                additional = 0 --没领取额外奖励
            end
        end
        local current_is_receive = not is_receive
        if is_write_end and current_is_receive then
            local function netCallback(response)
                if response["end"] == 1 then
                    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
                    self:closeView()
                    return
                end
                RewardUtil:rewardTipsByData(response.reward) --展示奖励
                self.m_model:updateServer(response)
                self.m_view:refreshRedDod()
            end
            local current_customs = self.m_model.customs
            --if is_receive and additional == 0 then
            --    current_customs = -1
            --end
            self.m_model:getNetData("fillword_receive_stage",{open_id = self.m_model.open_id,vsn = self.m_model.m_version,stage_id = current_customs},netCallback)
        else
            local click_obj= self.m_view:findGameObject("reward_btn")
            local rewards = active_type.rewards or {}
            self:openView("Pops.LookRewardTips",{rewards = rewards, click_transform = click_obj.transform, show_check_mark = is_receive})
        end
    end
end

---- 棋子生成器
--function M:initBlockManager()
--    self.block_manager = require("UI.Prestige.PrestigeBlockManager").new()
--    self.block_manager:init()
--    self.block_manager:setData(self)
--end

return M
