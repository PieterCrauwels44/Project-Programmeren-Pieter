local Player = {}

local DASHKEYS = {p=true}
local JUMPKEYS = {space=true,w=true,up=true}
local CROUCHKEYS = {c=true, down=true}
local SLOWTIMEKEYS = {tab=true, o=true}

local DASH = "dash"
local JUMP = "jump"
local DOUBLEJUMP = "doublejump"
local CROUCH = "crouch"
local SLOWTIME = "slowtime"

function Player:load()
   self.x = 10
   self.y = 300
   self.startX = self.x
   self.startY = self.y

   self.xVel = 0
   self.yVel = 0
   self.maxSpeed = 200
   self.dashSpeed = 1500
	self.dashTime = 0
	self.dashDuration = 0.15
  self.hasSlowtime = true
  self.slowTimeTimer = 0
  self.slowTimeDuration = 2

   self.hasDash = true

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
   self.crouched = false
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

  self.animation.draw = self.animation.idle.img[1]
end

function Player:die()
   self.alive = false
end

function Player:respawn()
   if not self.alive then
      self:resetPosition()
      self.alive = true
      self.height = 32
      self.crouched = false
   end
end

function Player:resetPosition()
   self.physics.body:setPosition(self.startX, self.startY)
end

function Player:update(dt)
   self:syncPhysics()
   self:setState()
   self:animate(dt)
   self:move(dt)
   self:applyGravity(dt)
   self:setDirection()
   self:respawn()
   --self:increaseSlowTimer(dt)
end

function Player:setState()
  if self.xVel > 0 or self.xVel < 0 and self.grounded then
    self.state = "run"
  elseif self.xVel == 0 and self.grounded then
    self.state = "idle"
  elseif not self.grounded then
    self.state = "jump"
  end
end

function Player:animate(dt)
  self.animation.timer = self.animation.timer + dt
  if self.state == "run" then
    self.animation.rate = 0.05
  end
  self.animation.rate = 0.1
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
      self.yVel = self.yVel + self.gravity * dt
   end
end

--[[function Player:increaseSlowTimer(dt)
  self.slowTimeTimer = self.slowTimeTimer + dt
  if self.slowTimeTimer > self.slowTimeDuration then

  end
end

function Player:slowTime(key)
  if SLOWTIMEKEYS[key] and self.hasSlowtime then
    if self.slowTimeTimer < self.slowTimeDuration then
    end
  end
end --]]

function Player:dash(key)
	if DASHKEYS[key] and self.hasDash and (not self.grounded) then
		self.hasDash = false
		table.insert(self.actions,DASH)
	end
end

function Player:crouch(key)
  if CROUCHKEYS[key] and self.grounded then
    self.height = 16
    self.crouched = true
    table.insert(self.actions, CROUCH)
  end
end

function Player:move(dt)
	local dir = 0
   if love.keyboard.isDown("d", "right") then
		dir = 1
   elseif love.keyboard.isDown("a", "left") then
		dir = -1
	end
	for _,a in ipairs(self.actions) do
		if a == JUMP then
			--print("JUMP")
			self.yVel = self.jumpAmount
      self.crouched = false
      self.height = 32
		elseif a == DOUBLEJUMP then
			--print("DOUBLEJUMP")
			self.yVel = self.jumpAmount * 0.8
    elseif a == CROUCH then
      self.xVel = self.xVel * 0.4
      self.maxSpeed = self.maxSpeed * 0.4
		elseif a == DASH then
			--print("DASH")
			self.dashTime = self.dashDuration
			if self.direction == "right" then
				self.xVel = self.dashSpeed
			else
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
	end

	if dir == 0 then
		self:applyFriction(dt)
	else
		self.acceleration = 5000
		self.xVel = self.xVel + dir * self.acceleration * dt
		if math.abs(self.xVel) > self.maxSpeed then
			self.xVel = dir * self.maxSpeed
		end
    print(self.xVel, self.yVel, self.maxSpeed)
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
   elseif b == self.physics.fixture then
      if ny < 0 then
         self:land(collision)
      elseif ny > 0 then
         self.yVel = 0
      end
   end
end

function Player:land(collision)
	print("LAND")
   self.currentGroundCollision = collision
   self.yVel = 0
   self.grounded = true
   self.hasDouble = true
   self.graceTime = self.graceDuration
   self.hasDash = true
	self.dashTime = self.dashDuration
	self.maxSpeed = 200
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
  elseif self.yVel > self.xVel then
    self.direction = "down"
  end
end

function Player:draw()
   local scaleX = 1
   if self.direction == "left" then
      scaleX = -1
   end
   local scaleY = 1
   local frame = self.animation.draw
   local offsetX = 3
   local offsetY = 0
   if self.state == "run" or self.state == "jump" then
     if self.direction == "right" then
       offsetX = 3
     elseif self.direction == "left" then
       offsetX = -3
     elseif self.direction == "down" then
       offsetY = 4
       offsetX = 1
     end
     love.graphics.setColor(1, 0.8, 1, 0.4)
     love.graphics.draw(frame, self.x - offsetX, self.y + offsetY, 0, scaleX, scaleY, frame:getWidth() / 2, self.height + 15)
   end
   love.graphics.setColor(1, 1, 1, 1)
   love.graphics.draw(frame, self.x, self.y, 0, scaleX, scaleY, frame:getWidth() / 2, self.height + 15)
end

return Player

-- (slow time)
-- climbing
-- level
-- unlockables

-- dash animatie
-- dead animation
-- jump animatie
-- crouch/slide animatie
-- spike
