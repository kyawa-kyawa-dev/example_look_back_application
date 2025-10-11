class TagsController < ApplicationController
  def index
    # ここでは登録済みのタグを一覧で表示
    @tags = Tag.where(user_id: current_user.id)
  end

  def show
    @tag = Tag.find(params[:id])
  end

  def new
    @tag = Tag.new
  end

  def create
    attrs = permit_params.merge(user_id: current_user.id)
    @tag = Tag.new(attrs)

    if @tag.save
      # リダイレクト用にフラッシュメッセージを作成する
      # TurboStreamを使用するから非同期ようにflash.nowを指定する
      flash.now[:notice] = "タグが正常に作成されました!"

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to tags_path, notice: "タグが作成されました" }
      end
    else
      # 失敗したとき用にもフラッシュメッセージを設定する
      flash.now[:alert] = "タグの作成に失敗しました"

      # ここでは明示的にturbo_streamで行う処理を実装している(フラッシュメッセージ・モーダルの削除)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
           turbo_stream.replace("flash", partial: "shared/flash_messages"),
           turbo_stream.replace("modal") { '<turbo-frame id="modal"></turbo-frame>'.html_safe }
          ], status: :unprocessable_entity
        end
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @tag = Tag.find(params[:id])
  end

  def update
    @tag = Tag.find(params[:id])
    
    if @tag.update(permit_params)
      flash.now[:notice] = "タグを更新しました"
    else
      flash.now[:alert] = "タグの更新に失敗しました"
    end
  end

  def destroy
    @tag = Tag.find(params[:id])

    if @tag.destroy
      flash.now[:notice] = 'タグを削除しました'
    else
      flash.now[:alert] = 'タグの削除に失敗しました'
    end
  end

  private

  def permit_params
    params.require(:tag).permit(:name, :color)
  end
end
