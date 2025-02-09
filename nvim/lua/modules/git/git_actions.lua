local M = {}
local Job = require('plenary.job')
local events = require('neo-tree.events')

local function get_node_info(state)
  local node = state.tree:get_node()
  local path = node:get_id()
  local cwd = vim.fn.getcwd()
  local relative_path = vim.fn.fnamemodify(path, ':~:.')
  local filename = vim.fn.fnamemodify(path, ':t')
  local current_dir = vim.fn.fnamemodify(path, ':h')
  return node, path, relative_path, filename, current_dir
end

-- Git add and enter commit message - or skip commit msg to add several files (for neotree)

function M.git_add_and_commit(state)
  local _, path, relative_path, filename = get_node_info(state)

  Job
    :new({
      command = 'git',
      args = { 'status', '--porcelain', path },
      on_exit = function(job, status_val)
        vim.schedule(function()
          local output = job:result()

          if #output == 0 then
            print('No changes to stage for ' .. filename)
            return
          end

          Job
            :new({
              command = 'git',
              args = { 'add', path },
              on_exit = function(_, stage_val)
                vim.schedule(function()
                  if stage_val == 0 then
                    print(filename .. ' staged successfully!')

                    vim.ui.input({
                      prompt = filename .. " staged - Enter commit message (or type 'skip' to skip): ",
                    }, function(msg)
                      if not msg or msg == '' then
                        print('Commit cancelled. No message added.')
                        events.fire_event(events.GIT_EVENT)

                        Job:new({
                          command = 'git',
                          args = { 'restore', '--staged', path },
                          on_exit = function(_, unstage_val)
                            vim.schedule(function()
                              if unstage_val == 0 then
                                print(filename .. ' unstaged successfully.')
                                events.fire_event(events.GIT_EVENT)
                              else
                                print('Failed to unstage ' .. filename)
                              end
                            end)
                          end,
                        }):start()

                        return
                      end

                      if msg:lower() == 'skip' then
                        print(filename .. ' staged without commit.')
                        events.fire_event(events.GIT_EVENT)
                        return
                      end

                      Job:new({
                        command = 'git',
                        args = { 'commit', '-m', msg },
                        on_exit = function(_, commit_val)
                          vim.schedule(function()
                            if commit_val == 0 then
                              print('Commit successful for ' .. filename)
                              events.fire_event(events.GIT_EVENT)
                            else
                              print('Commit failed for ' .. filename)
                            end
                          end)
                        end,
                      }):start()
                    end)
                  else
                    print('Failed to stage: ' .. relative_path .. '. Is the file or folder valid?')
                  end
                end)
              end,
            })
            :start()
        end)
      end,
    })
    :start()
end

-- End of 'git_add_and_commit' function

-- Delete and auto add msg for commit
function M.git_delete_and_commit(state)
  local _, path, relative_path, filename = get_node_info(state)
  local is_dir = vim.fn.isdirectory(path) == 1
  local entity = is_dir and 'directory' or 'file'

  local prompt_message = is_dir and ('REMOVE "' .. relative_path .. '/" directory and content? [y/N]: ')
    or ('REMOVE "' .. relative_path .. '"? [y/N]: ')

  Job:new({
    command = 'git',
    args = { 'ls-files', '--error-unmatch', path },
    on_exit = function(_, return_val)
      vim.schedule(function()
        if return_val ~= 0 then
          print(
            entity:sub(1, 1):upper() .. entity:sub(2) .. ' not tracked by Git - failed to remove: ' .. relative_path
          )
        else
          vim.ui.input({ prompt = prompt_message }, function(input)
            if input and input:lower() == 'y' then
              local git_args = is_dir and { 'rm', '-r', path } or { 'rm', path }

              Job:new({
                command = 'git',
                args = git_args,
                on_exit = function(_, remove_val)
                  vim.schedule(function()
                    if remove_val == 0 then
                      print(
                        entity:sub(1, 1):upper()
                          .. entity:sub(2)
                          .. ' removed: '
                          .. relative_path
                          .. (is_dir and '/' or '')
                      )

                      local msg = filename
                        .. (is_dir and ' directory' or ' file')
                        .. ' has been terminated by '
                        .. os.getenv('USER')

                      Job:new({
                        command = 'git',
                        args = { 'commit', '-m', msg },
                        on_exit = function(_, commit_val)
                          vim.schedule(function()
                            if commit_val == 0 then
                              print('Commit successful! Message: ' .. msg)
                              events.fire_event(events.GIT_EVENT)
                            else
                              print('Commit failed.')
                            end
                          end)
                        end,
                      }):start()
                    else
                      print('Failed to remove: ' .. relative_path)
                    end
                  end)
                end,
              }):start()
            else
              print(entity:sub(1, 1):upper() .. entity:sub(2) .. ' removal cancelled.')
            end
          end)
        end
      end)
    end,
  }):start()
end -- End of "git delete and commit" function

-- Git commit function
function M.git_commit(state)
  Job:new({
    command = 'git',
    args = { 'diff', '--cached', '--name-only' },
    cwd = state.path,
    on_exit = function(j, return_val)
      vim.schedule(function()
        local output = j:result()
        if return_val ~= 0 or #output == 0 then
          print('No staged files to commit.')
          return
        end

        vim.ui.input({
          prompt = 'Enter commit message: ',
        }, function(msg)
          if not msg or msg == '' then
            print('Commit cancelled.')
            return
          end

          Job:new({
            command = 'git',
            args = { 'commit', '-m', msg },
            cwd = state.path,
            on_exit = function(_, commit_val)
              vim.schedule(function()
                if commit_val == 0 then
                  print('Commit successful! Message: ' .. msg)
                  events.fire_event(events.GIT_EVENT)
                else
                  print('Commit failed.')
                end
              end)
            end,
          }):start()
        end)
      end)
    end,
  }):start()
end

-- Git restore file function
function M.git_restore(state)
  local _, path, filename = get_node_info(state)

  Job:new({
    command = 'git',
    args = { 'status', '--porcelain', path },
    on_exit = function(job, status_val)
      vim.schedule(function()
        local output = job:result()

        if #output == 0 then
          print('No changes to restore for ' .. filename)
          return
        end

        vim.ui.input({
          prompt = 'RESTORE ' .. filename .. '? [y/N]: ',
        }, function(input)
          if input and input:lower() == 'y' then
            Job:new({
              command = 'git',
              args = { 'restore', path },
              on_exit = function(_, return_val)
                vim.schedule(function()
                  if return_val == 0 then
                    print('Restored to last commit: ' .. filename)
                    events.fire_event(events.GIT_EVENT)
                  else
                    print('Failed to restore: ' .. filename)
                  end
                end)
              end,
            }):start()
          else
            print('File restore cancelled.')
          end
        end)
      end)
    end,
  }):start()
end

-- Git move file function

function M.git_move_file(state)
  local _, path, relative_path, filename, current_dir = get_node_info(state)

  if vim.fn.isdirectory(path) == 1 then
    print('Cannot move/rename directories. Only files are supported.')
    return
  end

  Job:new({
    command = 'git',
    args = { 'ls-files', '--error-unmatch', path },
    on_exit = function(_, is_tracked)
      vim.schedule(function()
        if is_tracked ~= 0 then
          print('File is not tracked by Git: ' .. filename)
          return
        end

        vim.ui.input({
          prompt = "Enter new name or path for '" .. filename .. "': ",
        }, function(input)
          if not input or input == '' then
            print('Rename/move cancelled.')
            events.fire_event(events.GIT_EVENT)
            return
          end

          local new_path
          if input:match('^/') then
            new_path = input
          elseif input:match('/$') then
            new_path = vim.fn.fnamemodify(current_dir .. '/' .. input .. filename, ':p')
          else
            new_path = vim.fn.fnamemodify(current_dir .. '/' .. input, ':p')
          end

          if new_path == path then
            print('Source and destination paths are the same. Operation cancelled.')
            return
          end

          Job:new({
            command = 'git',
            args = { 'mv', path, new_path },
            on_exit = function(j, return_val)
              vim.schedule(function()
                if return_val == 0 then
                  print('File moved/renamed successfully to: ' .. new_path)
                  events.fire_event(events.GIT_EVENT)
                else
                  print('Failed to move/rename file: ' .. table.concat(j:stderr_result(), '\n'))
                  events.fire_event(events.GIT_EVENT)
                end
              end)
            end,
          }):start()
        end)
      end)
    end,
  }):start()
end

return M
