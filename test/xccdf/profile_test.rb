# frozen_string_literal: true

require 'common/testcase'
require 'openscap'
require 'openscap/source'
require 'openscap/xccdf/benchmark'
require 'openscap/xccdf/profile'

class TestProfile < OpenSCAP::TestCase
  def test_new_from_file
    with_profile do |p|
      assert p.title == 'Common Profile for General-Purpose Fedora Systems'
    end
  end

  def test_description_html
    with_profile do |p|
      assert_equal p.description, 'This profile contains items common to general-purpose Fedora installations.'
    end
  end

  def test_status
    with_profile do |p|
      assert_nil p.status_current&.status
    end
  end

  def test_version
    with_profile do |p|
      assert_equal p.version, '3.2.1'
    end
  end

  def test_references
    with_profile do |p|
      assert_equal p.references, []
    end
  end

  def test_abstract
    with_profile do |p|
      assert_false p.abstract?
    end
  end

  private

  def with_profile(&)
    benchmark do |b|
      assert b.profiles.size == 1, b.profiles.to_s
      profile = b.profiles['xccdf_org.ssgproject.content_profile_common']
      assert profile
      yield profile
    end
  end

  def benchmark(&)
    OpenSCAP::Source.new '../data/xccdf.xml' do |source|
      OpenSCAP::Xccdf::Benchmark.new(source, &)
    end
  end
end
