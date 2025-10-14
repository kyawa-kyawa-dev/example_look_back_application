# == Schema Information
#
# Table name: knowledge_tags
#
#  id           :bigint           not null, primary key
#  created_at   :datetime         not null
#  knowledge_id :bigint           not null
#  tag_id       :bigint           not null
#
# Indexes
#
#  index_knowledge_tags_on_knowledge_id             (knowledge_id)
#  index_knowledge_tags_on_knowledge_id_and_tag_id  (knowledge_id,tag_id) UNIQUE
#  index_knowledge_tags_on_tag_id                   (tag_id)
#
# Foreign Keys
#
#  fk_rails_...  (knowledge_id => knowledges.id)
#  fk_rails_...  (tag_id => tags.id)
#
class KnowledgeTag < ApplicationRecord
  belongs_to :knowledge
  belongs_to :tag
end
