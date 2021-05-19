love.graphics.setDefaultFilter("nearest", "nearest")
local Player = require("player")
local Camera = require("camera")
local Map = require("map")
local Spike  = require("spike")

function love.load()
	Map:load()
	setBackground()
	Player:load()
end

function setBackground()
 background = love.graphics.newImage("/assets/bg"..Map.currentLevel..".jpg")
end

function love.update(dt)
	World:update(dt)
	Player:update(dt)
	Spike:updateAll(dt)
	Camera:setPosition(Player.x, 0)
	Map:update(dt)
end

function love.draw()
	love.graphics.draw(background)
	Map.level:draw(-Camera.x, -Camera.y, Camera.scale, Camera.scale)

	Camera:apply()
	Player:draw()
	Spike:drawAll()
	Camera:clear()
end

function love.keypressed(key)
	Player:jump(key)
	Map:nextMap(key)
	Player:crouch(key)
	Player:dash(key)
	--Player:slowTime(key)
end

function beginContact(a, b, collision)
	if Spike.beginContact(a, b, collision) then return end
	Player:beginContact(a, b, collision)
end

function endContact(a, b, collision)
	Player:endContact(a, b, collision)
end
