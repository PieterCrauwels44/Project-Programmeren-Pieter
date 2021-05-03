local Player = {}

function Player:load()
   self.x = 100
   self.y = 0
   self.startX = self.x
   self.startY = self.y
   self.xVel = 0
   self.yVel = 0
   self.maxSpeed = 200
   self.dashSpeed = 1000
   self.hasDash = true
   self.acceleration = 4000
   self.friction = 3500
   self.gravity = 1500
   self.jumpAmount = -500
   self.width = 33
   self.height = 60
   self.hasDouble = true
   self.graceTime = 0
   self.graceDuration = 0.1
   self.grounded = false
   self.crouched = false
   self.direction = "right"
   self.isDashing = false

   self.physics = {}
   self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
   self.physics.body:setFixedRotation(true)
   self.physics.shape = love.physics.newRectangleShape(self.width, self.height)
   self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
   self.physics.body:setGravityScale(0)
   self.physics.img = love.graphics.newImage("/assets/player.png")
end

function Player:update(dt)
   self:syncPhysics()
   self:move(dt)
   self:applyGravity(dt)
   self:setDirection()
   self:dash()
end

function Player:applyGravity(dt)
   if not self.grounded then
      self.yVel = self.yVel + self.gravity * dt
   end
end

function Player:dash(key)
  if key == "g" then
    if self.hasDash and not self.grounded then
      self.isDashing = true
      self.hasDash = false
      if self.direction == "right" then
        self.xVel = self.dashSpeed
        self.isDashing = false
      elseif self.direction == "left" then
        self.xVel = -self.dashSpeed
        self.isDashing = false
      end
    end
  end
end

function Player:move(dt)
   if love.keyboard.isDown("d", "right") and not self.isDashing then
      self.xVel = math.min(self.xVel + self.acceleration * dt, self.maxSpeed)
   elseif love.keyboard.isDown("a", "left") and not self.isDashing then
      self.xVel = math.max(self.xVel - self.acceleration * dt, -self.maxSpeed)
   else
      self:applyFriction(dt)
   end
end

function Player:crouch(key)
  if key == "s" or key == "down" then
    self.height = 30
    self.crouched = true
  else
    self.crouched = false
    self.height = 60
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
   self.currentGroundCollision = collision
   self.yVel = 0
   self.grounded = true
   self.hasDouble = true
   self.graceTime = self.graceDuration
   self.hasDash = true
end

function Player:jump(key)
   if (key == "w" or key == "up" or key == "space") then
      if self.grounded or self.graceTime > 0 then
         self.yVel = self.jumpAmount
         self.graceTime = 0
      elseif self.hasDouble then
         self.yVel = self.jumpAmount * 0.8
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
   if self.direction == "left" then
      scaleX = -1
   end
   local scaleY = 1
   local crouchOffset = 0
   if self.crouched then
     scaleY = 0.5
     crouchOffset = 8
   end
   love.graphics.draw(self.physics.img, self.x, self.y + crouchOffset, 0, scaleX, scaleY, self.width / 2, self.height / 2)
end

return Player

-- Double jump
-- Verandering richting
-- Dash
-- Grace time
-- Spike
