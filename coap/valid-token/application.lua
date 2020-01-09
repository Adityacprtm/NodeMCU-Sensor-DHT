local module = {}
local mytmr = tmr.create()
local cc = nil
local token = nil
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
                protocol = "coap",
                timestamp = tmr.now(),
                topic = config.TOPIC,
                humidity = {value = humi, unit = "persen"},
                temperature = {value = temp, unit = "celcius"},
                token = token
            }
        )
        if ok then
            print(payload)
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
    counter = 1
    maxCounter = config.COUNT

    cc = coap.Client()

    mytimer = tmr.create()
    mytimer:register(
        10000,
        tmr.ALARM_AUTO,
        function(t)
            if counter <= maxCounter then
                -- print("Message published")
                -- pubSec2, pubUsec2 = rtctime.get()
                -- print(
                --     counter .. "\tpubs time (sec):\t" .. (pubUsec2 + ((pubSec2 - pubSec) * 1000000) - pubUsec) / 1000000
                -- )
                set_get_dht()
                -- print("publishing message")
                -- pubSec, pubUsec = rtctime.get()
                cc:post(coap.CON, "coap://" .. config.HOST .. ":" .. config.PORT_COAP .. "/r/" .. config.TOPIC, payload)
            else
                print(maxCounter .. " messages published")
                t:unregister()
            end
            counter = counter + 1
        end
    )
    mytimer:interval(2000)
    mytimer:start()
end

local function get_token()
    -- reqSec, reqUsec = rtctime.get() -- req token
    http.post(
        "http://" .. config.HOST .. ":" .. config.PORT_AUTH .. config.PATH_AUTH,
        "Content-Type: application/json\r\n",
        '{"things_id":"' .. config.THINGS_ID .. '","things_password":"' .. config.THINGS_PASSWORD .. '"}',
        function(code, data)
            if (code == 200) then
                -- print(code, data)
                -- print(token)
                t = sjson.decode(data)
                token = t.token
                -- reqSec2, reqUsec2 = rtctime.get()
                -- print("\treq time (sec):\t" .. (reqUsec2 + ((reqSec2 - reqSec) * 1000000) - reqUsec) / 1000000)
                coap_start()
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
        coap_start()
    end
end

return module
