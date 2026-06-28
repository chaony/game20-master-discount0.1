---@class OptionsSettingPopView:OOPopBase
local M = class("OptionsSettingPopView", LikeOO.OOPopBase)

M.m_uiName = "Options/OptionsSettingPop"
M.m_size_type = 2


local __click_effect_toggle = {"click_effect_close_btn", "click_effect_open_btn"}                  --点击屏幕特效
local __fps_toggle = {"closeFps_btn","openFps_btn"}                                                --帧率
local __stroke_toggle = {"closeStroke_btn","openStroke_btn"}                                       --描边
local __shadow_toggle = {"closeShadow_btn","openShadow_btn"}                                       --阴影

local __anti_aliasing_toggle = {"low_anti_aliasing","middle_anti_aliasing","height_anti_aliasing"} --抗锯齿
local __quality_toggle = {"low_quality","middle_quality","height_quality","auto_quality"}          --游戏画质
local __hfr_toggle = {"closeHfr_btn","openHfr_btn"}                                                --高帧率(60帧)
local __power_toggle = {"low_power","middle_power","height_power"}                                 --分辨率
local __scene_toggle = {"low_scene","middle_scene","height_scene"}                                 --场景质量
local __effect_toggle = {"low_effect","middle_effect","height_effect"}                             --特效质量

local setting_mode = {
    {mode_id = 1,mode_img = "frame_img",mode_text = "frame_text",panel = "frame_panel"}, --画面设置
    {mode_id = 2,mode_img = "voice_setting_img",mode_text = "voice_setting_text",panel = "voice_setting_panel"}, --声音设置
    {mode_id = 3,mode_img = "privacy_img",mode_text = "privacy_text",panel = "privacy_panel"}, --隐私设置
}


function M:onEnter()
    self.setting_mode = setting_mode
    local music_slider = self:findSlider("music_slider")
    music_slider.value = audio.music_volume
    local effic_slider = self:findSlider("effic_slider")
    effic_slider.value = audio.effect_volume
    local voice_slider = self:findSlider("voice_slider")
    voice_slider.value = audio.cv_volume
    self:setTextByLanKey("privacy_text", "new_str_1034")
    self:setTextByLanKey("frame_text", "new_str_1035")
    self:setTextByLanKey("voice_setting_text", "new_str_1036")
    self:setTextByLanKey("hide_text", "new_str_1037")
    self:setTextByLanKey("system_text", "new_str_1038")
    self:setTextByLanKey("sdk_text", "new_str_1039")
    self:setTextByLanKey("user_text", "new_str_1040")
    self:setTextByLanKey("person_list_text", "new_str_1041")
    self:setTextByLanKey("person_info_text", "new_str_0117")
    self:setTextByLanKey("common_title_text", "options_str_0002")
    self:setTextByLanKey("music_text", "new_str_0978")
    self:setTextByLanKey("effic_text", "new_str_0979")
    self:setTextByLanKey("voice_text", "new_str_0980")
    self:setTextByLanKey("quality_text", "new_str_0981")
    self:setTextByLanKey("low_text", "new_str_0977")
    self:setTextByLanKey("middle_text", "new_str_0976")
    self:setTextByLanKey("height_text", "new_str_0975")
    self:setTextByLanKey("auto_text", "new_str_0985")
    self:setTextByLanKey("click_effect_text", "new_str_0986")
    self:setTextByLanKey("click_effect_open_text", "new_str_0987")
    self:setTextByLanKey("click_effect_close_text", "new_str_0988")
    self:setTextByLanKey("fps_text", "new_str_0989")
    self:setTextByLanKey("openFps_text", "new_str_0990")
    self:setTextByLanKey("closeFps_text", "new_str_0991")
    self:setTextByLanKey("Anti_Aliasing_text", "new_str_0992")
    self:setTextByLanKey("Anti_Aliasing_low_text", "new_str_0977")
    self:setTextByLanKey("Anti_Aliasing_middle_text", "new_str_0976")
    self:setTextByLanKey("Anti_Aliasing_height_text", "new_str_0975")
    self:setTextByLanKey("stroke_text", "new_str_0993")
    self:setTextByLanKey("openStroke_text", "new_str_0994")
    self:setTextByLanKey("closeStroke_text", "new_str_0995")
    self:setTextByLanKey("shadow_text", "new_str_0996")
    self:setTextByLanKey("openShadow_text", "new_str_0997")
    self:setTextByLanKey("closeShadow_text", "new_str_0998")
    self:setTextByLanKey("hfr_text", "new_str_0999")
    self:setTextByLanKey("openHfr_text", "new_str_1000")
    self:setTextByLanKey("closeHfr_text", "new_str_1001")
    self:setTextByLanKey("power_text", "new_str_1002")
    self:setTextByLanKey("power_height_text", "new_str_0975")
    self:setTextByLanKey("power_middle_text", "new_str_0976")
    self:setTextByLanKey("power_low_text", "new_str_0977")
    self:setTextByLanKey("scene_text", "new_str_1006")
    self:setTextByLanKey("scene_low_text", "new_str_0977")
    self:setTextByLanKey("scene_middle_text", "new_str_0976")
    self:setTextByLanKey("scene_height_text", "new_str_0975")
    self:setTextByLanKey("effects_text", "new_str_1007")
    self:setTextByLanKey("effects_low_text", "new_str_0977")
    self:setTextByLanKey("effects_middle_text", "new_str_0976")
    self:setTextByLanKey("effects_height_text", "new_str_0975")



    self:setMusicValue()
    self:setEffectValue()
    self:setVoiceValue()
    self:sliderEvent()

    if SDKUtil.is_oneSDK then
        local restart_btn = self:findGameObject("restart_btn")
        restart_btn.gameObject:SetActive(true)
        self:setTextByLanKey("restart_btn_text", "logout_exit_sdk")
    elseif not SDKUtil.is_no_sdk then
		local textObj = self:findGameObject("restart_btn_text")
		local txt = textObj:GetComponent("Text")
		txt.text =Language:getTextByKey("sdk_txt_006")
    end





    ----判断是否有用户中心
    --if SDKUtil.is_gmsdk then
    --    local platform = GameUtil:getpPlatform()
    --    if platform == "Ios" then
    --        local restart_btn = self:findGameObject("restart_btn")
    --        restart_btn.gameObject:SetActive(true)
    --
    --    else
    --        SDKUtil:SDKIsAvailable(function(params) --没有用户中心接口
    --            local restart_btn = self:findGameObject("restart_btn")
    --            restart_btn.gameObject:SetActive(params.data)
    --        end,"gsdk_api_open_user_center")
    --    end
    --end

    if LODUtil.init_lodlevel == 0 then
        self:setObjectVisible("height_anti_aliasing",false);
        self:setObjectVisible("Anti_Aliasing_height_text",false);
    end

    self:setObjectVisible("overseaBind_btn",false);

    self:setObjectVisible("privacy", false)
    self:refreshMode()
end

--设置设置页签
function M:refreshMode()
    for i, v in pairs(self.setting_mode) do
        if v.mode_id == self.m_model.m_setting_mode then
            self:setObjectVisible(v.panel,true)
            self:setImg("a_ui_currency_yeqian_h_s","common_ui",v.mode_img)
        else
            self:setObjectVisible(v.panel,false)
            self:setImg("a_ui_currency_yeqian_h_n","common_ui",v.mode_img)
        end
    end
end

--整体lod设定 
--value  低 0 中 1 高 2 自定义 3
function M:setGameQuality( value )
    self:updateToggerGroup(__quality_toggle, value)
end

--设定抗锯齿 
--value 低 0 中 1 高 2
function M:setAntiAliasing(value)
    self:updateToggerGroup(__anti_aliasing_toggle, value)
end


--设定场景lod
--value 低 0 中 1 高 2
function M:setScene(value)
    self:updateToggerGroup(__scene_toggle, value)
end

--设定特效lod
--value 低 0 中 1 高 2
function M:setEffect(value)
    self:updateToggerGroup(__effect_toggle, value)
end

--设定场景lod
--value 低 0 中 1 高 2
function M:setPower(value)
    self:updateToggerGroup(__power_toggle, value)
end

--设定描边
--value 0 关闭 1 开启
function M:setStroke(value)
    self:updateToggerGroup(__stroke_toggle, value)
end

--设定阴影
--value 0 关闭 1 开启
function M:setShadow(value)
    self:updateToggerGroup(__shadow_toggle, value)
end


--开启高帧率
--value 0 关闭 1 开启
function M:setHfr(value)
    self:updateToggerGroup(__hfr_toggle, value)
end

--开启FPS
--value 0 关闭 1 开启
function M:setFPS(value)
    self:updateToggerGroup(__fps_toggle, value)
end

--开启特效效果
--value 0 关闭 1 开启
function M:setEffectShow(value)
    self:updateToggerGroup(__click_effect_toggle, value)
end


function M:updateToggerGroup( toggle_table, value )
    for i, v in ipairs(toggle_table) do
        local toggle = self:findGameObject(v);
        if value == (i-1) then
            GameUtil:updateToggleButton(toggle, true);
        else
            GameUtil:updateToggleButton(toggle, false);
        end
    end
end


function M:sliderEvent()
    local function musicSlider(value)
        self:updateMsg("music_value", value)
    end
    self:addSliderListener("music_slider", musicSlider)

    local function efficSlider(value)
        self:updateMsg("effic_value", value)
    end
    self:addSliderListener("effic_slider", efficSlider)

    local function efficSlider(value)
        self:updateMsg("voice_value", value)
    end
    self:addSliderListener("voice_slider", efficSlider)
end

function M:refreshUI()
    self:updateClickEffectBtn()
end

function M:updateClickEffectBtn()
end

function M:setMusicValue()
    local value = audio.music_volume or 0
    self:setTextByLanKey("music_value_text", tostring(math.floor(value * 100)) .. "%")
end

function M:setVoiceValue()
    local value = audio.cv_volume or 0
    self:setTextByLanKey("voice_value_text", tostring(math.floor(value * 100)) .. "%")
end

function M:setEffectValue()
    local value = audio.effect_volume or 0
    self:setTextByLanKey("effect_value_text", tostring(math.floor(value * 100)) .. "%")
end

return M
