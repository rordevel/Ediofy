class Ediofy::Users::PasswordsController < Devise::PasswordsController
  layout 'home', only: [:new]
end