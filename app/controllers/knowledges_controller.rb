class KnowledgesController < ApplicationController
  def index
    # ここでは登録したナレッジを一覧表示するためのアクション
  end

  def show
    # ここでは個別のナレッジを表示する
    @knowledge = Knowledge.find(params[:id])
  end

  def new
    @knowledge = Knowledge.new
    @tags = Tag.where(user_id: current_user.id)
  end

  def create
    if has_tags?(permit_params)
      existing_tag_ids = permit_params[:tag_ids]&.map(&:to_i)
    else
      set_objects_with_current_input(permit_params)
      return render_with_flash_message(:alert, :new, "ナレッジの作成に失敗しました", status: :unprocessable_entity)
    end

    @new_knowledge = Knowledge.create(
      user_id: current_user.id,
      title: permit_params[:title],
      body: permit_params[:content],
      tag_ids: existing_tag_ids
    )

    if @new_knowledge.errors.blank?
      @new_knowledge.add_context_references(permit_params[:urls])
      redirect_to @new_knowledge, notice: "ナレッジを追加しました"
    else
      set_objects_with_current_input(permit_params)
      render_with_flash_message(:alert, :new, "ナレッジの作成に失敗しました", status: :unprocessable_entity)
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

  # 現在入力されている値でオブジェクトを作成する
  def set_objects_with_current_input(params)
    @knowledge = Knowledge.new(
      title: permit_params[:title],
      body: permit_params[:body]
    )
    @tags = Tag.where(user_id: current_user.id)
  end

  # 指定された組み合わせでフラッシュメッセージを設定して、renderメソッドを呼び出す
  def render_with_flash_message(type, action, message, status)
    flash.now[type] = message
    render action, status
  end
end
