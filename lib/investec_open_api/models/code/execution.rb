require "dry-struct"
require "dry-types"
require "investec_open_api/string_utilities"
require_relative "../base"
require_relative "execution_log"

module Types
  include Dry.Types()
end

module InvestecOpenApi::Models::Code
  class Execution < Dry::Struct
    extend InvestecOpenApi::Models::Base
    transform_keys do |key|
      key_mapping(key.to_s)
    end

    attribute :id, Types::String
    attribute :root_code_function_id, Types::String
    attribute :sandbox, Types::Bool
    attribute :type, Types::String
    attribute :authorization_approved, Types::String.optional.default(nil)
    attribute :logs, Types::Array.of(ExecutionLog).default([])
    attribute :sms_count, Types::Integer.default(0)
    attribute :email_count, Types::Integer.default(0)
    attribute :push_notification_count, Types::Integer.default(0)
    attribute :created_at, Types::Params::Time
    attribute :started_at, Types::Params::Time
    attribute :completed_at, Types::Params::Time
    attribute :updated_at, Types::Params::Time

    def self.key_map
      {
        "executionId" => :id
      }
    end
  end
end
