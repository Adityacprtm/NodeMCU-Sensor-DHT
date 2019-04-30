local module = {}
local m = nil
local token = nil

-- Sends a simple ping to the broker
local function send_ping()
    m:publish(config.ENDPOINT.."ping","id="..config.ID,0,0)
end

local function mqtt_start()
    m = mqtt.Client("clientid", 120, token, nil)
    m:connect(config.HOST, config.PORT_MQTT,0, function(client)
        print('Connected to broker')
        m:publish("topic", "hello", 1, 0, function(client) print("sent") end)
    end)
end

local function get_token()
    http.post('http://'..config.HOST..':'..config.PORT_AUTH..config.PATH_AUTH,
        'Content-Type: application/json\r\n',
        '{"device_id":"'..config.DEVICE_ID..'","password":"'..config.PASSWORD..'"}',
        function(code, data)
            if (code == 200) then
                print(code, data)
                token = data
                mqtt_start()
            elseif (code == 401) then
                print(code, data)
                print("Wait 30 sec")
                config.mytmr:alarm(20000, tmr.ALARM_SINGLE, function() get_token() end)
            else
                print("HTTP request failed")
            end
        end)
end

function module.start()
    if (token == nil) then
        get_token()
    else
        mqtt_start()
    end
end

return module
