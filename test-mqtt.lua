m = mqtt.Client("nodemcu-123", 120, "vomirrci", "qJuD87Qr10kZ")

--Fungsi di bawah ini berfugsi untuk mengkonekkan device ke ip geeknesia.com
function connect()
    m:connect("m16.cloudmqtt.com", 19131, 0, function(client)
        print("connected")
        client:lwt("iot/will", "device-8d7dc14bf6cf01xxxxxx", 0, 0)
        client:subscribe("topic",0, function(conn)
            print("subscribe success")
        end)
        client:publish("topic", "hello", 1, 0, function(conn) 
            print("Sent") 
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
    end
end)
