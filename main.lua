love.graphics.setDefaultFilter("nearest", "nearest")
local Player = require("player")
local Camera = require("camera")
local Map = require("map")

function love.load()
	Map:load()
	background = love.graphics.newImage("/assets/bg1.jpg")
	Player:load()
end

function love.update(dt)
	World:update(dt)
	Player:update(dt)
	Camera:setPosition(Player.x, 0)
end

function love.draw()
	love.graphics.draw(background)
	Map.level:draw(-Camera.x, -Camera.y, Camera.scale, Camera.scale)

	Camera:apply()
	Player:draw()
	Camera:clear()
end

function love.keypressed(key)
	Player:jump(key)
end

function beginContact(a, b, collision)
	Player:beginContact(a, b, collision)
end

function endContact(a, b, collision)
	Player:endContact(a, b, collision)
end
