window.$ = $ = require("jquery")
NodeClient = require("am-deven/web/NodeClient")
generate = require("am-test/generate")
nc = new NodeClient()
nc.start()

switch location.pathname
  when "/test/am-autoevent.html" then require("./test/am-autoevent")
  when "/test/am-test.html" then require("./test/am-test")
  when "/"
    testcase = require("./testcase.cson")
    generate(testcase)
