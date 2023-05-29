# frozen_string_literal: true

require 'openscap/source'
require 'openscap/xccdf/profile'
require 'openscap/xccdf/item'
require 'openscap/xccdf/status'

module OpenSCAP
  module Xccdf
    class Benchmark
      attr_reader :raw

      def initialize(p)
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

      def id
        OpenSCAP.xccdf_benchmark_get_id raw
      end

      def title lang: nil
        OpenSCAP::TextList.find_plaintext OpenSCAP.xccdf_benchmark_get_title(@raw), lang:
      end

      def description lang: nil
        TextList.find_markup OpenSCAP.xccdf_benchmark_get_description(@raw), lang:
      end

      def status_current
        Status.new OpenSCAP.xccdf_benchmark_get_status_current(raw)
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

      def destroy
        OpenSCAP.xccdf_benchmark_free @raw
        @raw = nil
      end

      private

      def profiles_init
        profiles = {}
        OpenSCAP._iterate over: OpenSCAP.xccdf_benchmark_get_profiles(@raw), as: 'xccdf_profile' do |pointer|
          profile = OpenSCAP::Xccdf::Profile.new pointer
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

  attach_function :xccdf_benchmark_get_id, [:pointer], :string
  attach_function :xccdf_benchmark_get_status_current, [:pointer], :pointer
  attach_function :xccdf_benchmark_get_title, [:pointer], :pointer
  attach_function :xccdf_benchmark_get_description, [:pointer], :pointer
  attach_function :xccdf_benchmark_get_profiles, [:pointer], :pointer
  attach_function :xccdf_profile_iterator_has_more, [:pointer], :bool
  attach_function :xccdf_profile_iterator_next, [:pointer], :pointer
  attach_function :xccdf_profile_iterator_free, [:pointer], :void
end
