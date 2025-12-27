module ApplicationHelper
  # 以下は安全にRefererを使用するためのメソッド
  def safe_referer_path(fallback: root_path, from: nil)
    # リクエストの送信元のアクションがcreate, updateの場合には一覧ページへのリンクを返す
    return knowledges_path if (from == "create" || from == "update")

    referer = request.referer

    return fallback if referer.blank?

    uri = URI.parse(referer) rescue nil
    return fallback unless uri

    return uri.host == request.host ? referer : fallback
  end

  # ナレッジの作成日時を表示するためのカスタムヘルパー
  def knowledge_updated_at_tag(updated_at)
    tag.span(time_ago_in_words(updated_at), class: "text-base text-gray-500")
  end
end
