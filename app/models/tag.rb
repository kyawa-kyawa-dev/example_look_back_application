class Tag < ApplicationRecord
  belongs_to :user
  has_many :knowledge_tags, dependent: :destroy
  has_many :knowledges, through: :knowledge_tags
  validates :name, uniqueness: true
end
