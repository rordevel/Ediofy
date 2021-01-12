class Reference < ActiveRecord::Base
  belongs_to :referenceable, polymorphic: true

  validates :title, :referenceable_type, presence: true
  validates :referenceable_id, presence: true, unless: :new_record?

  def url
    _url = read_attribute(:url).try(:downcase)
    if(_url.present?)
      unless _url[/\Ahttp:\/\//] || _url[/\Ahttps:\/\//]
        _url = "http://#{_url}"
      end
    end
  _url
  end


  
  belongs_to :comment, -> { where( references: { referenceable_type: 'Comment' } )}, foreign_key: 'referenceable_id'
end