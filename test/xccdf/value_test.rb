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

  private

  def with_benchmark(&)
    OpenSCAP::Source.new '../data/xccdf.xml' do |source|
      OpenSCAP::Xccdf::Benchmark.new(source, &)
    end
  end
end
