# TODO not using in Beta
class VisitorsController < ApplicationController
  layout 'email_verification', only: [:email_verification, :email_verification_succ]
  
end
