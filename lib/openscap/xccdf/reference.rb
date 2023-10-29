# frozen_string_literal: true

module OpenSCAP
  module Xccdf
    class Reference
      def initialize(raw)
        raise OpenSCAP::OpenSCAPError, "Cannot initialize #{self.class.name} with '#{raw}'" unless raw.is_a?(FFI::Pointer)

        @raw = raw
      end

      def title = OpenSCAP.oscap_reference_get_title @raw
      def href = OpenSCAP.oscap_reference_get_href @raw
      def html_link = "<a href='#{href}'>#{title}</a>"
      def to_hash = { title:, href:, html_link: }
    end
  end
  attach_function :oscap_reference_get_href, [:pointer], :string
  attach_function :oscap_reference_get_title, [:pointer], :string
end
