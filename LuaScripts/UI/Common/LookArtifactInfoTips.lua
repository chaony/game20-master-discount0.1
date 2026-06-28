--- 神器信息查看
local M = class("LookArtifactInfoTips",LikeOO.OOUIbase)

M.m_uiName = "HeroInfo/LookArtifactInfoTips"
M.m_sortOrder = 9999

function M:onCreate()
	self.m_content = self:findGameObject("content")
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
	local art_cfg = self.m_params.cfg
	local art_lv = self.m_params.lv
	self.m_content:SetActive(true)
	local attrs = art_cfg.level_up[art_lv].attr
	local des = art_cfg.level_up[art_lv].param_des
	if #des == 0 and art_lv > 0 then
		for i = art_lv, 0,-1 do
			local c_des = art_cfg.level_up[i].param_des
			if  #c_des ~= 0 then
				des = c_des
				break
			end
		end
	end
	for i = 1,table.nums(attrs) do
		local item = ResourceUtil:LoadUIGameObject("HeroInfo/look_art_cell", Vector3.zero, nil)
		item.transform:SetParent(self.attr_list.transform, false)
		local cur_art = attrs[i]
		local atr_key = GameUtil:getAttrsKey(cur_art[1])
		local name = GameUtil:getAttrsName(atr_key)
		local show_text = name..":"
		if GameUtil:attrTransition(atr_key) == true then
			show_text = show_text..(cur_art[2] * 100).."%"
		else
			show_text = show_text..cur_art[2]
		end
		UIUtil.setTextByLanKey(item.transform, "attr_name_text", show_text )
	end
	self:setImg(art_cfg.icon, "item_icon", "art_icon")
	self:setTextByLanKey("are_name", art_cfg.name)
	self.m_des_text = self:setTextByLanKey("des_text", des)
	self.m_click_transform = self.m_params.click_transform
	if self.m_click_transform then
		local pos = self.m_content.transform.parent:InverseTransformPoint(self.m_click_transform.position)
		local click_transform_h = self.m_click_transform.rect.height
		local click_transform_w = self.m_click_transform.rect.width
		local content_w,content_h = 320, 300
		pos.y = pos.y - content_h*0.5 - click_transform_h*0.5
		pos.x = pos.x + content_w*0.5 + click_transform_w*0.5

        local width,height = self.m_rt.rect.width, self.m_rt.rect.height
        pos.y = math.max(math.min(pos.y ,height*0.5 - content_h*0.5), - height*0.5)
        pos.x = math.max(math.min(pos.x ,width*0.5 - content_w*0.5), - width*0.5 + content_w*0.5) 
		self.m_content.transform.localPosition = pos
	end
	for i = 1 , 5 do
		self:setObjectVisible("star_"..i, false)
	end
	if art_lv > 0 then
		for i = 1 , art_lv do
			self:setObjectVisible("star_"..i, true)
		end
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
	GameUtil:resetLookArtInfoTips()
end

return M