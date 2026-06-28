--==================================
-- file:  View.lua
-- brief:  酒楼
--==================================
local M = class("HotelView", LikeOO.OOPopBase)

M.m_uiName = "Hotel/Hotel"
M.m_size_type = 1

function M:onEnter()
    self:setTextByLanKey("close_title_text", "hotel_text_001")
    self:setTextByLanKey("game1_btn_text", "hotel_text_031")
    self:setTextByLanKey("game2_btn_text", "hotel_text_032")
    self:setTextByLanKey("game3_btn_text", "hotel_text_033")
    self:setTextByLanKey("game4_btn_text", "fate_text_001")
    self:setTextByLanKey("hall_btn_text", "hotel_text_005")
    self:setTextByLanKey("reward_btn_text", "hotel_text_006")
    self.m_gray_img = self:findImage("gray_image")
    self.m_info_obj = self:findGameObject("info_detail_obj")
    local base_cfg = ConfigManager:getCfgByName("hotel_room_base")
    for k,v in ipairs(base_cfg) do
        self:setTextByLanKey("room_name_" .. k, v.name)
        local room_lv = self.m_model.m_rooms_lv[k]
        local open_gacha_lv = v.open_gacha_room_level and v.open_gacha_room_level[1] or nil
        if open_gacha_lv ~= nil then
            local attr = v.gacha_attr_id
            local func_names = {"hotel_text_041", "hotel_text_042", "hotel_text_042"}
            self:setTextByLanKey("gacha" .. k .. "_btn_text", func_names[attr])
            self:refreshGachaOption(k, room_lv, open_gacha_lv)
        end
    end
	self:refreshUI()
    self:refreshRedPoint()
    self:refreshDailyRewardPoint()
    self:refreshGachaRedPoint()
    self.m_focus = 0
    self:refreshStage()
end

function M:refreshUI()
    self:setTextByLanKey("level_text", self.m_model.m_level)
    self:setTextByLanKey("times_text", "hotel_text_007", self.m_model.m_times)
    self:setTextByLanKey("total_day_text", self.m_model:getRunDay())
    self:setTextByLanKey("total_coin_text", GameUtil:formatValueToString(self.m_model.m_his_coin))
    self:setObjectVisible("daily_reward_point", self.m_model.m_is_daily_reward == false)
end

function M:showOption(index)
    if index <= 0 then
        self:setObjectVisible("option" .. self.m_focus, false)
        return
    end
    self:setObjectVisible("option" .. self.m_focus, false)
    self:setObjectVisible("option" .. index, true)
    self.m_focus = index
end

--抽卡选项置灰与点亮
function M:refreshGachaOption(room_id, room_lv, open_gacha_lv)
    local btn_img = self:findImage("gacha" .. room_id .. "_btn")
    if btn_img == nil then
        return
    end
    if room_lv >= open_gacha_lv then
        btn_img.material = nil
    else
        btn_img.material = self.m_gray_img.material
    end
end

function M:refreshGachaRedPoint()
    for i = 1, 3 do
        local point_img = self:findGameObject("gacha" .. i .. "_red_point")
        local is_red = self.m_model:isGachaRedPoint(i)
        if point_img then
            point_img:SetActive(is_red == true)
        end
    end
end

function M:refreshDailyRewardPoint()
    local daily_reward_point = self:findGameObject("daily_reward_point")
    if self.m_model.m_is_daily_reward == true then
        daily_reward_point:SetActive(false)
        return
    end
    daily_reward_point:SetActive(true)
    self.m_daily_sequence = Tweening.DOTween.Sequence()
    self.m_daily_sequence:AppendInterval(0.8)
    self.m_daily_sequence:Append(daily_reward_point.transform:DOScale(Vector3(-0.8, 0.8, 0.8), 0.2))
    self.m_daily_sequence:AppendInterval(0.8)
    self.m_daily_sequence:Append(daily_reward_point.transform:DOScale(0, 0.2))
    self.m_daily_sequence:SetLoops(-1)
    --daily_reward_point.transform:DOScale(Vector3(-0.8, 0.8, 0.8), 0.2):SetLoops(-1, Tweening.LoopType.Yoyo)
end

function M:refreshRedPoint()
    if self.m_sequence ~= nil then
        self.m_sequence:Kill()
    end
    --tween
    self.m_sequence = Tweening.DOTween.Sequence()
    for i = 1, 3 do
        local room_point_img = self:findImage("room_point_img_" .. i)
        local flag = self.m_model:isRoomRedPoint(i)
        if flag == true then
            room_point_img.gameObject:SetActive(true)
            self.m_sequence:Append(room_point_img.transform:DOScale(Vector3(1, 1, 1), 0.2))
            self.m_sequence:AppendInterval(1)
            self.m_sequence:Append(room_point_img.transform:DOScale(0, 0.2))
            self.m_sequence:AppendInterval(1)
        else
            room_point_img.gameObject:SetActive(false)
        end
    end
    self.m_sequence:SetLoops(-1)
end

--背景spine
function M:refreshStage()
    self:setTextByLanKey("level_text", self.m_model.m_level)
    local spine_res = self.m_model.m_back_spine_res
    local back_spine_res_name = "jiuxiu_jiulou_zhujiemian" .. spine_res
    local front_spine_res_name = "jiuxiu_jiulou_zhujiemian" .. spine_res
    local back_spine = self:findGameObject("back_spine")
    local front_spine = self:findGameObject("front_spine")
    GameUtil:updateSpineLoadSet(back_spine,"RoleSpine/" .. back_spine_res_name .. "hou_SkeletonData",back_spine_res_name .. "hou", 0,true)
    GameUtil:updateSpineLoadSet(front_spine,"RoleSpine/" .. front_spine_res_name .. "qian_SkeletonData",back_spine_res_name .. "qian", 0,true)
end

--切换背景spine效果
function M:changeStage()
    local function callback()
        self:refreshStage()
    end
    self:showCloud(callback)
end

--云
function M:showCloud(callBack)
    local cloudOpenAnim = ResourceUtil:LoadUIGameObject("FivelinesNew/FivelinesOpenAnim", Vector3.zero, nil)
    cloudOpenAnim.transform:SetParent(self.m_rootView.transform, false)
    self.m_control:setOnceTimer(0.7, function()
        if callBack then
            callBack()
        end
    end)
    self.m_control:setOnceTimer(1.5, function()
        UIUtil.destroyObject(cloudOpenAnim)
        GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("hotel_text_037", self.m_model.m_level), delay_close = 2})
        --if callBack then
        --    callBack()
        --end
    end)
end

function M:destroy()
    M.super.destroy(self)
    if self.m_sequence then
        self.m_sequence:Kill()
    end
    if self.m_daily_sequence then
        self.m_daily_sequence:Kill()
    end
end

return M