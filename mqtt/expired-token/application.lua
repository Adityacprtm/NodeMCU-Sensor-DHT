local module = {}
local mytmr = tmr.create()
local m = nil
local token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0aGluZ3NfaWQiOiJiNzdmMGNkMWM1NGZmZDQ4NWFlMTFjMDExM2I5OWZhZmI4NzY3NjYwN2Q5Y2M3OWViNzU4NzY4ZmE4ODc4YmRhIiwidGhpbmdzX25hbWUiOiJub2RlLW1xdHQiLCJ0aW1lc3RhbXAiOiIxNTc2MDc3MTc5MDY3Iiwicm9sZSI6InB1Ymxpc2hlciIsImlhdCI6MTU3NjA3NzE3OSwiZXhwIjoxNTc2MDc3MTg5LCJpc3MiOiJhZGl0eWFjcHJ0bS5jb20ifQ._j3xhQToDCbXzsySJw_Nj1EKlAAFOveE8a48kXzPdEI"
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
                protocol = "mqtt",
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

local function mqtt_start()
    counter = 1
    maxCounter = config.COUNT

    m = mqtt.Client(config.ID, 120, token, nil)

    -- print("mqtt connecting ...")
    conSec, conUsec = rtctime.get()
    m:connect(
        config.HOST,
        config.PORT_MQTT,
        false,
        function(client)
        end,
        function(client, reason)
            print("failed reason: " .. reason)
        end
    )

    m:on(
        "connect",
        function(client)
            -- print("mqtt connected")
            conSec2, conUsec2 = rtctime.get()
            print("\tconn time (sec):\t" .. (conUsec2 + ((conSec2 - conSec) * 1000000) - conUsec) / 1000000)
            mytimer = tmr.create()
            mytimer:register(
                10000,
                tmr.ALARM_AUTO,
                function(t)
                    if counter <= maxCounter then
                        set_get_dht()
                        -- print("publishing message")
                        pubSec, pubUsec = rtctime.get()
                        client:publish(
                            config.ID .. "/" .. config.TOPIC,
                            payload,
                            1,
                            0,
                            function(client)
                            end
                        )
                        client:on(
                            "puback",
                            function(client, topic, message)
                                -- print("Message published")
                                pubSec2, pubUsec2 = rtctime.get()
                                print(
                                    counter ..
                                        "\tpubs time (sec):\t" ..
                                            (pubUsec2 + ((pubSec2 - pubSec) * 1000000) - pubUsec) / 1000000
                                )
                            end
                        )
                    else
                        print(maxCounter .. " messages successfully published")
                        t:unregister()
                    end
                    counter = counter + 1
                end
            )
            mytimer:interval(3000)
            mytimer:start()
        end
    )

    m:on(
        "offline",
        function(client)
            print("offline")
        end
    )
end

local function get_token()
    reqSec, reqUsec = rtctime.get() -- req token
    http.post(
        "http://" .. config.HOST .. ":" .. config.PORT_AUTH .. config.PATH_AUTH,
        "Content-Type: application/json\r\n",
        '{"things_id":"' .. config.THINGS_ID .. '","things_password":"' .. config.THINGS_PASSWORD .. '"}',
        function(code, data)
            if (code == 200) then
                -- print(code, data)
                -- token = decryption(data)
                -- print(token)
                t = sjson.decode(data)
                token = t.token
                reqSec2, reqUsec2 = rtctime.get()
                print("\treq time (sec):\t" .. (reqUsec2 + ((reqSec2 - reqSec) * 1000000) - reqUsec) / 1000000)
                mqtt_start()
            elseif (code == 401) then
                -- print("Wait 20 sec")
                -- mytmr:alarm(
                --     20000,
                --     tmr.ALARM_SINGLE,
                --     function()
                --         get_token()
                --     end
                -- )
                print(code, data)
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
        mqtt_start()
    end
end

return module
