module ApplicationHelper
  # 以下は安全にRefererを使用するためのメソッド
  def safe_referer_path(fallback: root_path)
    referer = request.referer

    return fallback if referer.blank?

    uri = URI.parse(referer) rescue nil
    return fallback unless uri

    return uri.host == request.host ? referer : fallback
  end
end
