# TODO not being used in BETA
class Enquiry
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :name, :email, :phone, :comments

  validates :name, :email, :comments, presence: true
  validates_length_of :comments, maximum: 1000

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

  def send_email
    # AdminMailer.enquiry(self).deliver
  end

end

