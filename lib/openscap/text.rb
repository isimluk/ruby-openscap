# frozen_string_literal: true

module OpenSCAP
  class Text
    attr_reader :raw

    def initialize(t = nil)
      @raw = case t
             when FFI::Pointer
               t
             when nil
               OpenSCAP.oscap_text_new
             end
    end

    def text=(str)
      OpenSCAP.raise! unless OpenSCAP.oscap_text_set_text(raw, str)
    end

    def text
      OpenSCAP.oscap_text_get_text(@raw).force_encoding Encoding::UTF_8
    end

    def destroy
      OpenSCAP.oscap_text_free(raw)
      @raw = nil
    end
  end

  class TextList
    def initialize(oscap_text_iterator)
      @raw = oscap_text_iterator

      begin
        yield self
      ensure
        destroy
      end if block_given?
    end

    def plaintext(lang = nil)
      OpenSCAP.oscap_textlist_get_preferred_plaintext @raw, lang
    end

    def markup(lang:)
      text_pointer = OpenSCAP.oscap_textlist_get_preferred_text @raw, lang
      return nil if text_pointer.null?

      Text.new(text_pointer).text
    end

    def destroy
      OpenSCAP.oscap_text_iterator_free @raw
    end

    def self.extract(pointer, lang:, markup:)
      new(pointer) do |list|
        if markup
          return list.markup(lang:)
        else
          return list.plaintext(lang)
        end
      end
    end
  end

  attach_function :oscap_text_new, [], :pointer
  attach_function :oscap_text_set_text, %i[pointer string], :bool
  attach_function :oscap_text_get_text, [:pointer], :string
  attach_function :oscap_text_free, [:pointer], :void

  attach_function :oscap_textlist_get_preferred_plaintext, %i[pointer string], :string
  attach_function :oscap_textlist_get_preferred_text, %i[pointer string], :pointer
  attach_function :oscap_text_iterator_free, [:pointer], :void
end
