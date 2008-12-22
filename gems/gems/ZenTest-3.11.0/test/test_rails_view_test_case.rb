require 'test/unit'
require 'test/zentest_assertions'

unless defined? $TESTING_RTC then
  $TESTING_RTC = true

  begin
    require 'test/rails'
  rescue LoadError, NameError
    $TESTING_RTC = false
  end
end

module Rails
  module VERSION
    STRING = '99.99.99' unless defined? STRING # HACK
  end
end

class TestRailsViewTestCase < Test::Rails::ViewTestCase

  def setup
    @assert_tag = []
    @assert_no_tag = []

    @assert_select = []
  end

  def test_assert_field
    assert_field :text, :game, :amount

    assert_equal 2, @assert_select.length

    expected = ["input[type='text'][name='game[amount]']"]

    assert_equal expected, @assert_select.first

    expected = ["label[for='game_amount']"]

    assert_equal expected, @assert_select.last
  end

  def test_assert_field_form
    assert_field '/game/save', :text, :game, :amount

    assert_equal 4, @assert_select.length

    assert_equal @assert_select.shift, ["form[action='/game/save']"]
    assert_equal(@assert_select.shift,
                 ["input[type='text'][name='game[amount]']"])

    assert_equal @assert_select.shift, ["form[action='/game/save']"]
    assert_equal @assert_select.shift, ["label[for='game_amount']"]
  end

  def test_assert_form
    assert_form '/game/save'

    assert_equal 1, @assert_select.length
    assert_equal ["form[action='/game/save']"], @assert_select.first
  end

  def test_assert_form_method
    assert_form '/game/save', :post

    assert_equal 1, @assert_select.length
    assert_equal ["form[action='/game/save'][method='post']"],
                 @assert_select.first
  end

  def test_assert_form_enctype
    assert_form '/game/save', nil, 'multipart/form-data'

    assert_equal 1, @assert_select.length
    assert_equal ["form[action='/game/save'][enctype='multipart/form-data']"],
                 @assert_select.first
  end

  def test_assert_h
    assert_h 1, 'hi'

    assert_equal [['h1', { :text => 'hi' }]], @assert_select
  end

  def test_assert_img
    assert_image '/images/bucket.jpg'

    assert_equal [["img[src='/images/bucket.jpg']"]], @assert_select
  end

  def test_assert_input
    assert_input :text, 'game[amount]'

    assert_equal 1, @assert_select.length
    assert_equal ["input[type='text'][name='game[amount]']"],
                 @assert_select.first
  end

  def test_assert_input_form
    assert_input '/game/save', :text, 'game[amount]'

    assert_equal 2, @assert_select.length
    assert_equal ["form[action='/game/save']"], @assert_select.shift
    assert_equal ["input[type='text'][name='game[amount]']"],
                 @assert_select.shift
  end

  def test_assert_input_value
    assert_input :text, 'game[amount]', 5

    expected = ["input[type='text'][name='game[amount]'][value='5']"]

    assert_equal 1, @assert_select.length
    assert_equal expected, @assert_select.first
  end

  def test_assert_label
    assert_label 'game_amount'

    expected = ["label[for='game_amount']"]

    assert_equal 1, @assert_select.length
    assert_equal expected, @assert_select.first
  end

  def test_assert_label_form
    assert_label '/game/save', 'game_amount'

    assert_equal 2, @assert_select.length
    assert_equal ["form[action='/game/save']"], @assert_select.shift
    assert_equal ["label[for='game_amount']"], @assert_select.shift
  end

  def test_assert_links_to
    assert_links_to '/game/show/1', 'hi'

    expected = ["a[href='/game/show/1']", { :text => 'hi' }]


    assert_equal 1, @assert_select.length
    assert_equal expected, @assert_select.first
  end

  def test_assert_multipart_form
    assert_multipart_form '/game/save'

    expected = [
      "form[action='/game/save'][method='post'][enctype='multipart/form-data']"
    ]

    assert_equal 1, @assert_select.length
    assert_equal expected, @assert_select.first
  end

  def test_assert_post_form
    assert_post_form '/game/save'

    expected = ["form[action='/game/save'][method='post']"]

    assert_equal 1, @assert_select.length
    assert_equal expected, @assert_select.first
  end

  def test_assert_select_tag
    assert_select_tag :game, :location_id,
                      'Ballet' => 1, 'Guaymas' => 2

    assert_equal 2, @assert_select.length

    assert_include(@assert_select,
                   ["select[name='game[location_id]'] option[value='2']",
                    { :text => 'Guaymas' }])
    assert_include(@assert_select,
                   ["select[name='game[location_id]'] option[value='1']",
                    { :text => 'Ballet' }])
  end

  def test_assert_select_tag_form
    assert_select_tag '/game/save', :game, :location_id,
                      'Ballet' => 1, 'Guaymas' => 2

    assert_equal 4, @assert_select.length

    assert_include @assert_select, ["form[action='/game/save']"]
    assert_include(@assert_select,
                   ["select[name='game[location_id]'] option[value='2']",
                    { :text => 'Guaymas' }])
    assert_include @assert_select, ["form[action='/game/save']"]
    assert_include(@assert_select,
                   ["select[name='game[location_id]'] option[value='1']",
                    { :text => 'Ballet' }])
  end

  def test_assert_submit
    assert_submit 'Save!'

    assert_equal 1, @assert_select.length
    assert_equal ["input[type='submit'][value='Save!']"], @assert_select.first
  end

  def test_assert_submit_form
    assert_submit '/game/save', 'Save!'

    assert_equal 2, @assert_select.length
    assert_equal ["form[action='/game/save']"], @assert_select.shift
    assert_equal ["input[type='submit'][value='Save!']"], @assert_select.shift
  end

  def test_assert_tag_in_form
    assert_tag_in_form '/game/save', :tag => 'input'

    expected = {
      :tag => "form",
      :attributes => { :action => "/game/save" },
      :descendant => { :tag => "input" },
    }

    assert_equal 1, @assert_tag.length
    assert_equal expected, @assert_tag.first
  end

  def test_assert_text_area
    assert_text_area 'post[body]'

    assert_equal 1, @assert_select.length
    assert_equal ["textarea[name='post[body]']"], @assert_select.shift
  end

  def test_assert_text_area_body
    assert_text_area 'post[body]', 'OMG!1! that skank stole my BF!~1!'

    assert_equal 1, @assert_select.length
    assert_equal ["textarea[name='post[body]']",
                  { :text => 'OMG!1! that skank stole my BF!~1!' }],
                 @assert_select.shift
  end

  def test_assert_text_area_form
    assert_text_area '/post/save', 'post[body]'

    assert_equal 2, @assert_select.length
    assert_equal ["form[action='/post/save']"], @assert_select.shift
    assert_equal ["textarea[name='post[body]']"], @assert_select.shift
  end

  def test_assert_title
    assert_title 'hi'

    assert_equal [['title', { :text => 'hi' }]], @assert_select
  end

  def test_deny_links_to
    deny_links_to '/game/show/1', 'hi'

    expected = ["a[href='/game/show/1']", { :text => 'hi', :count => 0 }]

    assert_equal 1, @assert_select.length
    assert_equal expected, @assert_select.first
  end

  def assert_tag(arg)
    @assert_tag << arg
  end

  def assert_no_tag(arg)
    @assert_no_tag << arg
  end

  def assert_select(*args)
    @assert_select << args
    yield if block_given?
  end

end if $TESTING_RTC

