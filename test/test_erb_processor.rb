require 'minitest/autorun'
require 'sprockets'
require 'sprockets/cache'
require 'sprockets/erb_processor'

class TestERBProcessor < MiniTest::Test
  def tset_compile_js_erb_template
    environment = Sprockets::Environment.new

    input = {
      environment: environment,
      filename: "foo.js.erb",
      content_type: 'application/javascript',
      data: "var data = <%= JSON.generate({foo: true}) %>;",
      metadata: {},
      cache: Sprockets::Cache.new
    }

    output = "var data = {\"foo\":true};"
    assert_equal output, Sprockets::ERBProcessor.call(input)[:data]
  end

  def test_compile_erb_template_with_depend_on_call
    root = File.expand_path("../fixtures", __FILE__)
    environment = Sprockets::Environment.new(root)
    environment.append_path 'default'

    path = "#{root}/default/gallery.js"
    input = {
      environment: environment,
      filename: "foo.js.erb",
      content_type: 'application/javascript',
      data: "<%= depend_on('#{path}') %>\nvar data = 'DATA';",
      metadata: {},
      cache: Sprockets::Cache.new
    }

    output = "var data = 'DATA';"
    result = Sprockets::ERBProcessor.call(input)
    assert_equal output, result[:data]
    assert_equal "file-digest://#{path}", result[:dependencies].first
  end

  def test_pass_custom_erb_helpers_to_template
    environment = Sprockets::Environment.new

    template = Sprockets::ERBProcessor.new do
      def foo
        :bar
      end
    end

    input = {
      environment: environment,
      filename: "foo.js.erb",
      content_type: 'application/javascript',
      data: "var foo = <%= foo %>;",
      metadata: {},
      cache: Sprockets::Cache.new
    }

    output = "var foo = bar;"
    assert_equal output, template.call(input)[:data]
  end
end
