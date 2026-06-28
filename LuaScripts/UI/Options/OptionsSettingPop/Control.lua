---@class OptionsHeadPopControl:OOControlBase
local M = class("OptionsHeadPopControl", LikeOO.OOControlBase)

function M:onEnter()
    --特效 是否显示
    local effectShow_value = UserDataManager.local_data:getLocalDataByKey("effectShow",1)
    self:setEffectShow(effectShow_value)

    --FPS 是否显示
    local fps_value = UserDataManager.local_data:getLocalDataByKey("gameFPS",1)
    self:setFPS(fps_value)

    if LODUtil.init_lodlevel == 0 then
        self:setAntiAliasing(0)
        UserDataManager.local_data:setLocalDataByKey("phone_antiAliasing",0)
    else
        --抗锯齿
        local antiAliasing = UserDataManager.local_data:getLocalDataByKey("phone_antiAliasing",0)
        self:setAntiAliasing(antiAliasing)
    end

    local hfr_value = UserDataManager.local_data:getLocalDataByKey("hfr",1)
    self:setHfr(hfr_value)

    --本地取到画质等级
    local is_auto_setting = UserDataManager.local_data:getLocalDataByKey("is_auto_setting",0)
    if is_auto_setting == 1 then
        --自定义
        Logger.logError(" 自定义 ~~~~~~~~~"..is_auto_setting)
        self:setAutoQuality();
    else
        local value = UserDataManager.local_data:getLocalDataByKey("picture_quality",1)
        Logger.logError(" nushi 自定义 ~~~~~~~~~"..is_auto_setting)
        self:setGameQuality(value);
    end

    self.is_show_setting = nil
end


--设定自定义的画质
function M:setAutoQuality()
    --设置抗锯齿  低 0 中 1 高 2
    --local anti_value = UserDataManager.local_data:getLocalDataByKey("phone_antiAliasing",1)
    --self:setAntiAliasing(anti_value)
    --设置描边  0:关闭  1:开启
    local stroke_value = UserDataManager.local_data:getLocalDataByKey("stroke",1)
    self:setStroke(stroke_value)
    --设置阴影  0:关闭  1:开启
    local shadow_value = UserDataManager.local_data:getLocalDataByKey("shadow",1)
    self:setShadow(shadow_value)
    --设置高帧率(60帧)  0:关闭  1:开启
    local hfr_value = UserDataManager.local_data:getLocalDataByKey("hfr",1)
    self:setHfr(hfr_value)
    --设置分辨率 0,1,2
    local power_value = UserDataManager.local_data:getLocalDataByKey("power",1)
    self:setPower(power_value)
    --设置场景质量 0,1,2
    local scene_value = UserDataManager.local_data:getLocalDataByKey("sceneLod",1)
    self:setScene(scene_value)
    --设置特效质量 0,1,2
    local effect_value = UserDataManager.local_data:getLocalDataByKey("effectLod",1)
    self:setEffect(effect_value)
    
    UserDataManager.local_data:getLocalDataByKey("is_auto_setting",1)
    local value = UserDataManager.local_data:getLocalDataByKey("picture_quality",1)
    self.m_view:setGameQuality(value);
end


function M:setGameQuality(value)
    --0 低 1 中 2 高 3 自定义Logger.LogErrorf
    UserDataManager.local_data:setLocalDataByKey("picture_quality",value)
    LODUtil:setLodLevel(value)
    if value == 0 then
        self:setAntiAliasing(value)
    end
    self:setPower(value)
    self:setScene(value)
    self:setEffect(value)
    --0:关闭  1:开启
    if value >= 1 then
        self:setStroke(1)
    else
        self:setStroke(0)
    end
    --高配开启阴影
    if value == 2 then
        self:setShadow(1)
    else
        self:setShadow(0)
    end
    UserDataManager.local_data:setLocalDataByKey("is_auto_setting",0)
    self.m_view:setGameQuality(value);
end


function M:onHandle(msg, data)
    if msg == 99999 then -- 返回
        if self.is_show_setting then
            if not UserDataManager.client_data.update_login_token then
                SDKUtil:logIn(
                    function(newloginParam)
                        if newloginParam.result == true then
                            local tok = newloginParam.token
                            UserDataManager.client_data:setSdkToken(tok)
                        else
                        end
                    end,
                    Json.encode({inGameLogin = true})
                )
            end
        end

        self.is_show_setting = nil
        self:closeView()
    elseif msg == "click_effect_open_btn" then
        self:setEffectShow(1)
    elseif msg == "click_effect_close_btn" then
        self:setEffectShow(0)
    elseif msg == "low_quality" then
        local current_value = UserDataManager.local_data:getLocalDataByKey("picture_quality",1)
        self:tipsShow("quality_btn",current_value,0)
        --self:setGameQuality(0)
    elseif msg == "middle_quality" then
        local current_value = UserDataManager.local_data:getLocalDataByKey("picture_quality",1)
        self:tipsShow("quality_btn",current_value,1)
        --self:setGameQuality(1)
    elseif msg == "height_quality" then
        local current_value = UserDataManager.local_data:getLocalDataByKey("picture_quality",1)
        self:tipsShow("quality_btn",current_value,2)
        --self:setGameQuality(2)
    elseif msg == "music_value" then
        self.m_model:setMusicVolume(data)
        self.m_view:setMusicValue()
    elseif msg == "effic_value" then
        self.m_model:setEffectVolume(data)
        self.m_view:setEffectValue()
    elseif msg == "voice_value" then
        self.m_model:setCVVolume(data)
        self.m_view:setVoiceValue()
    elseif msg == "openFps_btn" then
        --开始FPS
        self:setFPS(1)
        self:updateMsg("frame_visible_status", nil, "parent")
    elseif msg == "closeFps_btn" then
        --关闭FPS
        self:setFPS(0)
        self:updateMsg("frame_visible_status", nil, "parent")
    elseif msg == "low_anti_aliasing" then
        --低抗锯齿
        self:setAntiAliasing(0)
    elseif msg == "middle_anti_aliasing" then
        --中抗锯齿
        local current_value = UserDataManager.local_data:getLocalDataByKey("phone_antiAliasing",1)
        self:tipsShow("anti_aliasing",current_value,1)
    elseif msg == "height_anti_aliasing" then
        --高抗锯齿
        local current_value = UserDataManager.local_data:getLocalDataByKey("phone_antiAliasing",1)
        self:tipsShow("anti_aliasing",current_value,2)
    elseif msg == "openStroke_btn" then 
        --开启描边
        self:setStroke(1)
        self:autoQuality()
    elseif msg == "closeStroke_btn" then 
        --关闭描边
        self:setStroke(0)
        self:autoQuality()
    elseif msg == "openShadow_btn" then 
        --开启阴影
        local current_value = UserDataManager.local_data:getLocalDataByKey("shadow",1)
        self:tipsShow("openShadow_btn",current_value,1)
        --self:setShadow(1)
        self:autoQuality()
    elseif msg == "closeShadow_btn" then 
        --关闭阴影
        self:setShadow(0)
        self:autoQuality()
    elseif msg == "openHfr_btn" then 
        --开启高帧率(60帧)
        local current_value = UserDataManager.local_data:getLocalDataByKey("hfr",1)
        self:tipsShow("Hfr_btn",current_value,1)
        --self:openTip("openHfr_btn")
        --self:setHfr(1)
        self:autoQuality()
    elseif msg == "closeHfr_btn" then
        --关闭高帧率(60帧)
        local current_value = UserDataManager.local_data:getLocalDataByKey("hfr",1)
        self:tipsShow("Hfr_btn",current_value,0)
        --self:setHfr(0)
        self:autoQuality()
    elseif msg == "low_power" then 
        --低分辨率
        --self:openPowerTip(0)
        local current_value = UserDataManager.local_data:getLocalDataByKey("power",1)
        self:tipsShow("power_btn",current_value,0)
        --self:setPower(0)
        self:autoQuality()
    elseif msg == "middle_power" then 
        --中分辨率
        local current_value = UserDataManager.local_data:getLocalDataByKey("power",1)
        self:tipsShow("power_btn",current_value,1)
        --self:setPower(1)
        self:autoQuality()
        --self:openPowerTip(1)
    elseif msg == "height_power" then 
        --高分辨率
        local current_value = UserDataManager.local_data:getLocalDataByKey("power",1)
        self:tipsShow("power_btn",current_value,2)
        --self:openTip("power_btn")
        --self:setPower(2)
        self:autoQuality()
        --self:openPowerTip(2)
    elseif msg == "low_scene" then 
        --场景质量低
        local current_value = UserDataManager.local_data:getLocalDataByKey("sceneLod",1)
        self:tipsShow("scene_btn",current_value,0)
        --self:setScene(0)
        self:autoQuality()
    elseif msg == "middle_scene" then 
        --场景质量中
        local current_value = UserDataManager.local_data:getLocalDataByKey("sceneLod",1)
        self:tipsShow("scene_btn",current_value,1)
        --self:setScene(1)
        self:autoQuality()
    elseif msg == "height_scene" then 
        --场景质量高
        local current_value = UserDataManager.local_data:getLocalDataByKey("sceneLod",1)
        self:tipsShow("scene_btn",current_value,2)
        --self:setScene(2)
        self:autoQuality()
    elseif msg == "low_effect" then 
        --特效质量低
        local current_value = UserDataManager.local_data:getLocalDataByKey("effectLod",1)
        self:tipsShow("effect_btn",current_value,0)
        --self:setEffect(0)
        self:autoQuality()
    elseif msg == "middle_effect" then
        --特效质量中
        local current_value = UserDataManager.local_data:getLocalDataByKey("effectLod",1)
        self:tipsShow("effect_btn",current_value,1)
        --self:setEffect(1)
        self:autoQuality()
    elseif msg == "height_effect" then 
        --特效质量高
        local current_value = UserDataManager.local_data:getLocalDataByKey("effectLod",1)
        self:tipsShow("effect_btn",current_value,2)
        --self:setEffect(2)
        self:autoQuality()
    elseif msg == "restart_btn" then
        self.is_show_setting = true
        self:loginAgain()
    elseif msg == "privacy_click_btn" then --隐私设置
        self.m_model.m_setting_mode = 3
        self.m_view:refreshMode() 
    elseif msg == "frame_click_btn" then --画面设置
        self.m_model.m_setting_mode = 1
        self.m_view:refreshMode()
    elseif msg == "voice_setting_click_btn" then --声音设置
        self.m_model.m_setting_mode = 2
        self.m_view:refreshMode()
    elseif msg == "hide_btn" then --隐私协议
        SDKUtil:openUrl("https://lf26-cdn-tos.draftstatic.com/obj/ies-hotsoon-draft/GSDK/542735dc-9989-4794-844d-8e3618097e32.html")
    elseif msg == "system_btn" then --系统权限
        SDKUtil:openUrl("https://sf3-cdn-tos.douyinstatic.com/obj/ies-hotsoon-draft/GSDK/os_perms_newdomain.html")
    elseif msg == "sdk_btn" then --sdk列表
        SDKUtil:openUrl("https://sf3-draftcdn-tos.pstatp.com/obj/ies-hotsoon-draft/GSDK/third_party_sdk_list.html") 
    elseif msg == "user_btn" then --用户协议
        SDKUtil:openUrl("https://sf3-cdn-tos.douyinstatic.com/obj/ies-hotsoon-draft/GSDK/user_contract_newdomain.html") 
    elseif msg == "person_list_btn" then --个人信息清单
        SDKUtil:openUrl("https://lf26-cdn-tos.draftstatic.com/obj/ies-hotsoon-draft/GSDK/info_collect_list.html")
    elseif msg == "person_info_btn" then --个人信息
        SDKUtil:callSdkFunc(
            "isSandbox",
            {},
            function(rst)
                local url = "https://bsdk"
                if rst.isSandbox then
                    url = url .. "-sandbox"
                end

                local name = UserDataManager.user_data:getUserStatusDataByKey("name")
                local server_Name = UserDataManager.server_data:getServerName()

                url = url .. ".snssdk.com/h5/personal_protection/query?nickname="
                    ..string.urlencode(name) .."&roleid="..UserDataManager.user_data:getUid().."&gamename="..string.urlencode("武林闲侠")
                    .."&version="..GameVersionConfig.CLIENT_VERSION
             
                Logger.log(url, "person_info sdk WebView")    

                SDKUtil:openUrl(url, 
                function()
                end)
            end
        )
   
    end
end

function M:loginAgain()

    if SDKUtil.is_oneSDK then
        SDKUtil:logOut(handler(self, function()
            GameMain.reStart()
        end))

    else
        SDKUtil:setCallback(
                "game_logout",
                function(param)
                    GameMain.reStart()
                end
        )

        if not SDKUtil:handleGameEvent("user_setting") then
            GameMain.reStart()
        end
    end


end

function M:setEffectShow(value)
    self.m_model:setEffectShow(value)
    self.m_view:setEffectShow(value);
end

function M:setAntiAliasing(value)
    self.m_model:setAntiAliasing(value)
    self.m_view:setAntiAliasing(value);
end

function M:setStroke(value)
    self.m_model:setStroke(value)
    self.m_view:setStroke(value);
end

function M:setPower(value)
    self.m_model:setPower(value)
    self.m_view:setPower(value);
end

function M:setShadow(value)
    self.m_model:setShadow(value)
    self.m_view:setShadow(value);
end

function M:setHfr(value)
    self.m_model:setHfr(value)
    self.m_view:setHfr(value);
end

function M:setFPS(value)
    self.m_model:setFPS(value)
    self.m_view:setFPS(value);
end

function M:setScene(value)
    self.m_model:setScene(value)
    self.m_view:setScene(value);
end

function M:setEffect(value)
    self.m_model:setEffect(value)
    self.m_view:setEffect(value);
end

function M:openPowerTip(data)
    local params = {
        --ok_btn_light_time = 3,
        text = Language:getTextByKey("new_str_0972"),
        on_ok_call = function(msg)
            self:setPower(data)
            self:autoQuality()
            GameMain.reStart();
        end,
    }
    self:openView("Pops.CommonPop",params)
end


function M:openTip(name)
    local tip_text = 0
    if name == "height_power" then --高分辨率
        tip_text = Language:getTextByKey("new_str_1008")
    elseif name == "openHfr_btn" then --高帧率
        tip_text = Language:getTextByKey("new_str_1009")
    end
    
    local params = 
    {
        text = tip_text,
        isreward = true,
        on_ok_call = function(msg)
            if name == "height_power" then --高分辨率
                self:setPower(2)
                self:autoQuality()
            elseif name == "openHfr_btn" then --高帧率
                self:setHfr(1)
                self:autoQuality()
            end
        end,
        on_cancel_call = function(msg)
            
        end
    }
    self:openView("Pops.CommonPop",params)
end

--自定义画质
function M:autoQuality()
    UserDataManager.local_data:setLocalDataByKey("is_auto_setting",1)
    --self.m_view:setGameQuality(3);
end

--切换设置弹窗
function M:tipsShow(name,current_value,next_value)
    local tip_text = ""
    if next_value > current_value then
        tip_text = Language:getTextByKey("new_str_1010")
    elseif next_value < current_value then
        tip_text =  Language:getTextByKey("new_str_1011")
    end
    if tip_text == "" then
        return
    end
    local params =
    {
        text = tip_text,
        isreward = true,
        on_ok_call = function(msg)
            if name == "power_btn" then --分辨率
                self:setPower(next_value)
            elseif name == "Hfr_btn" then --帧率
                self:setHfr(next_value)
            elseif name == "scene_btn" then --场景
                self:setScene(next_value)
            elseif name == "effect_btn" then --特效
                self:setEffect(next_value)
            elseif name == "quality_btn" then --画质
                self:setGameQuality(next_value)
            elseif name == "openShadow_btn" then --阴影
                self:setShadow(next_value)
            elseif name == "anti_aliasing" then --抗鋸齒
                self:setAntiAliasing(next_value)
            end
        end,
        on_cancel_call = function(msg)

        end
    }
    self:openView("Pops.CommonPop",params)
end

return M
