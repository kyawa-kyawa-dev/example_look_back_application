# == Schema Information
#
# Table name: tags
#
#  id         :bigint           not null, primary key
#  color      :string(255)      not null
#  name       :string(50)       not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_tags_on_name     (name) UNIQUE
#  index_tags_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Tag < ApplicationRecord
  belongs_to :user
  has_many :knowledge_tags, dependent: :destroy
  has_many :knowledges, through: :knowledge_tags
  validates :name, uniqueness: true, length: { maximum: 50, message: "タグに登録できる最大文字数は50文字です" }
end
