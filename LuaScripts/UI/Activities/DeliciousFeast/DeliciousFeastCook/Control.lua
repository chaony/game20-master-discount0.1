---@class DeliciousFeastCookControl: OOControlBase
---@field m_model DeliciousFeastCookModel
---@field m_view DeliciousFeastCookView
local M = class("DeliciousFeastCookControl", LikeOO.OOControlBase)
local meituan_url = "https://sf3-g-cn.dailygn.com/obj/sf-game-lf/gopscn/20220426-153556.jpg"

function M:onEnter()

end

function M:onHandle(msg, data)
    if msg == 99999 then
        -- 返回
        self:closeView()
    elseif msg == "item1" then
        --物品1
        self:handleMake(1)
    elseif msg == "item2" then
        --物品2
        self:handleMake(2)
    elseif msg == "item3" then
        --物品3
        self:handleMake(3)
    elseif msg == "item4" then
        --物品4
        self:handleMake(4)
    elseif msg == "refreshNum" then
        --刷新数量
        self.m_view:refreshCookItem()
    elseif msg == "menu_btn" and self.m_model:checkIsOfficial() then
        CS.UnityEngine.Application.OpenURL(meituan_url)
    elseif msg == "explain_btn" then
        -- 说明
        self:openView("Pops.CommonHelpPop", { title = Language:getTextByKey("feast_text_0011"), content = Language:getTextByKey("tid#MTDes1") })
    end
end

function M:handleMake(index)
    self.m_model:setCurIndex(index)
    local nums = self.m_model:getTargetMaxNums()
    local params = { maxNum = nums[index], item_data = self.m_model:getCurSelectData(), version = self.m_model:getVersion(), openId = self.m_model:getOpenId(), index = index}
    self:openView("Activities.DeliciousFeast.DeliciousFeastCookPop", params)
end

return M
