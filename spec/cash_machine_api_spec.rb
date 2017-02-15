describe CashMachineAPI do
  include Rack::Test::Methods

  def app
    CashMachineAPI
  end

  def json_response
    JSON.parse(last_response.body)
  end

  context "not initialized cash machine" do
    it '/cash_machine/initialize' do
      post '/cash_machine/receive_cash', {requested_amount: 2000}
      expect(last_response.status).to eq(400)
      expect(json_response).to eq({"error" => "Cash Machine is not initialized. /cash_machine/initialize_method should be called"})
    end
  end

  context "load cash" do
    before do
      post '/cash_machine/initialize', {cash_to_load: cash_to_load}
    end

    context do
      let(:cash_to_load) { {50 => 3, 25 => 2, 10 => 1} }

      it '/cash_machine/initialize' do
        expect(last_response.status).to eq(201)
        expect(last_response.body).to eq(cash_to_load.to_json)
        expect(CashMachine.last.loaded_cash).to eq(cash_to_load)
      end

      it do
        post '/cash_machine/receive_cash', {requested_amount: 200}
        expect(last_response.status).to eq(200)
        expect(json_response).to eq({"50" => 3, "25" => 2})
      end

      it "saving state" do
        post '/cash_machine/receive_cash', {requested_amount: 200}
        expect(last_response.status).to eq(200)
        expect(json_response).to eq({"50" => 3, "25" => 2})

        post '/cash_machine/receive_cash', {requested_amount: 50}
        expect(last_response.status).to eq(400)
        expect(json_response).to eq({"error" => "Not enough money on your balance. Your balance is: 10"})
      end

      it do
        post '/cash_machine/receive_cash', {requested_amount: -2}
        expect(last_response.status).to eq(400)
        expect(json_response).to eq({"error" => "requested_amount should be positive"})
      end

      it do
        post '/cash_machine/receive_cash', {requested_amount: "h"}
        expect(last_response.status).to eq(400)
        expect(json_response).to eq({"error" => "requested_amount is invalid"})
      end
    end

    context "cash_to_load check" do
      let(:cash_to_load) { {'50' => '3', '25' => 2.25, '10' => 'what?'} }

      it '/cash_machine/initialize' do
        expect(last_response.status).to eq(201)
        expect(last_response.body).to eq({'50' => 3, '25' => 2}.to_json)
      end

      context do
        let(:cash_to_load) { "hello" }
        it '/cash_machine/initialize' do
          expect(last_response.status).to eq(400)
          expect(json_response).to eq({'error' => 'cash_to_load is invalid'})
        end
      end
    end

    context "not enough cash" do
      let(:cash_to_load) { {50 => 5} }
      it do
        post '/cash_machine/receive_cash', {requested_amount: 2000}
        expect(last_response.status).to eq(400)
        expect(json_response).to eq({"error" => "Not enough money on your balance. Your balance is: 250"})
      end
    end

    context "order does not matter" do
      let(:cash_to_load) { {1 => 15, 2 => 15, 5 => 15, 10 => 15} }

      it do
        post '/cash_machine/receive_cash', {requested_amount: 10}
        expect(last_response.status).to eq(200)
        expect(json_response).to eq({"10" => 1})
      end
    end

    context "enough cash but incorrect amount" do
      context do
        let(:cash_to_load) { {50 => 3, 25 => 2, 10 => 2} }
        it do
          post '/cash_machine/receive_cash', {requested_amount: 11}
          expect(last_response.status).to eq(400)
          expect(json_response).to eq({"error" => "It's impossible to give this amount. Try: 10 or 20"})
        end
      end

      context do
        let(:cash_to_load) { {50 => 3, 25 => 2, 10 => 1} }
        it do
          post '/cash_machine/receive_cash', {requested_amount: 11}
          expect(last_response.status).to eq(400)
          expect(json_response).to eq({"error" => "It's impossible to give this amount. Try: 10 or 25"})
        end
      end

      context do
        let(:cash_to_load) { {50 => 3, 25 => 2, 10 => 1, 5 => 2} }
        it do
          post '/cash_machine/receive_cash', {requested_amount: 11}
          expect(last_response.status).to eq(400)
          expect(json_response).to eq({"error" => "It's impossible to give this amount. Try: 10 or 15"})
        end
      end

      context do
        let(:cash_to_load) { {50 => 3} }
        it do
          post '/cash_machine/receive_cash', {requested_amount: 11}
          expect(last_response.status).to eq(400)
          expect(json_response).to eq({"error" => "It's impossible to give this amount. Try: 0 or 50"})
        end
      end
    end
  end

  after do
    FileStorage.clear
  end
end