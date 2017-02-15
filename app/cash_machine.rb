class CashMachine
  DENOMINATIONS = [1, 2, 5, 10, 25, 50]
  STORAGE = FileStorage

  attr_reader :loaded_cash

  def load_with(cash_to_load_hash = {})
    @loaded_cash = cash_to_load_hash.map do |k, v|
      [k.to_i, v.to_i]
    end.sort.reverse.to_h.delete_if { |k, v| v == 0 }
    save_state!
  end

  def balance
    loaded_cash.map do |denomination, banknotes_left|
      denomination * banknotes_left
    end.inject(:+)
  end

  def self.last
    STORAGE.load
  end

  def self.init_with_cash(cash_hash)
    obj = self.new
    obj.load_with(cash_hash)
    obj
  end

  def save_state!
    STORAGE.save(self)
  end
end