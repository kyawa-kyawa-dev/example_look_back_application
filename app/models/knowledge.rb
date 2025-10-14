# == Schema Information
#
# Table name: knowledges
#
#  id         :bigint           not null, primary key
#  body       :text(65535)
#  title      :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_knowledges_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Knowledge < ApplicationRecord
  belongs_to :user
  has_many :context_references, dependent: :destroy
  has_many :knowledge_tags, dependent: :destroy
  has_many :tags, through: :knowledge_tags

  validates :title, presence: true

  def add_context_references(urls)
    context_references = urls.map do |url|
      { title: "" , url: url, knowledge_id: self.id }
    end

    self.context_references.create(context_references)
  end
end
