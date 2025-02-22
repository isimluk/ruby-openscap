# frozen_string_literal: true

require 'ffi'

module OpenSCAP
  extend FFI::Library
  ffi_lib ['libopenscap.so.8', 'libopenscap.so.25', 'libopenscap.so.33', 'openscap']

  def self.error?
    oscap_err
  end

  def self.full_error
    err = oscap_err_get_full_error
    err.null? ? nil : err.read_string
  end

  def self.raise!(msg = nil)
    err = full_error
    if err.nil?
      err = msg.nil? ? '(unknown error)' : msg
    else
      err += "\n#{msg}"
    end
    raise OpenSCAPError, err
  end

  def self._iterate(over:, as:, &)
    has_more_method = "#{as}_iterator_has_more"
    next_method = "#{as}_iterator_next"
    free_method = "#{as}_iterator_free"

    yield send(next_method, over) while send(has_more_method, over)
    send(free_method, over)
  end

  attach_function :oscap_init, [], :void
  attach_function :oscap_cleanup, [], :void
  attach_function :oscap_get_version, [], :string

  attach_function :oscap_document_type_to_string, [:int], :string

  attach_function :oscap_err, [], :bool
  attach_function :oscap_err_get_full_error, [], :pointer
  private_class_method :oscap_err, :oscap_err_get_full_error
end
