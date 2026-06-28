---@class GachaTenPopControl:OOControlBase
local M = class("GachaTenPopControl",LikeOO.OOControlBase)

function M:onEnter()
	self.m_guide_file_name = "UI.Pub.GachaTenPop.Guide"
	self.m_can_show_new = true
end

function M:onHandle(msg , data)
    if msg == 99999 then 
    	self:updateMsg("show_reward", nil, "Pub")
        self:closeView()
    elseif msg == "oneKey_btn" or msg == "open_all_btn" then
    	self:openAll()
		--解决引导时快速连续点击会卡主
		self.m_view:lockTouch()
		self:setOnceTimer(0.6, function()
			self.m_view:unlockTouch()
		end)
    elseif msg == "gacha_btn" then
    	-- self:closeView()
    	self:updateMsg("ten_gacha_again", self.m_view.gacha_times, "Pub")
	elseif msg == "close_btn2" then
		self:updateMsg(99999)
    elseif msg == "card_btn_1" then
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
    	self:fingerOpen(10)
    elseif msg == "show_new" then
    	if self.m_can_show_new and self.m_show_new then
	    	local card_id = self.m_model:getOpenNewCard()
			if card_id then
				self.m_can_show_new = false
				local card_hero_cfg = ConfigManager:getCfgByName("card_hero")
				local cfg = card_hero_cfg[card_id]
				self:openView("HeroInfo.HeroNewPop", {hero_id = cfg.hero_id, is_new = true})
			else
				self.m_show_new = false
			end
	    end
	elseif msg == "close_new" then
		self.m_can_show_new = true
		self:updateMsg("show_new")
	elseif msg == "share_btn" then
		self.m_view:ShareShow(false)
		local show_call = function()
			self.m_view:ShareShow(true)
		end
		self:openView("SharePicture", {picture_callback = show_call})
    end
end

function M:fingerOpen(index)
	if self.m_model.m_open[index] then
		local card_hero_cfg = ConfigManager:getCfgByName("card_hero")
		local card = self.m_model.m_cards[index]
		local cfg = card_hero_cfg[card[2]]
		if cfg.hero_evo > 2 then
			self:openView("Pops.HeroLookInfo", {hero_id = cfg.hero_id, is_new = false})
		end
	else
		self:openCard(index)
	end
end

function M:openCard(index)
	if self.m_model.m_open[index] then
		return
	end
	self.m_model:openCard(index)
    self.m_view:openCard(index)
	self.m_show_new = self.m_model:checkIsNewCard(index)
end

function M:openAll()
	if self.m_model.m_is_open_all == false then
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
						if is_open then -- 紫卡先不翻
							self.m_model:openCard(index)
							self.m_view:openCard(index)
							self.m_show_new = self.m_model:checkIsNewCard(index)
						else -- 播放紫卡常驻特效
							time = 0.03
							self.m_view:showZiCardEffect(index)
						end
		    		else
		    			--self:removeTimer(self.m_tick)
		    			--self.m_view:updateUI()
						self:updateMsg("oneKey_btn")
		    		end
				end
			end
		end
		self.m_tick = self:setTimer(0.01, tick)
	else
		self:removeTimer(self.m_tick)
		-- self.m_model:openAllCard()
		self.m_view:openAllCard()
		--self.m_view:updateUI()
		self.m_show_new = true
		self.m_can_show_new = true
	end
end

return M