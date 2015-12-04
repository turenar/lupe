--- watch_command_factory.lua

local WatchCommandFactory = {}

function WatchCommandFactory.create()
  local m = {}

  --- ウォッチに関するコマンドを作る．
  -- line: 入力された文字列
  -- 入力された文字列から
  --  ・ウォッチの追加
  --  ・ウォッチの削除
  --  ・ウォッチの一覧
  -- のいずれかのコマンドを返す．
  -- 上記のどれにも当てはまらなかったら，nil を返す．
  function m:createCommand(line)
    local cmd = utils:splitWords(line)
    if not cmd and #cmd <= 0 then
      return nil
    end

    -- ウォッチ式の一覧
    if cmd[1] == 'watch' or cmd[1] == 'w' then
      if cmd[2] == nil then
        return function(debugger)
          local watches = debugger.watch_manager.watches
          local fmt = '%' .. tostring(utils:numDigits(#watches)) .. 'd: %s = %s'
          for i, watch in ipairs(watches) do
            local str_value = utils:inspect(watch.value)
            debugger.writer:writeln(string.format(fmt, i, watch.chunk, str_value))
          end
          return true
        end
      else
        return function(debugger)
          local context = debugger.call_stack[1]
          local chunk, err
          local index = tonumber(cmd[2])
          if not index then
            chunk = utils:join(utils:slice(cmd, 2), " ")
            err   = debugger.watch_manager:add(context, chunk)
          else
            chunk = utils:join(utils:slice(cmd, 3), " ")
            err   = debugger.watch_manager:set(index, context, chunk)
          end

          if err then
            debugger.writer:writeln('ERROR: ' .. tostring(err))
            return true
          end

          debugger.writer:writeln('add watch ' .. chunk)
          return true
        end
      end
    end

    -- ウォッチ式の削除
    if cmd[1] == 'delwatch' or cmd[1] == 'dw' then
      local index = tonumber(cmd[2])
      if not index then
        return nil
      end

      return function(debugger)
        local watch = debugger.watch_manager:remove(index)
        if watch then
          debugger.writer:writeln('remove watch ' .. watch.chunk)
        end
        return true
      end
    end

    return nil
  end

  function m:help(debugger, cmd)
    local help_shown = false
    if cmd == nil or cmd == 'watch' or cmd == 'w' then
      debugger.writer:writeln('watch')
      debugger.writer:writeln('watch <CHUNK> [WATCH_ID]')
      if cmd ~= nil then
        debugger.writer:writeln('  or alias `w\'')
        debugger.writer:writeln('If no arg passed, show watching chunk list')
        debugger.writer:writeln('Otherwise, add watching chunk or set alternative chunk as specified watcher')
        debugger.writer:writeln('  CHUNK: valid lua chunk (ex. variable, func())')
        debugger.writer:writeln('  WATCH_ID: if set, replace watcher rather than create new watcher')
      end
      help_shown = true
    end

    if cmd == nil or cmd == 'delwatch' or cmd == 'dw' then
      debugger.writer:writeln('delwatch <WATCH_ID>')
      if cmd ~= nil then
        debugger.writer:writeln('         dw <WATCH_ID>')
        debugger.writer:writeln('Remove specified watcher')
        debugger.writer:writeln('  WATCH_ID: watcher id')
      end
      help_shown = true
    end

    return help_shown
  end

  return m
end
