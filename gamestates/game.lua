local deque = require 'lib.deque'


local game = {}

local WALL_THICKNESS = 1.0
local GRAVITY = 9.81 

local scoreP1 = 0
local scoreP2 = 0
local playerWon = nil
local matchPoint = 5
local function reset()
  scoreP1 = 0
  scoreP2 = 0
  playerWon = nil
  matchPoint = 5
  posBall:setPosition(0, 0)
  posBall:setLinearVelocity(0, 0)
  posP1:setPosition(-BOUNDS_WIDTH/4, 0)
  posP1:setLinearVelocity(0, 0)
  posP2:setPosition(BOUNDS_WIDTH/4, 0)
  posP2:setLinearVelocity(0, 0)
end

function game:init()
  world = love.physics.newWorld(0, GRAVITY * love.physics.getMeter(), false)
  -- boundaries
  shapeX = love.physics.newRectangleShape(BOUNDS_WIDTH, WALL_THICKNESS)
  shapeY = love.physics.newRectangleShape(WALL_THICKNESS, BOUNDS_HEIGHT)
  posTop    = love.physics.newBody(world, 0, -BOUNDS_HEIGHT/2, "static")
  posBottom = love.physics.newBody(world, 0, BOUNDS_HEIGHT/2, "static")
  posLeft   = love.physics.newBody(world, -BOUNDS_WIDTH/2, 0, "static")
  posRight  = love.physics.newBody(world, BOUNDS_WIDTH/2, 0, "static")
  wallTop = love.physics.newFixture(posTop, shapeX)
  wallBottom = love.physics.newFixture(posBottom, shapeX)
  wallLeft = love.physics.newFixture(posLeft, shapeY)
  wallRight = love.physics.newFixture(posRight, shapeY)
  wallBottom:setFriction(0.7)
  wallRight:setRestitution(1.0)
  wallLeft:setRestitution(1.0)
  -- bounds shape
  shapeXY = love.physics.newRectangleShape(BOUNDS_WIDTH, BOUNDS_HEIGHT)
  posCenter = love.physics.newBody(world, 0, 0, "static")
  wallBounds = love.physics.newFixture(posCenter, shapeXY)
  wallBounds:setSensor(true)
  -- players
  shapeP = love.physics.newRectangleShape(2, 2.8)
  posP1 = love.physics.newBody(world, 0, 0, "dynamic")
  player1 = love.physics.newFixture(posP1, shapeP)
  posP2 = love.physics.newBody(world, 0, 0, "dynamic")
  player2 = love.physics.newFixture(posP2, shapeP)
  -- ball
  shapeBall = love.physics.newRectangleShape(1, 1)
  posBall = love.physics.newBody(world, 0, 0, "dynamic")
  ball = love.physics.newFixture(posBall, shapeBall)
  ball:setRestitution(0.7)
  -- goals
  shapeGoal = love.physics.newRectangleShape(1, 6)
  posLeftGoal   = love.physics.newBody(world, -BOUNDS_WIDTH/2, BOUNDS_HEIGHT/4, "static")
  posRightGoal  = love.physics.newBody(world, BOUNDS_WIDTH/2, BOUNDS_HEIGHT/4, "static")
  goal1 = love.physics.newFixture(posLeftGoal, shapeGoal)
  goal2 = love.physics.newFixture(posRightGoal, shapeGoal)
  goal1:setSensor(true)
  goal2:setSensor(true)
end

function game:enter(previous)
  reset()
end

function game:leave()
  
end

function game:update(dt)
  world:update(dt)
  posP1:setAngle(0)
  posP2:setAngle(0)
  posBall:setAngle(0)

  if scoreP1 == matchPoint -1 and scoreP2 == matchPoint - 1 then
    matchPoint = matchPoint + 1
  elseif scoreP1 == matchPoint then
    playerWon = 1
  elseif scoreP2 == matchPoint then
    playerWon = 2
  end

  if not playerWon then
    if posBall:isTouching(posLeftGoal) then
      print("goal 1")
      scoreP2 = scoreP2 + 1
      posBall:setPosition(0, 0)
      posBall:setLinearVelocity(0, 0)
    elseif posBall:isTouching(posRightGoal) then
      print("goal 2")
      scoreP1 = scoreP1 + 1
      posBall:setPosition(0, 0)
      posBall:setLinearVelocity(0, 0)
    end
  else
    if love.keyboard.isDown("r") then
      reset()
    end
  end

  function kickBall(kicker)
    local str = 0.01
    local bx, by = posBall:getPosition()
    local px, py = kicker:getPosition()
    local dx, dy = vector.normalize(vector.sub(bx, by, px, py))
    posBall:applyLinearImpulse(str * dx, math.min(str * dy, -0.05))
  end

  if posBall:isTouching(posP1) then
    kickBall(posP1)
  end

  if posBall:isTouching(posP2) then
    kickBall(posP2)
  end

  if love.keyboard.isDown("w") then
    if posP1:isTouching(posBottom) or posP1:isTouching(posP2) then
      posP1:applyLinearImpulse(0, -0.3)
    end
  elseif love.keyboard.isDown("s") then
    posP1:applyForce(0, GRAVITY / 4)
  end
  if love.keyboard.isDown("d") then --press the right arrow key to push the ball to the right
    posP1:applyForce(1, 0)
  elseif love.keyboard.isDown("a") then --press the left arrow key to push the ball to the left
    posP1:applyForce(-1, 0)
  end

  if love.keyboard.isDown("up") then
    if posP2:isTouching(posBottom) or posP2:isTouching(posP1) then
      posP2:applyLinearImpulse(0, -0.3)
    end
  elseif love.keyboard.isDown("down") then
    posP2:applyForce(0, GRAVITY / 4)
  end
  if love.keyboard.isDown("right") then --press the right arrow key to push the ball to the right
    posP2:applyForce(1, 0)
  elseif love.keyboard.isDown("left") then --press the left arrow key to push the ball to the left
    posP2:applyForce(-1, 0)
  end

end

local function renderShape(t, fixture) 
  local shape = fixture:getShape()
  local body = fixture:getBody()
  love.graphics.polygon(t, body:getWorldPoints(shape:getPoints()))
end

local red = {1.0, 0.5, 0.5} 
local blue = {0.5, 0.5, 1.0}
local green = {0.5, 1.0, 0.5}
local white = {1.0, 1.0, 1.0}
local function augment(arr, num)
  local i
  local new = {}
  for i=1, #arr do
    table.insert(new, arr[i] * num)
  end
  return new
end

function game:draw(dt)
  -- text
  love.graphics.setColor(blue, 0.7)
  love.graphics.printf(scoreP1, 0, 0, love.graphics.getWidth(), "left")
  love.graphics.setColor(red, 0.7)
  love.graphics.printf(scoreP2, 0, 0, love.graphics.getWidth(), "right")
  love.graphics.setColor(white, 0.7)
  love.graphics.printf("Match Point: " .. matchPoint, 0, 0, love.graphics.getWidth(), "center")
  -- objects
  camera:attach()
  -- love.graphics.setLineWidth(0.1)
  -- love.graphics.setPointSize(10)
  love.graphics.setColor(white)
  renderShape("fill", player1)
  renderShape("fill", player2)
  love.graphics.setColor(blue)
  renderShape("line", player1)
  love.graphics.setColor(red)
  renderShape("line", player2)
  love.graphics.setColor(white)
  renderShape("line", wallBounds)
  love.graphics.setColor(green)
  renderShape("fill", ball)
  renderShape("line", ball)
  love.graphics.setColor(blue)
  renderShape("fill", goal1)
  love.graphics.setColor(red)
  renderShape("fill", goal2)
  -- for _, fixture in pairs(renderList) do
  --     local shape = fixture:getShape()
  --     local body = fixture:getBody()
  --     love.graphics.polygon("line", body:getWorldPoints(shape:getPoints()))
  -- end
  camera:detach()
  if playerWon then
    love.graphics.setColor(white)
    love.graphics.printf("Player " .. playerWon .. " \nWon!\n\n(press 'R' to reset)", 0, love.graphics.getHeight()/2, love.graphics.getWidth(), "center")
  end
end

return game