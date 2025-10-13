class KnowledgeTag < ApplicationRecord
  belongs_to :knowledge, dependent: :destroy
  belongs_to :tag, dependent: :destroy
end
