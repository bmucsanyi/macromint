module = "macromint"

sourcefiledir = "tex/latex/macromint"
sourcefiles = { "*.sty" }
installfiles = { "*.sty" }
unpackfiles = { }
testfiledir = "testfiles"
checkengines = { "luatex", "xetex", "pdftex" }

local engines = {
  lualatex = "lualatex",
  xelatex = "xelatex",
  pdflatex = "pdflatex",
}

local standard_tests = {
  "minimal-check",
  "figmint-check",
  "public-api-check",
}

local opentype_tests = {
  "opentype-math-check",
}

local tagged_tests = {
  "tagged-math-check",
}

local log_needles = {
  "Missing character",
  "Fatal error",
  "Undefined control sequence",
  "LaTeX Error",
  "Emergency stop",
  "LaTeX Warning:",
  "LaTeX Font Warning:",
  "Overfull \\hbox",
  "Overfull \\vbox",
  "Underfull \\hbox",
  "Underfull \\vbox",
}

local function quote(value)
  return "'" .. string.gsub(value, "'", "'\\''") .. "'"
end

local function run(label, command)
  print(label)
  local result = os.execute(command)
  if result == true or result == 0 then
    return 0
  end
  return 1
end

local function file_contains(path, needle)
  local handle = io.open(path, "r")
  if not handle then
    return false
  end
  local content = handle:read("*a")
  handle:close()
  return string.find(content, needle, 1, true) ~= nil
end

local function line_has_log_problem(line)
  if string.sub(line, 1, 1) == "!" then
    return true
  end
  if string.match(line, "^Package .+ Error") then
    return true
  end
  if string.match(line, "^Package .+ Warning:") then
    return true
  end
  if string.match(line, "^Class .+ Error") then
    return true
  end
  if string.match(line, "^Class .+ Warning:") then
    return true
  end
  for _, needle in ipairs(log_needles) do
    if string.find(line, needle, 1, true) then
      return true
    end
  end
  return false
end

local function scan_log(path)
  for line in io.lines(path) do
    if line_has_log_problem(line) then
      print(path .. ": " .. line)
      return 1
    end
  end
  return 0
end

local function compile_test(name, engine_name)
  local texinputs = table.concat({
    "./tex/latex/macromint",
    "../figmint/tex/latex/figmint",
    "",
  }, ":")
  local command = "env TEXINPUTS=" .. quote(texinputs)
    .. " " .. engines[engine_name]
    .. " -halt-on-error -interaction=nonstopmode"
    .. " -jobname=" .. quote(name .. "-" .. engine_name)
    .. " -output-directory=build"
    .. " " .. quote("testfiles/" .. name .. ".tex")

  if run(engine_name .. " " .. name, command) ~= 0 then
    return 1
  end
  return run(engine_name .. " " .. name, command)
end

local function compile_error_test(name, engine_name, needle)
  local texinputs = table.concat({
    "./tex/latex/macromint",
    "../figmint/tex/latex/figmint",
    "",
  }, ":")
  local command = "env TEXINPUTS=" .. quote(texinputs)
    .. " " .. engines[engine_name]
    .. " -halt-on-error -interaction=nonstopmode"
    .. " -jobname=" .. quote(name .. "-" .. engine_name)
    .. " -output-directory=build"
    .. " " .. quote("testfiles/" .. name .. ".tex")

  if run(engine_name .. " " .. name .. " expected error", command) == 0 then
    print(name .. ": expected TeX error did not occur")
    return 1
  end

  local log_path = "build/" .. name .. "-" .. engine_name .. ".log"
  if not file_contains(log_path, needle) then
    print(log_path .. ": missing expected error text")
    return 1
  end
  return 0
end

local function text_check()
  return run(
    "pdftotext abbreviation check",
    "pdftotext " .. quote("build/public-api-check-pdflatex.pdf")
      .. " - | grep -F " .. quote("etc. Text")
  )
end

local function macromint_check()
  if run("create build directory", "mkdir -p build") ~= 0 then
    return 1
  end

  for name in pairs(engines) do
    for _, test in ipairs(standard_tests) do
      if compile_test(test, name) ~= 0 then
        return 1
      end
    end
  end

  for _, name in ipairs({ "lualatex", "xelatex" }) do
    for _, test in ipairs(opentype_tests) do
      if compile_test(test, name) ~= 0 then
        return 1
      end
    end
  end

  for _, test in ipairs(tagged_tests) do
    if compile_test(test, "lualatex") ~= 0 then
      return 1
    end
  end

  local where_error =
    "Package macromint Error: \\where may only be used inside \\set"
  for name in pairs(engines) do
    if compile_error_test("set-marker-error-check", name, where_error) ~= 0 then
      return 1
    end
  end

  if text_check() ~= 0 then
    return 1
  end

  for name in pairs(engines) do
    for _, test in ipairs(standard_tests) do
      if scan_log("build/" .. test .. "-" .. name .. ".log") ~= 0 then
        return 1
      end
    end
  end

  for _, name in ipairs({ "lualatex", "xelatex" }) do
    for _, test in ipairs(opentype_tests) do
      if scan_log("build/" .. test .. "-" .. name .. ".log") ~= 0 then
        return 1
      end
    end
  end

  for _, test in ipairs(tagged_tests) do
    if scan_log("build/" .. test .. "-lualatex.log") ~= 0 then
      return 1
    end
  end

  return 0
end

target_list.check.func = function()
  return macromint_check()
end
