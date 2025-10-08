class TagsController < ApplicationController
  def index
    # ここでは登録済みのタグを一覧で表示
    @tags = Tag.where(user_id: current_user.id)
  end

  def new
    @tag = Tag.new
  end

  def create
    attrs = permit_params.merge(user_id: current_user.id)
    @tag = Tag.new(attrs)

    if @tag.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to tags_path, notice: "タグが作成されました" }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    tag = Tag.find(params[:id])

    if tag.destroy
      redirect_to tags_path, notice: 'tagを削除しました'
    else
      render :index, alerts: 'tagの削除に失敗しました'
    end
  end

  private

  def permit_params
    params.require(:tag).permit(:name, :color)
  end
end
