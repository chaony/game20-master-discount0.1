---@class PetFactorySendPopControl: OOControlBase
---@field m_model PetFactorySendPopModel
---@field m_view PetFactorySendPopView
local M = class("PetFactorySendPopControl", LikeOO.OOControlBase)

function M:onEnter()
    M.super.onCreate(self)
end

function M:onHandle(msg, data)
    if msg == 99999 then
        -- 返回
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    elseif msg == "big_close_btn" or msg == "close_btn" then
        self:closeView()
    elseif msg == "send_btn" then
        -- 请求派遣
        local petID = self.m_model.m_selected_oid
        local pos = self.m_model.m_curPos - 1
        self:dispatchRequest(petID, pos)
    elseif msg == "quick_send_btn" then
        -- 请求一键派遣
        self:dispatchQuickRequest()
    elseif msg == "click_cell" then
        if data.pos and data.pos ~= 0 then
            -- 召回
            self:recallRequest(data.pos - 1)
        else
            self:setShow(data)
        end
    end
end

---========================[net function]======================================

---派遣
---@param petID number 宠物唯一ID
---@param pos number 位置索引，从 0 开始
function M:dispatchRequest(petID, pos)
    if petID == "" then
        local msgStr = Language:getTextByKey("pet_factory_text_0016")
        GameUtil:lookInfoTips(self, { msg = msgStr, delay_close = 2 })
        return
    end
    
    local function callback(response)
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("pet_factory_text_0028"), delay_close = 2 })
        response.tag = "pet_factory_dispatch"
        self:updateMsg("pet_factory_update_ui", response, "PetBreeding.PetFactoryPop")
        self:closeView()
    end

    print("[REQ_PET_FACTORY][dispatch]" .. table.dump({pos = pos, pet_oid = petID}, true, 5))
    self.m_model:getNetData("pet_factory_dispatch", { pet_oid = petID, pos = pos }, callback)
end

---一键派遣
function M:dispatchQuickRequest()
    local function callback(response)
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("pet_factory_text_0029"), delay_close = 2 })
        response.tag = "pet_factory_quick_dispatch"
        self:updateMsg("pet_factory_update_ui", response, "PetBreeding.PetFactoryPop")
        self:notifyGetPetIndexData()
        self:closeView()
    end

    print("[REQ_PET_FACTORY][dispatchQuick]")
    self.m_model:getNetData("pet_factory_quick_dispatch", { }, callback)
end

--- 召回宠物
---@param pos number 位置索引，从 0 开始
function M:recallRequest(pos)
    local function callback(response)
        response.tag = "pet_factory_recall"
        self:updateMsg("pet_factory_update_ui", response, "PetBreeding.PetFactoryPop")
        self.m_model:setExcludePetList(response)
        self:notifyGetPetIndexData()
        if self.m_view then 
            self.m_view:refreshUI()
        end
    end

    print("[REQ_PET_FACTORY][recall]" .. table.dump({pos = pos}, true, 5))
    self.m_model:getNetData("pet_factory_recall", { pos = pos }, callback)
end

-- 通知刷新数据
function M:notifyGetPetIndexData()
    self:updateMsg("update_pet_index", nil, "PetBreeding.PetBreedingMain")
end

---============================================================

function M:setShow(data)
    self.m_model:setSelectID(data.oid)
    if self.m_view then
        self.m_view:refreshUI()    
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M
