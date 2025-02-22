# frozen_string_literal: true

require 'openscap'
require 'openscap/source'
require 'openscap/ds/sds'
require 'common/testcase'

class TestSds < OpenSCAP::TestCase
  DS_FILE = '../data/sds-complex.xml'

  def test_new
    new_sds.destroy
  end

  def test_new_non_sds
    filename = '../data/xccdf.xml'
    @s = OpenSCAP::Source.new filename
    assert !@s.nil?
    msg = nil
    begin
      OpenSCAP::DS::Sds.new source: @s
      assert false
    rescue OpenSCAP::OpenSCAPError => e
      msg = e.to_s
    end
    assert msg.start_with?('Could not create Source DataStream session: File is not Source DataStream.'), msg
  end

  def test_select_checklist
    sds = new_sds
    benchmark = sds.select_checklist!
    assert !benchmark.nil?
    sds.destroy
  end

  def tests_select_checklist_wrong
    sds = new_sds
    msg = nil
    begin
      benchmark = sds.select_checklist! datastream_id: 'wrong'
      assert false
    rescue OpenSCAP::OpenSCAPError => e
      msg = e.to_s
    end
    assert msg.start_with?('Failed to locate a datastream with ID matching'), msg
    assert benchmark.nil?
    sds.destroy
  end

  def tests_use_through_yields
    OpenSCAP::Source.new DS_FILE do |source|
      assert_equal 'SCAP Source Datastream', source.type
      OpenSCAP::DS::Sds.new source: do |sds|
        benchmark_source = sds.select_checklist!

        OpenSCAP::Xccdf::Benchmark.new benchmark_source do |benchmark|
          assert_empty benchmark.profiles
          assert benchmark.items.length == 1
          assert benchmark.items.keys.first == 'xccdf_moc.elpmaxe.www_rule_first'
        end
      end
    end
  end

  private

  def new_sds
    @s = OpenSCAP::Source.new DS_FILE
    assert !@s.nil?
    sds = OpenSCAP::DS::Sds.new source: @s
    assert !sds.nil?
    sds
  end
end
