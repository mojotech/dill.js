fs           = require 'fs'
path         = require 'path'
scaffold     = require './scaffold_builder.js'
_            = require 'lodash'

CONFIG_NAMES = [
  "tags",
  "feature",
  "require",
  "format",
  "error_formatter",
  "coffee",
  "driver",
  "preventReload",
  "scaffold"
]

module.exports =
  convertToExecOptions: (objArry, libPath) ->
    execOptions =
      _.map objArry, (val) =>
        k = _.keys(val)[0]

        switch
          when k is 'driver'
            process.argv.push "--driver=#{val[k]}"
            ""

          when k is 'coffee'
            if val[k]
              "--#{k}"
            else
              ""
          when k is "format"
            v = val[k]
            if fs.existsSync(p = path.join(process.cwd(), v))
              "--format=#{p}"
            else
              "--format=#{path.join(libPath, v)}"


          when k is 'preventReload'
            v = val[k]
            switch
              when typeof(v) is "string"
                if(v == "true")
                  process.argv.push("--prevent-browser-reload")
                ""

              else
                if(val[k])
                  process.argv.push("--prevent-browser-reload")
                ""

          when k is 'feature'
            "#{val[k]}"

          when k is 'require'
            val[k].reduce((p, v) ->
              p.concat("--require", v)
            , [])

          when k is 'scaffold'
            if(val[k])
              scaffold.createScaffold()

          when typeof(val[k]) is 'object'
            for v in val[k]
              "--#{k}=#{v}"

          else
            "--#{k}=#{val[k]}"

    _(execOptions)
    .concat(["--require", "#{libPath}/support"])
    .flatten()
    .compact()
    .tap( (arr) -> arr.splice(0, 0, null, null))
    .value()

  generateOptions: (minimist, config, libPath) ->
    options =
    _(CONFIG_NAMES)
    .map((name) ->
      obj = {}

      if (minimist[name]?)
        obj[name] = minimist[name]
        if name is 'require'
          if(typeof(obj[name]) == 'string')
            obj[name] = [obj[name]].concat(config[name])
          else
            config[name].map((field)->
              obj[name].push(field)
            )
      else if config[name]?
        obj[name] = config[name]

      if obj[name]? then obj else null
    )
    .compact()
    .value()

    if(!!@checkForFeature(options))
      if(fs.existsSync(path.join(process.cwd(), '/features')))
        @convertToExecOptions(options, libPath)
      else
        if(!!minimist["_"].length)
          options.push({feature: minimist["_"]})
          @convertToExecOptions(options, libPath)
        else
          scaffold.featureNotSpecified()
    else
      @convertToExecOptions(options, libPath)

  checkForFeature: (options) ->
    _.findIndex(options, (opt) ->
      _.keys(opt)[0] == 'feature'
    )
