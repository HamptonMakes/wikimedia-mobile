##
# test/rails/render_tree.rb adds debug rendering to ActionView::Base#render.
#
# Debug rendering prints out a tree of calls to render allowing you to easily
# visualize where rendering occurs in unfamiliar code.

class ActionView::Base

  alias plain_render render # :nodoc:

  ##
  # List of render types for ActionView::Base#render

  RENDERS = [:partial, :template, :file, :action, :text, :inline, :nothing,
             :update]

  ##
  # Add debug output to rendering.
  #
  # When you include lib/rails/render_tree a tree of renders will be displayed
  # in the console.  This is especially useful when writing tests.
  #
  # This test:
  #
  #   require 'test/test_helper'
  #   require 'test/rails/render_tree'
  #   
  #   class ThingsViewTest < Test::Rails::ViewTestCase
  #   
  #     fixtures :goals
  #   
  #     def test_body
  #       assigns[:goal] = goals(:first)
  #       assigns[:related_goals_moved] = []
  #       assigns[:related_goals_instead] = []
  #   
  #       render :partial => 'things/body'
  #   
  #       assert_tag :tag => 'div', :attributes => { :id => 'entriesbucket' }
  #     end
  #   
  #   end
  #
  # Will give this output when run:
  #
  #   $ ruby test/views/things_view_test.rb -n test_body
  #   Loaded suite test/views/things_view_test
  #   Started
  #   "things/_body"
  #     :partial => "widgets/goals_gallery_teaser"
  #       "widgets/_goals_gallery_teaser"
  #     :partial => "entries_bucket"
  #       "things/_entries_bucket"
  #     :partial => "things/ask_a_question"
  #       "things/_ask_a_question"
  #     "widgets/forms/related_goals"
  #   .
  #   Finished in 1.293523 seconds.
  #   
  #   1 tests, 1 assertions, 0 failures, 0 errors

  def render(*args)
    @level ||= 0

    print '  ' * @level

    case args.first
    when String then
      p args.first
    when Hash then
      hash = args.first
      if hash.include? :collection and hash.include? :partial then
        puts "%p => %p" % [:collection, hash[:partial]]
      else
        found = hash.keys & RENDERS
        if found.length == 1 then
          puts "%p => %p" % [found.first, hash[found.first]]
        else
          raise "Dunno: %p" % [hash]
        end
      end
    else
      raise "Dunno: %p" % [args]
    end

    @level += 1
    result = plain_render(*args)
    @level -= 1
    result
  end

end

