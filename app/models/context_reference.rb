# == Schema Information
#
# Table name: context_references
#
#  id           :bigint           not null, primary key
#  url          :string(500)      not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  knowledge_id :bigint           not null
#
# Indexes
#
#  index_context_references_on_knowledge_id  (knowledge_id)
#
# Foreign Keys
#
#  fk_rails_...  (knowledge_id => knowledges.id)
#
class ContextReference < ApplicationRecord
  belongs_to :knowledge
end
