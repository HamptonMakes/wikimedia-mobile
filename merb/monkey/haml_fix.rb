module Haml
  # This class is used only internally. It holds the buffer of HTML that
  # is eventually output as the resulting document.
  # It's called from within the precompiled code,
  # and helps reduce the amount of processing done within `instance_eval`ed code.
  class Buffer
    alias push_text_encoding_problems push_text  
    
    def push_text(text, tab_change, dont_tab_up)
      text = text.force_encoding("UTF-8")
      
      push_text_encoding_problems(text, tab_change, dont_tab_up)
    end
  end
end