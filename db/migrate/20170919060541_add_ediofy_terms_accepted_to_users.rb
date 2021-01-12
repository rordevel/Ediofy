class AddEdiofyTermsAcceptedToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :ediofy_terms_accepted, :boolean, null: false, default: false
  end
end
