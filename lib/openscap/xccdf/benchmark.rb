# frozen_string_literal: true

require 'openscap/source'
require_relative 'profile'
require_relative 'item'
require_relative 'item_common'
require_relative 'value'
require_relative 'status'

module OpenSCAP
  module Xccdf
    class Benchmark
      include ItemCommon
      attr_reader :raw

      def initialize p
        case p
        when OpenSCAP::Source
          @raw = OpenSCAP.xccdf_benchmark_import_source p.raw
        else
          raise OpenSCAP::OpenSCAPError,
                "Cannot initialize OpenSCAP::Xccdf::Benchmark with '#{p}'"
        end
        OpenSCAP.raise! if @raw.null?

        begin
          yield self
        ensure
          destroy
        end if block_given?
      end

      def resolved?
        OpenSCAP.xccdf_benchmark_get_resolved @raw
      end

      def status_current
        Status.new OpenSCAP.xccdf_benchmark_get_status_current(@raw)
      end

      def profiles
        @profiles ||= profiles_init
      end

      def items
        @items ||= items_init
      end

      def each_item(&)
        OpenSCAP._iterate over: OpenSCAP.xccdf_item_get_content(@raw), as: 'xccdf_item' do |pointer|
          yield OpenSCAP::Xccdf::Item.build(pointer)
        end
      end

      def each_profile(&)
        OpenSCAP._iterate over: OpenSCAP.xccdf_benchmark_get_profiles(@raw), as: 'xccdf_profile' do |pointer|
          yield OpenSCAP::Xccdf::Profile.new pointer
        end
      end

      def each_value(&)
        OpenSCAP._iterate over: OpenSCAP.xccdf_benchmark_get_values(@raw), as: 'xccdf_value' do |pointer|
          yield OpenSCAP::Xccdf::Value.new pointer
        end
      end

      def policy_model
        @policy_model ||= PolicyModel.new self
      end

      def schema_version
        pointer = OpenSCAP.xccdf_benchmark_get_schema_version @raw
        OpenSCAP.xccdf_version_info_get_version pointer
      end

      def destroy
        # Policy Model takes ownership of Xccdf::Benchmark. It is one of these lovely quirks of libopenscap
        if @policy_model
          @policy_model.destroy
        else
          OpenSCAP.xccdf_benchmark_free @raw
        end
        @raw = nil
      end

      private

      def profiles_init
        profiles = {}
        each_profile do |profile|
          profiles[profile.id] = profile
        end
        profiles
      end

      def items_init
        items = {}
        each_item do |item|
          items.merge! item.sub_items
          items[item.id] = item
        end
        items
      end
    end
  end

  attach_function :xccdf_benchmark_import_source, [:pointer], :pointer
  attach_function :xccdf_benchmark_free, [:pointer], :void

  attach_function :xccdf_benchmark_get_status_current, [:pointer], :pointer
  attach_function :xccdf_benchmark_get_resolved, [:pointer], :pointer
  attach_function :xccdf_benchmark_get_profiles, [:pointer], :pointer
  attach_function :xccdf_profile_iterator_has_more, [:pointer], :bool
  attach_function :xccdf_profile_iterator_next, [:pointer], :pointer
  attach_function :xccdf_profile_iterator_free, [:pointer], :void
  attach_function :xccdf_benchmark_get_values, [:pointer], :pointer
  attach_function :xccdf_value_iterator_has_more, [:pointer], :bool
  attach_function :xccdf_value_iterator_next, [:pointer], :pointer
  attach_function :xccdf_value_iterator_free, [:pointer], :void

  attach_function :xccdf_benchmark_get_schema_version, [:pointer], :pointer
  attach_function :xccdf_version_info_get_version, [:pointer], :string
end

require_relative 'policy_model'
