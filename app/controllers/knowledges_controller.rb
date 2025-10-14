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
    existing_tag_ids = permit_params[:tag_ids]&.map(&:to_i)

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
      @knowledge = Knowledge.new
      @tags = Tag.where(user_id: current_user.id)
      flash.now[:alert] = "ナレッジの作成に失敗しました"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def permit_params
    # 今回のurlsのように値が配列で送信されている際には、配列形式で取得する必要があるらしい
    params.require(:knowledge).permit(:title, :content, urls: [], tag_ids: [])
  end
end
