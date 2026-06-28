local M = class("TianXiaBattleView",LikeOO.OOPopBase)

M.m_uiName = "TianXiaZhengBa/TXBattleMainView"  -- prefab name
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
    self:setObjectVisible("img_time_bg" , false)
    --self:setTextByLanKey("text_tips", "tx_battle_tips_txt")
    --self:setText("text_time", self.m_model.m_regroup_time)
    
    self:setTextByLanKey("close_title_text", "totol_world_text_4")

    self:setTextByLanKey("rank_btn_text", "total_world_rank_text_02")
    self:refreshUI()
end

function M:refreshUI()
    self:refreshShopLoopScroll()

    --快速导航
    self:setObjectVisible("guide_btn", true)
end

function M:refreshShopLoopScroll()
    local data = self.m_model:getShowData()
    self.hero_items = {}
    local loopscroll = self:findGameObject("loopscroll")
    if self.m_loop_scroll_view == nil then
		local params = {
			show_data = data,
			one_line_count = 2,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
                self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, cell_data.user.uid)
			end,
            ui_name = self.m_uiName
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
        self.m_loop_scroll_view.m_scroll_rect.onValueChanged:AddListener(handler(self, self.onValueChanged))
	else
		self.m_loop_scroll_view:reloadData(data,true)
	end
    self:updateJianTou()
end

function M:onValueChanged(pos)
    self:updateJianTou()
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local transform = cell_object.transform
    local data = cell_data
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    local HeadNode = luaBehaviour:FindGameObject("HeadNode")
    GameUtil:setUserAvatar(HeadNode,data.user,false,nil,{show_flag = true, scale = 0.8})
    local server_name = UserDataManager.server_data:getServerNameById(data.server_id)
    LuaBehaviourUtil.setText(luaBehaviour, "server_id_text", server_name)
    LuaBehaviourUtil.setText(luaBehaviour, "rank_player_text", data.user.name)
    LuaBehaviourUtil.setText(luaBehaviour, "guild_name", data.user.guild_name)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "img_xian", index ~= #(self.m_model:getShowData()))
    self:updateJianTou()
end

function M:updateJianTou()
    if self.m_loop_scroll_view and self.m_loop_scroll_view.m_line_count > 2 then
        if self.m_loop_scroll_view:getVerticalNormalizedPosition() < 0.1 then
            self:setObjectVisible("jiantou_left_img", false)
        else
            self:setObjectVisible("jiantou_left_img", true)
        end
        if self.m_loop_scroll_view:getVerticalNormalizedPosition() > 0.9 then
            self:setObjectVisible("jiantou_right_img", false)
        else
            self:setObjectVisible("jiantou_right_img", true)
        end
    else
        self:setObjectVisible("jiantou_left_img", false)    
        self:setObjectVisible("jiantou_right_img", false)  
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M