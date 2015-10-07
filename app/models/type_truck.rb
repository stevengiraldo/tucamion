class TypeTruck < ActiveRecord::Base
  has_many :trucks, dependent: :destroy
  has_many :sub_trucks, dependent: :destroy
  has_many :extras, dependent: :destroy
  has_many :brand_extras,->{self.uniq}, through: :extras
  has_many :brand_trucks, through: :trucks

  HUMANIZED_ATTRIBUTES = {
      :name => 'Nombre'
  }


  validates :name, presence: true

  def self.human_attribute_name(attr, options = {})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end



  before_create do

    self.link_rewrite = self.name.downcase
    self.link_rewrite = I18n.transliterate(self.link_rewrite)

    if self.name.count(' ') >= 1
      self.link_rewrite = self.link_rewrite.gsub! ' ', '-'
    end

  end


  before_update do

    self.link_rewrite = self.name.downcase
    self.link_rewrite = I18n.transliterate(self.link_rewrite)

    if self.name.count(' ') >= 1
      self.link_rewrite = self.link_rewrite.gsub! ' ', '-'
    end

  end

  scope :group_by_brand,->{
      self.select('type_trucks.id,
                   type_trucks.name,
                   COUNT(extras.type_truck_id) as total').
       joins(:extras).
       group('type_trucks.id').includes(:brand_extra)
  }

end
