require "spec_helper"
require "investec_open_api/models/document"

RSpec.describe InvestecOpenApi::Models::Document do
  describe "#from_api" do
    context "without document content" do
      it "returns a new instance of InvestecOpenApi::Models::Document with attributes" do
        model_instance = InvestecOpenApi::Models::Document.from_api({
          "documentType" => "Statement",
          "documentDate" => "2022-12-01"
        })

        expect(model_instance.type).to eq "Statement"
        expect(model_instance.date).to eq Date.parse("2022-12-01")
        expect(model_instance.file_content).to be_nil
      end
    end

    context "with document content" do
      it "ignores invalid attributes and returns a new instance with only valid attributes" do
        model_instance = InvestecOpenApi::Models::Document.from_api({
            "documentType" => "Statement",
            "documentDate" => "2022-12-01",
            "file_content" => "\x00\x01\x02\x03"

        })

        expect(model_instance.type).to eq "Statement"
        expect(model_instance.date).to eq Date.parse("2022-12-01")
        expect(model_instance.file_content).to eq "\x00\x01\x02\x03"

        expect { model_instance.bank_account_number }.to raise_error(NoMethodError)
      end
    end
  end
end
