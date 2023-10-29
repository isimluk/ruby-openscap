# frozen_string_literal: true

require 'openscap/source'
require 'openscap/xccdf/profile'

module OpenSCAP
  module Xccdf
    class Tailoring
      attr_reader :raw

      def initialize(source, benchmark)
        case source
        when OpenSCAP::Source
          @raw = OpenSCAP.xccdf_tailoring_import_source source.raw, benchmark
        else
          raise OpenSCAP::OpenSCAPError, "Cannot initialize #{self.class.name} with '#{source}'"
        end
        OpenSCAP.raise! if @raw.null?
      end

      def profiles
        @profiles ||= {}.tap do |profiles|
          OpenSCAP._iterate over: OpenSCAP.xccdf_tailoring_get_profiles(@raw), as: 'xccdf_profile' do |pointer|
            profile = OpenSCAP::Xccdf::Profile.new pointer
            profiles[profile.id] = profile
          end
        end
      end

      def destroy
        OpenSCAP.xccdf_tailoring_free @raw
        @raw = nil
      end
    end
  end

  attach_function :xccdf_tailoring_import_source, %i[pointer pointer], :pointer
  attach_function :xccdf_tailoring_free, [:pointer], :void

  attach_function :xccdf_tailoring_get_profiles, [:pointer], :pointer
  attach_function :xccdf_profile_iterator_has_more, [:pointer], :bool
  attach_function :xccdf_profile_iterator_next, [:pointer], :pointer
  attach_function :xccdf_profile_iterator_free, [:pointer], :void
end
