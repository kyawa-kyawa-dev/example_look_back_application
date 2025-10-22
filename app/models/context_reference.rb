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

  validates :url, presence: true, length: { maximum: 500 , message: "500文字以上のURLは登録できません" },
                  format: { with: URI::DEFAULT_PARSER.make_regexp("https"), message: "入力されたURLは不正な形式です" }

end
