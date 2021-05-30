local Player = {}
local STI = require("sti")
local DASHKEYS = {p=true}
local JUMPKEYS = {space=true,w=true,up=true}
local SLOWTIMEKEYS = {o=true}

local DASH = "dash"
local JUMP = "jump"
local DOUBLEJUMP = "doublejump"
local SLOWTIME = "slowtime"

function Player:load()
   self.x = 10
   self.y = 301
   self.startX = 10
   self.startY = 301
   self.test = self.wallLayer
   self.sideCollision = false
   self.xVel = 0
   self.yVel = 0
   self.moveAllowed = true
   self.maxSpeed = 200
   self.dashSpeed = 1500
	self.dashTime = 0
	self.dashDuration = 0.15
  self.hasSlowtime = true
  self.slowTimeTimer = 0.5
  self.slowTimeDuration = 0.5
  self.climbing = true
  self.slowFactorX = 1
  self.slowFactorY = 1
   self.hasDash = true
   self.gravityFactor = 1
   self.isDashing = false
   self.isRunning = false
   self.startTimer = false
   self.deadTimer = 0.3
   self.endTimer = false

	self.actions = { }

   self.acceleration = 5000
   self.friction = 3500
   self.gravity = 1500
   self.jumpAmount = -500
   self.width = 16
   self.height = 32
   self.hasDouble = true
   self.graceTime = 0
   self.graceDuration = 0.1
   self.grounded = false
   self.direction = "right"
   self.alive = true
   self.state = "idle"
   self:loadAssets()
   self.physics = {}
   self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
   self.physics.body:setFixedRotation(true)
   self.physics.shape = love.physics.newRectangleShape(self.width, self.height)
   self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
   self.physics.body:setGravityScale(0)
end

function Player:loadAssets()
  self.animation = {timer = 0, rate = 0.1}
  self.animation.idle = {current = 1, total = 3, img = {}}
  for i=1, self.animation.idle.total do
    self.animation.idle.img[i] = love.graphics.newImage("/assets/player/idle/idle"..i..".png")
  end

  self.animation.run = {current = 1, total = 5, img = {}}
  for i=1, self.animation.run.total do
    self.animation.run.img[i] = love.graphics.newImage("/assets/player/run/run"..i..".png")
  end

  self.animation.jump = {current = 1, total = 4, img = {}}
  for i=1, self.animation.jump.total do
    self.animation.jump.img[i] = love.graphics.newImage("/assets/player/jump/jump"..i..".png")
  end

  self.animation.dash = {current = 1, total = 3, img = {}}
  for i=1, self.animation.dash.total do
    self.animation.dash.img[i] = love.graphics.newImage("/assets/player/dash/dash"..i..".png")
  end

  self.animation.dead = {current = 1, total = 8, img = {}}
  for i=1, self.animation.dead.total do
    self.animation.dead.img[i] = love.graphics.newImage("/assets/player/dead/dead"..i..".png")
  end

  self.animation.slow = {current = 1, total = 1, img = {}}
  self.animation.slow.img[1] = love.graphics.newImage("/assets/player/slow/slow.png")

  self.animation.draw = self.animation.idle.img[1]
end

function Player:die()
   self.alive = false
   self:respawn()
end

function Player:respawn()
      self.startTimer = true
      self.moveAllowed = false
      self.state = "dead"
      if self.endTimer then
        self:resetPosition()
        self.startTimer = false
        self.moveAllowed = true
        self.alive = true
        self.endTimer = false
      end
end

function Player:timer(dt)
  if self.startTimer then
    self.deadTimer = self.deadTimer - dt
    if self.deadTimer < 0 then
      self.endTimer = true
      self:respawn()
      self.deadTimer = 0.3
    end
  end
end

function Player:resetPosition()
   self.physics.body:setPosition(self.startX, self.startY)
   print(self.startX, self.startY)
end

function Player:update(dt)
   self:syncPhysics()
   self:applyGravity(dt)
   self:setState()
   self:animate(dt)
   self:move(dt)
   self:climb()
   self:setDirection()
   self:timer(dt)
end

function Player:climb()
  if self.sideCollision == "left" or self.sideCollision == "right"then
    if not self.grounded then
      self.climbing = true
      self:hold()
    end
  end
end

function Player:hold()

end

function Player:setState()
  if self.isRunning == true and self.grounded and not self.isDashing and self.alive and self.slowFactorY == 1 then
    self.state = "run"
  elseif self.xVel == 0 and self.grounded and self.alive then
    self.state = "idle"
  elseif not self.grounded and not self.isDashing and self.alive and self.slowFactorY == 1 then
    self.state = "jump"
  elseif self.isDashing and not self.grounded and self.alive and self.slowFactorY == 1 then
    self.state = "dash"
  elseif not self.alive and self.alive then
    self.state = "dead"
  elseif self.slowFactorY == 0.025 then
    self.state = "slow"
  end
  print(self.state)
end

function Player:animate(dt)
  self.animation.timer = self.animation.timer + dt
  if self.state == "run" or self.state == "dash" then
    self.animation.rate = 0.05
  elseif self.state == "idle" or self.state == "jump" then
    self.animation.rate = 0.1
  end
  if self.animation.timer > self.animation.rate then
    self.animation.timer = 0
    self:newFrame()
  end
end

function Player:newFrame()
  local anim = self.animation[self.state]
  if anim.current < anim.total then
    anim.current = anim.current + 1
  else
    anim.current = 1
  end
  self.animation.draw = anim.img[anim.current]
end

function Player:applyGravity(dt)
   if not self.grounded then
      self.yVel = self.yVel + self.gravity * dt * self.gravityFactor
   end
end

function Player:dash(key)
	if DASHKEYS[key] and self.hasDash and (not self.grounded) then
		self.hasDash = false
		table.insert(self.actions,DASH)
    self.isDashing = true
    self.isRunning = false
	end
end

function Player:move(dt)
  if self.moveAllowed then
  	local dir = 0
     if love.keyboard.isDown("d", "right") then
       self.isRunning = true
  		dir = 1
     elseif love.keyboard.isDown("a", "left") then
       self.isRunning = true
  		dir = -1
  	end
    local slow =  false
    if love.keyboard.isDown("o") and not self.grounded then
      slow = true
    end

  	for _,a in ipairs(self.actions) do
  		if a == JUMP then
  			--print("JUMP")
  			self.yVel = self.jumpAmount
  		elseif a == DOUBLEJUMP then
  			--print("DOUBLEJUMP")
  			self.yVel = self.jumpAmount * 0.8
  		elseif a == DASH then
    			self.dashTime = self.dashDuration
    			if self.direction == "right" then
    				self.xVel = self.dashSpeed
    			elseif self.direction == "left" then
    				self.xVel = -self.dashSpeed
    			end
  			  self.maxSpeed = self.dashSpeed
  	 	 end
  	end

  	self.actions = {}

    self.dashTime = self.dashTime - dt
  	if self.dashTime < 0 then
    	self.dashTime = 0
    	self.maxSpeed = math.min(200, self.maxSpeed)
      self.isDashing = false
  	end

    if slow == true then
    self.slowTimeTimer = self.slowTimeTimer - dt
    if self.slowTimeTimer < 0 then
      self.slowTimeTimer = 0
      slow = false
    end
    end

    if slow == false then
      self.slowFactorX = 1
      self.slowFactorY = 1
      self.gravityFactor = 1
    elseif slow then
      self.slowFactorX = 0.7
      self.slowFactorY = 0.025
      self.gravityFactor = 0.4
   end

	if dir == 0 then
    self.isRunning = false
		self:applyFriction(dt)
	else
		self.acceleration = 5000
		self.xVel = self.xVel + dir * self.acceleration * dt * self.slowFactorX
		if math.abs(self.xVel) > self.maxSpeed then
			self.xVel = dir * self.maxSpeed * self.slowFactorX
		end
	end
end
end

function Player:applyFriction(dt)
   if self.xVel > 0 then
      self.xVel = math.max(self.xVel - self.friction * dt, 0)
   elseif self.xVel < 0 then
      self.xVel = math.min(self.xVel + self.friction * dt, 0)
   end
end

function Player:syncPhysics()
   self.x, self.y = self.physics.body:getPosition()
   self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end

function Player:beginContact(a, b, collision)
   if self.grounded == true then return end
   local nx, ny = collision:getNormal()
   if a == self.physics.fixture then
      if ny > 0 then
         self:land(collision)
      elseif ny < 0 then
         self.yVel = 0
      end
    else
        if nx < 0 then
          self.sideCollision = "left"
          print("coll")
        elseif nx > 0 then
          self.sideCollision = "right"
          print("coll")
        end
   end

   if b == self.physics.fixture then
      if ny < 0 then
         self:land(collision)
      elseif ny > 0 then
         self.yVel = 0
      end
    else
        if nx < 0 then
          self.sideCollision = "left"
          print("coll")
        elseif nx > 0 then
          self.sideCollision = "right"
          print("coll")
        end
   end
end

function Player:land(collision)
   self.currentGroundCollision = collision
   self.yVel = 0
   self.grounded = true
   self.hasDouble = true
   self.graceTime = self.graceDuration
   self.hasDash = true
	self.dashTime = self.dashDuration
	self.maxSpeed = 200
  self.slowTimeTimer = self.slowTimeDuration
end

function Player:jump(key)
   if JUMPKEYS[key] then
      if self.grounded or self.graceTime > 0 then
			table.insert(self.actions,JUMP)
--         self.yVel = self.jumpAmount
         self.graceTime = 0
      elseif self.hasDouble then
			table.insert(self.actions,DOUBLEJUMP)
 --        self.yVel = self.jumpAmount * 0.8
         self.hasDouble = false
      end
   end
end

function Player:endContact(a, b, collision)
   if a == self.physics.fixture or b == self.physics.fixture then
      if self.currentGroundCollision == collision then
         self.grounded = false
      end
   end
end

function Player:setDirection()
  if self.xVel < 0 then
    self.direction = "left"
  elseif self.xVel > 0 then
    self.direction = "right"
  end
end

function Player:draw()
   local scaleX = 1
   local scaleY = 1
   local offsetX = 3
   local offsetY = 0
   if self.direction == "left" then
      scaleX = -1
   end
   if self.state == "slow" then
     self.animation.draw = self.animation.slow.img[1]
   end
   local frame = self.animation.draw
   if self.state == "run" or self.state == "jump" then -- schaduw
     if self.direction == "right" then
       offsetX = 3
     elseif self.direction == "left" then
       offsetX = -3
     elseif self.direction == "down" then
       offsetY = 4
       offsetX = 1
     end
     love.graphics.setColor(0.5, 0, 0.8, 0.4)
     love.graphics.draw(frame, self.x - offsetX, self.y + offsetY, 0, scaleX, scaleY,  frame:getWidth() / 2, self.height + 15)
   end

   love.graphics.setColor(1, 1, 1, 1) -- echte speler
   love.graphics.draw(frame, self.x, self.y, 0, scaleX, scaleY, frame:getWidth() / 2, self.height + 15)
end

return Player

-- climbing
-- level
-- unlockables

-- spike
