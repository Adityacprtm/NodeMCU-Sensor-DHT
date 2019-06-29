local module = {}

module.SSID = "MyRasPiApp"
module.PWD = "pleasehelpme"

module.HOST = "192.168.100.1"
module.PORT_MQTT = 1883

module.PATH_AUTH = "/device/request"
module.PORT_AUTH = 80
module.ALGORITHM = "AES-CBC"

module.ID = node.chipid()

module.DEVICE_ID = "05693c53e99f144585513e5809be9d08a912f2c6d8859b20a97bd187cfc82d98"
module.PASSWORD = "292a66d43de240ef04e89284b900ce80cb2e9abdf78e7103fc66975918a8618a"

-- module.KEY = "1e595ebbbe8cca1a3cbaeb6411d16fe4"
-- module.IV = "fa86d7acf043382456746dabcd8db57b"

module.TOPIC = "home"

module.PIN = 4

return module
