module WikiMedia
  module Spec
    class ControllerBase < Merb::Controller
      self._template_root = File.dirname(__FILE__) / "views"
    end # ControllerBase 
  end # Spec
end # WikiMedia
    