# frozen_string_literal: true

require "spec_helper"

module SorbetResult
  RSpec.describe Result do
    describe "creation" do
      it "can create an ok variant" do
        expect(Result.ok(:ok)).to be_ok
      end

      it "can create an error variant" do
        expect(Result.error(:error)).to be_error
      end
    end

    describe "#unwrap!" do
      it "unwraps the wrapped ok value" do
        expect(Result.ok(:ok).unwrap!).to eq(:ok)
      end

      it "raises a RuntimeError when result is an error" do
        expect { Result.error(:error).unwrap! }.to raise_error(RuntimeError)
      end
    end

    describe "#unwrap_or" do
      it "unwraps the wrapped ok value" do
        expect(Result.ok(:ok).unwrap_or { :lazy_fallback }).to eq(:ok)
      end

      it "evaluates the provided block to lazily generate a fallback" do
        expect(Result.error(:error).unwrap_or { :lazy_fallback }).to eq(:lazy_fallback)
      end

      it "provides the result itself to the fallback block" do
        expect(Result.error(:error).unwrap_or { |error| error }).to eq(:error)
      end
    end

    describe "#transform_value" do
      it "transforms the wrapped ok value" do
        expect(
          Result.ok(1).transform_value { |value| value * 2 }.unwrap!
        ).to eq(2)
      end

      it "does not transform the wrapped error value" do
        expect(
          Result.error(1).transform_value { |value| value * 2 }.unwrap_error!
        ).to eq(1)
      end
    end

    describe "#transform_error" do
      it "transforms the wrapped errro value" do
        expect(
          Result.error(1).transform_error { |value| value * 2 }.unwrap_error!
        ).to eq(2)
      end

      it "does not transform the wrapped ok value" do
        expect(
          Result.ok(1).transform_error { |value| value * 2 }.unwrap!
        ).to eq(1)
      end
    end
  end
end
