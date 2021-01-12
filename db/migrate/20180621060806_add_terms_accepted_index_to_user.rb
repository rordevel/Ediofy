class AddTermsAcceptedIndexToUser < ActiveRecord::Migration[5.0]
  def change
    add_index :users, :ediofy_terms_accepted
  end
end
