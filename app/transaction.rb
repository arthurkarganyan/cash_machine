class Transaction
  attr_reader :requested_amount, :cash_machine
  attr_accessor :new_loaded_cash, :res, :ceil_possible, :floor_possible
  delegate :balance, to: :cash_machine

  def initialize(requested_amount, cash_machine)
    @requested_amount = requested_amount
    @cash_machine = cash_machine
  end

  def enough_money?
    balance - requested_amount > 0
  end

  def exact?
    setup_vars
    !!res
  end

  def commit!
    cash_machine.load_with new_loaded_cash
  end

  private def run(amount)
    res = {}
    new_loaded_cash = loaded_cash.dup
    new_loaded_cash.each do |denomination, banknotes_left|
      n = [amount / denomination, banknotes_left].min
      next if n == 0
      amount -= denomination * n
      new_loaded_cash[denomination] -= n
      res[denomination] = n
      return [new_loaded_cash, res, nil] if amount == 0
    end

    floor_possible = res.map do |denomination, banknotes_left|
      denomination * banknotes_left
    end.inject(:+) || 0

    [new_loaded_cash, nil, floor_possible]
  end

  private def detect_ceil_possible
    for i in requested_amount..balance
      if next_value_hash = run(i)[1]
        self.ceil_possible = next_value_hash.map do |denomination, banknotes_left|
          denomination * banknotes_left
        end.inject(:+)
        break
      end
    end
  end

  private def setup_vars
    self.new_loaded_cash, self.res, self.floor_possible = run(requested_amount)
    return res if self.res
    detect_ceil_possible
    nil
  end

  private def loaded_cash
    cash_machine.loaded_cash
  end

  private def retrieving_algorithm
    @retrieving_algorithm ||= RetrievingAlgorithm.new
  end
end