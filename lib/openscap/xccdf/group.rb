# frozen_string_literal: true

require 'openscap/exceptions'
require 'openscap/xccdf'
require 'openscap/xccdf/item'

module OpenSCAP
  module Xccdf
    class Group < Item
      def each_child(&)
        OpenSCAP._iterate over: OpenSCAP.xccdf_item_get_content(@raw), as: 'xccdf_item' do |pointer|
          yield OpenSCAP::Xccdf::Item.build pointer
        end
      end

      def sub_items
        @sub_items ||= sub_items_init
      end

      private

      def sub_items_init
        collect = {}
        each_child do |item|
          collect.merge! item.sub_items
          collect[item.id] = item
        end
        collect
      end
    end
  end

  attach_function :xccdf_item_get_content, [:pointer], :pointer
  attach_function :xccdf_item_iterator_has_more, [:pointer], :bool
  attach_function :xccdf_item_iterator_next, [:pointer], :pointer
  attach_function :xccdf_item_iterator_free, [:pointer], :void
end
