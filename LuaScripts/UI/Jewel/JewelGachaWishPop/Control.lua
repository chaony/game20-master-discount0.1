local M = class("JewelGachaWishPopControl",LikeOO.OOControlBase)

function M:onEnter()
    --self.m_guide_file_name = "UI.Jewel.JewelGachaWishPop.Guide"
end

function M:startGuide()
    --[[local have_guide = UserDataManager.guide_data:setAnyTeamGuide(27, 2)
    if have_guide then
        if self.m_guide then
            self.m_guide:start()
        end
    end]]--
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "help_btn" then
        local params = {
            title = Language:getTextByKey("tid#Jewel_2"),
            content = Language:getTextByKey("tid#Jewel_3"),
        }
        self:openView("Pops.CommonFiveLineHelpPop", params)
    --elseif msg == "tab_btn" then
    --    local quality = data
    --    self.m_view:updateListScroll(quality)
    elseif msg == "select_wish" then
        local times = data.times
        if self.m_model.m_wish_times == times then
            return
        end
        self.m_model.m_wish_times = times
        self.m_view:updateListScroll(times)
    elseif msg == "select_jewel" then
        self:clickJewel(data)
    end
end

--点击某个英雄
function M:clickJewel(id)
    local last_jewel_id = self.m_model:getJewelId(self.m_model.m_wish_times)
    --if key == nil then
    --    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0925"), delay_close = 2})
    --    return
    --end
    self:requestWish(self.m_model.m_wish_times, id, last_jewel_id)
end

function M:requestWish(times, replace_jewel_id, last_jewel_id)
    local last_id = last_jewel_id
    local function callBack(response)
        local times = response.num
        local jewel_id = response.jewel_id
        self.m_model:updateWish(times, jewel_id)
        self:updateMsg("update_wish", {times = times, id = jewel_id}, "Jewel.JewelGacha")
        self.m_view:refreshWishes()
        self.m_view:refreshListCheck(response.jewel_id, true)
        if last_id > 0 then
            self.m_view:refreshListCheck(last_id, false)
        end
    end
    local params = {num = times, jewel_id = replace_jewel_id}
    self.m_model:getNetData("jewel_set_wish", params, callBack)
end

function M:destroy()
    M.super.destroy(self)
end

return M