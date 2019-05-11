local module = {}

module.SSID = "ap-testing"
module.PWD = "attackme"

module.HOST = "192.168.137.1"
module.PORT_COAP = 5683

module.PATH_AUTH = "/device/request"
module.PORT_AUTH = 8080
module.ALGORITHM = "AES-CBC"

module.ID = node.chipid()

module.DEVICE_ID = "e4838d7e3ee627002cf97ab7de3066857d4509d33fe101afdafb5fda29f3577e"
module.PASSWORD = "8c558fef290d83bb7e70a8c011ecebeee14e1293b25dfae9d63250e3141897c3"
module.KEY = "048d6b03d40e243dae2f2437900f311a"

module.TOPIC = "home"

module.PIN = 4

return module
