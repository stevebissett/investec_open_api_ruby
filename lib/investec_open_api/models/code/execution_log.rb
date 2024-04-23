require "dry-struct"
require "dry-types"
require "investec_open_api/string_utilities"
require_relative "../base"

module Types
  include Dry.Types()
end

module InvestecOpenApi::Models::Code
  class ExecutionLog < Dry::Struct
    extend InvestecOpenApi::Models::Base
    transform_keys do |key|
      key_mapping(key.to_s)
    end

    attribute :created_at, Types::Params::Time
    attribute :level, Types::String
    attribute :content, Types::String

    def parsed_content
      begin
        JSON.parse(content)
      rescue JSON::ParserError
        { "error" => "Content is not valid JSON" }
      end
    end

    def self.key_map
      {}
    end
  end
end
