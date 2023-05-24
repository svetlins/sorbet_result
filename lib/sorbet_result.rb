# frozen_string_literal: true
# typed: strict

require "sorbet-runtime"
require_relative "sorbet_result/version"

module SorbetResult
  class Result < T::Struct
    extend T::Sig
    extend T::Generic

    OkType = type_member
    ErrorType = type_member { {upper: Object} }

    const :success, T::Boolean
    const :wrapped_value, T.nilable(OkType), default: nil
    const :wrapped_error, T.nilable(ErrorType), default: nil

    private_class_method :new
    private :wrapped_value, :wrapped_error

    sig do
      type_parameters(
        :OkType
      ).params(
        value: T.type_parameter(:OkType)
      ).returns(
        Result[T.type_parameter(:OkType), T.untyped]
      )
    end
    def self.ok(value)
      new(success: true, wrapped_value: value)
    end

    sig do
      type_parameters(
        :ErrorType
      ).params(
        error: T.all(T.type_parameter(:ErrorType), Object)
      ).returns(
        Result[T.untyped, T.all(T.type_parameter(:ErrorType), Object)]
      )
    end
    def self.error(error)
      new(success: false, wrapped_error: error)
    end

    sig { returns(T::Boolean) }
    def ok?
      success
    end

    sig { returns(T::Boolean) }
    def error?
      !success
    end

    sig { returns(OkType) }
    def unwrap!
      if ok?
        wrapped_value
      else
        raise("Failed to unwrap! Result with #{wrapped_error.inspect}")
      end
    end

    sig { returns(ErrorType) }
    def unwrap_error!
      if error?
        wrapped_error
      else
        raise("Failed to unwrap_error! Result (#{inspect})")
      end
    end

    sig do
      params(
        _block: T.proc.params(error: ErrorType, _self: Result[T.untyped, ErrorType]).returns(OkType)
      ).returns(OkType)
    end
    def unwrap_or(&_block)
      if ok?
        wrapped_value
      else
        yield(T.must(wrapped_error), self)
      end
    end

    sig do
      type_parameters(
        :NewOkType
      ).params(
        _block: T.proc.params(wrapped_value: OkType).returns(T.type_parameter(:NewOkType))
      ).returns(
        Result[T.type_parameter(:NewOkType), ErrorType]
      )
    end
    def transform_value(&_block)
      if ok?
        self.class.ok(yield(T.must(wrapped_value)))
      else
        self.class.error(T.must(wrapped_error))
      end
    end

    sig do
      type_parameters(
        :NewErrorType
      ).params(
        _block: T.proc.params(error: ErrorType).returns(T.all(T.type_parameter(:NewErrorType), Object))
      ).returns(
        Result[OkType, T.all(T.type_parameter(:NewErrorType), Object)]
      )
    end
    def transform_error(&_block)
      if error?
        self.class.error(yield(T.must(wrapped_error)))
      else
        self.class.ok(T.must(wrapped_value))
      end
    end
  end
end
