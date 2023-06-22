# frozen_string_literal: true

require 'common/testcase'
require 'openscap'
require 'openscap/source'
require 'openscap/xccdf/benchmark'
require 'openscap/xccdf/policy'
require 'openscap/xccdf/policy_model'

class TestPolicy < OpenSCAP::TestCase
  def test_new_policy_model
    with_policy_model do |pm|
      assert pm.policies.size == 1, pm.policies.to_s
      assert pm.policies['xccdf_org.ssgproject.content_profile_common']
    end
  end

  def test_profile_getter
    with_policy do |policy|
      profile = policy.profile
      assert_equal profile.id, 'xccdf_org.ssgproject.content_profile_common'
    end
  end

  def test_selects_item
    with_policy do |policy|
      assert policy.selects_item?('xccdf_org.ssgproject.content_rule_disable_prelink')
      refute policy.selects_item?('xccdf_org.ssgproject.content_rule_disable_vsftpd')
    end
  end

  private

  def with_policy(&)
    with_policy_model do |pm|
      yield pm.policies['xccdf_org.ssgproject.content_profile_common']
    end
  end

  def with_policy_model(&)
    OpenSCAP::Source.new '../data/xccdf.xml' do |source|
      b = OpenSCAP::Xccdf::Benchmark.new source
      assert !b.nil?
      OpenSCAP::Xccdf::PolicyModel.new(b, &)
    end
  end
end
