module = "macromint"

sourcefiledir = "tex/latex/macromint"
sourcefiles = { "*.sty" }
installfiles = { "*.sty" }
unpackfiles = { }

local engines = {
  "lualatex",
  "xelatex",
  "pdflatex",
}

-- Each test with the engines that compile it. The class tests and the box
-- comparisons do not depend on the engine and run under pdflatex.
local tests = {
  { name = "minimal-check", engines = engines },
  { name = "bm-before-macromint-check", engines = engines },
  { name = "figmint-check", engines = engines },
  { name = "public-api-check", engines = engines },
  { name = "opentype-math-check", engines = { "lualatex", "xelatex" } },
  { name = "tagged-math-check", engines = { "lualatex" } },
  { name = "theorem-beamer-check", engines = { "pdflatex" } },
  { name = "theorem-jmlr-check", engines = { "pdflatex" } },
  { name = "theorem-acmart-check", engines = { "pdflatex" } },
  { name = "theorem-llncs-check", engines = { "pdflatex" } },
  { name = "theorem-preamble-check", engines = { "pdflatex" } },
  { name = "box-check", engines = { "pdflatex" } },
}

-- llncs warns on its own, through the obsolete aliascnt package it loads and
-- through amsmath, which cannot redefine the \vec that llncs defines. Its
-- log is not scanned.
local unscanned_logs = {
  ["theorem-llncs-check"] = true,
}

local where_error = "Package macromint Error: \\where may only be used inside \\set"

-- The bold symbols under unicode-math: mathematical bold italic small x,
-- bold italic capital A, bold italic small theta, bold capital theta, bold
-- capital A, and bold digit zero.
local bold_code_points = {
  utf8.char(0x1D499),
  utf8.char(0x1D468),
  utf8.char(0x1D73D),
  utf8.char(0x1D6AF),
  utf8.char(0x1D400),
  utf8.char(0x1D7CE),
}

local theorem_headings = {
  -- Beamer prints headings without numbers.
  ["theorem-beamer-check"] = {
    "Theorem", "Proposition", "Lemma", "Corollary",
    "Definition", "Assumption", "Problem", "Remark",
  },
  -- jmlr numbers its six environments on one counter, and macromint adds
  -- assumption and problem to it.
  ["theorem-jmlr-check"] = {
    "Theorem 1 T.", "Proposition 2 P.", "Lemma 3 L.", "Corollary 4 C.",
    "Definition 5 D.", "Assumption 6 A.", "Problem 7 Q.", "Remark 8 R.",
  },
  -- acmart defines its environments at the end of the preamble and skips
  -- those that exist, so all eight are macromint's, numbered within the
  -- section.
  ["theorem-acmart-check"] = {
    "Theorem 1.1. T.", "Proposition 1.2. P.", "Lemma 1.3. L.", "Corollary 1.4. C.",
    "Definition 1.5. D.", "Assumption 1.6. A.", "Problem 1.7. Q.", "Remark 1.8. R.",
  },
  -- llncs numbers each of its environments on its own counter, and the
  -- assumption that macromint adds counts with the theorems.
  ["theorem-llncs-check"] = {
    "Theorem 1. T.", "Proposition 1. P.", "Lemma 1. L.", "Corollary 1. C.",
    "Definition 1. D.", "Assumption 2 A.", "Problem 1. Q.", "Remark 1. R.",
  },
  -- A \newtheorem in the preamble can use the theorem counter.
  ["theorem-preamble-check"] = { "Theorem 1.1", "Conjecture 1.2" },
}

-- Text that the compiled tests must contain, read through pdftotext.
local text_checks = {
  { "public-api-check", "pdflatex", { "etc. Text" } },
  { "opentype-math-check", "lualatex", bold_code_points },
  { "opentype-math-check", "xelatex", bold_code_points },
  { "theorem-beamer-check", "pdflatex", theorem_headings["theorem-beamer-check"] },
  { "theorem-jmlr-check", "pdflatex", theorem_headings["theorem-jmlr-check"] },
  { "theorem-acmart-check", "pdflatex", theorem_headings["theorem-acmart-check"] },
  { "theorem-llncs-check", "pdflatex", theorem_headings["theorem-llncs-check"] },
  { "theorem-preamble-check", "pdflatex", theorem_headings["theorem-preamble-check"] },
}

-- The box comparisons of box-check: each macromint command sets the same box
-- as its hand-written reference, and the two negative controls differ.
local box_checks = {
  "abs-automatic;same=true",
  "abs-big;same=true",
  "abs-Bigg-differs-from-automatic;same=false",
  "norm-Big;same=true",
  "card-bigg;same=true",
  "ceil-Bigg;same=true",
  "floor-big;same=true",
  "inprod-automatic;same=true",
  "inprod-big;same=true",
  "set-automatic;same=true",
  "set-big;same=true",
  "set-suchthat-big;same=true",
  "laplace;same=true",
  "laplace-at;same=true",
  "laplace-variable;same=true",
  "laplace-variable-at;same=true",
  "laplace-variable-differs-from-evaluation;same=false",
  "gradient-variable;same=true",
  "gradient-variable-at;same=true",
  "jacobian-at;same=true",
  "jacobian-variable-at;same=true",
  "hessian-variable;same=true",
}

local function check(harness)
  local environment = {
    TEXINPUTS = harness.texinputs({
      "./tex/latex/macromint",
      harness.require_sibling("figmint"),
    }),
  }

  for _, test in ipairs(tests) do
    for _, engine in ipairs(test.engines) do
      if harness.compile_test(environment, test.name, engine) ~= 0 then
        return 1
      end
    end
  end

  for _, engine in ipairs(engines) do
    if harness.compile_error_test(environment, "set-marker-error-check", engine, where_error) ~= 0 then
      return 1
    end
  end

  for _, text_check in ipairs(text_checks) do
    local name, engine, needles = text_check[1], text_check[2], text_check[3]
    local text = harness.output(name, engine, "txt")
    if harness.run("pdftotext " .. name .. " " .. engine,
      "pdftotext " .. harness.quote(harness.output(name, engine, "pdf")) .. " " .. harness.quote(text)) ~= 0 then
      return 1
    end
    for _, needle in ipairs(needles) do
      if not harness.file_contains(text, needle) then
        print(text .. ": missing " .. needle)
        return 1
      end
    end
  end

  local box_log = harness.output("box-check", "pdflatex", "log")
  for _, box_check in ipairs(box_checks) do
    local needle = "MACROMINT_BOX name=" .. box_check
    if not harness.file_contains(box_log, needle) then
      print(box_log .. ": missing " .. needle)
      return 1
    end
  end

  for _, test in ipairs(tests) do
    if not unscanned_logs[test.name] then
      for _, engine in ipairs(test.engines) do
        if harness.scan_log(harness.output(test.name, engine, "log")) ~= 0 then
          return 1
        end
      end
    end
  end

  return 0
end

target_list.check.func = function()
  local path = "../figmint/harness.lua"
  local harness = loadfile(path)
  if not harness then
    print(path .. " is missing: the tests need a checkout of figmint next to this repository")
    return 1
  end
  return check(harness())
end
