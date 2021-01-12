class Specialty < ApplicationRecord
  default_scope -> {order('name')}
end
