-- NOTE: most templates are inspired from ChatGPT.nvim -> chatgpt-actions.json
local avante_grammar_correction = 'Correct the text to standard English, but keep any code blocks inside intact.'
local avante_keywords = 'Extract the main keywords from the following text'
local avante_code_readability_analysis = [[
  You must identify any readability issues in the code snippet.
  Some readability issues to consider:
  - Unclear naming
  - Unclear purpose
  - Redundant or obvious comments
  - Lack of comments
  - Long or complex one liners
  - Too much nesting
  - Long variable names
  - Inconsistent naming and code style.
  - Code repetition
  You may identify additional problems. The user submits a small section of code from a larger file.
  Only list lines with readability issues, in the format <line_num>|<issue and proposed solution>
  If there's no issues with code respond with only: <OK>
]]
local avante_summarize = 'Summarize the following text'
local avante_translate = 'Translate this into Korean, but keep any code blocks inside intact'
local avante_explain_code = 'Explain the following code'
local avante_add_docstring = 'Add docstring to the following codes'
local avante_add_tests = 'Implement tests for the following code'

require('which-key').add {
  { '<leader>a', group = 'Avante' }, -- NOTE: add for avante.nvim
  {
    mode = { 'n', 'v' },
    {
      '<leader>ag',
      function()
        require('avante.api').ask { question = avante_grammar_correction }
      end,
      desc = 'Grammar Correction(ask)',
    },
    {
      '<leader>ak',
      function()
        require('avante.api').ask { question = avante_keywords }
      end,
      desc = 'Keywords(ask)',
    },
    {
      '<leader>al',
      function()
        require('avante.api').ask { question = avante_code_readability_analysis }
      end,
      desc = 'Code Readability Analysis(ask)',
    },
    {
      '<leader>am',
      function()
        require('avante.api').ask { question = avante_summarize }
      end,
      desc = 'Summarize text(ask)',
    },
    {
      '<leader>an',
      function()
        require('avante.api').ask { question = avante_translate }
      end,
      desc = 'Translate text(ask)',
    },
    {
      '<leader>ax',
      function()
        require('avante.api').ask { question = avante_explain_code }
      end,
      desc = 'Explain Code(ask)',
    },
    {
      '<leader>ad',
      function()
        require('avante.api').ask { question = avante_add_docstring }
      end,
      desc = 'Docstring(ask)',
    },
    {
      '<leader>au',
      function()
        require('avante.api').ask { question = avante_add_tests }
      end,
      desc = 'Add Tests(ask)',
    },
  },
}
