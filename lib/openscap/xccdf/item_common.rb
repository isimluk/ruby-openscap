# frozen_string_literal: true

module OpenSCAP
  module Xccdf
    module ItemCommon
      def id
        OpenSCAP.xccdf_item_get_id @raw
      end

      def version
        OpenSCAP.xccdf_item_get_version @raw
      end
    end
  end

  attach_function :xccdf_item_get_id, [:pointer], :string
  attach_function :xccdf_item_get_version, [:pointer], :string
end
