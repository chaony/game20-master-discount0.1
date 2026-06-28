---@class RedPacketPopView: OOPopBase
---@field m_model RedPacketPopModel
local M = class("RedPacketPopView",LikeOO.OOPopBase)

M.m_uiName = "Main/RedPacketPop"
M.m_iphoneXAdapter = true
M.m_size_type = 2

local __animation_name = "idle"
local __rotation = Vector4(0,0,0.1,1)
function M:onEnter()
    self.red_packet_spine = self:findSkeletonGraphic("close_state_spine")
    self.red_packet_spine.AnimationState.TimeScale = 1.2
    self:setObjectVisible("close_btn",false)
    self:initUiByState()
end

function M:initUiByState()
    local close_obj = self:findGameObject("close_state_img")
    self:setObjectVisible("open_state_img",self.m_model.m_state == 2)
    if self.m_model.m_state == 1 then  --关闭状态
        
    elseif self.m_model.m_state == 2 then --领取状态
        --close_obj.transform.rotation  = __rotation
        self:refreshUI()    
    end     
end

function M:refreshUI()
    local user_data = self.m_model.m_data.user_info or {}
    local name_str = user_data.name or "无名英雄"
    local head_icon = user_data.avatar or ""
    local nums = self.m_model.m_data.money_num or 1
    local money_guide_cfg = self.m_model:getMoneyTypeData()
    local cfg = ConfigManager:getPlayerPictureCfg(head_icon)
    local icon = cfg.icon or "TX_210" 
    self:setImg(icon,"hero_head_ui","owner_head_img")
    self:setTextByLanKey("owner_name_text","red_packet_text_0010",name_str)
    self:setTextByLanKey("owner_award_nums_text",GameUtil:formatValueToString(nums))
    self:setImg(money_guide_cfg.icon,"item_icon","owner_award_nums_img")
    local can_recv = self.m_model.m_data.can_recv_num or 0
    local max = self.m_model.m_data.recv_tot or 0
    local already = max - can_recv
    already = math.min(already,max)
    local owner_state_str = Language:getTextByKey("red_packet_text_005") .. already .. "/" .. max   
    self:setTextByLanKey("owner_state_text",owner_state_str)
    self:createLoopCroll()
end

function M:createLoopCroll()
    local data = self.m_model:getListData()
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params ={
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell =function(index, cell_obj, cell_data)
                self:updateCell(index,cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(index)
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data, true)
    end
end

function M:updateCell(index,cell_obj,cell_data)
    local luaBehaiour = UIUtil.findLuaBehaviour(cell_obj)
    if luaBehaiour then
        local user = cell_data.user
        local name = user.name or "小花"
        local head_icon = user.avatar or ""
        local cfg = ConfigManager:getPlayerPictureCfg(head_icon)
        local icon = cfg.icon or "TX_210"
        local nums = cell_data.score or 0
        local money_guide_cfg = self.m_model:getMoneyTypeData()
        LuaBehaviourUtil.setTextByLanKey(luaBehaiour,"name_text",name)
        LuaBehaviourUtil.setImg(luaBehaiour,"head_img",icon,"hero_head_ui")
        LuaBehaviourUtil.setTextByLanKey(luaBehaiour,"award_nums_text",GameUtil:formatValueToString(nums))
        LuaBehaviourUtil.setImg(luaBehaiour,"award_nums_img",money_guide_cfg.icon,"item_icon")
        --判断是不是自己的那条数据
        --local flag = user.uid ==  UserDataManager.user_data:getUserStatusDataByKey("uid")
        --LuaBehaviourUtil.setObjectVisible(luaBehaiour,"owner_bg",flag)
        --LuaBehaviourUtil.setObjectVisible(luaBehaiour,"other_bg",not flag)
    end
end

function M:setSpineAnimation(id,flag)
    local animation_name = __animation_name .. id
    if not IsNull(self.red_packet_spine) then
            self.red_packet_spine.AnimationState:ClearTracks()
            self.red_packet_spine.AnimationState:SetAnimation(0, animation_name, flag)
    end
end

function M:setImgAlpha()
    local img = self:findGameObject("open_state_img")
    local canvas_group = img:GetComponent("CanvasGroup")
    canvas_group.alpha = 0.8
    local sequence = Tweening.DOTween.Sequence()
    sequence:Append(DOTweenModuleUI.DOFade(canvas_group, 1, 1.5))
    sequence:SetAutoKill(true)
end


function M:destroy()
    M.super.destroy(self)
end

return M