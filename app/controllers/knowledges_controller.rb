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
    if has_tags?(permit_params)
      existing_tag_ids = permit_params[:tag_ids]&.map(&:to_i)
    else
      # @knowledgeに対してタグが選択されていないことを伝えるメッセージを追加する
      @knowledge = Knowledge.new(
        title: permit_params[:title],
        body: permit_params[:body]
      )
      @knowledge.errors.add(:base, "タグは最低一つ選択してください")
      @tags = Tag.where(user_id: current_user.id)

      return render :new, status: :unprocessable_entity
    end

    @knowledge = Knowledge.create(
      user_id: current_user.id,
      title: permit_params[:title],
      body: permit_params[:body],
      tag_ids: existing_tag_ids
    )

    if @knowledge.errors.blank?
      # ナレッジのコンテキストを追加する
      register_context_references(@knowledge, permit_params[:urls])

      # ナレッジのリマインダーを登録する
      register_reminders(@knowledge, three: permit_params[:notify_3days], seven: permit_params[:notify_7days])

      redirect_to @knowledge, notice: "ナレッジを追加しました"
    else
      render :new, status: :unprocessable_entity
    end
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

    # ナレッジの追加の際にContextReferenceが正常に登録できなければリダイレクト
    new_context_references = knowledge.context_references.build(context_references)
    if new_context_references.all?(&:valid?)
    else
      return nil
    end
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

    knowledge.reminders.create(reminder_datas) if reminder_datas.present?
  end
end
