# frozen_string_literal: true

require 'common/testcase'
require 'openscap'
require 'openscap/source'
require 'openscap/xccdf/benchmark'
require 'openscap/xccdf/profile'

class TestProfile < OpenSCAP::TestCase
  def test_new_from_file
    profile do |p|
      assert p.title == 'Common Profile for General-Purpose Fedora Systems'
    end
  end

  def test_description_html
    profile do |p|
      assert_equal p.description, 'This profile contains items common to general-purpose Fedora installations.'
    end
  end

  def test_status
    profile do |p|
      assert_nil p.status_current&.status
    end
  end

  def test_version
    profile do |p|
      assert_equal p.version, '3.2.1'
    end
  end

  private

  def profile(&)
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
