class Knowledge < ApplicationRecord
  belongs_to :user
  has_many :context_references, dependent: :destroy
  has_many :knowledge_tags, dependent: :destroy
  has_many :tags, through: :knowledge_tags
end
