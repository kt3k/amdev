require("./test-iframe.tag")

<test-list>
  <test-list-count />
  <a onclick={toRouteHash}>base</a>
  <recursive-item data={opts.testPatterns} routing="" />
  <test-iframe ref="testFrame" if={instanceUrl} url={instanceUrl} config={WholeStatus.config}></test-iframe>
  <style scoped>
    :scope {
      display: block;
      width: 100%;
      background-color: white;
      font-size: 14px;
    }
    a {
      color: blue;
      text-decoration: none;
      cursor: pointer;
      display: inline-block;
    }
    a:hover {
      opacity: 0.4;
    }
  </style>
  <script type="coffee">
    @WholeStatus = WholeStatus = require("./Status")
    route = require("riot-route")
    bodyStyle = document.body.style
    @init = =>
      @instanceUrl = null
      WholeStatus.trigger("init")
    @check = =>
      @init()
      WholeStatus.sumInit()
      executePath = route.query().path
      return @update() unless executePath
      executePath = decodeURIComponent(executePath)
      executePath = encodeURIComponent(executePath)
      unless WholeStatus.executablePath[executePath]
        @instanceUrl = decodeURIComponent(executePath)
        @update()
        @refs.testFrame.setConsoleEvent()
        return
      WholeStatus.executablePath[executePath]()
    @toRouteHash = => route("")
    WholeStatus.on("item-update", () =>
      for itemStatus in WholeStatus.itemStatuses
        if itemStatus.onExecute
          onExecute = true
          break
      bodyStyle.overflowY = if onExecute or @instanceUrl then "hidden" else ""
    )
    @on("mount", () =>
      @check()
      route.start()
    )
    route.base(WholeStatus.thisBasePath)
    route("..", @check)
    # route機能はpathがないと動かないため無いときはつける必要がある
    window.addEventListener("popstate", =>
      unless location.href.match("\\" + WholeStatus.thisBasePath)
        history.replaceState("", null, WholeStatus.thisBasePath)
    )
  </script>
</test-list>

<test-list-count>
  <span>{WholeStatus.successSum}/{WholeStatus.executeSum}</span>
  <script type="coffee">
    @WholeStatus = require("./Status")
    @WholeStatus.on("item-update", =>
      this.update()
    )
  </script>
</test-list-count>

<recursive-item>
  <list-line ref="lines" each={data, key in list} list={this} routing={this.parent.opts.routing} />
  <style scope>
    :scope {
      display: block;
    }
  </style>
  <script type="coffee">
    @list = if typeof opts.data is "object"
      opts.data
     else
      {}
  </script>
</recursive-item>

<list-line>
  <div class="line{isHover && ' hover'}">
    <div class="" onmouseover={mouseOn} onmouseout={mouseOut}>
      <span class="bold {success: success, error: error, warn: warn}"></span>
      <a class="tree" href={routing} onclick={router}>{key}</a>
      <a class="single" if={url} href={routerExecutionPath} onclick={router}>{url}</a>
    </div>
    <recursive-item ref="item" if={!url} data={data} routing={routing} />
  </div>
  <test-iframe ref="testFrame" if={url && status.onExecute} url={routerExecutionPath} config={WholeStatus.config}></test-iframe>
  <style scoped type="less">
    .bold {
      font-weight: bold;
    }
    .tree {
      color: #333;
      word-break: break-all;
    }
    .single {
      padding-left: 6px;
    }
    .line {
      margin-left: 10px;
    }
    .line.hover {
      background: rgba(0, 0, 255, 0.05);
    }
    .success {
      color: blue;
      &:after {
        content: "〇";
      }
    }
    .warn {
      color: gold;
      &:after {
        content: "△";
      }
    }
    .error {
      color: red;
      &:after {
        content: "×";
      }
    }
    .step {
      color: #333; margin-right: 10px;
    }
  </style>
  <script type="coffee">
    WholeStatus = @WholeStatus = require("./Status")
    route = require("riot-route")
    executeIframe = =>
      WholeStatus.executeIframe.shift()?()
    @key = opts.list.key
    @data = opts.list.data
    @routing = if opts.routing then "#{opts.routing}/#{@key}" else @key
    @url = if typeof @data is "object" then "" else @data
    @routerExecutionPath = @url + WholeStatus.basePath + @routing
    @status = {onExecute: false}
    @deleteIframe = =>
      @status.onExecute = false
      @update()
    @init = =>
      @error = null
      @warn = null
      @success = null
      @deleteIframe()
    @recursivelyExecuteTask = =>
      item = @refs.item
      if item
        lines = item.refs.lines
        unless lines.length
          lines.recursivelyExecuteTask()
        else
          for line in lines
            line.recursivelyExecuteTask()
      else
        WholeStatus.executeIframe.push(=> @executeTask( =>
          @deleteIframe()
          executeIframe()
        ))
    @multiExecuteTask = =>
      WholeStatus.executeIframe.length = 0
      @recursivelyExecuteTask()
      executeIframe()
    @executeTask = (callback) =>
      @status.onExecute = true
      this.update()
      console.clear()
      ++WholeStatus.executeSum
      @refs.testFrame.setConsoleEvent(
        assert: (flg, msg) =>
          if msg
            console.assert(flg, msg)
          else
            console.assert(flg)
          unless flg
            @error = true
            @update()
            callback and callback()
        info: (msg) =>
          if msg is "finished" and not @error
            console.info(msg)
            @success = true unless @warn
            ++WholeStatus.successSum
            @update()
            callback and callback()
        error: (msg) =>
          @warn = true
      )
    @router = (e) =>
      route("path=" + e.target.getAttribute("href"))
      e.preventDefault()
    @mouseOn = => @isHover = true
    @mouseOut = => @isHover = false
    WholeStatus.on("init", => @init())
    WholeStatus.itemStatuses.push(@status)
    WholeStatus.executablePath[encodeURIComponent(@routing)] =  () =>
      @multiExecuteTask()
    WholeStatus.executablePath[encodeURIComponent(@routerExecutionPath)] = () => @executeTask() if @url
    @on("update", => WholeStatus.trigger("item-update"))
    @init()
  </script>
</list-line>
