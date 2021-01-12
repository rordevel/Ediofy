class ChangeDateForCpdFromStringToDate < ActiveRecord::Migration[5.1]
  def change
    change_column :users, :cpd_from, :date, using:  'cpd_from::date'
    change_column :users, :cpd_to,   :date, using: 'cpd_to::date'
  end
end
