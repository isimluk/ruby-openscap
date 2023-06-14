# frozen_string_literal: true

require 'openscap/text'
require 'openscap/xccdf/item_common'

module OpenSCAP
  module Xccdf
    class Profile
      include ItemCommon
      attr_reader :raw

      def initialize(p)
        case p
        when FFI::Pointer
          @raw = p
        else
          raise OpenSCAP::OpenSCAPError, "Cannot initialize #{self.class.name} with #{p}"
        end
      end

      def status_current
        pointer = OpenSCAP.xccdf_profile_get_status_current @raw
        Status.new pointer unless pointer.null?
      end

      def abstract?
        OpenSCAP.xccdf_profile_get_abstract @raw
      end
    end
  end

  attach_function :xccdf_profile_get_status_current, [:pointer], :pointer
  attach_function :xccdf_profile_get_abstract, [:pointer], :bool
end
