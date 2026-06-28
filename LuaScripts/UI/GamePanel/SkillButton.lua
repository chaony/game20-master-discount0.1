--技能按钮
local M = class("SkillButton")
--特效地址
--卡牌燃烧效果
M.effect_list = {}
--切换特效
M.changeEffect = nil
--切换 sprite 图片
M.changeSprite = nil
--之前的旧图片
M.oldSprite = nil

M.isDead  = nil

M.icon_btn = nil

M.icon_img = nil

M.icon_trans = nil

M.icon_quality_img = nil

M.hero_name = nil

M.startPos = nil
--血条预制
M.mHpShow = nil
--卡牌检测的玩家
M.player = nil

M.isAready = false

--卡牌的预制体
M.obj = nil
--卡牌的hero节点
M.hero = nil
--切换的Sprite
M.changeSprite = nil

M.m_luaBehaviour = nil

M.m_lanValue = nil;
M.m_lanValue_Recttran = nil;
M.m_angerMax = nil;

M.QUALITY_COMMON_SETTING = {
    {card_frame_name = "a_zd_kapai_lan" }, --1 灰色
    {card_frame_name = "a_zd_kapai_lan" }, --2 绿色
    {card_frame_name = "a_zd_kapai_lan" }, --3 蓝色
    {card_frame_name = "a_zd_kapai_lan" }, --4 蓝+ 有外框
    {card_frame_name = "a_zd_kapai_zi" }, --5 紫色
    {card_frame_name = "a_zd_kapai_zi" }, --6 紫+ 有外框
    {card_frame_name = "a_zd_kapai_cheng" }, --7 金
    {card_frame_name = "a_zd_kapai_cheng" }, --8 金+ 有外框
    {card_frame_name = "a_zd_kapai_cheng" }, --9 金++ 有外框
    {card_frame_name = "a_zd_kapai_hong" }, --10 红 
    {card_frame_name = "a_zd_kapai_hong" }, --11 红+ 
    {card_frame_name = "a_zd_kapai_hong" }, --12 红++ 
    {card_frame_name = "a_zd_kapai_hong" }, --13 红+++ 
    {card_frame_name = "a_zd_kapai_bojin" }, --14 白
    {card_frame_name = "a_zd_kapai_bojin" }, --15 1
    {card_frame_name = "a_zd_kapai_bojin" }, --16 2
    {card_frame_name = "a_zd_kapai_bojin" }, --17 3
    {card_frame_name = "a_zd_kapai_bojin" }, --18 4
    {card_frame_name = "a_zd_kapai_cai" }, --19 彩
    {card_frame_name = "a_zd_kapai_cai" }, --20 1
    {card_frame_name = "a_zd_kapai_cai" }, --21 2
    {card_frame_name = "a_zd_kapai_cai" }, --22 3
    {card_frame_name = "a_zd_kapai_cai" }, --23 4
    {card_frame_name = "a_zd_kapai_cai" }, --24 彩5
}
--创建
function M:init(player, index, parent, changeCard, control, is_horizontally, aspRatio)
    self.m_control = control
    self.player = player
    self.is_horizontally = is_horizontally or false
    local hero_table = ConfigManager:getCfgByName("hero_detail");
    local hero_table_data = hero_table[self.player.playerId]
    --加载卡牌预制体
    if self.is_horizontally then
        self.obj = ResourceUtil:GetUIItem("GamePanel/Card1", nil, "ui_prefabs")
    else    
        self.obj = ResourceUtil:GetUIItem("GamePanel/Card", nil, "ui_prefabs")
    end
    self.obj.transform:SetParent(parent)
    UIUtil.setLocalPosition( self.obj.transform, 0, 0, 0) 
    --UIUtil.setScale(self.obj.transform,1,1,1)
    UIUtil.setScale(self.obj.transform,1.35)
    self.m_luaBehaviour = self.obj:GetComponent("LuaBehaviour")
    self.m_luaBehaviour:RegistButtonClick(handler(self, self.UnityCallBack))
    --这里时状态满的时候动画
    self.effect_list = {}
    --local bg_effect = self.m_luaBehaviour:FindGameObject("bg_effect")
    --local ms_effect = self.m_luaBehaviour:FindGameObject("ms_effect")
    --local fg_effect = self.m_luaBehaviour:FindGameObject("fg_effect")
    local xunhuan_effect = self.m_luaBehaviour:FindGameObject("UI_GamePanel_XuMan_001")
    --table.insert( self.effect_list, bg_effect)
    --table.insert( self.effect_list, ms_effect)
    --table.insert( self.effect_list, fg_effect)
    table.insert( self.effect_list, xunhuan_effect)
    self.slider = self.m_luaBehaviour:FindGameObject("slider")	
    --加载切换动画
    --self.changeEffect = UIUtil.findTrans(self.obj.transform,"fx_shanguang_01")
    --按钮
    self.icon_btn = UIUtil.setButtonClick(self.obj.transform, handler(self,self.OnClickMe),"","icon_bg/hero/skill_btn")
    self.icon_btn.enabled = false
    --图片
    self.icon_img = self.m_luaBehaviour:FindImage("hero_img")
    self.quality_img = self.m_luaBehaviour:FindImage("quality_img")
    --self.outline_img = self.m_luaBehaviour:FindImage("outline_img")
    self.gray = self.m_luaBehaviour:FindImage("gray")

    self.icon_trans = UIUtil.findTrans(self.obj.transform,"icon_bg")
    self.stars_trans = UIUtil.findTrans(self.obj.transform,"stars")
    --英雄根节点
    self.hero = UIUtil.findTrans(self.obj.transform,"hero")
    self.m_lanValue = self.m_luaBehaviour:FindImage("lanValue")
    self.m_lanValue_Recttran = self.m_lanValue.gameObject:GetComponent('RectTransform')
    -- local size = self.m_lanValue_Recttran.sizeDelta;
    -- size.x = 103;
    --self.m_lanValue_Recttran.sizeDelta = size;
    self.m_hpValue = self.m_luaBehaviour:FindImage("hpValue")
    self.m_hpValue_Recttran = self.m_hpValue.gameObject:GetComponent('RectTransform')
    if self.is_horizontally == true then
        self.m_max_length = 75
    else
        self.m_max_length = 75
    end
    
    if self.is_horizontally == true then
       --之前的图片
       --local icon_name = hero_table_data.m_battle_icon
       local icon_big_name = "h_"..hero_table_data.icon.."_l"
       --self.oldSprite = ResourceUtil:GetSprite(icon_name,"hero_head_ui")
       --LuaBehaviourUtil.setTexture(self.m_luaBehaviour, "hero_big_img", "HeroIcon/"..icon_big_name, "heroicon_"..icon_big_name)
       --self.icon_img.sprite = self.oldSprite
        GameUtil:updateResourcesImg(self.icon_img, "Texture/HeroIcon/" .. icon_big_name)
       --改变之后的图片
       --self.changeSprite = ResourceUtil:GetSprite(icon_name,"hero_head_ui")
    else
       --之前的图片
       self.oldSprite = ResourceUtil:GetSprite(hero_table_data.icon.."_da","hero_head_ui")
       self.icon_img.sprite = self.oldSprite
       --改变之后的图片
       --self.changeSprite = ResourceUtil:GetSprite(hero_table_data.icon.."_da","hero_head_ui")
    end
    --开始位置
    self.startPos = self.obj.transform.localPosition;
    --隐藏切换动画
    --self.changeEffect.gameObject:SetActive(false)
    --隐藏状态满的时候动画
    self:showEffect(false)
    --获取动画状态机
    self.mAnim = self.obj:GetComponent('Animator')

    if self.m_control.m_model.m_mode == GlobalConfig.BATTLE_MODE.PET_DOUJI then
        local hero_data,hero_cfg = UserDataManager.pet_data:getPetDataById(player:get_playerInstanceId())
        local generation_data  = GameUtil:getPetInfoByData(hero_data)
        self.icon_quality_img = self.m_luaBehaviour:FindImage("hero_bg_img")
        self.icon_quality_img.sprite = ResourceUtil:GetSprite(generation_data.zd_bg, "hero_head_ui")
    else
         --英雄
        local hero_data,hero_cfg = GameUtil:getHeroById(player:get_playerInstanceId())
        local farm = self.QUALITY_COMMON_SETTING[player.data.evo]
        local farm_add_data = GlobalConfig.HERO_QUALITY_COMMON_SETTING[player.data.evo]
        local farm_data = GlobalConfig.QUALITY_FRAME[player.data.evo] --big_frame_add_name
        self.icon_quality_img = self.m_luaBehaviour:FindImage("hero_bg_img")
        self.icon_quality_img.sprite = ResourceUtil:GetSprite(farm.card_frame_name, "hero_head_ui")
        self:updateStars(hero_data,hero_cfg)
    end
   
    --设定怒气比例
    self:angerUpdateHandler( self.player.data:get_AngerRate() )
    if self.icon_trans and self.is_horizontally == false then
        UIUtil.setScale(self.icon_trans.transform,aspRatio,aspRatio)
    end
  
end

function M:updateStars(hero_data,hero_cfg)
    if self.is_horizontally == false then
        return
    end
    if hero_data ~= nil and hero_cfg ~= nil then
        GameUtil:updateHeroContentByData(self.obj, hero_data, hero_cfg)
    end

    --local stars = self.m_luaBehaviour:FindGameObject("stars")
    --stars:SetActive(false)
    -- if lv > 11 then --彩色之后
    --     stars:SetActive(true)
    --     -- local show_star_count = lv - 11
    --     -- for i = 1, 5 do
    --     --     local str = self.m_luaBehaviour:FindGameObject("star_"..i)
    --     --     str:SetActive(show_star_count >= i)
    --     -- end
    -- end
end

--置灰
function M:setGray(isGray)
    if isGray then
        self.icon_img.material = self.gray.material
        self.quality_img.material = self.gray.material
        --self.outline_img.material = self.gray.material
    else
        self.icon_img.material = nil
        self.quality_img.material = nil
        --self.outline_img.material = nil
    end
end


function M:UnityCallBack( obj, name, tag )
    if name == "SetSprite" then
        --self.icon_img.sprite = self.changeSprite;
        --self.changeEffect.gameObject:SetActive(true)
    elseif name == "BackSprite" then
        --self.icon_img.sprite = self.oldSprite;
        --self.changeEffect.gameObject:SetActive(false)
    end
end

--受伤回调
function  M:PlayerInjureHandler()
	if not IsNull(self.mHpShow) then
		--mHpShow.SetHp(_owner.data:get_curHp());
	end
end

function M:playerDead()
    self:setGray(true)
    self.slider:SetActive(false);
    self.m_luaBehaviour:ResetAnimState()
    self:showEffect(false) 
    LuaBehaviourUtil.setObjectVisible(self.m_luaBehaviour, "UI_GamePanel_ChuFa_001", false)
    LuaBehaviourUtil.setObjectVisible(self.m_luaBehaviour, "UI_GamePanel_ChuFa_002", false)
    UIUtil.setScale(self.icon_btn.transform, 1,1,1)
    UIUtil.setLocalPosition( self.icon_btn.transform, 0, 0, 0) 
    self.obj.transform.rotation = FixQuaternion.New(0,0,0,0);
    UIUtil.setScale(self.obj.transform, 1,1,1)
    self.icon_trans.localPosition = Vector3(0,0,0)
end

--黑屏结束
function M:blackOver()
    --self.mAnim:CrossFadeInFixedTime("Card_Big_Down", 0.01)
end


function M:hpUpdateHandeler( hpRate )
    -- local size = self.m_hpValue_Recttran.sizeDelta;
    -- size.x = hpRate * self.m_max_length;
    -- self.m_hpValue_Recttran.sizeDelta = size;
    self.m_hpValue.fillAmount = hpRate
end


function M:angerUpdateHandler( anger )
    self.m_lanValue.fillAmount = anger
    if anger >= 1 then
        self.icon_btn.enabled = true
    else
        self.icon_btn.enabled = false
    end
end


function M:playerSkillOkHandler()
    if self.player and self.player.plySkill and (self.player.plySkill:getSkillByName("skill3") or self.player.plySkill:getSkillByName("skill3_plus")) then
        --local curSkillConfig = self.player.plySkill:getSkillByName("skill3").cur_skill_config
        --if curSkillConfig:canUseSkill3() == true then
            self:playSkillAnim()
        --end
    end
end

function M:playSkillAnim()
    self.isAready = true
    self:showEffect(true)
    self.m_luaBehaviour:RunAnim("Card_Show", nil, 1)
    self.m_control:updateMsg("check_guide")
    audio:SendEvtUI("Ui_Dazhao_Hint")
end

--点击技能按钮
function M:OnClickMe()
    local is_guide = UserDataManager.guide_data:isGuiding()
    if SceneManager.scene_pause == false or is_guide or SceneManager.curScene.gameover == false then
        local skill_name = "skill3"
        if self.player ~= nil and self.player:isLive() then
            local skill3 = self.player.plySkill:getSkillByName(skill_name)
            if skill3 == nil then
                skill_name = "skill3_plus"
                skill3 = self.player.plySkill:getSkillByName(skill_name)
            end
            if skill3 ~= nil then
                local curSkillConfig = skill3.cur_skill_config
                if self.isAready and curSkillConfig.skill3Already and self.m_control.m_model:isCanReleaseSkill() then
                    --大招按下时
                    --如果玩家活着
                    self.player:useHandSkill3()
                    if UserDataManager.guide_data:isGuiding() then
                        self.m_control:updateMsg("skill_click")
                    end
                    audio:SendEvtUI("Ui_Skill")
                end
            end
        end
    end
end

function M:useSkill()
    if self.isAready then
        --大招按下时
        --如果玩家活着
        if self.player ~= nil and self.player:isLive() then
            local function endCallFunc()
                --卡牌切换动画
                local function endCallFunc2()
                    if self.changeEffect then
                        self.changeEffect.gameObject:SetActive(false)
                    end   
                end
                self:showEffect(false) 
                if self.changeEffect then
                    self.changeEffect.gameObject:SetActive(true)
                end 
                self.m_luaBehaviour:RunAnim("Card_Big 1", endCallFunc2, 1.5)
            end
            self:showEffect(true) 
            endCallFunc()
        end
        self.isAready = false
    end
end

function M:showEffect(show)
    if show == true and self.isAready == false then
        self:playSkillAnim()
    end
    if  self.effect_list ~= nil and next(self.effect_list) ~= nil then
        for k,v in pairs(self.effect_list) do
            v.gameObject:SetActive(show) 
        end
    end
end

function M:destroy()
    if self.obj then
        U3DUtil:Destroy(self.obj)
        self.obj = nil
    end
    self.m_control = nil;
    self.player = nil;
end

return M