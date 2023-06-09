# frozen_string_literal: true

require 'openscap/text'

module OpenSCAP
  module Xccdf
    class Profile
      attr_reader :raw

      def initialize(p)
        case p
        when FFI::Pointer
          @raw = p
        else
          raise OpenSCAP::OpenSCAPError, "Cannot initialize #{self.class.name} with #{p}"
        end
      end

      def id
        OpenSCAP.xccdf_profile_get_id raw
      end

      def title(prefered_lang = nil)
        TextList.extract(OpenSCAP.xccdf_profile_get_title(@raw), lang: prefered_lang, markup: false)
      end

      def description(prefered_lang: nil, markup: false)
        TextList.extract(OpenSCAP.xccdf_item_get_description(@raw), lang: prefered_lang, markup:)
      end

      def status_current
        pointer = OpenSCAP.xccdf_profile_get_status_current @raw
        Status.new pointer unless pointer.null?
      end
    end
  end

  attach_function :xccdf_profile_get_id, [:pointer], :string
  attach_function :xccdf_profile_get_title, [:pointer], :pointer
  attach_function :xccdf_profile_get_status_current, [:pointer], :pointer
end
