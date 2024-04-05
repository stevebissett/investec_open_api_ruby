require "dry-struct"
require "dry-types"
require "money"
require "date"
require "digest"
require_relative 'base' 

module Types
  include Dry.Types()

  String = Types::Strict::String
  MoneyType = Types.Constructor(Money) do |value, _currency = "ZAR"|
    amount = value.is_a?(Numeric) ? BigDecimal(value.to_s) * 100 : 0
    Money.from_cents(amount, "ZAR")
  end
end

module InvestecOpenApi::Models
  class Transaction < Dry::Struct
    extend Base
    transform_keys do |key|
      key_mapping(key.to_s)
    end

    attribute :account_id, Types::String
    attribute :posted_order, Types::Integer
    attribute :type, Types::String
    attribute :transaction_type, Types::String
    attribute :status, Types::String.optional
    attribute :card_number, Types::String.optional
    attribute :amount, Types::MoneyType
    attribute :description, Types::String
    attribute :running_balance, Types::MoneyType
    attribute :date, Types::Params::Date
    attribute :posting_date, Types::Params::Date
    attribute :value_date, Types::Params::Date
    attribute :action_date, Types::Params::Date

    def id
      data_string = [amount.to_i.abs, description, date.to_s].to_s
      Digest::SHA1.hexdigest(data_string)
    end

    def amount_signed
      amount.abs * (type == "DEBIT" ? -1 : 1)
    end

    def self.key_map
      { "transactionDate" => :date }
    end

  end
end