local Spike = require("spike")
local Map = {}
local STI = require("sti")
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
    self:clean(self.level)
    self:init()
    setBackground()
  end
end

function Map:clean()
  self.level:box2d_removeLayer("solid")
  Spike:removeAll()
end

function Map:init()
   self.level = STI("/assets/map/stranded"..self.currentLevel..".lua", {"box2d"})

   self.level:box2d_init(World)
   self.solidLayer = self.level.layers.solid
   self.groundLayer = self.level.layers.ground
   self.entityLayer = self.level.layers.entity
   self.wallLayer = self.level.layers.climb
   self.solidLayer.visible = false
   self.entityLayer.visible = false
   self.wallLayer.visible = false
   MapWidth = self.groundLayer.width * 16
   self:spawnEntities()
end

function Map:spawnEntities()
	for i,v in ipairs(self.entityLayer.objects) do
		if v.type == "spikes" then
			Spike:new(v.x + v.width / 2, v.y + v.height / 2)
		end
	end
end

return Map
