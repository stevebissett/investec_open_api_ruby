require "money"
require 'pry'


module InvestecOpenApi::Models
  TransactionStruct = Struct.new(
    :account_id,
    :posted_order,
    :type,
    :transaction_type,
    :status,
    :card_number,
    :amount,
    :description,
    :running_balance,
    :date,
    :posting_date,
    :value_date,
    :action_date,
    keyword_init: true
  )

  class Transaction < TransactionStruct
    def id
      [amount.to_i, description, date.to_s].map(&:to_s).join('-')
    end

    def self.from_api(params)
      original_params = params.dup
      params = underscore_and_symbolize_keys(params)

      if params[:amount]
        adjusted_amount = params[:amount] * 100
        adjusted_amount = -adjusted_amount if params[:type] == 'DEBIT'

        Money.rounding_mode = BigDecimal::ROUND_HALF_UP
        #Money.locale_backend = :i18n
        params[:amount] = Money.from_cents(adjusted_amount, "ZAR")
      end

      if params[:running_balance]
        adjusted_amount = params[:running_balance] * 100

        Money.rounding_mode = BigDecimal::ROUND_HALF_UP
        #Money.locale_backend = :i18n
        params[:running_balance] = Money.from_cents(adjusted_amount, "ZAR")
      end
  
      if params[:transaction_date]
        params[:date] = Date.parse(params.delete(:transaction_date))
      end

      params[:action_date] = Date.parse(params[:action_date]) if params[:action_date]
      params[:posting_date] = Date.parse(params[:posting_date]) if params[:posting_date]
      params[:value_date] = Date.parse(params[:value_date]) if params[:value_date]

      new(params)
    end

    def self.underscore_and_symbolize_keys(hash)
      hash.each_with_object({}) do |(key, value), result|
        underscored_key = underscore(key.to_s)
        symbolized_key = underscored_key.to_sym
        result[symbolized_key] = value
      end
    end

    def self.underscore(camel_cased_word)
      camel_cased_word.gsub(/::/, '/')
      .gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
      .gsub(/([a-z\d])([A-Z])/,'\1_\2')
      .tr("-", "_")
      .downcase
    end

  end
end