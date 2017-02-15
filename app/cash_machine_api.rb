class CashMachineAPI < Grape::API
  format :json
  default_error_status 400

  resource :cash_machine do
    desc 'Initialize cash machine'

    params do
      requires :cash_to_load, type: Hash, desc: 'Cash to load.'
    end

    post :initialize do
      CashMachine.init_with_cash(params[:cash_to_load])
      CashMachine.last.loaded_cash
    end

    desc 'Try to receive cash'

    params do
      requires :requested_amount, type: Fixnum
    end

    post :receive_cash do
      error!("requested_amount should be positive") if params[:requested_amount] <= 0

      cash_machine = CashMachine.last
      unless cash_machine
        error!("Cash Machine is not initialized. /cash_machine/initialize_method should be called")
      end

      transaction = Transaction.new(params[:requested_amount], cash_machine)
      unless transaction.enough_money?
        error!("Not enough money on your balance. Your balance is: #{cash_machine.balance}")
      end

      if transaction.exact?
        transaction.commit!
        status 200
        transaction.res
      else
        error!("It's impossible to give this amount. Try: #{transaction.floor_possible} or #{transaction.ceil_possible}")
      end
    end
  end
end
