-- Disables code if not avatar host
if not host:isHost() then return end

-- Navigation setup
local pageNav = {}

-- Actions table
local acts = {}

-- Set starting page to main page
local main = action_wheel:newPage("Main")
action_wheel:setPage(main)

-- Logs pages order for navigation
local navMap = {}

-- Go forward a page
function pageNav.descend(page)
	
	table.insert(navMap, action_wheel:getCurrentPage())
	action_wheel:setPage(page)
	
end

-- Go back a page
function pageNav.ascend()
	
	action_wheel:setPage(table.remove(navMap, #navMap))
	
end

-- Reset to main page
function pageNav.reset()
	
	navMap = {}
	action_wheel:setPage(main)
	
end

-- Wrap item functions in the action API in the itemCheck lib function
local itemCheck = require("lib.ItemCheck")
local oldActionIndex = figuraMetatables.Action.__index
local adjFuncs = {}
local adjKeys = {
	"setItem",
	"setToggleItem",
	"setHoverItem"
}

-- Create functions to override API
for _, k in ipairs(adjKeys) do
	
	-- Get old function
	local oldFunc = oldActionIndex(nil, k)
	
	-- Create wrapper around function
	adjFuncs[k] = function(self, ...)
		local item = itemCheck(...)
		return oldFunc(self, item)
	end
	
	-- Copy new function to alias
	adjFuncs[k:gsub("^set(%u)", string.lower)] = adjFuncs[k]
	
end

-- Apply to API
function figuraMetatables.Action.__index(self, key)
	return adjFuncs[key] or oldActionIndex(self, key)
end

-- Action back to previous page
local backAct = action_wheel:newAction()
	:title(toJson(
		{text = "Go Back?", bold = true, color = "red"}
	))
	:hoverColor(vectors.hexToRGB("FF5555"))
	:item("barrier")
	:onLeftClick(function() pageNav.ascend() end)
	:onRightClick(function() pageNav.reset() end)

-- After all pages are created, add a back button to all pages except main
function events.ENTITY_INIT()
	
	for k, v in pairs(action_wheel:getPage()) do
		if k ~= "Main" then
			v:setAction(-1, backAct)
		end
	end
	
end

-- Provides color inputs (provided by script)
local s, c = pcall(require, "scripts.ColorProperties")
if not s then c = {} end

-- Return functions, actions, and colors
return pageNav, acts, c