class SampleTest extends require("am-lunch-test")
  params1: (params1Val) =>
    console.assert(params1Val)
    location.href = "//google.com"
    console.info("finished")
window.nt = new SampleTest()
nt.preStart()
