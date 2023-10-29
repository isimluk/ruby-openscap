# frozen_string_literal: true

require 'openscap/text'
require_relative 'reference'

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

      def description prefered_lang: nil, markup: true
        TextList.extract(OpenSCAP.xccdf_item_get_description(@raw), lang: prefered_lang, markup:)
      end

      def references
        refs = []
        OpenSCAP._iterate over: OpenSCAP.xccdf_item_get_references(@raw), as: 'oscap_reference' do |pointer|
          refs << OpenSCAP::Xccdf::Reference.new(pointer)
        end
        refs
      end
    end
  end

  attach_function :xccdf_item_get_id, [:pointer], :string
  attach_function :xccdf_item_get_title, [:pointer], :pointer
  attach_function :xccdf_item_get_description, [:pointer], :pointer
  attach_function :xccdf_item_get_references, [:pointer], :pointer
  attach_function :xccdf_item_get_version, [:pointer], :string
end
