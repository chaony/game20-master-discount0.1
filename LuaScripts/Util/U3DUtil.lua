--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-04-14 11:10:22
]]
U3DUtil = {}
local M = U3DUtil

function M:init()
    
end

function M:u3dToUGUIPosition( camera3d, u3d_pos )
    local screenPos = camera3d:WorldToScreenPoint(u3d_pos);
    local uguiPos = static_ui_camera:ScreenToWorldPoint(screenPos);
    return uguiPos;
end

--U3D的按下事件
function M:Input_GetKeyDown( keyCode )
    local u3d_keycode = CS.UnityEngine.KeyCode.W
    if keyCode == "w" then
        u3d_keycode = CS.UnityEngine.KeyCode.W
    elseif keyCode == "s" then
        u3d_keycode = CS.UnityEngine.KeyCode.S
    elseif keyCode == "a" then
        u3d_keycode = CS.UnityEngine.KeyCode.A
    elseif keyCode == "d" then
        u3d_keycode = CS.UnityEngine.KeyCode.D
    elseif keyCode == "o" then
        u3d_keycode = CS.UnityEngine.KeyCode.O
    elseif keyCode == "e" then
        u3d_keycode = CS.UnityEngine.KeyCode.E
    elseif keyCode == "p" then
        u3d_keycode = CS.UnityEngine.KeyCode.P
    end
    if CS.UnityEngine.Input.GetKeyDown(u3d_keycode) then
        return true;
    else
        return false;
    end
end

--U3D的抬起事件
function M:Input_GetKeyUp( keyCode )
    local u3d_keycode = CS.UnityEngine.KeyCode.W
    if keyCode == "w" then
        u3d_keycode = CS.UnityEngine.KeyCode.W
    elseif keyCode == "s" then
        u3d_keycode = CS.UnityEngine.KeyCode.S
    elseif keyCode == "a" then
        u3d_keycode = CS.UnityEngine.KeyCode.A
    elseif keyCode == "d" then
        u3d_keycode = CS.UnityEngine.KeyCode.D
    elseif keyCode == "o" then
        u3d_keycode = CS.UnityEngine.KeyCode.O
    end
    if CS.UnityEngine.Input.GetKeyUp(u3d_keycode) then
        return true;
    else
        return false;
    end
end

--按下鼠标 value 键
function M:Input_GetMouseButtonDown( value )
    return CS.UnityEngine.Input.GetMouseButtonDown(value)
end

--抬起鼠标 value 键
function M:Input_GetMouseButtonUp( value)
    return CS.UnityEngine.Input.GetMouseButtonUp(value)
end

--按下鼠标 滚轮 键
function M:Input_GetMouseAxis( value )
    return CS.UnityEngine.Input.GetAxis(value)
end

--GameObject 找物体
function M:GameObject_Find( name )
    return CS.UnityEngine.GameObject.Find(name)
end

--本地获取int型数据
function M:PlayerPrefs_GetInt(name, defaultValue)
    return CS.UnityEngine.PlayerPrefs.GetInt(name, defaultValue)
end

--设定数据
function M:PlayerPrefs_SetInt(name, value)
    return CS.UnityEngine.PlayerPrefs.SetInt(name, value);
end

--返回浮点数
function M:PlayerPrefs_GetFloat(name, defaultValue)
    return CS.UnityEngine.PlayerPrefs.GetFloat(name, defaultValue);
end

--设定数据
function M:PlayerPrefs_SetFloat(name, value)
    return CS.UnityEngine.PlayerPrefs.SetFloat(name, value);
end

--返回字符串
function M:PlayerPrefs_GetString(name, defaultValue)
    return CS.UnityEngine.PlayerPrefs.GetString(name, defaultValue);
end

--设定数据
function M:PlayerPrefs_SetString(name, value)
    return CS.UnityEngine.PlayerPrefs.SetString(name, value);
end

--保存数据
function M:PlayerPrefs_Save()
    return CS.UnityEngine.PlayerPrefs.Save();
end


--设定雾效的距离
function M:Set_RenderSettings_Fog_Distance( dis )
    CS.UnityEngine.RenderSettings.fogEndDistance = dis;
end


--获取平台
function M:Get_Platform(value)
    return CS.UnityEngine.Application.platform
end

--是否是某个平台
function M:Is_Platform( platform )
    if platform == "OSXEditor" then
        return CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.OSXEditor;
    elseif platform == "WindowsEditor" then
        return CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.WindowsEditor;
    elseif platform == "Android" then
        return CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.Android;
    elseif platform == "WindowsPlayer" then
        return CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.WindowsPlayer;
    elseif platform == "IPhonePlayer" then
        return CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.IPhonePlayer;
    end
    return false;
end

--获取网络模式
function M:Get_NetWorkMode()
    local internetReachability = CS.UnityEngine.Application.internetReachability
	if internetReachability == CS.UnityEngine.NetworkReachability.ReachableViaLocalAreaNetwork then
		return "wifi"  -- wifi或者有线
	elseif internetReachability == CS.UnityEngine.NetworkReachability.ReachableViaCarrierDataNetwork then
		return "4G"  -- 2.3.5G
	else
		return "nil"  -- 无网络
	end
end

--设定动画状态机的模式
function M:Set_AnimtorUpdateMode( anim, value )
    if anim ~= nil then
        if value == 0 then
            anim.updateMode = CS.UnityEngine.AnimatorUpdateMode.Normal
        elseif value == 1 then
            anim.updateMode = CS.UnityEngine.AnimatorUpdateMode.AnimatePhysics
        elseif value == 2 then
            anim.updateMode = CS.UnityEngine.AnimatorUpdateMode.UnscaledTime
        end
    end
end

function M:IsHov()
    return CS.wt.framework.ResourcesHelper.useHovBattle
end

function M:Test()
    return CS.wt.framework.ResourcesHelper.useTest
end


function M:Get_SystemInfo_Indentifier()
    return CS.UnityEngine.SystemInfo.deviceUniqueIdentifier
end

function M:Get_SystemLanguage()
    return CS.UnityEngine.Application.systemLanguage
end

-- 当前电量
function M:Get_SystemInfo_batteryLevel()
    return CS.UnityEngine.SystemInfo.batteryLevel
end

--颜色
function M:Color(r,g,b,a)
    return CS.UnityEngine.Color(r,g,b,a)
end

function M:GetMousePosition()
    return CS.UnityEngine.Input.mousePosition
end

function M:RectTransform_Edge( type )
    if type == "top" then
        return CS.UnityEngine.RectTransform.Edge.Top
    elseif type == "bottom" then
        return CS.UnityEngine.RectTransform.Edge.Bottom
    end
end

function M:SetUnScale( unscale )
    CS.wt.framework.TweenTool.SetUnScale(unscale);
end

function M:MoveTo( go,target,time,loop,isLocal,ease,func)
    CS.wt.framework.TweenTool.MoveTo(go,target,time,loop,isLocal,ease,func)
end

function M:ColorTo( go,target,time,loop,ease,func)
    CS.wt.framework.TweenTool.ColorTo(go,target,time,loop,ease,func)
end

function M:ScaleTo( go,target,time,loop,isLocal,ease,func)
    CS.wt.framework.TweenTool.ScaleTo(go,target,time,loop,isLocal,ease,func)
end


--[[
    @desc: 
    author:{author}
    time:2020-04-14 14:01:31
    @return:
]]------------------------------------------------- UI -----------------------------------------

--销毁物体
function M:Destroy(obj, prefabName)
    if not IsNull(obj) then
        CS.wt.framework.AssetLoaderHelper.Inst:DestoryInstance(obj,prefabName or "","", false);
    end
end


function M:DestroyAndBundle(obj, prefabName, deleteBundle, delayTime)
    if not IsNull(obj) then
        if deleteBundle == nil then
            deleteBundle = true;
        end
        CS.wt.framework.AssetLoaderHelper.Inst:DestoryUI(obj,prefabName or "","",deleteBundle, delayTime or 3);
    end
end

function M:GameObjectDestroy(obj)
    CS.UnityEngine.GameObject.Destroy(obj)
end

--实例化
function M:Instantiate(obj)
    return CS.UnityEngine.GameObject.Instantiate(obj)
end

--创建一个GameObject
function M:GameObject(name)
    return CS.UnityEngine.GameObject(name);
end

function M:LookRotation(dir)
    return CS.UnityEngine.Quaternion.LookRotation(dir)
end

--屏幕宽度
function M:Screen_Width()
    return CS.UnityEngine.Screen.width
end

--屏幕高度
function M:Screen_Height()
    return CS.UnityEngine.Screen.height
end

--log 错误
function M:LogError(log)
    return CS.UnityEngine.Debug.LogError
end

--log
function M:Log(log)
    return CS.UnityEngine.Debug.Log
end

--logWarning
function M:LogWarning(log)
    return CS.UnityEngine.Debug.LogWarning
end

function M:Random_Range(min, max)
    return CS.UnityEngine.Random.Range(min,max);
end

--时间
function M:Time()
    return CS.UnityEngine.Time.time;
end

--时间
function M:RealtimeSinceStartup()
    return CS.UnityEngine.Time.realtimeSinceStartup;
end

--RectTransform Axis的模式
function M:RectTransform_Axis( name )
    if name == "hor" then
        return CS.UnityEngine.RectTransform.Axis.Horizontal;
    elseif name == "ver" then
        return CS.UnityEngine.RectTransform.Axis.Vertical;
    end
end

function M:Get_EventTriggerType(type_name)
    if type_name == "PointerDown" then
        return CS.UnityEngine.EventSystems.EventTriggerType.PointerDown
    elseif type_name == "PointerUp" then
        return CS.UnityEngine.EventSystems.EventTriggerType.PointerUp
    elseif type_name == "PointerEnter" then
        return CS.UnityEngine.EventSystems.EventTriggerType.PointerEnter
    elseif type_name == "PointerExit" then
        return CS.UnityEngine.EventSystems.EventTriggerType.PointerExit
    elseif type_name == "Drag" then
        return CS.UnityEngine.EventSystems.EventTriggerType.Drag
    end
end

function M:Get_TextAnchor(type_name)
    if type_name == "UpperLeft" then
        return CS.UnityEngine.TextAnchor.UpperLeft
    elseif type_name == "UpperCenter" then
        return CS.UnityEngine.TextAnchor.UpperCenter
    elseif type_name == "UpperRight" then
        return CS.UnityEngine.TextAnchor.UpperRight
    elseif type_name == "MiddleLeft" then
        return CS.UnityEngine.TextAnchor.MiddleLeft
    elseif type_name == "MiddleCenter" then
        return CS.UnityEngine.TextAnchor.MiddleCenter
    elseif type_name == "MiddleRight" then
        return CS.UnityEngine.TextAnchor.MiddleRight
    elseif type_name == "LowerLeft" then
        return CS.UnityEngine.TextAnchor.LowerLeft
    elseif type_name == "LowerCenter" then
        return CS.UnityEngine.TextAnchor.LowerCenter
    elseif type_name == "LowerRight" then
        return CS.UnityEngine.TextAnchor.LowerRight
    end
end

--设定字体
function M:Set_Font()
    local font = ResourceUtil:LoadFont("Fonts/方正北魏楷书_GBK", "fonts")
    local fzfont = ResourceUtil:LoadFont("Fonts/方正行楷_GBK", "fonts")
    local num_font = ResourceUtil:LoadFont("Fonts/方正北魏楷书_GBK", "fonts")
    CS.UIFontController.wordFont = font
    CS.UIFontController.numberFont = num_font
    CS.UIFontController.btnFont = fzfont
    CS.UIFontController.titleFont = fzfont
end


--UI用的所有类型
function M:Get_Text()
    return CS.UnityEngine.UI.Text;
end

function M:Get_Image()
    return CS.UnityEngine.UI.Image;
end

function M:Get_Button()
    return CS.UnityEngine.UI.Button;
end

function M:Get_InputField()
    return CS.UnityEngine.UI.InputField;
end

function M:Get_Slider()
    return CS.UnityEngine.UI.Slider;
end

function M:Get_ScrollRect()
    return CS.UnityEngine.UI.ScrollRect;
end

function M:Get_RectTransform()
    return CS.UnityEngine.RectTransform;
end

function M:Get_Toggle()
    return CS.UnityEngine.UI.Toggle;
end

function M:Get_Outline()
    return CS.UnityEngine.UI.Outline;
end

function M:Get_CanvasGroup()
    return CS.UnityEngine.CanvasGroup;
end

function M:Get_VerticalLayoutGroup()
    return CS.UnityEngine.UI.VerticalLayoutGroup;
end

function M:Get_ContentSizeFitter()
    return CS.UnityEngine.UI.ContentSizeFitter;
end

function M:Get_OutlineEx()
    return CS.TooSimpleFramework.UI.OutlineEx;
end

function M:Get_LuaBehaviour()
    return CS.wt.framework.LuaBehaviour
end

function M:Get_ContentImmediate()
    return CS.wt.framework.ContentImmediate
end


function M:Get_ToggleGroup()
    return CS.UnityEngine.UI.ToggleGroup    
end

function M:Get_Camera()
    return CS.UnityEngine.Camera  
end

function M:Get_Input( )
    return CS.UnityEngine.Input
end

function M:Get_Animation()
    return CS.UnityEngine.Animation
end

function M:Get_ParticleSystem()
    return CS.UnityEngine.ParticleSystem
end

function M:Get_Animator()
    return CS.UnityEngine.Animator
end

function M:Get_EffectTime()
    return CS.EffectTime
end

function M:Get_LayoutRebuilder()
    return CS.UnityEngine.UI.LayoutRebuilder
end

function M:Get_DOTweenAnimation()
    return CS.DG.Tweening.DOTweenAnimation
end

return M;