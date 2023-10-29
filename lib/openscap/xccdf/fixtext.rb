# frozen_string_literal: true

module OpenSCAP
  module Xccdf
    class Fixtext
      def initialize(raw)
        raise OpenSCAP::OpenSCAPError, "Cannot initialize #{self.class.name} with '#{raw}'" unless raw.is_a?(FFI::Pointer)

        @raw = raw
      end

      def text
        Text.new(OpenSCAP.xccdf_fixtext_get_text(@raw)).text
      end
    end
  end

  attach_function :xccdf_fixtext_get_text, [:pointer], :pointer
end
