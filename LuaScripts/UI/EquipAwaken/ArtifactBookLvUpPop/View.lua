local M = class("ArtifactBookLvUpPopView",LikeOO.OOPopBase)

M.m_uiName = "EquipAwaken/ArtifactBookLvUpPop"
M.m_size_type = 2

--装备觉醒
M.TAG_TAB = {
    {img = "a_sbp_wuqi_li"}, --武器
    {img = "a_sbp_wuqi_ming"}, --武器
    {img = "a_sbp_wuqi_zhi"}, --武器
    {img = "a_sbp_fangju_li"}, --防具
    {img = "a_sbp_fangju_ming"}, --防具
    {img = "a_sbp_fangju_zhi"}, --防具
}


function M:onEnter()
	self:refreshUI()
    self:updateLoopScroll()
    self:setTextByLanKey("common_title_text", "equip_awake_014")
    self:setTextByLanKey("ok_btn_text", "equip_awake_041")
end

function M:refreshUI()
    local tag_data = self.TAG_TAB[self.m_model.m_type_index]
    self:setImg(tag_data.img.."_dianliang", ResourceUtil:getLanAtlas(), "cur_type_img")
    self:setImg(tag_data.img.."_dianliang", ResourceUtil:getLanAtlas(), "next_type_img")
    
    local show_quality = self.m_model:getThronsShowQualityByIndex()
    if show_quality > 10 then
        show_quality = 10
    end
    local star_lv_key = 30 + show_quality
    self:setTextByLanKey("cur_star_lev_text", "equip_awake_0" .. star_lv_key)
    local nextshow_quality = self.m_model:getNextThronsShowQualityByIndex()
    if nextshow_quality > 10 then
        nextshow_quality = 10
    end
    local next_star_lv_key = 30 + nextshow_quality
    self:setTextByLanKey("next_star_lev_text", "equip_awake_0" .. next_star_lv_key)
    
    -- 图鉴等级上限
    local curMaxLevel = self.m_model:getThronsMaxlvByIndex()
    local lastMaxLevel = self.m_model:getThronsNextMaxlvByIndex()
    self:setTextByLanKey("handbookLevel_attr_name", "equip_awake_042")
    self:setTextByLanKey("handbookLevel_attr_num", curMaxLevel)
    self:setTextByLanKey("handbookLevel_next_attr_num", lastMaxLevel)
    self:setObjectVisible("handbookLevel_add_img", (lastMaxLevel > curMaxLevel))
    
    local star = self.m_model:getThronsStarByIndex()
    for i = 1, 3 do 
        self:setObjectVisible("cur_star_"..i, i <= star)
    end
    local nextstar = self.m_model:getNextThronsStarByIndex()
    for i = 1, 3 do 
        self:setObjectVisible("next_star_"..i, i <= nextstar)
    end
    local cons_data = self.m_model:getThronsConsByIndex()
    if next(cons_data) ~= nil then
        local cons_data1 = RewardUtil:getProcessRewardData(cons_data[1])
        local cons_data2 = RewardUtil:getProcessRewardData(cons_data[2])
        self:setImg(cons_data1.icon_name, cons_data1.atlas_name, "cons_img_1")
        self:setImg(cons_data2.icon_name, cons_data2.atlas_name, "cons_img_2")
        if cons_data1.user_num >= cons_data1.data_num then 
            self:setTextByLanKey("cons_num_1", cons_data1.user_num.."/"..cons_data1.data_num)
        else
            self:setTextByLanKey("cons_num_1", "<color=#F1431F>"..cons_data1.user_num.."</color>/"..cons_data1.data_num)
        end

        if cons_data2.user_num >= cons_data2.data_num then 
            self:setTextByLanKey("cons_num_2", cons_data2.user_num.."/"..cons_data2.data_num)
        else
            self:setTextByLanKey("cons_num_2", "<color=#F1431F>"..cons_data2.user_num.."</color>/"..cons_data2.data_num)
        end
    end
    local add_att_str = self.m_model:getAddAttrsStr()
    self:setTextByLanKey("add_str", add_att_str)
    --local lv = self.m_model:getThronslvByIndex(self.m_model.m_type_index)
    --self:setTextByLanKey("cur_lv_num", lv.."/"..self.m_model:getThronsMaxlvByIndex())
    --self:setTextByLanKey("next_lv_num", lv.."/"..self.m_model:getThronsNextMaxlvByIndex())
end


--[[	
	属性列表
]]
function M:updateLoopScroll()
    local data = self.m_model:getThronsAttrByIndex()
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                local atk_key = GameUtil:getAttrsKey(cell_data[1])
                local atk_name =  GameUtil:getAttrsName(atk_key)
                local LuaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                if LuaBehaviour then
                    LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "attr_name",Language:getTextByKey("equip_awake_029") .. atk_name)
                    local cur_num = cell_data[2]
                    local last_num = self.m_model:getThroneCurAttr(cell_data[1])
                    if GameUtil:canPerAttrTransition(atk_key) == true then
                        cur_num = cur_num*100
                        last_num = last_num*100
                    end
                    if GameUtil:attrTransition(atk_key) == true then
                        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "attr_num", GameUtil:formatNum(last_num).. "%" )
                        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "next_attr_num", "+"..GameUtil:formatNum(cur_num).. "%" )
                    else
                        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "attr_num", GameUtil:formatNum(last_num))
                        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "next_attr_num", "+"..GameUtil:formatNum(cur_num))
                    end
                    if cur_num > last_num then
                        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "add_img", true)
                    else
                        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "add_img", false)    
                    end
                end
            end,
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data)
    end
end

return M