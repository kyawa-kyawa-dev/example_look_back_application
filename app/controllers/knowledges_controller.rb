class KnowledgesController < ApplicationController
  def index
    # ここでは登録したナレッジを一覧表示するためのアクション
  end

  def new
    @knowledge = Knowledge.new
  end

  def create

  end

  private

  def permit_params
    params.require(:knowledge).permit(:title, :content, :urls)
  end
end
