class Organization < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: [:slugged, :finders]

  has_one :administrator
  has_one :catalog, -> { order('created_at desc') }
  has_one :inventory
  has_one :liaison

  has_many :users
  has_many :activity_logs
  has_many :designation_files
  has_many :memo_files
  has_many :ministry_memo_files
  has_many :organization_sectors, dependent: :destroy
  has_many :sectors, through: :organization_sectors

  accepts_nested_attributes_for :administrator
  accepts_nested_attributes_for :designation_files
  accepts_nested_attributes_for :liaison
  accepts_nested_attributes_for :memo_files
  accepts_nested_attributes_for :ministry_memo_files
  accepts_nested_attributes_for :organization_sectors, allow_destroy: true

  scope :title_sorted, -> { order("organizations.title ASC") }
  scope :sector, -> slug { joins(:sectors).where('sectors.slug = ?', slug) }
  scope :gov_type, -> gov_type { where('gov_type = ?', Organization.gov_types[gov_type]) }

  enum gov_type: [:federal, :state, :municipal, :autonomous]
end
