class TagsController < ApplicationController
  def index
    # ここでは登録済みのタグを一覧で表示
  end

  def new
    @tag = Tag.new
  end

  def create
    attrs = permit_params.merge(user_id: current_user.id)
    tags = Tag.new(attrs)

    if tags.save
      redirect_to tags_path, notice: "タグが作成されました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def permit_params
    params.require(:tag).permit(:name, :color)
  end
end
