# frozen_string_literal: true

require 'openscap/exceptions'
require 'openscap/xccdf'
require_relative 'item'

module OpenSCAP
  module Xccdf
    class Group < Item
      def each_child(&)
        OpenSCAP._iterate over: OpenSCAP.xccdf_item_get_content(@raw), as: 'xccdf_item' do |pointer|
          yield OpenSCAP::Xccdf::Item.build pointer
        end
      end

      def each_value(&)
        OpenSCAP._iterate over: OpenSCAP.xccdf_group_get_values(@raw), as: 'xccdf_value' do |pointer|
          yield OpenSCAP::Xccdf::Value.new pointer
        end
      end

      def sub_items
        @sub_items ||= {}.tap do |sub_items|
          each_child do |item|
            sub_items.merge! item.sub_items
            sub_items[item.id] = item
          end
        end
      end
    end
  end

  attach_function :xccdf_item_get_content, [:pointer], :pointer
  attach_function :xccdf_item_iterator_has_more, [:pointer], :bool
  attach_function :xccdf_item_iterator_next, [:pointer], :pointer
  attach_function :xccdf_item_iterator_free, [:pointer], :void
  attach_function :xccdf_group_get_values, [:pointer], :pointer
end
