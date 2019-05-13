local module = {}

module.SSID = "ap-testing"
module.PWD = "attackme"

module.HOST = "192.168.137.1"
module.PORT_MQTT = 1883

module.PATH_AUTH = "/device/request"
module.PORT_AUTH = 8080
module.ALGORITHM = "AES-CBC"

module.ID = node.chipid()

module.DEVICE_ID = "5fe64b3576f8f17dd614c798fd0a992318d6721e0fd8c3e4f2de79e0abf02af7"
module.PASSWORD = "57b6592674b2bb5697b06026baa8fef87e20a6adcbf4d60e4ea8074c79b22a0c"

module.KEY = "51e5b379584d3faa99f8d8046dfadc28"
module.IV = ""

module.TOPIC = "office"

module.PIN = 4

return module
