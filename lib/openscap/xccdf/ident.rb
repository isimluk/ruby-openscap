# frozen_string_literal: true

module OpenSCAP
  module Xccdf
    class Ident
      def initialize raw
        raise OpenSCAP::OpenSCAPError, "Cannot initialize #{self.class.name} with '#{raw}'" unless raw.is_a?(FFI::Pointer)

        @raw = raw
      end

      def system = OpenSCAP.xccdf_ident_get_system @raw
      def id = OpenSCAP.xccdf_ident_get_id @raw
    end
  end
  attach_function :xccdf_ident_get_system, [:pointer], :string
  attach_function :xccdf_ident_get_id, [:pointer], :string
end
