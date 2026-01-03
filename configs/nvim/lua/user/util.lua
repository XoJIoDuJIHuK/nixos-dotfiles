return {
  function Get_venv_python()
  local cwd = vim.fn.getcwd()
  for _, name in ipairs({ ".venv", "venv", "env" }) do
    local py = cwd .. "/" .. name .. "/bin/python"
    if vim.fn.executable(py) == 1 then
      return py
    end
  end
  -- you could also check VIRTUAL_ENV:
  if vim.env.VIRTUAL_ENV then
    return vim.env.VIRTUAL_ENV .. "/bin/python"
  end
  return nil
end
}
