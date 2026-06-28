--- 悬赏信息查看
local M = class("RewardDes_Pop",LikeOO.OOUIbase)

M.m_uiName = "Reward/RewardDes_Pop"
M.m_sortOrder = 700

function M:onCreate()
	self.m_content = self:findGameObject("contentNode")
	self.m_content:SetActive(false)
	self.attr_list = self:findGameObject("attr_list")
	self.finish = self.m_params.finish
	local delay_open = self.m_params.delay_open or 0.1
	local delay_close = self.m_params.delay_close or 0
	if delay_close > 0 then
		local sequence = Tweening.DOTween.Sequence()
		sequence:AppendInterval(delay_open + delay_close)
		sequence:OnComplete(function()
			self.m_delay_close_sequence = nil
			self:destroy()
		end)
		sequence:SetAutoKill(true)
		self.m_delay_close_sequence = sequence
		self:setObjectVisible("close_btn", false)		
	end
end

function M:setParent(parent)
	if static_root_node then
		self.m_rootView.transform:SetParent(static_root_node.transform, false)
	end
end

function M:onButtonClick(obj, name)
	if name == "close_btn" then
		self:destroy()
	end
end

function M:onEnter()
	local sequence = Tweening.DOTween.Sequence()
	sequence:AppendInterval(self.m_params.delay_open or 0.1)
	sequence:OnComplete(function()
		self.m_delay_open_sequence = nil
		self:refreshUI() 
	end)
	sequence:SetAutoKill(true)
	self.m_delay_open_sequence = sequence
end

function M:refreshUI()
	self.m_content:SetActive(true)
	self.m_click_transform = self.m_params.click_transform
	local bounty_id = self.m_params.quest_id
	local bounty_data = self.m_params.data
	local bounty_cfg = self:getBountyCfg(bounty_id)
	self:setTextByLanKey("common_title_text", bounty_cfg.name)
	self:setTextByLanKey("desc_text", bounty_cfg.text)
	self:updateScroll(bounty_data)
	if bounty_cfg.reward[1] then
		local itemNode = self:findGameObject("ItemNode")
		GameUtil:updateItemElement(itemNode, bounty_cfg.reward_show[1],false,true)
		--GameUtil:updateItemElement(itemNode, bounty_cfg.reward[1])
		if bounty_cfg.reward[1][1] == 301 then
			local LuaBehaviour = UIUtil.findLuaBehaviour(itemNode)
			if LuaBehaviour then
				LuaBehaviourUtil.setImg(LuaBehaviour, "item_img", "DJ_tongqian", "item_icon")
			end
		end
	end
	if self.m_click_transform then
		local pos = self.m_content.transform.parent:InverseTransformPoint(self.m_click_transform.position)
		local click_transform_h = self.m_click_transform.rect.height
		local click_transform_w = self.m_click_transform.rect.width
		local content_w,content_h = 320, 300
		pos.y = pos.y - content_h*0.5 - click_transform_h*0.5
		pos.x = pos.x - content_w*0.5 - click_transform_w

        local width,height = self.m_rt.rect.width, self.m_rt.rect.height
        pos.y = math.max(math.min(pos.y ,height*0.5 - content_h*0.5), - height*0.5)
		pos.x = math.max(math.min(pos.x ,width*0.5 - content_w*0.5), - width*0.5 + content_w*0.5) 
		if pos.y < -100 then
			pos.y = -100
		end
		self.m_content.transform.localPosition = pos
	end
	local delay_close = self.m_params.delay_close or 0
	if delay_close > 0 then
		local sequence = Tweening.DOTween.Sequence()
		sequence:AppendInterval(0.5)
		sequence:Append(self.m_content.transform:DOLocalMoveY(180,delay_close - 0.5))
		sequence:SetAutoKill(true)
		self.m_move_sequence = sequence
	end
end

function M:updateScroll(data)
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("loopscroll_tiaojian")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
				local LuaBehaviour = UIUtil.findLuaBehaviour(cell_object)
				if LuaBehaviour then
					LuaBehaviourUtil.setText(LuaBehaviour, "tiaojian_text", cell_data.des)
					LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "yes_img", cell_data.bl)
					LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "no_img", not cell_data.bl)
				end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
        
            end
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data)
    end
end


function M:getBountyCfg(id)
	local table_cfg =  ConfigManager:getCfgByName("bounty_quest")
	return table_cfg[id]
end


function M:destroy()
	if self.m_delay_close_sequence then
		self.m_delay_close_sequence:Kill()
		self.m_delay_close_sequence = nil
	end
	if self.m_delay_open_sequence then
		self.m_delay_open_sequence:Kill()
		self.m_delay_open_sequence = nil
	end
	if self.m_move_sequence then
		self.m_move_sequence:Kill()
		self.m_move_sequence = nil
	end
	if self.finish ~= nil then
		self.finish()
	end
	M.super.destroy(self)
	GameUtil:resetBountyInfoTips()
end

return M