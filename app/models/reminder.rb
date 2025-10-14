# == Schema Information
#
# Table name: reminders
#
#  id           :bigint           not null, primary key
#  opened_at    :datetime
#  remind_type  :integer          not null
#  scheduled_at :datetime         not null
#  sent_at      :datetime
#  knowledge_id :bigint           not null
#
# Indexes
#
#  index_reminders_on_knowledge_id  (knowledge_id)
#
# Foreign Keys
#
#  fk_rails_...  (knowledge_id => knowledges.id)
#
class Reminder < ApplicationRecord
end
