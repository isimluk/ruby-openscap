# frozen_string_literal: true

require 'openscap/exceptions'
require 'openscap/xccdf/item'
require 'openscap/xccdf/fix'
require 'openscap/xccdf/fixtext'
require 'openscap/xccdf/ident'

module OpenSCAP
  module Xccdf
    class Rule < Item
      def severity
        severity = OpenSCAP.xccdf_rule_get_severity(@raw)
        severity_mapping = {
          xccdf_level_not_defined: 'Not defined',
          xccdf_unknown: 'Unknown',
          xccdf_info: 'Info',
          xccdf_low: 'Low',
          xccdf_medium: 'Medium',
          xccdf_high: 'High'
        }
        severity_mapping[severity] || severity_mapping[:xccdf_unknown]
      end

      def each_fix(&)
        OpenSCAP._iterate over: OpenSCAP.xccdf_rule_get_fixes(@raw), as: 'xccdf_fix' do |pointer|
          yield OpenSCAP::Xccdf::Fix.new pointer
        end
      end

      def each_fixtext(&)
        OpenSCAP._iterate over: OpenSCAP.xccdf_rule_get_fixtexts(@raw), as: 'xccdf_fixtext' do |pointer|
          yield OpenSCAP::Xccdf::Fixtext.new pointer
        end
      end

      def fixtexts
        @fixtexts ||= [].tap do |fixtexts|
          each_fixtext { |ft| fixtexts << ft }
        end
      end

      def fixes
        @fixes ||= [].tap do |fixes|
          each_fix do |fix|
            fixes << fix
          end
        end
      end

      def idents
        idents = []
        OpenSCAP._iterate over: OpenSCAP.xccdf_rule_get_idents(@raw), as: 'xccdf_ident' do |pointer|
          idents << OpenSCAP::Xccdf::Ident.new(pointer)
        end
        idents
      end
    end
  end
  XccdfSeverity = enum(
    :xccdf_level_not_defined, 0,
    :xccdf_unknown, 1,
    :xccdf_info,
    :xccdf_low,
    :xccdf_medium,
    :xccdf_high
  )
  attach_function :xccdf_rule_get_severity, [:pointer], XccdfSeverity
  attach_function :xccdf_rule_get_fixes, [:pointer], :pointer
  attach_function :xccdf_fix_iterator_has_more, [:pointer], :bool
  attach_function :xccdf_fix_iterator_next, [:pointer], :pointer
  attach_function :xccdf_fix_iterator_free, [:pointer], :void

  attach_function :xccdf_rule_get_fixtexts, [:pointer], :pointer
  attach_function :xccdf_fixtext_iterator_has_more, [:pointer], :bool
  attach_function :xccdf_fixtext_iterator_next, [:pointer], :pointer
  attach_function :xccdf_fixtext_iterator_free, [:pointer], :void

  attach_function :xccdf_rule_get_idents, [:pointer], :pointer
  attach_function :xccdf_ident_iterator_has_more, [:pointer], :bool
  attach_function :xccdf_ident_iterator_next, [:pointer], :pointer
  attach_function :xccdf_ident_iterator_free, [:pointer], :void
end
