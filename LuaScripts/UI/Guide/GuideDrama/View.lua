---@class GuideDramaView:OOPopBase
---@field m_model GuideDramaModel
--- 剧情对话
local M = class("GuideDramaView", LikeOO.OOPopBase)

M.m_uiName = "Guide/GuideDrama"
M.m_size_type = 2
local __WORD_ARR = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}

--位置配置
M.posConfig = {
    [1] = {
        -1100,
        360,
        0
    },
    [2] = {
        -400,
        360,
        0
    },
    [3] = {
        0,
        360,
        0
    },
    [4] = {
        400,
        360,
        0
    },
    [5] = {
        1100,
        360,
        0
    },
}

--出现或隐藏对应位置配置
M.relative_posConfig = {
    [2] = {
        -500,
        360,
        0
    },
    [3] = {
        0,
        280,
        0
    },
    [4] = {
        500,
        360,
        0
    },
}
M.color_name = Color(120/255,199/255,252/255)
function M:onEnter()
    self.cur_bank = nil 
    self.m_role_left_face = 1
    self.m_role_right_face = 1
    self:setTextByLanKey("skip_btn_text", "new_str_0346")
    self.drama_name_text = self:setTextByLanKey("drama_name_text", "")
    self.m_drama_text = self:setTextByLanKey("drama_text", "")
    self:setTextByLanKey("skip_btn_text","new_str_0346")
    self:setTextByLanKey("kv_tips_text","kv_tips_text")
    
    self.m_drama_text_rect = self:findRectTransform("drama_text")
    --图片互动
    self.m_move_spine = self:findSkeletonGraphic("move_spine");
    self.m_move_spine_btn = self:findGameObject("move_spine_btn");

    --立绘
    self.m_left_hero_spine = self:findSkeletonGraphic("left_hero_spine")
    self.m_center_hero_spine  = self:findSkeletonGraphic("center_hero_spine")
    self.m_right_hero_spine = self:findSkeletonGraphic("right_hero_spine")

    self.m_left_hero_img = self:findImage("left_hero_img")
    self.m_center_hero_img  = self:findImage("center_hero_img")
    self.m_right_hero_img = self:findImage("right_hero_img")
    
    self.m_left_hero = self:findGameObject("left_hero");
    self.m_right_hero = self:findGameObject("right_hero");
    self.m_center_hero = self:findGameObject("center_hero");
    
    --人物名牌
    self.m_left_hero_brand = self:findGameObject("left_brand");
    self.m_right_hero_brand = self:findGameObject("right_brand");
    self.m_center_hero_brand = self:findGameObject("center_brand");
    
    --专门用于cg的黑屏
    self.m_cg_black_screen = self:findGameObject("cg_black_screen");
    self.m_cg_black_screen_doTween = self.m_cg_black_screen:GetComponent(typeof(CS.DG.Tweening.DOTweenAnimation));

    self.m_left_hero_trans = self.m_left_hero.transform
    self.m_right_hero_trans = self.m_right_hero.transform
    self.m_center_hero_trans = self.m_center_hero.transform
    self.m_left_hero_group = self.m_left_hero:GetComponent("CanvasGroup")
    self.m_right_hero_group = self.m_right_hero:GetComponent("CanvasGroup")
    self.m_center_hero_group = self.m_center_hero:GetComponent("CanvasGroup")
    
    --立绘DoTween
    self.m_left_hero_spine_move_doTween = self.m_left_hero:GetComponent(typeof(CS.DG.Tweening.DOTweenAnimation));
    self.m_left_hero_spine_fade_doTween = self.m_left_hero_img.gameObject:GetComponent(typeof(CS.DG.Tweening.DOTweenAnimation));
    
    self.m_center_hero_spine_move_doTween = self.m_center_hero:GetComponent(typeof(CS.DG.Tweening.DOTweenAnimation));
    self.m_center_hero_spine_fade_doTween = self.m_center_hero_img.gameObject:GetComponent(typeof(CS.DG.Tweening.DOTweenAnimation));
    
    self.m_right_hero_spine_move_doTween = self.m_right_hero:GetComponent(typeof(CS.DG.Tweening.DOTweenAnimation));
    self.m_right_hero_spine_fade_doTween = self.m_right_hero_img.gameObject:GetComponent(typeof(CS.DG.Tweening.DOTweenAnimation));
    
    --图片
    self.m_left_item = self:findImage("left_item")
    self.m_center_item = self:findImage("center_item")
    self.m_right_item = self:findImage("right_item")
    
    --特殊图片播放动画出现
    self.m_left_item_doTween = self.m_left_item.gameObject:GetComponent(typeof(CS.DG.Tweening.DOTweenAnimation));
    self.m_center_item_doTween = self.m_center_item.gameObject:GetComponent(typeof(CS.DG.Tweening.DOTweenAnimation));
    self.m_right_item_doTween = self.m_right_item.gameObject:GetComponent(typeof(CS.DG.Tweening.DOTweenAnimation));
    
    --气泡
    self.m_left_pop = self:findGameObject("left_pop"):GetComponent("CanvasGroup")
    self.m_center_pop = self:findGameObject("center_pop"):GetComponent("CanvasGroup")
    self.m_right_pop = self:findGameObject("right_pop"):GetComponent("CanvasGroup")
    
    --全屏特效
    self.m_screen_effect = self:findImage("screen_effect")
    --cg长图
    self.m_changtu = self:findRawImage("cg_changtu");
    --黑屏背景
    self.m_blackScreenbg = self:findImage("blackScreenbg");
    --cg动画
    self.m_changtu_tween = self.m_changtu.gameObject:GetComponent(typeof(CS.DG.Tweening.DOTweenAnimation))
    self.m_changtu_rect = self.m_changtu.gameObject:GetComponent(typeof(CS.UnityEngine.RectTransform))
    --更新图片
    --GameUtil:updateResourcesImg
    
    self.m_black_screen = self:findImage("black_screen")
    self.m_white_text = self:findText("white_text")

    self.m_black_screen_tween = self.m_black_screen.gameObject:GetComponent(typeof(CS.DG.Tweening.DOTweenAnimation))
    self.m_white_text_tween  = self.m_white_text.gameObject:GetComponent(typeof(CS.DG.Tweening.DOTweenAnimation))
    
    self.m_name_node = self:findGameObject("name_node")
    self.m_bg_image = self:findImage("bg_image")
    self.bg_image_1 = self:findImage("bg_image_1")
    self.bg_image_2 = self:findImage("bg_image_2")
    self:setObjectVisible("select_drama_node", false)

    if self.m_model.dialogue_type == GlobalConfig.WORLD_MAP_EVENT.REGIONAL_EVENT then
        self:setObjectVisible("skip_btn", false)
    else
        self:setObjectVisible("skip_btn", true)
    end
    self:refreshUI()
    self:refreshAutoImg()
    --self:setObjectVisible("anim_node", false)
    --self.m_luaBehaviour:AddAnimEvent(function()
    --    self:setObjectVisible("anim_node", true)
    --end)
end

--在每句开始之前初始化UI
function M:resetViewBeforeWord()
    self:setColorA(self.m_black_screen,0);
    self:setColorA(self.m_white_text,0)
    self:setColorA(self.m_left_pop,0, false)
    self:setColorA(self.m_center_pop,0, false)
    self:setColorA(self.m_right_pop,0, false)
    --self:setColorA(self.m_left_hero_img,0)
    --self:setColorA(self.m_center_hero_img,0)
    --self:setColorA(self.m_right_hero_img,0)
    self:setColorA(self.m_left_item,0)
    self:setColorA(self.m_center_item,0)
    self:setColorA(self.m_right_item,0)
    self:setColorA(self.m_blackScreenbg, 0.6)
    self:setColorA(self.m_bg_image, 0)
    self:setObjectVisible("bg_image", false)
    self.m_move_spine.gameObject:SetActive(false)
end

--显示cg长图
function M:showCGChangeTu( tex, time, restart )
    if restart then
        --渐渐黑屏
        --self.m_cg_black_screen_doTween.duration = time;
        --self.m_cg_black_screen_doTween.endValueFloat = 1
        --self.m_cg_black_screen_doTween.easeType = CS.DG.Tweening.Ease.OutQuad;
        --self.m_cg_black_screen_doTween:CreateTween();
        --self.m_cg_black_screen_doTween.tween:Play();
        --self.m_control:setOnceTimer(1.5,function()
        --    self.m_cg_black_screen_doTween.duration = time;
        --    self.m_cg_black_screen_doTween.endValueFloat = 0
        --    self.m_cg_black_screen_doTween.easeType = CS.DG.Tweening.Ease.OutQuad;
        --    self.m_cg_black_screen_doTween:CreateTween();
        --    self.m_cg_black_screen_doTween.tween:Play();
            self:setColorA(self.m_changtu,1)
            GameUtil:updateResourcesTexture(self.m_changtu,"Texture/drama/"..tex)
            self:moveChangTu(time)
        --end)
    else
        self:setColorA(self.m_changtu,1)
        GameUtil:updateResourcesTexture(self.m_changtu,"Texture/drama/"..tex)
    end
end

--self.m_bg_scale
--移动cg长图
function M:moveChangTu( time )
    self.m_changtu_rect.anchoredPosition3D = Vector3(0,0,0);
    if self.m_changtu_tween ~= nil then
        self.m_changtu_tween.duration = time;
        --移动目标点
        self.m_changtu_tween.endValueV3 = Vector3(-900 * self.m_bg_scale,0,0)
        self.m_changtu_tween.easeType = CS.DG.Tweening.Ease.OutQuad;
        self.m_changtu_tween:CreateTween();
        self.m_changtu_tween.tween:Play();
    end
end


--显示互动图片
function M:showMoveSpine( spineName, hasDialog )
    self.m_move_spine.gameObject:SetActive(true)
    local hero_spine = spineName.. "_SkeletonData"
    local sk_data = ResourceUtil:GetSk(hero_spine, "rolespine_"..string.lower(hero_spine))
    self.m_move_spine.skeletonDataAsset = sk_data
    self.m_move_spine:Initialize(true)
    self.m_move_spine_btn:SetActive(true);
    if self.m_move_spine ~= nil then
        AnimUtil:setSpineAnimation(self.m_move_spine, 0, "animation1",false);
    end
end

--点击播放
function M:clickMoveSpine()
    if self.m_move_spine ~= nil then
        Logger.log(" 点击 互动图片 ~~~~~~~~~~~~~~~~~~~~~~")
        AnimUtil:setSpineAnimation(self.m_move_spine, 0, "animation2",false);
    end
    self.m_move_spine_btn:SetActive(false);
end


--0 = 无滤镜
--1 = 速度线
--2 = 受伤
--3 = 拼死
--4 = 灼烧
--5 = 中毒
--6 = 老照片
function M:showScreenEffect( index )
    if index > 0 then
        GameUtil:updateResourcesImg(self.m_screen_effect,"Texture/drama/screenEffect"..1)
    end
end

--显示黑屏白字
function M:showBlackScreen()
    self.m_black_screen_tween:CreateTween();
    self.m_black_screen_tween.tween:Play();
    self.m_white_text_tween:CreateTween();
    self.m_white_text_tween.tween:Play();
end

--显示特殊图片
function M:showSpecialImg(type,imgName,floor, width,height)
    local img = nil
    local img_tween;
    if type == 1 then
        img = self.m_left_item ;
        img_tween = self.m_left_item_doTween;
    elseif type == 2 then
        img = self.m_center_item;
        img_tween = self.m_center_item_doTween;
    elseif type == 3 then
        img = self.m_right_item;
        img_tween = self.m_right_item_doTween;
    end
    if img ~= nil and imgName ~= nil then
        GameUtil:updateResourcesImg(img,"Texture/drama/"..imgName)
    end

    if img_tween ~= nil then
        img_tween.duration = 0.5;
        img_tween.endValueFloat = 1
        img_tween.easeType = CS.DG.Tweening.Ease.OutQuad;
        img_tween:CreateTween();
        img_tween.tween:Play();
    end
    
    if img ~= nil then
        local imgRect = img:GetComponent("RectTransform")
        local rect = imgRect.sizeDelta;
        rect.x = width
        rect.y = height
        imgRect.sizeDelta = rect;
    end
end


--显示气泡
function M:showPop( type, id, offset_x, offset_y )
    if id == nil then return end;
    offset_x = offset_x or 0;
    offset_y = offset_y or 0;
    local pop = nil
    local popName = nil;
    if type == 1 then
        pop = self.m_left_pop;
        popName = "left_pop_icon"
    elseif type == 2 then
        pop = self.m_center_pop;
        popName = "center_pop_icon"
    elseif type == 3 then
        pop = self.m_right_pop;
        popName = "right_pop_icon"
    end
    --将气泡显示出来
    if pop ~= nil then
        self:setColorA(pop,1, false)
    end
    local pos = pop.transform.localPosition
    pos.x = pos.x + offset_x
    pos.x = pos.x + offset_y
    pop.transform.localPosition = pos
    self:setImg("pop"..id,"item_icon",popName)
end


--执行各种动画效果
function M:DoTweenHandler( type, moveType, moveTime, fadeTime, taragetPosIndex)
    local move_doTween = nil
    local fade_doTween = nil
    local obj = nil 
    local img = nil
    local trans = nil
    local group = nil
    local is_spine = false 

    if type == 1 then
        move_doTween = self.m_left_hero_spine_move_doTween;
        fade_doTween = self.m_left_hero_spine_fade_doTween;
        obj = self.m_left_hero;
        img = self.m_left_hero_img;

        trans = self.m_left_hero_trans
        group = self.m_left_hero_group
        --中
    elseif type == 2 then
        move_doTween = self.m_center_hero_spine_move_doTween;
        fade_doTween = self.m_center_hero_spine_fade_doTween;
        obj = self.m_center_hero;
        img = self.m_center_hero_img;
        
        trans = self.m_center_hero_trans
        group = self.m_center_hero_group
        --右
    elseif type == 3 then
        move_doTween = self.m_right_hero_spine_move_doTween;
        fade_doTween = self.m_right_hero_spine_fade_doTween;
        obj = self.m_right_hero;
        img = self.m_right_hero_img;
        
        trans = self.m_right_hero_trans
        group = self.m_right_hero_group
    else
        move_doTween = self.m_left_hero_spine_move_doTween;
        fade_doTween = self.m_left_hero_spine_fade_doTween;
        obj = self.m_left_hero;
        img = self.m_left_hero_img;

        trans = self.m_left_hero_trans
        group = self.m_left_hero_group
    end
    
    --1=移动
    --2=出现
    --3=消失
    --4=渐变出现
    --5=渐变消失
    --6=移动渐变出现
    --7=移动渐变消失
    
    if moveType == 1 then
        if trans ~= nil and group ~= nil then
            local pos = self.posConfig[taragetPosIndex];
            local endValue = Vector3(pos[1],pos[2],pos[3])
            local sequence = Tweening.DOTween.Sequence()
            sequence:Append(trans:DOLocalMove(endValue, moveTime):SetEase(CS.DG.Tweening.Ease.OutQuad))
        end
        
    elseif moveType == 2 then
        local pos = self.posConfig[taragetPosIndex];
        self:setColorA(group, 1, false)
        obj.transform.localPosition = Vector3(pos[1],pos[2],pos[3])
        Logger.log(" 出现 "..moveType.." 出现时间 "..fadeTime )
    elseif moveType == 3 then
        self:setColorA(group, 0, false)
        Logger.log(" 消失 "..moveType.." 出现时间 "..fadeTime )
    elseif moveType == 4 then
        if fade_doTween ~= nil then
            Logger.log(" 渐变出现 "..moveType.." 出现时间 "..fadeTime )
            fade_doTween.duration = fadeTime;
            self.anim_time = fadeTime
            fade_doTween.endValueFloat = 1
            fade_doTween.easeType = CS.DG.Tweening.Ease.OutQuad;
            fade_doTween:CreateTween();
            fade_doTween.tween:Play();
        end
    elseif moveType == 5 then
        if fade_doTween ~= nil then
            Logger.log(" 渐变消失 "..moveType.." 出现时间 "..fadeTime )
            fade_doTween.duration = fadeTime;
            self.anim_time = fadeTime
            fade_doTween.endValueFloat = 0
            fade_doTween.easeType = CS.DG.Tweening.Ease.OutQuad;
            fade_doTween:CreateTween();
            fade_doTween.tween:Play();
        end
    elseif moveType == 6 then
            Logger.log(" 移动渐变出现 "..moveType.." 出现时间 "..fadeTime )
        if trans ~= nil and group ~= nil then
            local relative_pos = self.relative_posConfig[taragetPosIndex];
            trans.localPosition = Vector3(relative_pos[1],relative_pos[2],relative_pos[3])
            group.alpha = 0
            local pos = self.posConfig[taragetPosIndex];
            local endValue = Vector3(pos[1],pos[2],pos[3])
            local sequence = Tweening.DOTween.Sequence()
            sequence:Append(trans:DOLocalMove(endValue, moveTime):SetEase(CS.DG.Tweening.Ease.OutQuad))
            sequence:Join(DOTweenModuleUI.DOFade(group,1,fadeTime):SetEase(CS.DG.Tweening.Ease.OutQuad))
        end
    elseif moveType == 7 then
        if trans ~= nil and group ~= nil then
            local pos = self.posConfig[taragetPosIndex]
            local relative_pos = self.relative_posConfig[taragetPosIndex]
            trans.localPosition = Vector3(pos[1],pos[2],pos[3])
            group.alpha = 1
            local endValue = Vector3(relative_pos[1],relative_pos[2],relative_pos[3])
            local sequence = Tweening.DOTween.Sequence()
            sequence:Append(trans:DOLocalMove(endValue, moveTime):SetEase(CS.DG.Tweening.Ease.OutQuad))
            sequence:Join(DOTweenModuleUI.DOFade(group,0,fadeTime):SetEase(CS.DG.Tweening.Ease.OutQuad))
        end
    end
end

function M:playLastImgAnimation(img_path)
    local function endCallFunc()
        self:setColorA(self.bg_image_1, 1)
        self:setObjectVisible("bg_image_1", false)
    end
    self:setObjectVisible("bg_image_1", true)
    GameUtil:updateResourcesImg(self.bg_image_1.gameObject, "Texture/map_plot/"..img_path)
    local sequence = Tweening.DOTween.Sequence()
    sequence:Append(DOTweenModuleUI.DOFade(self:findImage("bg_image_1"), 0, 1))
    sequence:OnComplete(endCallFunc)
    sequence:SetAutoKill(true)
end

function M:getTweenAnimation(obj, type)
    local tweens = obj:GetComponents(typeof(CS.DG.Tweening.DOTweenAnimation))
    if type == 1 then
        type = CS.DG.Tweening.DOTweenAnimation.AnimationType.LocalMove
    elseif type == 2 then
        type = CS.DG.Tweening.DOTweenAnimation.AnimationType.Fade
    end
    for i = 0, tweens.Length - 1 do
        local tween = tweens[i]
        if tween.animationType == type then
            return tween
        end
    end
    --local tween = obj:AddComponent(typeof(CS.DG.Tweening.DOTweenAnimation))
    --if type == 1 then
    --    tween.animationType = CS.DG.Tweening.DOTweenAnimation.AnimationType.LocalMove
    --elseif type == 2 then
    --    tween.animationType = CS.DG.Tweening.DOTweenAnimation.AnimationType.Fade
    --end
    --return tween
end

function M:setColorA( img, a, isImg )
    if isImg ~= false then
        local color = img.color
        color.a = a
        img.color = color
    else
        img.alpha = a
    end
end

function M:refreshUI()
    self:showDramaInfo()
end

function M:playVoice(dialogue_cfg)
    if dialogue_cfg.voice ~= nil and dialogue_cfg.voice ~= "" then
        if self.cur_bank ~= dialogue_cfg.soundbank then
            if self.cur_bank ~= nil and self.cur_bank ~= "" then
                ResourceUtil:UnLoadBank(self.cur_bank)
            end
            ResourceUtil:LoadBank(dialogue_cfg.soundbank)
            self.cur_bank = dialogue_cfg.soundbank
        end

        self.cur_vocie = audio:SendEvtUI(dialogue_cfg.voice)
    end
end

function M:stopAllVoice()
    if self.cur_vocie ~= nil then
        audio:StopPlayingID(self.cur_vocie)
        self.cur_vocie = nil
    end
end

function M:showDramaInfo()
    self:stopAllVoice()   -- 停止音效
    local talk_data = self.m_model:getCurDialog()
    if talk_data then
        self:resetViewBeforeWord();
        local dialogue_cfg = talk_data.dialogue_cfg
        self.anim_time = 0
        self:setName(dialogue_cfg)
        self:setSpine(dialogue_cfg)
        self.m_word = GameUtil:replacePlayerName(dialogue_cfg.words)
        self.m_audio_time = dialogue_cfg.time or 3
        self.m_word_len  = string.len(self.m_word)
        self.m_left = self.m_word_len
        self.m_model:setTalking(true)
        self:doDramaWord()
        self.m_control:runStoryEvent(dialogue_cfg)
        self:setBrand(dialogue_cfg)
        self:playVoice(dialogue_cfg)
    end
end

function M:setDramaText()
    if self.m_model:getTalking() then
        self:killAnim()
        self:setTextByLanKey("drama_text", self.m_word)
        self.m_model:setTalking(false)
        self:checkAuto()
    end
end

function M:setName(dialogue_cfg)
    local role_name = dialogue_cfg.role_name or ""
    if role_name ~= "" then
        local num = 0
        role_name, num = GameUtil:replacePlayerName(role_name)
        self:setTextByLanKey("drama_name_text", role_name)
        self.m_name_node:SetActive(true)
        self.drama_name_text.color = num > 0 and GlobalConfig.COMMON_COLLOR.COMMON_4 or GlobalConfig.COMMON_COLLOR.COMMON_1
        self.m_drama_text.color = num > 0 and self.color_name or GlobalConfig.COMMON_COLLOR.COMMON_1
    else
        self.m_name_node:SetActive(false)
    end
    local name_pos = dialogue_cfg.name_pos
    -- 1右 2左 3中
    if name_pos == 1 then
        UIUtil.setLocalPosition(self.m_name_node, self.m_view_width*0.5 - 184)
    elseif name_pos == 2 then
        UIUtil.setLocalPosition(self.m_name_node, - self.m_view_width*0.5 + 184)
    else
        UIUtil.setLocalPosition(self.m_name_node, 0)
    end
end

function M:setBrand(dialogue_cfg)
    local role_left = dialogue_cfg.role_left
    local role_right = dialogue_cfg.role_right
    local role_center = dialogue_cfg.role_center

    local npc_table = self.m_model:getNpcCfg()
    
    if role_left ~= 0 and npc_table[role_left] ~= nil and dialogue_cfg.left_up == 1 and npc_table[role_left].class_name ~= "" then
        local function callback()
            self.m_left_hero_brand:SetActive(true)
            self:setTextByLanKey("left_brand_text", npc_table[role_left].class_name)
        end
        if self.anim_time > 0 then
            self.m_left_hero_brand:SetActive(false)
            self.m_control:setOnceTimer(self.anim_time, callback)
        else
            callback()
        end
    else
        self.m_left_hero_brand:SetActive(false)
    end

    if role_right ~= 0 and npc_table[role_right] ~= nil and dialogue_cfg.right_up == 1 and npc_table[role_right].class_name ~= "" then
        local function callback()
            self.m_right_hero_brand:SetActive(true)
            self:setTextByLanKey("right_brand_text", npc_table[role_right].class_name)
        end
        if self.anim_time > 0 then
            self.m_right_hero_brand:SetActive(false)
            self.m_control:setOnceTimer(self.anim_time, callback)
        else
            callback()
        end
    else
        self.m_right_hero_brand:SetActive(false)
    end
    
    if role_center ~= 0 and npc_table[role_center] ~= nil and dialogue_cfg.center_up == 1 and npc_table[role_center].class_name ~= "" then
        local function callback()
            self.m_center_hero_brand:SetActive(true)
            self:setTextByLanKey("center_brand_text", npc_table[role_center].class_name)
        end
        if self.anim_time > 0 then
            self.m_center_hero_brand:SetActive(false)
            self.m_control:setOnceTimer(self.anim_time, callback)
        else
            callback()
        end
    else
        self.m_center_hero_brand:SetActive(false)
    end
end

--[[
    face
    1=角色立绘向右，在右侧时镜像
    2=角色立绘向左，在左侧时镜像
    0=角色正向，不转向
]]
function M:setSpine(dialogue_cfg)
    local role_left = dialogue_cfg.role_left	
    local role_right = dialogue_cfg.role_right	
    local role_center = dialogue_cfg.role_center

    if self.m_role_left ~= role_left then
        local hero_cfg = self:refreshSpine(role_left, self.m_left_hero_img, self.m_left_hero_spine)
        if hero_cfg then
            self.m_role_left_face = hero_cfg.face == 2 and -1 or 1
        end
        self.m_role_left = role_left
    end
    if self.m_role_center ~= role_center then
        self:refreshSpine(role_center, self.m_center_hero_img, self.m_center_hero_spine)
        self.m_role_center = role_center
    end
    if self.m_role_right ~= role_right then
        local hero_cfg = self:refreshSpine(role_right, self.m_right_hero_img, self.m_right_hero_spine)
        self.m_role_right = role_right
        if hero_cfg then
            self.m_role_right_face = hero_cfg.face == 1 and -1 or 1
        end
    end

    local left_up_sel = dialogue_cfg.left_up == 1
    local center_up_sel = dialogue_cfg.center_up == 1
    local right_up_sel = dialogue_cfg.right_up  == 1

    self.m_left_hero_img.color = left_up_sel and Color.white or Color.gray
    self.m_center_hero_img.color = center_up_sel and Color.white or Color.gray
    self.m_right_hero_img.color = right_up_sel and Color.white or Color.gray
    self.m_left_hero_spine.color = left_up_sel and Color.white or Color.gray
    self.m_center_hero_spine.color = center_up_sel and Color.white or Color.gray
    self.m_right_hero_spine.color = right_up_sel and Color.white or Color.gray
    
    if self.m_model.dialogue_type ~= GlobalConfig.WORLD_MAP_EVENT.REGIONAL_EVENT then
        local scale_config = ConfigManager:getCommonValueById(313,1)
        local left_scale = Vector3.one*(left_up_sel and 1 or scale_config)
        left_scale.x = left_scale.x * self.m_role_left_face
        local center_scale = Vector3.one*(center_up_sel and 1 or scale_config)
        local right_scale = Vector3.one*(right_up_sel and 1 or scale_config)
        right_scale.x = right_scale.x * self.m_role_right_face
        self.m_left_hero_img.gameObject.transform.localScale = left_scale
        self.m_center_hero_img.gameObject.transform.localScale = center_scale
        self.m_right_hero_img.gameObject.transform.localScale = right_scale
        self.m_left_hero_spine.gameObject.transform.localScale = left_scale
        self.m_center_hero_spine.gameObject.transform.localScale = center_scale
        self.m_right_hero_spine.gameObject.transform.localScale = right_scale
        if left_up_sel ~= true then
            self:setSpineAnim(self.m_left_hero_spine, "idle")
        else
            self:setSpineAnim(self.m_left_hero_spine, "talk")
        end
        if center_up_sel ~= true then
            self:setSpineAnim(self.m_center_hero_spine, "idle")
        else
            self:setSpineAnim(self.m_center_hero_spine, "talk")
        end
        if right_up_sel ~= true then
            self:setSpineAnim(self.m_right_hero_spine, "idle")
        else
            self:setSpineAnim(self.m_right_hero_spine, "talk")
        end
    else
        
    end

    if not center_up_sel then
        self.m_center_hero.gameObject.transform:SetAsFirstSibling()
    end
    if not right_up_sel then
        self.m_center_hero.gameObject.transform:SetAsFirstSibling()
    end
    if not left_up_sel then
        self.m_center_hero.gameObject.transform:SetAsFirstSibling() --- 是设置成第一个，显示在最后面
    end

    if center_up_sel then
        self.m_center_hero.gameObject.transform:SetAsLastSibling() 
    end
    if right_up_sel then
        self.m_right_hero.gameObject.transform:SetAsLastSibling()
    end
    if left_up_sel then
        self.m_left_hero.gameObject.transform:SetAsLastSibling() 
    end

    local transparent = dialogue_cfg.transparent or 155
    self:setColorA(self.bg_image_2, transparent/100)
    local dialog_kind = dialogue_cfg.dialog_kind or 1
    local Narrator = dialogue_cfg.Narrator or 0
    --1是旁白，
    if Narrator == 1 then
        self:setObjectVisible("pangbai_text_bg_img", true)
        self:setObjectVisible("drama_text_bg_img", false)
        --self.m_drama_text_rect.anchoredPosition = Vector2.New(0, -30)
        --self.m_drama_text.alignment = CS.UnityEngine.TextAnchor.MiddleCenter;
    else
        self:setObjectVisible("pangbai_text_bg_img", false)
        self:setObjectVisible("drama_text_bg_img", dialog_kind ~= 0)
        --self.m_drama_text_rect.anchoredPosition = Vector2.New(0, 15)
        --self.m_drama_text.alignment = CS.UnityEngine.TextAnchor.MiddleLeft;
    end
    if dialogue_cfg.bgpic and dialogue_cfg.bgpic ~= "" then
        if dialogue_cfg.bgpic == "a_ui_currency_mengban" then
            --黑屏
            self:setColorA(self.m_blackScreenbg, 1)
            self:setColorA(self.bg_image_2, 0)
        else
            self:setColorA(self.bg_image_2, transparent/100)
            GameUtil:updateResourcesImg(self.bg_image_2.gameObject, "Texture/map_plot/"..dialogue_cfg.bgpic)
            --self:setImg("bg_image_2", "Texture/map_plot/"..dialogue_cfg.bgpic, "texture_map_plot_"..dialogue_cfg.bgpic)
        end
    else
        self:setColorA(self.bg_image_2, 0)
    end
end


function M:setImgAutoSize(img)
    img.preserveAspect = true
    img:SetNativeSize()
end


function M:refreshSpine(player_id, img_obj, spine_obj)
    
    local npc_table = self.m_model:getNpcCfg()
    if npc_table[player_id] ~= nil and npc_table[player_id].m_battle_icon ~= "0" and npc_table[player_id].m_battle_icon ~= "" then
        --types是2播放spine，其他使用图片
        if npc_table[player_id].types == 2 then
            spine_obj.gameObject:SetActive(true)
            img_obj.gameObject:SetActive(false)
            
            --self:setColorA(spine_obj, 1)
            local hero_spine = npc_table[player_id].m_battle_icon .. "_SkeletonData"
            local sk_data = ResourceUtil:GetSk(hero_spine, "rolespine_"..string.lower(hero_spine))
            spine_obj.skeletonDataAsset = sk_data
            spine_obj:Initialize(true)
            self:setSpineMix(spine_obj)

            self:setSpineAnim(spine_obj, "talk")
        else
            img_obj.gameObject:SetActive(true)
            spine_obj.gameObject:SetActive(false)

            --self:setColorA(img_obj, 1)
            Logger.log(" 显示人物立绘 ~~~~~~~~~~~~~~~~ player_id "..player_id.." m_battle_icon "..npc_table[player_id].m_battle_icon )
            GameUtil:updateResourcesImg(img_obj,"Texture/map_plot/"..npc_table[player_id].m_battle_icon )
            self:setImgAutoSize(img_obj);
        end
    else
        img_obj.gameObject:SetActive(false)
        spine_obj.gameObject:SetActive(false)
        
        --self:setColorA(img_obj, 1)
    end
    
    --if self.m_model.dialogue_type == GlobalConfig.WORLD_MAP_EVENT.REGIONAL_EVENT then
    --    local npc_table = self.m_model:getNpcCfg()
    --    if npc_table[player_id] ~= nil and npc_table[player_id].m_battle_icon ~= "0" and npc_table[player_id].m_battle_icon ~= "" then
    --        spine_obj.gameObject:SetActive(true)
    --        spine_obj.transform.localScale = CS.UnityEngine.Vector3.one * (npc_table[player_id].size or 1)
    --        local hero_spine = npc_table[player_id].m_battle_icon .. "_SkeletonData"
    --        local sk_data = ResourceUtil:GetSk(hero_spine, "rolespine_"..string.lower(hero_spine))
    --        spine_obj.skeletonDataAsset = sk_data
    --        spine_obj:Initialize(true)
    --        npc_table[player_id].face = 2
    --        return npc_table[player_id]
    --    else
    --        spine_obj.gameObject:SetActive(false)
    --    end
    --else
    --    return GameUtil:setHeroSpineBySG(player_id, spine_obj)
    --end
end

function M:setSpineMix(sp)
    if sp.skeletonDataAsset ~= nil then
        local stateData = sp.skeletonDataAsset:GetAnimationStateData();
        stateData:SetMix("talk", "idle", 1);
        stateData:SetMix("idle", "talk", 1);
    end
end

function M:setSpineAnim(sp, anim_name)
    if sp.skeletonDataAsset ~= nil and sp.AnimationState:ToString() ~= anim_name then
        sp.AnimationState:SetAnimation(0, anim_name, true)
    end
end

function M:updateDramaWord()
    if self.m_model:getTalking() then
        if self.m_left == 0 then
            self.m_model:setTalking(false)
        else
            local tmp = string.byte(self.m_word, - self.m_left)
            local i = #__WORD_ARR
            while __WORD_ARR[i] do
                if tmp >= __WORD_ARR[i] then
                    self.m_left = self.m_left - i
                    break
                end
                i = i - 1
            end
            self:setTextByLanKey("drama_text", string.sub(self.m_word, 0, self.m_word_len - self.m_left))
        end
    end
end

function M:doDramaWord()
    if self.m_model:getTalking() then
        self:killAnim()
        local sequence = Tweening.DOTween.Sequence()
        self.m_drama_text.text = ""
        sequence:Append(DOTweenModuleUI.DOText(self.m_drama_text, self.m_word, 1))
        sequence:OnComplete(function()
            self.m_sequence = nil
            self.m_model:setTalking(false)
            self:checkAuto()
        end)
        self.m_sequence = sequence
    end
end

function M:killAnim()
    if self.next_Drama_timer ~= nil then
        self.m_control:removeTimer(self.next_Drama_timer)
        self.next_Drama_timer = nil
    end
    if self.m_sequence then
        self.m_sequence:Kill()
        self.m_sequence = nil
    end

    if self.m_kvsequence then
        self.m_kvsequence:Kill()
        self.m_kvsequence = nil
    end
end

function M:checkAuto()
    if self.m_has_kv then
        return
    end
    local timer = self.m_audio_time
    if timer == nil or timer <= 0 then
        timer = 3
    end
    local time = timer * self.m_model:getAutoTime()
    if time > 0 then
        timer = self.m_control:setOnceTimer(time, function()
            self:updateMsg("next_btn", {})
        end)
    end
    self.m_control:removeTimer(self.next_Drama_timer)
    self.next_Drama_timer = timer
end

--[[
	创建列表
]]
function M:updateSelectDramaLoopScroll()
    self:setObjectVisible("select_drama_node", true)
    self:setObjectVisible("next_text", false)
    self.m_luaBehaviour:RunAnim("juqingdongxiao_1", nil)
	local data = self.m_model:getSelectDramaData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "select_des_text", tostring(cell_data.des))
                local btn = cell_object:GetComponent("Button")
                if cell_data.can_choise == true then
                    LuaBehaviourUtil.setTextColor(luaBehaviour, "select_des_text", GlobalConfig.COMMON_COLLOR.COMMON_14)
                    --UIUtil.setImg(cell_object.transform,"a_map_jq_juqingxuanze_di", "main_ui", "Image")
                else
                    LuaBehaviourUtil.setTextColor(luaBehaviour, "select_des_text", GlobalConfig.COMMON_COLLOR.COMMON_11)
                    --UIUtil.setImg(cell_object.transform,"a_map_jq_juqingxuanze_di_hui", "main_ui", "Image")
                end
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
                if not cell_data.choose_flag and self.m_model.is_world_memory then
                    GameUtil:lookInfoTips(self.m_control, {msg = cell_data.move_tips, delay_close = 2})
                    return
                end
                self:updateMsg("select_drama_Item", {index = index , cell_data = cell_data})
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true)
	end
end

function M:refreshAutoImg()
    if self.m_model.m_auto_state == 0 then
        self:setImg("a_jqdh_zidong","pub_ui","auto_btn_img")
        self:setTextByLanKey("auto_btn_text","new_str_1012")
    elseif self.m_model.m_auto_state == 1 then
        self:setImg("a_jqdh_jiasu","pub_ui","auto_btn_img")
        self:setTextByLanKey("auto_btn_text","new_str_0705")
    elseif self.m_model.m_auto_state == 2 then
        self:setImg("a_jqdh_zanting","pub_ui","auto_btn_img")
        self:setTextByLanKey("auto_btn_text","new_str_1013")
    end
end

function M:displayImgDialog(key_img)
    if key_img and key_img ~= "" then
        self:lockTouch()
        self.m_has_kv = true
        self:setColorA(self.m_bg_image, 0)
        self:setObjectVisible("bg_image", true)
        self:setObjectVisible("kv_tips_text", false)
        local img = self:findImage("kv_img")
        GameUtil:updateResourcesImg(img, "Texture/map_plot/"..key_img)
        --self:setTexture("bg_image", "Texture/map_plot/"..key_img, "texture_map_plot_"..key_img)
        img:SetNativeSize()
        --local function recoverCallback()
        --    self:setColorA(self.m_bg_image, 0)
        --    self:setObjectVisible("bg_image", false)
        --end
        --local obj_bg_image = self:findGameObject("bg_image")
        DOTweenModuleUI.DOFade(self.m_bg_image, 1, 1.1)
        self:setColorA(img, 0)
        local sequence = Tweening.DOTween.Sequence()
        sequence:Append(DOTweenModuleUI.DOFade(img, 1, 1.1))
        sequence:AppendInterval(1)
        sequence:OnComplete(function()
            self:setObjectVisible("kv_tips_text", true)
            self:unlockTouch()
        end)
        sequence:SetAutoKill(true)

        self.m_kvsequence = Tweening.DOTween.Sequence()
        self.m_kvsequence:Append(DOTweenModuleUI.DOFade(self:findText("kv_tips_text"), 0.2, 2))
        self.m_kvsequence:Append(DOTweenModuleUI.DOFade(self:findText("kv_tips_text"), 1, 2))
        self.m_kvsequence:SetLoops(-1)
    end
end

function M:closeKVImag()
    self.m_has_kv = false
    self:setObjectVisible("bg_image", false)
    if self.m_kvsequence then
        self.m_kvsequence:Kill()
        self.m_kvsequence = nil
    end
end

function M:destroy()
    self:killAnim()
    M.super.destroy(self)
end

return M
