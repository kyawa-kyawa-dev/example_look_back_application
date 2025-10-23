class KnowledgesController < ApplicationController
  def index
    # ナレッジに紐づいたすべての情報を一括で取得する
    @today_knowledges = Knowledge.where(user_id: current_user.id)
                                 .where(created_at: Time.current.all_day)
                                 .includes(:tags)
  end

  def show
    # ここでは個別のナレッジを表示する
    @knowledge = Knowledge.includes(:tags, :context_references, :reminders).find(params[:id])
  end

  def new
    @knowledge = Knowledge.new
    @tags = Tag.where(user_id: current_user.id)
  end

  def create
    existing_tag_ids = has_tags?(permit_params) ? permit_params[:tag_ids]&.map(&:to_i) : []
    # ContextReference, Reminderが正常に作成されないとKnowledgeが作成されないようにする
    ActiveRecord::Base.transaction do
      @knowledge =
        if existing_tag_ids.any?
          Knowledge.create!(
            user_id: current_user.id,
            title: permit_params[:title],
            body: permit_params[:body],
            tag_ids: existing_tag_ids
          )
        else
          Knowledge.create!(
            user_id: current_user.id,
            title: permit_params[:title],
            body: permit_params[:body]
          )
        end

      register_context_references(@knowledge, permit_params[:urls])
      register_reminders(@knowledge, three: permit_params[:notify_3days], seven: permit_params[:notify_7days])
    end

    # トランザクションが成功した場合にのみナレッジ詳細にリダイレクトする
    redirect_to @knowledge, notice: "ナレッジを追加しました"
  rescue ActiveRecord::RecordInvalid => e
    @knowledge = Knowledge.new(
      title: permit_params[:title],
      body: permit_params[:body]
    )

    # ナレッジに関連するエラーが生じた場合には@knowledgeのエラーとしてレコードを返す
    if e.record.errors.any?
      e.record.errors.each do |error|
        @knowledge.errors.add(:base, error.full_message)
      end
    end
    @tags = Tag.where(user_id: current_user.id)
    return render :new, status: :unprocessable_entity
  end

  private

  def permit_params
    # 今回のurlsのように値が配列で送信されている際には、配列形式で取得する必要があるらしい
    params.require(:knowledge).permit(:title, :body, :notify_3days, :notify_7days, urls: [], tag_ids: [])
  end

  def has_tags?(params)
    # タグが選択されていない場合にはtag_idsキーが存在しない
    params.has_key?(:tag_ids)
  end

  def register_context_references(knowledge, urls)
    return if urls.blank?

    unique_urls = urls.compact_blank.to_set.to_a

    context_references = unique_urls.map do |url|
      { url: url }
    end

    new_context_references = knowledge.context_references.create!(context_references)
  end

  def register_reminders(knowledge, three:, seven:)
    reminder_datas = { three: three, seven: seven}.map do |day, value|
      next if value == "0"

      if day == :three
        { scheduled_at: knowledge.created_at + 3.days, remind_type: :three }
      elsif day == :seven
        { scheduled_at: knowledge.created_at + 7.days, remind_type: :seven }
      end
    end.compact

    knowledge.reminders.create!(reminder_datas) if reminder_datas.present?
  end
end
