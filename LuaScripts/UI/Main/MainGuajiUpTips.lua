--- 门派
local M = class("MainGuajiUpTips",LikeOO.OOUIbase)

M.m_uiName = "Main/MainGuajiUpTips"

local m_item_tab = {
    {item_type = RewardUtil.REWARD_TYPE_KEYS.COIN, config_key = "coin"},
    {item_type = RewardUtil.REWARD_TYPE_KEYS.EXP, config_key = "player_exp"},
    {item_type = RewardUtil.REWARD_TYPE_KEYS.HERO_EXP, config_key = "hero_exp"},
}

function M:onCreate()
    self.num = 0
    self:setTextByLanKey("title_text", "guaji_sy_tex")
    self.target = self.m_params.target
    local stage_idle = self.m_model:getStagepIdle()
    local times = 3600/stage_idle.rewards_cd
    self.m_item = {}
    for i,v in ipairs(m_item_tab) do
        local data = RewardUtil:getProcessRewardData({v.item_type, 0, stage_idle[v.config_key]*times})
        self:setText("num_text_" .. i, "x" .. math.floor(data.data_num))
        self:setImg(data.icon_name, data.atlas_name, "item_img_" .. i)
        self.m_item[i] = self:findGameObject("item_img_" .. i)
    end
    self.m_luaBehaviour:RunAnim("UI_MainGuajiUpTips_01" , handler(self,self.endCallFunc) , 1)
    --
end

function M:endCallFunc(anim_name)
    if anim_name == "anim_end" then
        self:itemFlyAction()
    end
end

function M:itemFlyAction()
    audio:SendEvtUI("PLAY_UI_GOLD")
    local delay = 0
    for k, v in pairs(self.m_item) do
        v.transform:SetParent(static_rootControl.m_view.m_ui_obj.transform, true)
        local tweener = v.transform:DOScale(0.4, 1)
        CS.wt.framework.TweenTool.Bezier(
                v,
                self.target.transform,
                0.6,
                CS.wt.framework.BezierType.Bezier_Level2,
                delay,
                false,
                function()
                    tweener:Kill()
                    UIUtil.destroyObject(v)
                    self:targetAction()
                end
        )
        delay = delay + 0.03
    end
end

function M:targetAction()
    if self.m_bag_action ~= true then
        self.m_bag_action = true
        local bag_togglebtn = self.target
        local sequence = Tweening.DOTween.Sequence()
        sequence:Append(bag_togglebtn.transform:DOScale(1.2, 0.05))
        sequence:Append(bag_togglebtn.transform:DOScale(1.0, 0.05))
        sequence:Append(bag_togglebtn.transform:DOScale(1.2, 0.05))
        sequence:Append(bag_togglebtn.transform:DOScale(1.0, 0.05))
        sequence:Append(bag_togglebtn.transform:DOScale(1.2, 0.05))
        sequence:Append(bag_togglebtn.transform:DOScale(1.0, 0.05))
        sequence:OnComplete(function ()
            self.m_bag_action = false
        end)
        sequence:SetAutoKill(true)
    end
    self.num = self.num + 1
    if self.num == #self.m_item then
        M.super.destroy(self)
    end
end

return M