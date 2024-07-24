require "spec_helper"
require "investec_open_api/models/code/execution_log"

RSpec.describe InvestecOpenApi::Models::Code::ExecutionLog do
  describe "#from_api" do
    let(:precise_time) { Time.iso8601("2024-04-14T13:18:38.201Z") }
    let(:parsed_log_content) do
      {
        "accountNumber" => "12748728432",
        "card" => { "display" => "402111XXXXXX1010", "id" => "10000" },
        "centsAmount" => 5800,
        "currencyCode" => "zar",
        "dateTime" => "2024-04-20T15:50:45.000Z",
        "merchant" => {
          "category" => { "code" => "4121",
                          "key" => "taxicabs_limousines",
                          "name" => "Taxicabs/Limousines" },
          "city" => "Johannesburg",
          "country" => { "alpha3" => "ZAF", "code" => "ZA", "name" => "South Africa" },
          "name" => "UBER RIDES",
        },
        "reference" => "4838274",
        "type" => "card",
      }
    end

    context "with valid attributes" do
      it "returns a new instance of InvestecOpenApi::Models::Code::Execution with attributes" do
        model_instance = InvestecOpenApi::Models::Code::ExecutionLog.from_api(
          {
            "createdAt": precise_time.iso8601(3),
            "level": "info",
            "content": "log content",
          }
        )

        expect(model_instance).to be_a InvestecOpenApi::Models::Code::ExecutionLog
        expect(model_instance.created_at).to be_a Time
        expect(model_instance.created_at).to eq precise_time
        expect(model_instance.level).to eq "info"
        expect(model_instance.content).to eq "log content"
      end
    end

    context "with JSON content" do
      it "returns parsed content" do
        model_instance = InvestecOpenApi::Models::Code::ExecutionLog.from_api(
          {
            "createdAt": precise_time.iso8601(3),
            "level": "info",
            "content": parsed_log_content.to_json,
          }
        )

        expect(model_instance.parsed_content).to eq(parsed_log_content)
      end
    end
  end
end
