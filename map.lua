
local Map = {}
local STI = require("sti")
local Player = require("player")

function Map:load()
   self.currentLevel = 1
   World = love.physics.newWorld(0,2000)
   World:setCallbacks(beginContact, endContact)

   self:init()
end

function Map:update(dt)
  self:nextMap()
end

function Map:changeLevel()
  if self.currentLevel == 2 then
    self.currentLevel = 1
  elseif self.currentLevel == 1 then
    self.currentLevel = 2
  end
end

function Map:nextMap(key)
  if key == "e" or key == "f" then
    self:changeLevel()
    self:clean()
    self:init()
    setBackground()
  end
end

function Map:clean()
  self.level:box2d_removeLayer("solid")
end

function Map:init()
   self.level = STI("/assets/map/"..self.currentLevel..".lua", {"box2d"})

   self.level:box2d_init(World)
   self.solidLayer = self.level.layers.solid
   self.groundLayer = self.level.layers.ground

   self.solidLayer.visible = false

   MapWidth = self.groundLayer.width * 16
end

return Map
