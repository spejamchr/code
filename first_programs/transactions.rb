create_table :accounts, force: true do |t|
  t.string :number
  t.decimal :balance, precision: 10, scale: 2, default: 0
end
class Account < ActiveRecord::Base
  validates :balance, numericality: {greater_than_or_equal_to: 0}
  def withdraw(amount)
    adjust_balance_and_save!(-amount)
  end
  def deposit(amount)
    adjust_balance_and_save!(amount)
  end
  private
  def adjust_balance_and_save!(amount)
    self.balance += amount
    save!
  end
end

peter = Account.create(balance: 100, number: "12345")
paul  = Account.create(balance: 200, number: "54321")

