local M = class("ExchangePopModel", LikeOO.OODataBase)

local TAB_ = {
	{id = 1, rewards = {}, num = 100, cons = {}  },
	{id = 2, rewards = {}, num = 100, cons = {}  },
	{id = 3, rewards = {}, num = 100, cons = {}  },
	{id = 4, rewards = {}, num = 100, cons = {}  },
	{id = 5, rewards = {}, num = 100, cons = {}  },
	{id = 6, rewards = {}, num = 100, cons = {}  },
	{id = 7, rewards = {}, num = 100, cons = {}  },
	{id = 8, rewards = {}, num = 100, cons = {}  },
	{id = 9, rewards = {}, num = 100, cons = {}  },
	{id = 10, rewards = {}, num = 100, cons = {}  },
}

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_change_tab = TAB_
end


return M
