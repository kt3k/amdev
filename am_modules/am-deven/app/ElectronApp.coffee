fs = require("fs")
ipcRenderer = require('electron').ipcRenderer
np = new (require("am-node-parts"))
$ = require("jquery")

module.exports = class ElectronApp
  _inspector: 1
  constructor: ->
  start: ->
    @init()
    @live_reload()
  ### 信頼しているメソッドなるべくフロー順 ###
  init: ->
    if @_inspector then @auto_inspector()
    ipcRenderer.on("browser send msg",(event, msg) ->
      console.log("%cfrom Browser, %c#{msg}", "color: gray", "color: blue")
    )
  auto_inspector: ->
    $(document).on "mousedown", (e) ->
      if e.button is 2
        obj =
          x: e.clientX
          y: e.clientY
        ipcRenderer.send('inspect element', obj, "mainWindow")
  live_reload: ->
    #Watcher
    _watcher_callback = (loc, eventname, filename) =>
      # TODO: compile前ファイルは一括でどこかで登録する
      return if not filename or filename.match(/\.(map|coffee|sass)/)
      if @_start_flag then return else @_start_flag = true
      location.reload()
    _watch_callback = (eventname, file) -> _watcher_callback(null, eventname, file)
    fs.watch("./app/index.html", _watch_callback)
    np.watch_dir_tree("./", [/\/(app|test)\/lib\//, /\/am-node-parts\/lib\//], _watcher_callback)
