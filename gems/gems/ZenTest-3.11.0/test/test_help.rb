# ActionPack
module ActionController; end
module ActionController::Flash; end
class ActionController::Flash::FlashHash < Hash; end
class ActionController::TestSession < Hash; end

class ActionController::TestRequest
  attr_accessor :session
end
class ActionController::TestResponse; end

class ApplicationController; end

module ActionView; end
module ActionView::Helpers; end
module ActionView::Helpers::ActiveRecordHelper; end
module ActionView::Helpers::TagHelper; end
module ActionView::Helpers::TextHelper; end
module ActionView::Helpers::FormTagHelper; end
module ActionView::Helpers::FormOptionsHelper; end
module ActionView::Helpers::FormHelper; end
module ActionView::Helpers::UrlHelper; end
module ActionView::Helpers::AssetTagHelper; end

class << Test::Unit::TestCase
  attr_accessor :use_transactional_fixtures
  attr_accessor :use_instantiated_fixtures
end

# ActionMailer
module ActionMailer; end
class ActionMailer::Base
  def self.deliveries=(arg); end unless defined? @@defined
  @@defined = true
end

