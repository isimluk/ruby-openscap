# frozen_string_literal: true

require 'common/testcase'
require 'openscap'
require 'openscap/source'
require 'openscap/xccdf/benchmark'

class TestBenchmark < OpenSCAP::TestCase
  def test_benchmark_values
    with_benchmark do |b|
      val_ids = []
      b.each_value do |val|
        val_ids << val.id
      end
      assert_equal val_ids, ['xccdf_org.ssgproject.content_value_conditional_clause']
    end
  end

  def test_value_props
    with_value do |val|
      assert_equal val.id, 'xccdf_org.ssgproject.content_value_conditional_clause'
      assert_equal val.title, 'A conditional clause for check statements.'
      assert_equal val.description, 'A conditional clause for check statements.'
    end
  end

  private

  def with_value(&)
    with_benchmark { |b| b.each_value(&) }
  end

  def with_benchmark(&)
    OpenSCAP::Source.new '../data/xccdf.xml' do |source|
      OpenSCAP::Xccdf::Benchmark.new(source, &)
    end
  end
end
