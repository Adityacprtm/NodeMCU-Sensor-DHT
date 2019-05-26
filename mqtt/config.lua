local module = {}

module.SSID = "AL-KHAWARIZMI"
module.PWD = "ibadurrahman"

module.HOST = "192.168.0.13"
module.PORT_MQTT = 1883

module.PATH_AUTH = "/device/request"
module.PORT_AUTH = 80
module.ALGORITHM = "AES-CBC"

module.ID = node.chipid()

module.DEVICE_ID = "8d037303aa8ac4f5d3af37a1dcd3d217eca85de58180fc5591bac69a93629981"
module.PASSWORD = "ade9bf56fe452eb68c599c989b414d31770683d8bc3fae88f191228ba2025f1c"

module.KEY = "1e595ebbbe8cca1a3cbaeb6411d16fe4"
module.IV = "fa86d7acf043382456746dabcd8db57b"

module.TOPIC = "home"

module.PIN = 4

return module
