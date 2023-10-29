# frozen_string_literal: true

require 'openscap/exceptions'
require 'openscap/text'
require_relative 'item_common'
require_relative 'group'
require_relative 'rule'

module OpenSCAP
  module Xccdf
    class Item
      include ItemCommon # reflects OpenSCAP's struct xccdf_item (thus operates with Benchmark, Profile, Group, Rule, and Value)

      def self.build t
        raise OpenSCAP::OpenSCAPError, "Cannot initialize #{self.class.name} with #{t}" \
          unless t.is_a?(FFI::Pointer)

        # This is Abstract base class that enables you to build its child
        case OpenSCAP.xccdf_item_get_type t
        when :group
          OpenSCAP::Xccdf::Group.new t
        when :rule
          OpenSCAP::Xccdf::Rule.new t
        else
          raise OpenSCAP::OpenSCAPError, "Unknown #{self.class.name} type: #{OpenSCAP.xccdf_item_get_type t}"
        end
      end

      def initialize t
        raise OpenSCAP::OpenSCAPError, "Cannot initialize #{self.class.name} abstract base class." if instance_of?(OpenSCAP::Xccdf::Item)

        @raw = t
      end

      def rationale prefered_lang = nil, markup: false
        TextList.extract(OpenSCAP.xccdf_item_get_rationale(@raw), lang: prefered_lang, markup:)
      end

      def warnings
        @warnings ||= [].tap do |warns|
          OpenSCAP._iterate over: OpenSCAP.xccdf_item_get_warnings(@raw), as: 'xccdf_warning' do |pointer|
            warns << {
              category: OpenSCAP.xccdf_warning_get_category(pointer),
              text: Text.new(OpenSCAP.xccdf_warning_get_text(pointer))
            }
          end
        end
      end

      def sub_items = {}

      def destroy
        OpenSCAP.xccdf_item_free @raw
        @raw = nil
      end
    end
  end

  attach_function :xccdf_item_free, [:pointer], :void
  attach_function :xccdf_item_get_rationale, [:pointer], :pointer

  XccdfItemType = enum(:benchmark, 0x0100,
                       :profile, 0x0200,
                       :result, 0x0400,
                       :rule, 0x1000,
                       :group, 0x2000,
                       :value, 0x4000)
  attach_function :xccdf_item_get_type, [:pointer], XccdfItemType

  enum :xccdf_warning_category_t, [
    :not_specified, # empty value
    :general, # General-purpose warning
    :functionality, # Warning about possible impacts to functionality
    :performance, # Warning about changes to target system performance
    :hardware, # Warning about hardware restrictions or possible impacts to hardware
    :legal, # Warning about legal implications
    :regulatory,	# Warning about regulatory obligations
    :management, # Warning about impacts to the mgmt or administration of the target system
    :audit, # Warning about impacts to audit or logging
    :dependency # Warning about dependencies between this Rule and other parts of the target system
  ]
  attach_function :xccdf_item_get_warnings, [:pointer], :pointer
  attach_function :xccdf_warning_iterator_has_more, [:pointer], :bool
  attach_function :xccdf_warning_iterator_next, [:pointer], :pointer
  attach_function :xccdf_warning_iterator_free, [:pointer], :void
  attach_function :xccdf_warning_get_category, [:pointer], :xccdf_warning_category_t
  attach_function :xccdf_warning_get_text, [:pointer], :pointer

  attach_function :oscap_reference_iterator_has_more, [:pointer], :bool
  attach_function :oscap_reference_iterator_next, [:pointer], :pointer
  attach_function :oscap_reference_iterator_free, [:pointer], :void
end
