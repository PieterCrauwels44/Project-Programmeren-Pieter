local spawn = {}
local Spike = require("spike")

function spawn:spawnEntities(layer)
	for i,v in ipairs(layer) do
		if v.type == "spikes" then
			Spike:new(v.x + v.width / 2, v.y + v.height / 2)
		end
	end
end

function spawn:clean(level)
  level:box2d_removeLayer("solid")
  Spike:removeAll()
end

return spawn
