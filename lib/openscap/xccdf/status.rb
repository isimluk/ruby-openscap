# frozen_string_literal: true

module OpenSCAP
  module Xccdf
    class Status
      def initialize(raw)
        raise OpenSCAP::OpenSCAPError, "Cannot initialize #{self.class.name} with '#{raw}'" \
          unless raw.is_a?(FFI::Pointer)

        @raw = raw
      end

      def status
        OpenSCAP.xccdf_status_get_status @raw
      end
    end
  end

  enum :xccdf_status_type_t, [
    :not_specified, # empty value
    :accepted,
    :deprecated,
    :draft,
    :incomplete,
    :interim
  ]

  attach_function :xccdf_status_get_status, [:pointer], :xccdf_status_type_t
end
