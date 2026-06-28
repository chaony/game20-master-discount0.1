local M = class("HeroBookShowControl",LikeOO.OOControlBase)

function M:onEnter()
	--self.m_view.m_luaBehaviour:UseFingersSliding(handler(self,self.fingerSliding))
	self.slid_lock = false
	self:switchTabBtn(self.m_model.m_open_tab_index, true)
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
		-- self:updateMsg("common_refresh",nil,"parent")
		self:updateMsg("refresh_ui",nil,"HeroBook")
		self:closeView()
	elseif msg == "closeNode_btn" then
		self:updateMsg(99999)
	 -- 1属性、2经脉、3逸闻 
	elseif type(msg) == "number" and msg >= 1 and msg <= 3 then
		self:switchTabBtn(msg)
 	elseif msg == "put_on_btn" then
		self:putOn()	    		
 	elseif msg == "last_btn" then --切换英雄
 		self:lastHero()
 	elseif msg == "next_btn" then 
 		self:nextHero()		
	elseif msg == "skill1_img" then
		local skills = self.m_model:getHeroSkill()
		local hero_lv = self.m_model:getHero_lv()
		self:openView("Pops.SkillPop",{skill = skills[1], index = 1, cur_lv = hero_lv })
	elseif msg == "skill2_img" then	
		local skills = self.m_model:getHeroSkill()
		local hero_lv = self.m_model:getHero_lv()
		self:openView("Pops.SkillPop",{skill = skills[2], index = 2, cur_lv = hero_lv })
	elseif msg == "skill3_img" then	
		local skills = self.m_model:getHeroSkill()
		local hero_lv = self.m_model:getHero_lv()
		self:openView("Pops.SkillPop",{skill = skills[3], index = 3, cur_lv = hero_lv })
	elseif msg == "skill4_img" then	
		local skills = self.m_model:getHeroSkill()
		local hero_lv = self.m_model:getHero_lv()
		self:openView("Pops.SkillPop",{skill = skills[4], index = 4, cur_lv = hero_lv })
	elseif msg == "camp_img_btn" then
		-- local data_desc = "status_"..self.m_model:getHeroRace()
		-- local btns = self.m_view:findGameObject("camp_img_btn")
		-- GameUtil:lookInfoTips(self.m_control, {click_transform = btns.transform, msg = Language:getTextByKey(data_desc)  } )
	elseif msg == "pro_img_btn" then
		-- local data_desc = "herotype"..self.m_model:getHeroType()
		-- local btns = self.m_view:findGameObject("pro_img_btn")
		-- GameUtil:lookInfoTips(self.m_control, {click_transform = btns.transform, msg = Language:getTextByKey(data_desc) } )
	elseif msg == "change_hero" then
		self.m_model:changeHero(data)
		self:update_Hero()
	elseif msg == "get_reward_btn" then
		self:getKillReward()
	end
end

-- tab按钮切换
function M:switchTabBtn(index, first_enter)
	if self.m_model.m_sel_tab_index ~= index then
		self.m_view:switchTabNode(index, first_enter)
		self.m_model.m_sel_tab_index = index
    end
end

function M:lastHero()
	-- 切换上一个英雄
	self.m_model:switchTo(false,handler(self,self.update_Hero))
	self.m_view:changeOffset(true)
end

function M:nextHero()
	-- 切换下一个英雄
	self.m_model:switchTo(true,handler(self,self.update_Hero))
	self.m_view:changeOffset(false)
end

function M:update_Hero()
	self.m_view:refreshUI()
end

function M:fingerSliding(locat)
	if self.m_model.m_sel_tab_index ~= 1 or self.slid_lock == true then
		return
	end
	if self.click_down and self.click_down == true then --
		return
	end
	if locat == true then
		self:lastHero()
	else
		self:nextHero()
	end
end

--领取奖励
function M:getKillReward()
    local function callfunc(response)
		RewardUtil:rewardTipsByData(response.reward)
		UserDataManager.hero_data:updateOneHeroCollect(self.m_model.m_cur_id)
		self:updateMsg("update_equip", nil, "HeroInfo")
		self.m_view:refreshUI()
	end
    local data = {
        hero_id = self.m_model.m_cur_id
    }
    self.m_model:getNetData("hero_collect_receive", data, callfunc)
end


function M:onDestroy()

end

return M
