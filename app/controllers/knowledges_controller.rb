class KnowledgesController < ApplicationController
  def index
    # ここでは登録したナレッジを一覧表示するためのアクション
  end

  def new
    @knowledge = Knowledge.new
    @tags = Tag.where(user_id: current_user.id)
  end

  def create
    puts "----------------------------"
    puts "params: #{permit_params.inspect}"
  end

  private

  def permit_params
    # 今回のurlsのように値が配列で送信されている際には、配列形式で取得する必要があるらしい
    params.require(:knowledge).permit(:title, :content, urls: [])
  end
end
