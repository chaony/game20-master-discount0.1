local M = class("HotelRunGainView", LikeOO.OOPopBase)

M.m_uiName = "Hotel/HotelRunGain"
M.m_size_type = 2

function M:onEnter()
    self:setTextByLanKey("title", "hotel_text_021")
	self:refreshUI()
end

function M:refreshUI()
    local cfg = ConfigManager:getCfgByName("hotel_room_base")
    self:setTextByLanKey("gain_text", "hotel_text_026", self.m_model.m_gain_value)
    for i,v in pairs(self.m_model.m_outputs) do
        local k = tonumber(i)
        self:setObjectVisible("gain_" .. k, true)
        self:setTextByLanKey("gain_name_" .. k, cfg[k].name)
        self:setText("gain_value_" .. k, v)
    end
    --back spine
    local spine_res = self.m_model.m_spine_res
    local back_spine_res_name = "jiuxiu_jiulou_zhujiemian" .. spine_res
    --local front_spine_res_name = "jiuxiu_jiulou_zhujiemian" .. spine_res
    local back_spine = self:findGameObject("back_spine")
    --local front_spine = luaBehaviour:FindGameObject("front_spine")
    GameUtil:updateSpineLoadSet(back_spine,"RoleSpine/" .. back_spine_res_name .. "hou_SkeletonData",back_spine_res_name .. "hou", 0,true)
    --GameUtil:updateSpineLoadSet(front_spine,"RoleSpine/" .. front_spine_res_name .. "hou_SkeletonData",back_spine_res_name, 0,true)
end

function M:destroy()
    M.super.destroy(self)
end

return M