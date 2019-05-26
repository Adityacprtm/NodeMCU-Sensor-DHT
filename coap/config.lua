local module = {}

module.SSID = "AL-KHAWARIZMI"
module.PWD = "ibadurrahman"

module.HOST = "192.168.0.13"
module.PORT_COAP = 5683

module.PATH_AUTH = "/device/request"
module.PORT_AUTH = 80
module.ALGORITHM = "AES-CBC"

module.ID = node.chipid()

module.DEVICE_ID = "4a83e9a771004924495dd843aaeac76e145df42e2db7968aa660181cfda5229e"
module.PASSWORD = "641e4670ff70255391ca779a385766edaafb1df0fbff5f3a28e0f19a9dc08e46"
module.KEY = "17922ef895d7f9eed51705fa618902d7"
module.IV = "ccc1730477fee41329a875286abce3f0"

module.TOPIC = "home"

module.PIN = 4

return module
