module KnowledgesHelper
  def back_to_knowledges_list_link(from)
    link_to(
      safe_referer_path(fallback: knowledges_path, from),
      class: "mb-4 text-indigo-600 hover:underline flex items-center gap-1 cursor-pointer"
    ) do
      svg_icon + " 一覧に戻る"
    end
  end

  private

  def svg_icon
    content_tag(
      :svg,
      tag.path(
        "stroke-linecap": "round",
        "stroke-linejoin": "round",
        "stroke-width": "2",
        d: "M15 19l-7-7 7-7"
      ),
      class: "w-4 h-4",
      fill: "none",
      stroke: "currentColor",
      viewBox: "0 0 24 24"
    )
  end
end
