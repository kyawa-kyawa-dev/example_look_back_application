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

  def edit
    get_current_knowledge_infos(current_user.id, params[:id])
  end

  def update
    @current_user = current_user
    @knowledge = Knowledge.find(params[:id])
    @selected_tag_ids = has_tags?(permit_params) ? permit_params[:tag_ids]&.map(&:to_i) : []

    # 新しく追加するContextReferencesの処理
    submitted_urls = Set.new(permit_params[:urls].compact_blank)
    current_urls = Set.new(@knowledge.context_references.pluck(:url))
    new_urls = (submitted_urls - current_urls).to_a # 新しいContextReference
    unnecessary_urls = (current_urls - submitted_urls).to_a # 不要になったContextReference
    existing_3day = @knowledge.reminders.three.any?
    existing_7day = @knowledge.reminders.seven.any?
    ActiveRecord::Base.transaction do
      @knowledge.update!(
        title: permit_params[:title],
        body: permit_params[:body],
        user_id: @current_user.id
      )
      @knowledge.tag_ids = @selected_tag_ids # タグの更新(自動で追加・削除される)

      # ContextReferenceの更新処理
      new_context_references = new_urls.map do |new_context_reference|
        { url: new_context_reference }
      end
      @knowledge.context_references.create!(new_context_references)
      @knowledge.context_references.where(url: unnecessary_urls).destroy_all

      # Reminderの更新処理
      # 3日リマインダー
      if permit_params[:notify_3days].to_i == 1 && !existing_3day
        @knowledge.reminders.create({ scheduled_at: Time.current + 3.days, remind_type: :three })
      elsif permit_params[:notify_3days].to_i == 0 && existing_3day
        @knowledge.reminders.three[0].destroy
      end

      # 7日リマインダー
      if permit_params[:notify_7days].to_i == 1 && !existing_7day
        @knowledge.reminders.create({ scheduled_at: Time.current + 7.days, remind_type: :seven })
      elsif permit_params[:notify_7days].to_i == 0 && existing_7day
        @knowledge.reminders.seven[0].destroy
      end
    end

    redirect_to @knowledge, notice: "変更を適用しました"
  rescue ActiveRecord::RecordInvalid => e
    get_current_knowledge_infos(@current_user_id, @knowledge.id)

    puts "エラー詳細"
    puts e.inspect
    # ナレッジに関連するエラーが生じた場合には@knowledgeのエラーとしてレコードを返す
    if e.record.errors.any?
      e.record.errors.each do |error|
        @knowledge.errors.add(:base, error.full_message)
      end
    end

    render :edit, status: :unprocessable_entity
  end

  def destroy
    @knowledge = Knowledge.find(params[:id])

    if @knowledge.destroy
      redirect_to knowledges_path, notice: "ナレッジを削除しました", status: :see_other
    else
      redirect_to knowledge_path(@knowledge), alert: "ナレッジの削除に失敗しました"
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

  # edit, updateアクションで使用する事前に登録されているナレッジの情報を取得するメソッド
  def get_current_knowledge_infos(current_user_id, knowledge_id)
    @knowledge = Knowledge.includes(:tags, :context_references, :reminders).find(knowledge_id)
    @tags = Tag.where(user_id: current_user_id)

    # 選択されているタグを取得する
    @registered_tag_ids = @knowledge.tags.pluck(:id)

    # リマインダーが登録されているかどうか確認する
    @has_three_day_reminder = @knowledge.reminders.map(&:three?).any?
    @has_seven_day_reminder = @knowledge.reminders.map(&:seven?).any?
  end
end
