require "dry-struct"
require "dry-types"
require "investec_open_api/string_utilities"
require_relative "base"

module Types
  include Dry.Types()
  Bool = Types::Strict::Bool.optional.default(nil)
end

module InvestecOpenApi::Models
  class Card < Dry::Struct
    extend Base
    transform_keys do |key|
      key_mapping(key.to_s)
    end

    attribute :key, Types::String
    attribute :number, Types::String
    attribute :is_programmable, Types::Bool
    attribute :status, Types::String
    attribute :type_code, Types::String
    attribute :account_number, Types::String
    attribute :account_id, Types::String
    attribute :embossed_name, Types::String
    attribute :is_virtual, Types::Bool

    def virtual?
      is_virtual
    end

    def programmable?
      is_programmable
    end

    def self.key_map
      {
        "CardKey" => :key,
        "CardNumber" => :number,
        "CardTypeCode" => :type_code,
        "IsVirtualCard" => :is_virtual,
      }
    end
  end
end
