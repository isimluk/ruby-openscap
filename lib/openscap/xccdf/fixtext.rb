# frozen_string_literal: true

module OpenSCAP
  module Xccdf
    class Fixtext
      def initialize(raw)
        raise OpenSCAP::OpenSCAPError, "Cannot initialize #{self.class.name} with '#{raw}'" unless raw.is_a?(FFI::Pointer)

        @raw = raw
      end

      def text = Text.new(OpenSCAP.xccdf_fixtext_get_text(@raw)).text
      def fixref = OpenSCAP.xccdf_fixtext_get_fixref @raw
      def reboot = OpenSCAP.xccdf_fixtext_get_reboot @raw
      def strategy = OpenSCAP.xccdf_fixtext_get_strategy @raw
      def disruption = OpenSCAP.xccdf_fixtext_get_disruption @raw
      def complexity = OpenSCAP.xccdf_fixtext_get_complexity @raw
    end
  end

  attach_function :xccdf_fixtext_get_text, [:pointer], :pointer
  attach_function :xccdf_fixtext_get_fixref, [:pointer], :string
  attach_function :xccdf_fixtext_get_reboot, [:pointer], :bool
  attach_function :xccdf_fixtext_get_strategy, [:pointer], XccdfStrategy
  attach_function :xccdf_fixtext_get_disruption, [:pointer], XccdfLevel
  attach_function :xccdf_fixtext_get_complexity, [:pointer], XccdfLevel
end
