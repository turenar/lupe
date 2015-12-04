--- help_command_factory.lua

local HelpCommandFactory = {}

function HelpCommandFactory.create()
  local m = {}

  --- ヘルプコマンドを作る．
  -- line: 入力された文字列
  -- 当てはまらなかったら，nil を返す．
  function m:createCommand(line)
    local cmd = utils:splitWords(line)
    if not cmd and #cmd <= 0 then
      return nil
    end

    -- ヘルプの表示
    if cmd[1] == 'help' or cmd[1] == 'h' then
      return function(debugger)
        local help_shown = false
        for _, command_factory in pairs(debugger.prompt.command_factories) do
          help_shown = command_factory:help(debugger, cmd[2]) or help_shown
        end

        if not help_shown then
          debugger.writer:writeln(string.format('%s: command is not found', cmd[1]))
        end
        return true
      end
    end

    return nil
  end

  function m:help(debugger, cmd)
    if cmd == nil or cmd == 'help' or cmd == 'h' then
      debugger.writer:writeln('help [COMMAND]')
      if cmd ~= nil then
        debugger.writer:writeln('   h [COMMAND]')
        debugger.writer:writeln('Show help')
        debugger.writer:writeln('  COMMAND: command name that you want to see help')
      end
      return true
    else
      return false
    end
  end

  return m
end
