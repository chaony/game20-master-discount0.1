---@class HalfAnniversaryLotteryView: OOPopBase
local M = class("CelebrateOneYearLotteryView", LikeOO.OOPopBase)

M.m_uiName = "CelebrateOneYear/CelebrateOneYearLottery"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
    self.avtive_data = self.m_model:getActiveData()
    if self.avtive_data then
        self:setTextByLanKey("close_title_text", self.avtive_data.name )
    end
    self:setTextByLanKey("desc_text", "half_year_text_0018")
    self:setTextByLanKey("result_title_text", "half_year_text_0019")
    self:setTextByLanKey("lotteryBtn_text", "half_year_text_0017")
    self:setTextByLanKey("lucky_text", "half_year_text_0016")
    self:setTextByLanKey("resultBtn_text", "half_year_text_0023")
    self:setTextByLanKey("level_text1", "half_year_text_0011")
    self:setTextByLanKey("level_text2", "half_year_text_0012")
    self:setTextByLanKey("level_text3", "half_year_text_0013")
    self:setTextByLanKey("level_text4", "half_year_text_0014")
    self:setTextByLanKey("desc_text1", "half_year_text_0024")
    self:setTextByLanKey("desc_text2", "half_year_text_0025")
    self:setTextByLanKey("desc_text3", "half_year_text_0026")
    self:setText("desc_text4", "")
    self.yaojiangji_sp = self:findGameObject("yaojiangji_sp"):GetComponent("SkeletonGraphic")
    self:addSpineComplete(self.yaojiangji_sp.AnimationState, function()
        if self.yaojiangji_sp.AnimationState:ToString() == "tap" then
            self.yaojiangji_sp.AnimationState:ClearTracks()
            self.yaojiangji_sp.AnimationState:SetAnimation(0, "pose", true)
        end
    end)
    self:refreshUI()
    self:updateActivityTimer()
end

function M:refreshUI()
    self:setObjectVisible("no_result", self.m_model.m_data.stage == 1)
    self:setObjectVisible("result_btn", self.m_model.m_data.stage ~= 1)
    if self.m_model.m_data.self_number == nil or self.m_model.m_data.self_number == "" then
        for i=1, 6 do
            self:setText("num_text" .. i, "?")
        end
        self:setObjectVisible("lottery_red_point", self.m_model.m_data.stage ~= 0)
    else
        local number = string.split(self.m_model.m_data.self_number, "|")
        for i=1,6 do
            self:setText("num_text" .. i, number[i] or "?")
        end
        self:setObjectVisible("lottery_red_point", false)
    end
    self:updateLeftReward()
    self:refreshRedPoint()
end

function M:updateLeftReward()
    local cfg_data = self.m_model:getLotteryReward()
    if cfg_data then
        for i=1,4 do
            local cell = self:findGameObject("cell" .. i)
            local luaBehaiour = cell:GetComponent("LuaBehaviour")
            local data = cfg_data[i]
            if data then
                cell:SetActive(true)
                local ItemNode = luaBehaiour:FindGameObject("ItemNode")
                GameUtil:updateItemElement(ItemNode, data.data.reward[1], true,true, function()
                    audio:SendEvtUI("Play_UI_Popup_1")
                end)
            else
                cell:SetActive(false)
            end
        end
    end
end


function M:updateActivityTimer()
    local data = self.m_model:getActivityData()
    if data then
        local server_time = UserDataManager:getServerTime()
        local active_time = data.end_ts - server_time
        if active_time > 0 then
            if self.m_model.m_data.stage_end_ts > 0 then
                local leftTime = self.m_model.m_data.stage_end_ts - server_time
                if leftTime >= 0 then
                    local time_text = GameUtil:formatTimeBySecond(leftTime)
                    local text = Language:getTextByKey("half_year_text_0015") .. time_text
                    self:setText("text_timer", text)
                else
                    self:updateMsg("update_data")
                end
            else
                self:setTextByLanKey("text_timer", "new_str_0558")
            end
        else
            self:updateMsg("time_over")
        end
    else
        self:updateMsg(99999)
    end
end

function M:playAnim()
    if not IsNull(self.yaojiangji_sp) then
        self.yaojiangji_sp.AnimationState:ClearTracks()
        self.yaojiangji_sp.AnimationState:SetAnimation(0, "tap", false)
    end
end

function M:refreshRedPoint()
    self:setObjectVisible("result_red_point", false)
    for k,v in pairs(self.m_model.m_data.history or {}) do
        if v.self_number and v.lucky_num and v.self_number ~= "" and v.lucky_num ~= "" and v.reced ~= 1 then
            self:setObjectVisible("result_red_point", true)
            break
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end


return M