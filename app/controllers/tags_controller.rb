class TagsController < ApplicationController
  def index
    # ここでは登録済みのタグを一覧で表示
    @tags = Tag.where(user_id: current_user.id)
  end

  def show
    # もしソートの基準が選択されている場合には取得する
    sort_option = params[:sort] || "newest"
    # ここではタグに紐づいているナレッジも取得したい
    @tag = Tag.find(params[:id])

    # ソートの条件に応じてソートする
    @knowledges_scope = 
      sort_option == "newest" ?
        @tag.knowledges.left_joins(:reminders).order(created_at: :desc) : 
        @tag.knowledges.left_joins(:reminders).order(created_at: :asc)

    @total_count = @knowledges_scope.count
    @this_week_count = @knowledges_scope.where('knowledges.created_at >= ?', 1.week.ago).count
    @this_month_count = @knowledges_scope.where('knowledges.created_at >= ?', 1.month.ago).count
    @not_reviewed_count = @knowledges_scope.where('reminders.sent_at IS NULL OR reminders.opened_at IS NULL').count
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
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to tags_path, notice: "タグを更新しました" }
      end
    else
      flash.now[:alert] = "タグの更新に失敗しました"
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash_messages"), status: :unprocessable_entity
        end
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @tag = Tag.find(params[:id])

    if @tag.destroy
      flash.now[:notice] = 'タグを削除しました'
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to tags_path, notice: 'タグを削除しました' }
      end
    else
      flash.now[:alert] = 'タグの削除に失敗しました'
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash_messages"), status: :unprocessable_entity
        end
        format.html { redirect_to tags_path, alert: 'タグの削除に失敗しました' }
      end
    end
  end

  private

  def permit_params
    params.require(:tag).permit(:name, :color)
  end
end
