---@class PetFreeControl: OOControlBase
---@field m_model PetFreeModel
---@field m_view PetFreeView
local M = class("PetFreeControl", LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg, data)
    if msg == 99999 then
        -- 返回
        self:updateMsg("common_refresh", self.m_model.m_pet_change, "PetBreeding.PetBag")
        self:closeView()
    elseif msg == "select_index" then
        self.m_model:selectHandle(data)
        self.m_view:refreshUI(true)
    elseif msg == "help_btn" then
        -- 说明
        self:openView("Pops.CommonHelpPop", { title = Language:getTextByKey("pet_evo_lv_0019"), content = Language:getTextByKey("tid#PetRuleDes_4") })
    elseif msg == "freet_btn" then
        if self.m_model:checkIsEgg(self.m_model.index_oid) == false then
            if self.m_model.index_oid == 0 then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("pet_evo_lv_0038"), delay_close = 2})
            elseif self.m_model:checkTips() then
                local isTips, tips_text = self.m_model:checkTips()
                local params =
                {
                    on_ok_call = function()
                        self:netDisband()
                    end,
                    no_close_btn = false,
                    tow_close_btn = true,
                    text = tips_text
                }
                self:openView("Pops.CommonPop", params)
            else
                self:netDisband()
            end
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("pet_evo_lv_0020"), delay_close = 2})
        end
    elseif msg == "level_btn" then
        --self:netLvUp()
    elseif msg == "free_all_btn" then
        self.m_model:setAllSelectState()
        self.m_view:setCheckImg()
        self.m_view:refreshUI(false)
    elseif msg == "sift_btn" then
        self.m_view:showSift()
    elseif msg == "quality_btn1" then
        if self.m_model.m_select_sift ~= 1 then
            self.m_model.m_select_sift = 1
            self.m_model:InitData()
            self.m_model:resetFreePets()
            self.m_view:refreshUI(false)
        end
        self.m_view:hideSift(false)
    elseif msg == "quality_btn2" then
        if self.m_model.m_select_sift ~= 2 then
            self.m_model.m_select_sift = 2
            self.m_model:InitData()
            self.m_model:resetFreePets()
            self.m_view:refreshUI(false)
        end
        self.m_view:hideSift(false)
    elseif msg == "quality_btn3" then
        if self.m_model.m_select_sift ~= 3 then
            self.m_model.m_select_sift = 3
            self.m_model:InitData()
            self.m_model:resetFreePets()
            self.m_view:refreshUI(false)
        end
        self.m_view:hideSift(false)
    elseif msg == "quality_btn4" then
        if self.m_model.m_select_sift ~= 4 then
            self.m_model.m_select_sift = 4
            self.m_model:InitData()
            self.m_model:resetFreePets()
            self.m_view:refreshUI(false)
        end
        self.m_view:hideSift(false)
    elseif msg == "quality_btn5" then
        if self.m_model.m_select_sift ~= 5 then
            self.m_model.m_select_sift = 5
            self.m_model:InitData()
            self.m_model:resetFreePets()
            self.m_view:refreshUI(false)
        end
        self.m_view:hideSift(false)
    elseif msg == "quality_btn6" then
        if self.m_model.m_select_sift ~= 6 then
            self.m_model.m_select_sift = 6
            self.m_model:InitData()
            self.m_model:resetFreePets()
            self.m_view:refreshUI(false)
        end
        self.m_view:hideSift(false)
    elseif msg == "mask_img" then
        self.m_view:hideSift(false)
    end
end

--发送升级请求
function M:netLvUp()
    local function callFunc(data)
        if data then
            self.m_view:refreshUI(true)
        end
    end
    self.m_model:getNetData("pet_level_up", { pet_oid = self.m_model.index_oid, level = 75}, callFunc, nil, true)
end

--发送归林请求
function M:netDisband()
    local function callFunc(data)
        if data then
            self.m_model:InitData()
            self.m_model:resetFreePets()
            self.m_view:refreshUI(false)
            RewardUtil:rewardTipsByData(data.reward)
            self:updateMsg("update_pet_index", nil,"PetBreeding.PetBreedingMain")
            self.m_model.m_pet_change = true
        end
    end
    self.m_model:getNetData("pet_disband", { pet_oids = self.m_model.m_free_pets}, callFunc, nil, true)
end

function M:destroy()
    M.super.destroy(self)
end

return M
