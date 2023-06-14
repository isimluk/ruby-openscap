# frozen_string_literal: true

require 'openscap/text'

module OpenSCAP
  module Xccdf
    module ItemCommon
      def id
        OpenSCAP.xccdf_item_get_id @raw
      end

      def version
        OpenSCAP.xccdf_item_get_version @raw
      end

      def title lang: nil
        TextList.extract OpenSCAP.xccdf_item_get_title(@raw), lang:, markup: false
      end
    end
  end

  attach_function :xccdf_item_get_id, [:pointer], :string
  attach_function :xccdf_item_get_title, [:pointer], :pointer
  attach_function :xccdf_item_get_version, [:pointer], :string
end
