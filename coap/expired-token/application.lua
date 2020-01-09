local module = {}
local mytmr = tmr.create()
local cc = nil
local token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0aGluZ3NfaWQiOiJhODJmYzExMjM0OTJjZTQyNTlmYzc3ZTMxMzNkMmNhNGQ0NTIzNmZjOGEwY2Q1YWFiZGY4NzQ1NGY1MTZiMWQ5IiwidGhpbmdzX25hbWUiOiJub2RlLWNvYXAiLCJ0aW1lc3RhbXAiOiIxNTc2MDc2MTU5MTY4Iiwicm9sZSI6InB1Ymxpc2hlciIsImlhdCI6MTU3NjA3NjE1OSwiZXhwIjoxNTc2MDc2MTY5LCJpc3MiOiJhZGl0eWFjcHJ0bS5jb20ifQ.ghaDBEyPtUs6RUTFYF0WJL2zFqxl55VcfjfoymB1sfk"
local payload = nil
rtctime.set(1561601630, 0)

local function set_get_dht()
	status, temp, humi, temp_dec, humi_dec = dht.read(config.PIN)
	if status == dht.OK then
		-- print("DHT Temperature:"..temp..";".."Humidity:"..humi)
		ok, payload =
			pcall(
			sjson.encode,
			{
				token = token,
				protocol = "coap",
				timestamp = tmr.now(),
				topic = config.TOPIC,
				humidity = {value = humi, unit = "%"},
				temperature = {value = temp, unit = "celcius"}
			}
		)
		if ok then
			-- print(payload)
		else
			print("failed to encode!")
		end
	elseif status == dht.ERROR_CHECKSUM then
		print("DHT Checksum error.")
	elseif status == dht.ERROR_TIMEOUT then
		print("DHT timed out.")
	end
end

local function coap_start()
	cc = coap.Client()
	--mytimer = tmr.create()
	--mytimer:register(30000, tmr.ALARM_AUTO, function()
	set_get_dht()
	cc:post(
		coap.CON,
		"coap://" .. config.HOST .. ":" .. config.PORT_COAP .. "/r/" .. config.ID .. "/" .. config.TOPIC,
		payload
	)
	--end)
	--mytimer:interval(3000)
	--mytimer:start()
end

local function get_token()
	http.post(
		"http://" .. config.HOST .. ":" .. config.PORT_AUTH .. config.PATH_AUTH,
		"Content-Type: application/json\r\n",
		'{"device_id":"' .. config.DEVICE_ID .. '","device_password":"' .. config.PASSWORD .. '"}',
		function(code, data)
			if (code == 200) then
				print(code, data)
				-- token = decryption(data)
				t = sjson.decode(data)
				token = t.token
				--print(token)
				coap_start()
			elseif (code == 401) then
				print(code, data)
				print("Wait 20 sec")
				mytmr:alarm(
					20000,
					tmr.ALARM_SINGLE,
					function()
						get_token()
					end
				)
			else
				print("HTTP request failed")
			end
		end
	)
end

function module.start()
	if (token == nil) then
		get_token()
	else
		coap_start()
	end
end

return module
