# frozen_string_literal: true

require 'openscap/exceptions'

module OpenSCAP
  module Xccdf
    class Policy
      attr_reader :raw

      def initialize(p)
        case p
        when FFI::Pointer
          @raw = p
        else
          raise OpenSCAP::OpenSCAPError, "Cannot initialize OpenSCAP::Xccdf::Policy with '#{p}'"
        end
        OpenSCAP.raise! if @raw.null?
      end

      def id
        OpenSCAP.xccdf_policy_get_id @raw
      end

      def profile
        Profile.new OpenSCAP.xccdf_policy_get_profile @raw
      end

      def selects_item? item_idref
        OpenSCAP.xccdf_policy_is_item_selected @raw, item_idref
      end
    end
  end

  attach_function :xccdf_policy_get_id, [:pointer], :string
  attach_function :xccdf_policy_get_profile, [:pointer], :pointer
  attach_function :xccdf_policy_is_item_selected, %i[pointer string], :bool
end
