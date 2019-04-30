m = mqtt.Client("nodemcu-123", 120, "user", "password")

--inisialisasi pin (gpio)
pin=2
gpio.mode(pin,gpio.OUTPUT)
gpio.write(pin,gpio.HIGH)

--Fungsi di bawah ini berfugsi untuk mengkonekkan device ke ip geeknesia.com
function connect()
    m:connect("geeknesia.com", 1883, 0, function(conn)
        print("connected")
        m:lwt("iot/will", "device-8d7dc14bf6cf01xxxxxx", 0, 0)
        m:subscribe("topic-8d7dc14bf6cf010dxxxxxx",0, function(conn)
            print("subscribe success")
        end)
    end)

    print("selesai connect")
end
connect()

--Script dibawah bertujuan supaya jika koneksi terputus maka akan auto reconnect
m:on("offline", function(conn)
    print("Reconnect" )
    connect()
end)

--Pesan yang diterima dari topic yang di subscribe
--Jika Esp-12 menerima “on” maka pin akan HIGH dan sebaliknya jika menerima
--“off” maka pin akan LOW (Tergantung Wiring Esp ke led)
m:on("message", function(conn, topic, data)
    print(topic .. ":" )
    if data ~= nil then
        print(data)
        if data=="on" then
            gpio.write(2, gpio.HIGH)
        end
        if data=="off" then
            gpio.write(2, gpio.LOW)
        end
    end
end)
