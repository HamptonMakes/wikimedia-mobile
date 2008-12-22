require 'test/unit' if $0 == __FILE__
require 'test/test_autotest'
require 'autotest/rails'

class TestRailsAutotest < TestAutotest

  def setup
    super

    @test_class = 'RouteTest'
    @test = 'test/unit/route_test.rb'
    @other_test = 'test/other_blah_test.rb'
    @impl = 'app/models/route.rb'
    @inner_test = 'test/outer/inner_test.rb'
    @outer_test = 'test/outer_test.rb'
    @inner_test_class = "OuterTest::InnerTest"

    @rails_unit_tests = [@test]

    @rails_controller_tests = %w(test/controllers/admin/themes_controller_test.rb
                                 test/controllers/articles_controller_test.rb
                                 test/controllers/dummy_controller_test.rb
                                 test/controllers/route_controller_test.rb)

    @rails_view_tests = %w(test/views/admin/themes_view_test.rb
                           test/views/articles_view_test.rb
                           test/views/layouts_view_test.rb
                           test/views/route_view_test.rb)

    @rails_functional_tests = %w(test/functional/admin/themes_controller_test.rb
                                 test/functional/articles_controller_test.rb
                                 test/functional/dummy_controller_test.rb
                                 test/functional/route_controller_test.rb)

    # These files aren't put in @file_map, so add them to it
    @extra_files = %w(test/controllers/admin/themes_controller_test.rb
                      test/controllers/articles_controller_test.rb
                      test/controllers/dummy_controller_test.rb
                      test/functional/articles_controller_test.rb
                      test/functional/dummy_controller_test.rb
                      test/views/admin/themes_view_test.rb
                      test/views/articles_view_test.rb
                      test/views/layouts_view_test.rb)

    @files.clear

    (@rails_unit_tests +
     @rails_controller_tests +
     @rails_view_tests +
     @rails_functional_tests +
     @extra_files +
     [@impl]).flatten.each_with_index do |path, t|
      @files[path] = Time.at(t+1)
    end

    @a.find_order = @files.keys
    @a.last_mtime = @files.values.sort.last
  end

  # Overridden from superclass... the scenario just doesn't happen the same way.
  def test_consolidate_failures_multiple_matches
    @test2 = 'test/unit/route_again_test.rb'
    @files[@test2] = Time.at(42)
    @files['app/views/routes/edit.rhtml'] = Time.at(42)
    @files['app/views/routes/list.rhtml'] = Time.at(42)

    @a.find_order = @files.keys

    result = @a.consolidate_failures([['test_unmatched', @test_class]])
    expected = {"test/unit/route_test.rb"=>["test_unmatched"]}
    assert_equal expected, result
    assert_equal '', @a.output.string
  end

  def test_reorder_random
    @a.order = :random

    srand 42
    expected, size = @files.dup, @files.size
    expected = expected.sort_by { rand(size) }

    srand 42
    result = @a.reorder(@files.dup)

    assert_equal expected, result
  end

  def test_test_files_for
    empty = []
    assert_equal empty, @a.test_files_for('blah.rb')
    assert_equal empty, @a.test_files_for('test_blah.rb')

    # controllers
    util_test_files_for('app/controllers/admin/themes_controller.rb',
                        'test/controllers/admin/themes_controller_test.rb',
                        'test/functional/admin/themes_controller_test.rb')

    util_test_files_for('app/controllers/application.rb',
                        @rails_controller_tests,
                        @rails_view_tests,
                        @rails_functional_tests)

    util_test_files_for('app/controllers/route_controller.rb',
                        'test/controllers/route_controller_test.rb',
                        'test/functional/route_controller_test.rb')

    util_test_files_for('app/controllers/notest_controller.rb')

    # helpers
    util_test_files_for('app/helpers/application_helper.rb',
                        @rails_view_tests,
                        @rails_functional_tests)

    util_test_files_for('app/helpers/route_helper.rb',
                        'test/views/route_view_test.rb',
                        'test/functional/route_controller_test.rb')

    # model
    util_test_files_for('app/models/route.rb',
                        @test)

    util_test_files_for('app/models/notest.rb')

    # views
    util_test_files_for('app/views/layouts/default.rhtml',
                        'test/views/layouts_view_test.rb')

    util_test_files_for('app/views/route/index.rhtml',
                        'test/views/route_view_test.rb',
                        'test/functional/route_controller_test.rb')

    util_test_files_for('app/views/route/xml.rxml',
                        'test/views/route_view_test.rb',
                        'test/functional/route_controller_test.rb')

    util_test_files_for('app/views/shared/notest.rhtml')

    util_test_files_for('app/views/articles/flag.rhtml',
                        'test/views/articles_view_test.rb',
                        'test/functional/articles_controller_test.rb')

    # tests
    util_test_files_for('test/fixtures/routes.yml',
                        @test,
                        'test/controllers/route_controller_test.rb',
                        'test/views/route_view_test.rb',
                        'test/functional/route_controller_test.rb')

    util_test_files_for('test/test_helper.rb',
                        @rails_unit_tests, @rails_controller_tests,
                        @rails_view_tests, @rails_functional_tests)

    util_test_files_for(@test, @test)

    util_test_files_for('test/controllers/route_controller_test.rb',
                        'test/controllers/route_controller_test.rb')

    util_test_files_for('test/views/route_view_test.rb',
                        'test/views/route_view_test.rb')

    util_test_files_for('test/functional/route_controller_test.rb',
                        'test/functional/route_controller_test.rb')

    util_test_files_for('test/functional/admin/themes_controller_test.rb',
                        'test/functional/admin/themes_controller_test.rb')

    # global conf thingies
    util_test_files_for('config/boot.rb',
                        @rails_unit_tests, @rails_controller_tests,
                        @rails_view_tests, @rails_functional_tests)

    util_test_files_for('config/database.yml',
                        @rails_unit_tests, @rails_controller_tests,
                        @rails_view_tests, @rails_functional_tests)

    util_test_files_for('config/environment.rb',
                        @rails_unit_tests, @rails_controller_tests,
                        @rails_view_tests, @rails_functional_tests)

    util_test_files_for('config/environments/test.rb',
                        @rails_unit_tests, @rails_controller_tests,
                        @rails_view_tests, @rails_functional_tests)

    util_test_files_for('config/routes.rb',
                        @rails_controller_tests,
                        @rails_view_tests, @rails_functional_tests)

    # ignored crap
    util_test_files_for('vendor/plugins/cartographer/lib/keys.rb')

    util_test_files_for('Rakefile')
  end

  def test_consolidate_failures_multiple_matches_before
    @test_class = 'BlahTest'
    @files.clear
    @files['app/model/blah.rb'] = Time.at(42)
    @files['app/model/different_blah.rb'] = Time.at(42)
    @files['test/unit/blah_test.rb'] = Time.at(42)
    @files['test/unit/different_blah_test.rb'] = Time.at(42)

    @a.find_order = @files.keys

    result = @a.consolidate_failures([['test_matched', @test_class]])
    expected = { 'test/unit/blah_test.rb' => [ 'test_matched' ] }
    assert_equal expected, result
    assert_equal "", @a.output.string
  end

  def util_test_files_for(file, *expected)
    assert_equal(expected.flatten.sort.uniq,
                 @a.test_files_for(file).sort.uniq, "tests for #{file}")
  end

  def test_path_to_classname
    # rails
    util_path_to_classname 'BlahTest', 'test/blah_test.rb'
    util_path_to_classname 'BlahTest', 'test/unit/blah_test.rb'
    util_path_to_classname 'BlahTest', 'test/functional/blah_test.rb'
    util_path_to_classname 'BlahTest', 'test/integration/blah_test.rb'
    util_path_to_classname 'BlahTest', 'test/views/blah_test.rb'
    util_path_to_classname 'BlahTest', 'test/controllers/blah_test.rb'
    util_path_to_classname 'BlahTest', 'test/helpers/blah_test.rb'

    util_path_to_classname('OuterTest::InnerTest',
                           'test/controllers/outer/inner_test.rb')
  end
end

