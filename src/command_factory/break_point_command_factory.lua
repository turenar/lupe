--- break_point_command_factory.lua

local BreakPointCommandFactory = {}

function BreakPointCommandFactory.create()
  local m = {}

  --- ブレークポイントに関するコマンドを作る．
  -- line: 入力された文字列
  -- 入力された文字列から
  --  ・ブレークポイントの追加
  --  ・ブレークポイントの削除
  --  ・ブレークポイントの一覧
  -- のいずれかのコマンドを返す．
  -- 上記のどれにも当てはまらなかったら，nil を返す．
  function m:createCommand(line)
    local cmd = utils:splitWords(line)
    if not cmd and #cmd <= 0 then
      return nil
    end

    -- ブレークポイントの追加
    if cmd[1] == 'break' or cmd[1] == 'b' then
      return function(debugger)
        if cmd[2] == nil then
          debugger.writer:writeln('missing argument')
          self:help(debugger, 'b')
          return true
        end
        if cmd[3] then
          debugger.break_point_manager:add(utils:withPrefixSource(cmd[2]), tonumber(cmd[3]))
        else
          debugger.break_point_manager:add(debugger.call_stack[1].source, tonumber(cmd[2]))
        end
        return true
      end
    end

    -- ブレークポイントの削除
    if cmd[1] == 'delete' or cmd[1] == 'd' then
      return function(debugger)
        if cmd[2] == nil then
          debugger.writer:writeln('missing argument')
          self:help(debugger, 'd')
          return true
        end
        if cmd[3] then
          debugger.break_point_manager:remove(utils:withPrefixSource(cmd[2]), tonumber(cmd[3]))
        else
          debugger.break_point_manager:remove(debugger.call_stack[1].source, tonumber(cmd[2]))
        end
        return true
      end
    end

    --[[
    -- ブレークポイントの一覧
    if line == 'breakPointList' or line == '' then
      return function(debugger)
        for id, _ in pairs(debugger.break_point_manager.break_points) do
          debugger.writer:writeln(id)
        end
        return true
      end
    end
    --]]

    return nil
  end

  function m:help(debugger, cmd)
    local help_showed = false
    if cmd == nil or cmd == 'break' or cmd == 'b' then
      debugger.writer:writeln('break [SOURCE] <LINE>')
      if cmd ~= nil then
        debugger.writer:writeln('    b [SOURCE] <LINE>')
        debugger.writer:writeln('Set breakpoint at specified line')
        debugger.writer:writeln('  SOURCE: lua file name. (default: the source of top frame)')
        debugger.writer:writeln('  LINE:   breakpoint line number')
      end
      help_showed = true
    end

    if cmd == nil or cmd == 'delete' or cmd == 'd' then
      debugger.writer:writeln('delete [SOURCE] <LINE>')
      if cmd ~= nil then
        debugger.writer:writeln('     d [SOURCE] <LINE>')
        debugger.writer:writeln('Remove breakpoint at specified line if set')
        debugger.writer:writeln('  SOURCE: lua file name. (default: the source of top frame)')
        debugger.writer:writeln('  LINE:   breakpoint line number')
      end
      help_showed = true
    end

    --[[
    if cmd == nil or cmd == 'breakPointList' or line == 'bl' then
      debugger.writer:writeln('breakPointList')
      if cmd ~= nil then
        debugger.writer:writeln('            bl')
        debugger.writer:writeln('List breakpoints')
      end
      help_showed = true
    end
    --]]

    return help_showed
  end

  return m
end
