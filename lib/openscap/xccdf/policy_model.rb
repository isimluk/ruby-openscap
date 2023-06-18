# frozen_string_literal: true

require 'openscap/exceptions'
require 'openscap/xccdf/benchmark'
require 'openscap/xccdf/policy'

module OpenSCAP
  module Xccdf
    class PolicyModel
      attr_reader :raw

      def initialize(b)
        case b
        when OpenSCAP::Xccdf::Benchmark
          @raw = OpenSCAP.xccdf_policy_model_new(b.raw)
        else
          raise OpenSCAP::OpenSCAPError,
                "Cannot initialize OpenSCAP::Xccdf::PolicyModel with '#{b}'"
        end
        OpenSCAP.raise! if @raw.null?

        begin
          yield self
        ensure
          destroy
        end if block_given?
      end

      def policies
        @policies ||= policies_init
      end

      def destroy
        OpenSCAP.xccdf_policy_model_free @raw
        @raw = nil
      end

      def each_policy(&)
        OpenSCAP.raise! unless OpenSCAP.xccdf_policy_model_build_all_useful_policies(raw).zero?
        OpenSCAP._iterate over: OpenSCAP.xccdf_policy_model_get_policies(@raw),
                          as: 'xccdf_policy' do |pointer|
          yield OpenSCAP::Xccdf::Policy.new pointer
        end
      end

      private

      def policies_init
        policies = {}
        each_policy do |policy|
          policies[policy.id] = policy
        end
        policies
      end
    end
  end

  attach_function :xccdf_policy_model_new, [:pointer], :pointer
  attach_function :xccdf_policy_model_free, [:pointer], :void
  attach_function :xccdf_policy_model_build_all_useful_policies, [:pointer], :int

  attach_function :xccdf_policy_model_get_policies, [:pointer], :pointer
  attach_function :xccdf_policy_iterator_has_more, [:pointer], :bool
  attach_function :xccdf_policy_iterator_next, [:pointer], :pointer
  attach_function :xccdf_policy_iterator_free, [:pointer], :void
end
