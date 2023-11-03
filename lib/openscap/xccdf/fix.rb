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
      def fix_system = OpenSCAP.xccdf_fix_get_system @raw
      def content = OpenSCAP.xccdf_fix_get_content @raw
      def reboot = OpenSCAP.xccdf_fix_get_reboot @raw
      def strategy = OpenSCAP.xccdf_fix_get_strategy @raw
      def disruption = OpenSCAP.xccdf_fix_get_disruption @raw

      def to_hash
        { id:, platform:, system: fix_system, content: }
      end
    end
  end
  attach_function :xccdf_fix_get_id, [:pointer], :string
  attach_function :xccdf_fix_get_platform, [:pointer], :string
  attach_function :xccdf_fix_get_system, [:pointer], :string
  attach_function :xccdf_fix_get_content, [:pointer], :string
  attach_function :xccdf_fix_get_reboot, [:pointer], :bool

  XccdfStrategy = enum(
    :strategy_unknown, 0, # Strategy not defined
    :strategy_configure,  # Adjust target config or settings
    :strategy_disable,    # Turn off or deinstall something
    :strategy_enable,     # Turn on or install something
    :strategy_patch,      # Apply a patch, hotfix, or update
    :strategy_policy,	   # Remediation by changing policies/procedures
    :strategy_restrict,	 # Adjust permissions or ACLs
    :strategy_update,	   # Install upgrade or update the system
    :strategy_combination # Combo of two or more of the above
  )
  attach_function :xccdf_fix_get_strategy, [:pointer], XccdfStrategy
  XccdfLevel = enum(
    :level_not_defined, 0,
    :level_unknown, 1, # Unknown.
    :level_info, # Info.
    :level_low, # Low.
    :level_medium, # Medium.
    :level_high		          # High.
  )
  attach_function :xccdf_fix_get_disruption, [:pointer], XccdfLevel
end
