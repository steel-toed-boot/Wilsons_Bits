--Kulopto @ Youtube

local sideDetect = false
updateId = nil
buttons ={}
local buttonToggle = {}
local buttonFlash = {}

--peripheral scanner
function checkPeripheral()
	for i,side in pairs(rs.getSides()) do
		if peripheral.getType(side) =="monitor" then
			m=peripheral.wrap(side)
			sideDetect = true
			print("Monitor found on side "..side)
			break
		end
	end
	if sideDetect == false then
			print("No Monitor Detected.. waiting for 5 seconds")
			return false
	end
end

--Makes the screen and monitor ready for use. 
function housekeeping()
	repeat
		checkPeripheral()
		if not sideDetect then sleep(5) end
	until sideDetect
  m.clear()
  m.setTextScale(1)
  m.setBackgroundColor(colors.black)
  m.setTextColor(colors.white)
end

--this is the only local run function and is not necessarily required but recommended.
housekeeping()

function clearScreen()
	m.clear()
end

function getMonitorSize()
	return m.getSize()
end

function makeFlashButton(id)
	buttonFlash[id]=true
end

function getButtons()
	return buttons
end

function buttonToggleHandler(buttonId, toggleId)
	table.insert(buttonToggle, buttonId, toggleId)
end

function buttonsEditor(buttonId, data, newValue,keepState)
	keepState = keepState or true
	if keepState then buttons[buttonId]["state"]=not buttons[buttonId]["state"] end
	buttons[buttonId][data] = newValue
	updateButtons(buttonId)
end

function drawBackground(xmin,ymin,xmax,ymax,bColor,tColor,text,xpoint,ypoint)
	--Draws actual background
	m.setBackgroundColor(bColor)
	for y=ymin, ymax do
		for x=xmin, xmax do
			m.setCursorPos(x,y)
			m.write(" ")
		end
	end
  
	--draws header if given respected values (text, xpoint, ypoint)
	tColor = (tColor or colors.white)
	text= (text or "")
	xpoint = xpoint or xmin+ math.floor((xmax - xmin - string.len(text)) /2) +1
	ypoint = ypoint or ymin
  
	m.setCursorPos(xpoint,ypoint)
	m.setTextColor(tColor)
	m.write(text)
end

function writeText(xpoint,ypoint,text,bgColor,textColor,fontScale)
	bgColor = bgColor or colors.black
	textColor = textColor or colors.white
	fontScale = fontScale or 1
	m.setBackgroundColor(bgColor)
	m.setTextColor(textColor)
	m.setTextScale(fontScale)
	
	m.setCursorPos(xpoint,ypoint)
	m.write(text)
end

function buttonData(state,text,xmin,ymin,xmax,ymax,buttonId,invisibleButton,tColor,bColorOff,bColorOn,textAlignedLeft,textAlignedRight)
	if buttonToggle[buttonId]==nil then buttonToggleHandler(buttonId, -8*buttonId) end
	if buttonFlash[buttonId] == nil then buttonFlash[buttonId] = false end
	
	buttons[buttonId] = {}
	buttons[buttonId]["state"] = state or false
	buttons[buttonId]["xmin"] = xmin
	buttons[buttonId]["ymin"] = ymin
	buttons[buttonId]["xmax"] = xmax
	buttons[buttonId]["ymax"] = ymax
	buttons[buttonId]["text"] = text
	buttons[buttonId]["tColor"] = tColor or colors.white
	buttons[buttonId]["bColor1"] = bColorOff or colors.red
	buttons[buttonId]["bColor2"] = bColorOn or colors.green
	buttons[buttonId]["invisibleButton"] = invisibleButton or false
	buttons[buttonId]["textAlignedLeft"] = textAlignedLeftt or nil
	buttons[buttonId]["textAlignedRight"] = textAlignedRightt or nil
	
end

function drawButton(buttonId) 
	local state = buttons[buttonId]["state"]
	local xmin = buttons[buttonId]["xmin"]
	local ymin = buttons[buttonId]["ymin"]
	local xmax = buttons[buttonId]["xmax"]
	local ymax = buttons[buttonId]["ymax"]
	local text = buttons[buttonId]["text"]
	local tColor = buttons[buttonId]["tColor"]
	local bColorOff = buttons[buttonId]["bColor1"]
	local bColorOn = buttons[buttonId]["bColor2"]
	local invisibleButton = buttons[buttonId]["invisibleButton"]
	local textAlignedLeft = buttons[buttonId]["textAlignedLeft"] 
	local textAlignedRight = buttons[buttonId]["textAlignedRight"]
	
	local xpoint = xmin+ math.floor((xmax - xmin - string.len(text)) /2) +1
	local ypoint = math.floor((ymin+ymax)/2)
	
	if not invisibleButton then
		if not state then
			m.setBackgroundColor(bColorOff)
		elseif state then
			m.setBackgroundColor(bColorOn)
		end

    --draws the actual button
		for y=ymin, ymax do
			for x=xmin, xmax do
				m.setCursorPos(x,y)
				m.write(" ")
			end
		end
		
	--draws text
		m.setCursorPos(xpoint,ypoint)
		m.setTextColor(tColor)
		m.write(text)
		
		if textAlignedLeft ~=nil then
			m.setCursorPos(xmin,ypoint)
			m.write(textAlignedLeft)
		end
		if textAlignedRight ~=nil then
			m.setCursorPos(xmax-string.len(textAlignedRight),ypoint)
			m.write(textAlignedRight)
		end
		
		m.setBackgroundColor(colors.black)
	end
end

function getUpdateId()
	return updateId
end

function testTouch()
	event,side,x,y = os.pullEvent("monitor_touch")
	--checks if touch was within button boundaries
	for buttonId=1, #buttons do
		if buttons[buttonId]["ymin"]<=y and buttons[buttonId]["ymax"]>=y then
			if buttons[buttonId]["xmin"]<=x and buttons[buttonId]["xmax"]>=x then
				updateButtons(buttonId)
				updateId = buttonId
				
				if buttonFlash[updateId] then
					sleep(.2) 
					updateButtons(updateId)
				end
			end
		end
	end
end

function updateButtons(buttonId)
	if buttonId ~= nil then
		buttons[buttonId]["state"] = not buttons[buttonId]["state"]
		for id=1, #buttons do
			if buttonToggle[id] == buttonToggle[buttonId] and id ~= buttonId then
				buttons[id]["state"] = false
			end
			drawButton(id)
		end
	end
end