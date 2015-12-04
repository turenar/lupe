--- run_command_factory.lua

--- runコマンドを作成するファクトリクラス．
local RunCommandFactory = {}

--- RunCommandFactoryを作る．
function RunCommandFactory.create()
  local m = {}

  --- runコマンドを作る．
  -- line: 入力された文字列
  -- 入力された文字列が run コマンドに当てはまらなかった場合はnil
  -- そうでない場合 run コマンド
  function m:createCommand(line)
    if line == 'continue' or line == 'c' then
      return function(debugger)
        return false
      end
    end
    return nil
  end

  function m:help(debugger, cmd)
    if cmd == nil or cmd == 'continue' or cmd == 'c' then
      debugger.writer:writeln('continue')
      if cmd ~= nil then
        debugger.writer:writeln('       c')
        debugger.writer:writeln('Continue program')
      end
      return true
    else
      return false
    end
  end

  return m
end
