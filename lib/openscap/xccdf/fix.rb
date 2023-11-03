# frozen_string_literal: true

module OpenSCAP
  module Xccdf
    class Fix
      def initialize raw
        raise OpenSCAP::OpenSCAPError, "Cannot initialize #{self.class.name} with '#{raw}'" unless raw.is_a? FFI::Pointer

        @raw = raw
      end

      def id = OpenSCAP.xccdf_fix_get_id @raw
      def platform = OpenSCAP.xccdf_fix_get_platform @raw
      def system = OpenSCAP.xccdf_fix_get_system @raw
      def content = OpenSCAP.xccdf_fix_get_content @raw
      def reboot = OpenSCAP.xccdf_fix_get_reboot @raw
      def strategy = OpenSCAP.xccdf_fix_get_strategy @raw
      def disruption = OpenSCAP.xccdf_fix_get_disruption @raw
      def complexity = OpenSCAP.xccdf_fix_get_complexity @raw
      alias fix_system system

      def to_hash
        { id:, platform:, system:, content: }
      end
    end
  end
  attach_function :xccdf_fix_get_id, [:pointer], :string
  attach_function :xccdf_fix_get_platform, [:pointer], :string
  attach_function :xccdf_fix_get_system, [:pointer], :string
  attach_function :xccdf_fix_get_content, [:pointer], :string
  attach_function :xccdf_fix_get_reboot, [:pointer], :bool

  XccdfStrategy = enum(
    :unknown, 0, # Strategy not defined
    :configure,  # Adjust target config or settings
    :disable,    # Turn off or deinstall something
    :enable,     # Turn on or install something
    :patch,      # Apply a patch, hotfix, or update
    :policy,	   # Remediation by changing policies/procedures
    :restrict,	 # Adjust permissions or ACLs
    :update,	   # Install upgrade or update the system
    :combination # Combo of two or more of the above
  )
  attach_function :xccdf_fix_get_strategy, [:pointer], XccdfStrategy
  XccdfLevel = enum(
    :not_defined, 0,
    :unknown, 1,
    :info,
    :low,
    :medium,
    :high
  )
  attach_function :xccdf_fix_get_disruption, [:pointer], XccdfLevel
  attach_function :xccdf_fix_get_complexity, [:pointer], XccdfLevel
end
