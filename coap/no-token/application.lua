local module = {}
local mytmr = tmr.create()
local cc = nil
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
    -- counter = 1
    -- maxCounter = config.COUNT

    cc = coap.Client()

    mytimer = tmr.create()
    mytimer:register(
        10000,
        tmr.ALARM_AUTO,
        function(t)
            -- if counter <= maxCounter then
                set_get_dht()
                -- print("publishing message")
                pubSec, pubUsec = rtctime.get()
                cc:post(
                    coap.NON,
                    "coap://" .. config.HOST .. ":" .. config.PORT_COAP .. "/r/" .. config.ID .. "/" .. config.TOPIC,
                    payload
                )
                -- print("Message published")
                -- pubSec2, pubUsec2 = rtctime.get()
                -- print(
                --     counter .. "\tpubs time (sec):\t" .. (pubUsec2 + ((pubSec2 - pubSec) * 1000000) - pubUsec) / 1000000
                -- )
            -- else
            --     print(maxCounter .. " messages published")
            --     t:unregister()
            -- end
            -- counter = counter + 1
        end
    )
    mytimer:interval(2000)
    mytimer:start()
end

function module.start()
    coap_start()
end

return module
