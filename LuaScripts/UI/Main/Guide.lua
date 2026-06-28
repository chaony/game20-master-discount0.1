local guide = class("Main", LikeOO.OOGuideBase)

-- 点击挑战首领
function guide:excuteGuideFunc1(info)
    if self.m_model.m_sel_tab_index and self.m_model.m_sel_tab_index ~= 1 then
        local is_force = UserDataManager.guide_data:curGuideIsForce()
        if is_force then
            self.m_control:updateMsg("closeNode_btn")
        else
            return    
        end
    end
    
    local node = self.m_view.m_battle_node:findGameObject("challenge_btn_guide")
    if node then
        self.m_listener = {
            key = "challenge_btn",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 点击武神按钮
function guide:excuteGuideFunc2(info)
    if self.m_model.m_sel_tab_index ~= 1 then 
        self.m_control:updateMsg("closeNode_btn")
    end
	local toggle_tab = {"union_btn", "hero_btn", "bag_btn", "mail_btn", "task_btn"}
    local target = info.target[1]
    local node = self.m_view:findGameObject(toggle_tab[target])
    if node then
        self.m_listener = {
            key = toggle_tab[target],
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 点击特定武神
function guide:excuteGuideFunc3(info)
	local target = info.target[1]
	local heros = self.m_model.Filtrate_list
	local node = nil
    if not self.m_view.m_cur_tab_node then
        return
    end
    
	for i,v in ipairs(heros) do
		local hero, cfg = UserDataManager.hero_data:getHeroDataById(v)
		if cfg.id == target then
            self.m_view.m_cur_tab_node.m_loop_scroll_view:moveToCellIndex(i)
			local cell_node = self.m_view.m_cur_tab_node.m_loop_scroll_view.m_cache_cells[i]
		    if cell_node then
	    		node = cell_node
	    		break
			end
		end
	end

    if node then
        self.m_listener = {
            key = "select_hero",
            check = function (data)
            	local hero, cfg = UserDataManager.hero_data:getHeroDataById(data)
            	if cfg.id == target then
            		return true
            	end
            end
        }   
        self:guideTargetNode(node.transform, 1, 1)
    else

    end
end

-- 点击功能建筑
function guide:excuteGuideFunc6(info)
    if self.m_view.m_cur_tab_node and self.m_view.m_cur_tab_node.m_btn_lock_img then
        local target = info.target[1]
        local build_tab = self.m_view.m_cur_tab_node.m_btn_lock_img
        local build_cfg = build_tab[target]
        self.m_view.m_cur_tab_node:jumpBuild(target)
        local node = self.m_view.m_cur_tab_node:findGameObject(build_cfg.bnt_key)
        if node then
            self.m_view.m_cur_tab_node.m_sliding = false
            self.m_view.m_cur_tab_node.m_scroll_rect.horizontal = false
            self.m_listener = {
                key = build_cfg.bnt_key,
            }
            self:guideTargetNode(node.transform, 1, 1)
        else
            self:doNextGuide()
        end
    end
end

-- 展示卡牌
function guide:excuteGuideFunc8(info)
    local card = info.target[1]
    self:doNextGuide()
    if card then
        self.m_control:openView("HeroInfo.HeroNewPop", {hero_id = card, is_new = true})
    end
end

-- 点击挂机宝箱
function guide:excuteGuideFunc9(info)
    if self.m_model.m_sel_tab_index ~= 1 then 
        self.m_control:updateMsg("closeNode_btn")
    end

    local node = self.m_view.m_battle_node:findGameObject("guaji_box")
    if node then
        self.m_listener = {
            key = "guaji_box",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 点击快速挂机
function guide:excuteGuideFunc10(info)
    if self.m_model.m_sel_tab_index ~= 1 then 
        self.m_control:updateMsg("closeNode_btn")
    end
    
    local node = self.m_view.m_battle_node:findGameObject("guaji_btn")
    if node then
        self.m_listener = {
            key = "guaji_btn",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end

function guide:excuteGuideFunc11(info)
    local function callback()
        self:doNextGuide()
    end
    self.m_control:openView("Pops.PlotPop", {callback = callback})
end

function guide:excuteGuideFunc12(info)
    local node = self.m_view:findGameObject("sect_btn")
    if node then
        self.m_listener = {
            key = "sect_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

function guide:excuteGuideFunc13(info)
    local node = self.m_view:findGameObject("big_world_btn")
    if node then
        self.m_listener = {
            key = "big_world_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

function guide:excuteGuideFunc14(info)
    local function nameback()
        self:checkGuide()
    end
    self.m_control:openView("Pops.GuidePlayerNamePop", {callback = nameback})
    self:doNextGuide()
end

-- 点击江湖
function guide:excuteGuideFunc15(info)
    local node = self.m_view:findGameObject("rune_scape_btn")
    if node then
        self.m_listener = {
            key = "rune_scape_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 点击天下
function guide:excuteGuideFunc16(info)
    local node = self.m_view:findGameObject("total_arena_btn")
    if node then
        self.m_listener = {
            key = "total_arena_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 点击小游戏
function guide:excuteGuideFunc17(info)
    local node = self.m_view.m_battle_node:findGameObject("helpdog_btn")
    if node then
        self.m_listener = {
            key = "little_games_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
    self:doNextGuide()
end

--点击主界面主菜单的招募
function guide:excuteGuideFunc18(info)
    local node = self.m_view:findGameObject("tavern_btn")
    if node then
        self.m_listener = {
            key = "tavern_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

--点击主界面主菜单的酒楼
function guide:excuteGuideFunc19(info)
    local node = self.m_view:findGameObject("hotel_btn")
    if node then
        self.m_listener = {
            key = "hotel_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

function guide:excuteGuideFunc99999(info)
    if self.m_view.m_cur_tab_node then
        local node = self.m_view.m_cur_tab_node:findGameObject("close_btn")
        if node then
            self.m_listener = {
                key = "close_btn",
            }
            self:guideTargetNode(node.transform, 1, 1)
        end
    end
end

return guide
