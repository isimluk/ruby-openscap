# frozen_string_literal: true

require 'openscap/source'

module OpenSCAP
  module DS
    class Sds
      attr_reader :raw

      def initialize(param)
        @raw = case param
               when OpenSCAP::Source
                 OpenSCAP.ds_sds_session_new_from_source param.raw
               when Hash
                 OpenSCAP.ds_sds_session_new_from_source param[:source].raw
               end
        OpenSCAP.raise! if @raw.null?

        begin
          yield self
        ensure
          destroy
        end if block_given?
      end

      def select_checklist(p = {})
        source_p = OpenSCAP.ds_sds_session_select_checklist(@raw, p[:datastream_id], p[:component_id], nil)
        OpenSCAP::Source.new source_p
      end

      def select_checklist!(p = {})
        checklist = select_checklist(p)
        OpenSCAP.raise! if checklist.nil? or checklist.raw.null?
        checklist
      end

      def destroy
        OpenSCAP.ds_sds_session_free(@raw)
        @raw = nil
      end
    end
  end

  attach_function :ds_sds_session_new_from_source, [:pointer], :pointer
  attach_function :ds_sds_session_free, [:pointer], :void
  attach_function :ds_sds_session_select_checklist, %i[pointer string string string], :pointer
end
