
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
  self:changeMap()
end

function Map:changeLevel(currentLevel)
  if currentLevel == 2 then
    currentLevel = 1
  elseif currentLevel == 1 then
    currentLevel = 2
  end
  return currentLevel
end

function Map:nextMap()
  if key == "e" or key == "f" then
    self.currentLevel = self:changeLevel(self.currentLevel)
  end
end

function Map:changeMap()

function Map:init()
   self.level = STI("/assets/map/"..self.currentLevel..".lua", {"box2d"})

   self.level:box2d_init(World)
   self.solidLayer = self.level.layers.solid
   self.groundLayer = self.level.layers.ground

   self.solidLayer.visible = false

   MapWidth = self.groundLayer.width * 16
end

return Map
