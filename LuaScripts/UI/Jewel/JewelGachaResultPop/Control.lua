local M = class("JewelGachaResultPopControl",LikeOO.OOControlBase)

function M:onEnter()
	self.m_can_show_new = true
	self.m_show_new = false
end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "close_btn2" then
    	self:updateMsg("show_reward", nil, "Jewel.JewelGacha")
        self:closeView()
    elseif msg == "oneKey_btn" then
		self:openNew()
    	--self:openAll()
    elseif msg == "gacha_btn" then
		local count = #self.m_model.m_cards
		if count == 1 then
			self:updateMsg("one_btn", nil, "Jewel.JewelGacha")
		elseif count == 10 then
			self:updateMsg("ten_btn", nil, "Jewel.JewelGacha")
		end
		self:closeView()
    --[[elseif msg == "card_btn_1" then
    	self:fingerOpen(1)
	elseif msg == "card_btn_2" then
		self:fingerOpen(2)
	elseif msg == "card_btn_3" then
		self:fingerOpen(3)
	elseif msg == "card_btn_4" then
		self:fingerOpen(4)
	elseif msg == "card_btn_5" then
		self:fingerOpen(5)
	elseif msg == "card_btn_6" then
		self:fingerOpen(6)
	elseif msg == "card_btn_7" then
		self:fingerOpen(7)
	elseif msg == "card_btn_8" then
		self:fingerOpen(8)
	elseif msg == "card_btn_9" then
		self:fingerOpen(9)
	elseif msg == "card_btn_10" then
    	self:fingerOpen(10)]]--
    elseif msg == "show_new" then
    	if self.m_can_show_new and self.m_show_new then
	    	local card_id = self.m_model:getOpenNewCard()
			if card_id then
				self.m_can_show_new = false
				self:openView("Jewel.JewelNewPop", {id = card_id})
			else
				self.m_show_new = false
				self:openAllNew()
			end
	    end
	elseif msg == "close_new" then
		self.m_can_show_new = true
		self:updateMsg("show_new")
    end
end

--作废
function M:fingerOpen(index)
	--if self.m_model.m_open[index] then
	--	local card_hero_cfg = ConfigManager:getCfgByName("card_hero")
	--	local card = self.m_model.m_cards[index]
	--	local cfg = card_hero_cfg[card[2]]
	--	if cfg.hero_evo > 2 then
	--		self:openView("Pops.HeroLookInfo", {hero_id = cfg.hero_id, is_new = false})
	--	end
	--else
		self:openCard(index)
	--end
end

function M:openCard(index)
	if self.m_model.m_open[index] then
		return
	end
	self.m_model:openCard(index)
    self.m_view:openCard(index)
	self.m_show_new = self.m_model:checkIsNewCard(index)
end

--作废
function M:openAll()
	if self.m_model.m_is_open_all == true then
		self:removeTimer(self.m_tick)
		self.m_view:openAllCard()
		self.m_show_new = true
		self.m_can_show_new = true
		return
	end
	self.m_model.m_is_open_all = true
	self.m_view:setAllCardBtn(false)
	local chard_index = 1
	local time = 0
	local function tick(_, dt)
		if self.m_show_new ~= true then
			time = time - dt
			if time <= 0 then
				time = 0.03
				local index, is_open = self.m_model:getCloseCard(chard_index)
				chard_index = chard_index + 1
				if index then
					if is_open then -- 新宝物先不翻
						self.m_model:openCard(index)
						self.m_view:openCard(index)
					else -- 播放新宝物常驻特效
						time = 0.03
						self.m_view:showZiCardEffect(index)
					end
				else
					self:updateMsg("oneKey_btn")
				end
			end
		end
	end
	self.m_tick = self:setTimer(0.01, tick)
end

--先显示新获得宝物
--再依次翻开卡背，展示结果
--再翻面显示碎片
function M:openNew()
	self.m_show_new = true
	self.m_can_show_new = true
	self:updateMsg("show_new")
end

function M:openAllNew()
	if self.m_model.m_is_open_all == true then
		self:removeTimer(self.m_tick)
		self.m_view:openAllCard()
		return
	end
	self.m_model.m_is_open_all = true
	self.m_view:setAllCardBtn(false)
	local chard_index = 1
	local time = 0
	local function tick(_, dt)
		if self.m_show_new ~= true then
			time = time - dt
			if time <= 0 then
				time = 0.03
				local index, is_open = self.m_model:getCloseCard(chard_index)
				chard_index = chard_index + 1
				if index then
					if is_open then -- 新宝物先不翻
						self.m_model:openCard(index)
						self.m_view:openCard(index)
					else -- 播放新宝物常驻特效
						time = 0.03
						self.m_view:showZiCardEffect(index)
					end
				else
					self:updateMsg("oneKey_btn")
				end
			end
		end
	end
	self.m_tick = self:setTimer(0.01, tick)
end

return M