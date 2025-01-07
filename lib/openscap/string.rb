# frozen_string_literal: true

module OpenSCAP
  class String
    def initialize s
      @raw = case s
             when FFI::Pointer
               s
             end
    end
  end

  attach_function :oscap_string_iterator_free, [:pointer], :void
  attach_function :oscap_string_iterator_has_more, [:pointer], :bool
  attach_function :oscap_string_iterator_next, [:pointer], :pointer
end
